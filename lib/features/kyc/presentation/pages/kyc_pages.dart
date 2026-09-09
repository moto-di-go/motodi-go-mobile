import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/core/widgets/app_loading.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_bundle.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_status.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_document_type.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_file_draft.dart';
import 'package:motodi_go_mobile/features/kyc/domain/entities/kyc_requirement.dart';
import 'package:motodi_go_mobile/features/kyc/presentation/cubit/kyc_cubit.dart';
import 'package:motodi_go_mobile/features/kyc/presentation/widgets/kyc_figma_icons.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:url_launcher/url_launcher.dart';

class KycInvalidFileArgs {
  final KycFileValidation validation;
  final String? message;

  const KycInvalidFileArgs({required this.validation, this.message});
}

class KycNotificationPayload {
  final String title;
  final String body;
  final ValidationStatus status;
  final String? reason;
  final DateTime occurredAt;

  const KycNotificationPayload({
    required this.title,
    required this.body,
    required this.status,
    this.reason,
    required this.occurredAt,
  });
}

class KycStatusPage extends StatelessWidget {
  const KycStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<KycCubit>()..load(),
      child: BlocBuilder<KycCubit, KycState>(
        builder: (context, state) {
          if (state.status == KycStatus.loading || state.bundle == null) {
            if (state.status == KycStatus.failure) {
              return _KycScaffold(
                title: 'Validation du profil'.tr(context),
                showBack: true,
                child: AppErrorView(
                  message: state.errorMessage ?? 'Chargement KYC impossible.'.tr(context),
                  onRetry: () => context.read<KycCubit>().load(),
                ),
              );
            }
            return _KycScaffold(
              title: 'Validation du profil'.tr(context),
              showBack: true,
              child: AppLoading(),
            );
          }
          return _KycScaffold(
            title: 'Validation du profil'.tr(context),
            showBack: true,
            bottom: _KycBottomButton(
              label: 'Continuer la validation'.tr(context),
              onPressed: () => context.go(RouteConstants.kycDocuments),
            ),
            child: _KycStatusContent(bundle: state.bundle!),
          );
        },
      ),
    );
  }
}

class KycDocumentsPage extends StatelessWidget {
  const KycDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<KycCubit>()..load(),
      child: BlocBuilder<KycCubit, KycState>(
        builder: (context, state) {
          if (state.status == KycStatus.loading || state.bundle == null) {
            if (state.status == KycStatus.failure) {
              return _KycScaffold(
                title: 'Mes documents'.tr(context),
                child: AppErrorView(
                  message: state.errorMessage ?? 'Chargement KYC impossible.'.tr(context),
                  onRetry: () => context.read<KycCubit>().load(),
                ),
              );
            }
            return _KycScaffold(title: 'Mes documents'.tr(context), child: AppLoading());
          }
          return _KycScaffold(
            title: 'Mes documents'.tr(context),
            child: _DocumentsList(bundle: state.bundle!),
          );
        },
      ),
    );
  }
}

enum _KycStatusTabKind { required, inProgress, history }

class _KycStatusContent extends StatefulWidget {
  final KycBundle bundle;

  const _KycStatusContent({required this.bundle});

  @override
  State<_KycStatusContent> createState() => _KycStatusContentState();
}

class _KycStatusContentState extends State<_KycStatusContent> {
  _KycStatusTabKind _selectedTab = _KycStatusTabKind.required;

  @override
  Widget build(BuildContext context) {
    final bundle = widget.bundle;
    final percent = (bundle.completionRatio * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _KycStatusTabs(
          selected: _selectedTab,
          onChanged: (tab) => setState(() => _selectedTab = tab),
        ),
        const SizedBox(height: 24),
        switch (_selectedTab) {
          _KycStatusTabKind.required => _KycRequiredStatusView(bundle: bundle, percent: percent),
          _KycStatusTabKind.inProgress => _KycInProgressView(bundle: bundle),
          _KycStatusTabKind.history => _KycHistoryView(bundle: bundle),
        },
      ],
    );
  }
}

class _KycStatusTabs extends StatelessWidget {
  final _KycStatusTabKind selected;
  final ValueChanged<_KycStatusTabKind> onChanged;

  const _KycStatusTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1EA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _KycStatusTab(
              label: 'Requis'.tr(context),
              selected: selected == _KycStatusTabKind.required,
              onTap: () => onChanged(_KycStatusTabKind.required),
            ),
          ),
          Expanded(
            child: _KycStatusTab(
              label: 'En cours'.tr(context),
              selected: selected == _KycStatusTabKind.inProgress,
              onTap: () => onChanged(_KycStatusTabKind.inProgress),
            ),
          ),
          Expanded(
            child: _KycStatusTab(
              label: 'Historique'.tr(context),
              selected: selected == _KycStatusTabKind.history,
              onTap: () => onChanged(_KycStatusTabKind.history),
            ),
          ),
        ],
      ),
    );
  }
}

class _KycStatusTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _KycStatusTab({required this.label, this.selected = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          decoration: selected
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(color: Color(0x17000000), blurRadius: 8, offset: Offset(0, 3)),
                  ],
                )
              : null,
          child: Text(
            label,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              color: selected ? AppColors.textPrimary : const Color(0xFF8A968C),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _KycRequiredStatusView extends StatelessWidget {
  final KycBundle bundle;
  final int percent;

  const _KycRequiredStatusView({required this.bundle, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _KycProgressCard(bundle: bundle, percent: percent),
        const SizedBox(height: 24),
        for (final requirement in bundle.requirements) ...[
          _KycStatusRequirementRow(
            requirement: requirement,
            document: bundle.latestDocumentFor(requirement.type),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _KycInProgressView extends StatelessWidget {
  final KycBundle bundle;

  const _KycInProgressView({required this.bundle});

  @override
  Widget build(BuildContext context) {
    if (!_hasSubmittedBundleInProgress(bundle)) {
      return _KycEmptyState(
        title: 'Aucun dossier soumis'.tr(context),
        message: 'Tous les documents requis doivent etre fournis avant le suivi de verification.'.tr(context),
      );
    }
    final submittedAt = _latestSubmittedAt(bundle);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4CB),
            border: Border.all(color: const Color(0xFFF3D77B), width: 1.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7DD7A),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(child: MotodigoPendingYellowIcon(size: 38)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dossier soumis'.tr(context),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      submittedAt == null
                          ? 'En cours de verification'.tr(context)
                          : 'Soumis le {date}'.tr(
                              context,
                              placeholders: {'date': _formatShortDate(context, submittedAt)},
                            ),
                      style: const TextStyle(
                        color: Color(0xFF8A6410),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _KycTimelineStep(
          title: 'Documents soumis'.tr(context),
          subtitle: 'Dossier complet'.tr(context),
          active: true,
          icon: Icons.check_rounded,
        ),
        _KycTimelineStep(
          title: 'Verification en cours'.tr(context),
          subtitle: 'En traitement'.tr(context),
          warning: true,
          icon: Icons.circle,
        ),
        _KycTimelineStep(
          title: 'Decision'.tr(context),
          subtitle: 'En attente'.tr(context),
          icon: Icons.shield_outlined,
        ),
      ],
    );
  }
}

class _KycHistoryView extends StatelessWidget {
  final KycBundle bundle;

  const _KycHistoryView({required this.bundle});

  @override
  Widget build(BuildContext context) {
    final decisions =
        bundle.documents
            .where(
              (document) =>
                  document.status == KycDocumentStatus.accepted ||
                  document.status == KycDocumentStatus.rejected,
            )
            .toList()
          ..sort((a, b) {
            final aDate = a.updatedAt ?? a.uploadedAt ?? DateTime(0);
            final bDate = b.updatedAt ?? b.uploadedAt ?? DateTime(0);
            return bDate.compareTo(aDate);
          });

    if (decisions.isEmpty) {
      return _KycEmptyState(
        title: 'Aucun historique'.tr(context),
        message: 'Les dossiers valides ou rejetes apparaitront ici apres decision admin.'.tr(context),
      );
    }

    return Column(
      children: [
        for (final document in decisions) ...[
          _KycHistoryTile(document: document),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _KycHistoryTile extends StatelessWidget {
  final KycDocument document;

  const _KycHistoryTile({required this.document});

  @override
  Widget build(BuildContext context) {
    final rejected = document.status == KycDocumentStatus.rejected;
    final color = rejected ? const Color(0xFFC62828) : AppColors.primary;
    final background = rejected ? const Color(0xFFFDE3E3) : const Color(0xFFDFF5E8);
    final date = document.updatedAt ?? document.uploadedAt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        border: Border.all(color: const Color(0xFFDDE3DA), width: 1.3),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(16)),
            child: Icon(
              rejected ? Icons.close_rounded : Icons.check_rounded,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.type.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  date == null
                      ? document.displayName
                      : '${document.displayName} - ${_formatShortDate(context, date)}',
                  style: const TextStyle(
                    color: Color(0xFF8A968C),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            rejected ? 'Rejeté'.tr(context) : 'Validé'.tr(context),
            style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _KycEmptyState extends StatelessWidget {
  final String title;
  final String message;

  _KycEmptyState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        border: Border.all(color: const Color(0xFFDDE3DA), width: 1.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const MotodigoFileLeftGrayIcon(size: 52),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF54615A),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _KycTimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool active;
  final bool warning;

  _KycTimelineStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.active = false,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? AppColors.primary
        : warning
        ? const Color(0xFFF3C316)
        : const Color(0xFFDDE3DA);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color,
            child: Icon(
              icon,
              color: active ? Colors.white : AppColors.textSecondary,
              size: warning ? 16 : 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: active || warning ? AppColors.textPrimary : AppColors.textSecondary,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: warning ? const Color(0xFF8A6410) : AppColors.textTertiary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KycProgressCard extends StatelessWidget {
  final KycBundle bundle;
  final int percent;

  const _KycProgressCard({required this.bundle, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        border: Border.all(color: const Color(0xFFDDE3DA), width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Statut global'.tr(context),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _KycCompletionPill(),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  '{provided} / {required} documents fournis'.tr(
                    context,
                    placeholders: {
                      'provided': '${bundle.providedCount}',
                      'required': '${bundle.requiredCount}',
                    },
                  ),
                  style: const TextStyle(
                    color: Color(0xFF54615A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: bundle.completionRatio.clamp(0, 1),
              backgroundColor: const Color(0xFFE5E7E1),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _KycCompletionPill extends StatelessWidget {
  _KycCompletionPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDB7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 3.5, backgroundColor: Color(0xFFF3C316)),
          const SizedBox(width: 7),
          Text(
            'À compléter'.tr(context),
            style: TextStyle(
              color: Color(0xFF8A6410),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _KycStatusRequirementRow extends StatelessWidget {
  final KycRequirement requirement;
  final KycDocument? document;

  const _KycStatusRequirementRow({required this.requirement, this.document});

  @override
  Widget build(BuildContext context) {
    final status = document?.status ?? requirement.latestStatus;
    return Row(
      children: [
        _KycStatusRequirementIcon(status: status),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            _kycRequirementLabel(context, requirement.type),
            overflow: TextOverflow.fade,
            softWrap: false,
            style: TextStyle(
              color: _isMissingStatus(status) ? const Color(0xFF54615A) : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _kycStatusChecklistLabel(context, status),
          style: TextStyle(
            color: _kycStatusChecklistColor(status),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _KycStatusRequirementIcon extends StatelessWidget {
  final KycDocumentStatus status;

  const _KycStatusRequirementIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == KycDocumentStatus.accepted) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: Icon(Icons.check_circle_outline, color: AppColors.primary, size: 32),
        ),
      );
    }
    if (status == KycDocumentStatus.pendingReview ||
        status == KycDocumentStatus.uploaded ||
        status == KycDocumentStatus.encrypted) {
      return const SizedBox(
        width: 32,
        height: 32,
        child: Center(child: MotodigoPendingYellowIcon(size: 28)),
      );
    }
    return const SizedBox(
      width: 32,
      height: 32,
      child: Center(child: MotodigoFileLeftGrayIcon(size: 27)),
    );
  }
}

class KycPreviewPage extends StatelessWidget {
  final KycFileDraft? draft;

  const KycPreviewPage({super.key, this.draft});

  @override
  Widget build(BuildContext context) {
    final selectedDraft = draft;
    if (selectedDraft == null) {
      return _KycScaffold(
        title: 'Aperçu du document'.tr(context),
        child: AppErrorView(
          message: 'Aucun document selectionne.'.tr(context),
          onRetry: () => context.go(RouteConstants.kycDocuments),
        ),
      );
    }
    return _KycScaffold(
      title: 'Aperçu du document'.tr(context),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _KycBottomButton(
            label: 'Envoyer'.tr(context),
            leading: const MotodigoUploadWhiteIcon(size: 21),
            onPressed: () => context.push(RouteConstants.kycUploading, extra: selectedDraft),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go(RouteConstants.kycDocuments),
            child: Text(
              'Reprendre'.tr(context),
              style: TextStyle(color: Color(0xFF54615A), fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          _PreviewFrame(draft: selectedDraft),
          const SizedBox(height: 18),
          _SelectedFileCard(draft: selectedDraft),
        ],
      ),
    );
  }
}

class KycUploadingPage extends StatefulWidget {
  final KycFileDraft? draft;

  const KycUploadingPage({super.key, this.draft});

  @override
  State<KycUploadingPage> createState() => _KycUploadingPageState();
}

class _KycUploadingPageState extends State<KycUploadingPage> {
  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    if (draft == null) {
      return _KycScaffold(
        title: 'Envoi en cours'.tr(context),
        child: AppErrorView(
          message: 'Aucun document selectionne.'.tr(context),
          onRetry: () => context.go(RouteConstants.kycDocuments),
        ),
      );
    }
    return BlocProvider(
      create: (_) {
        final cubit = getIt<KycCubit>();
        WidgetsBinding.instance.addPostFrameCallback((_) => cubit.uploadDraft(draft));
        return cubit;
      },
      child: BlocConsumer<KycCubit, KycState>(
        listener: (context, state) async {
          if (state.status == KycStatus.uploadSuccess || state.status == KycStatus.submitted) {
            final sessionCubit = context.read<SessionCubit>();
            await sessionCubit.refreshAfterProfileChange();
            if (context.mounted) {
              if (state.status == KycStatus.submitted) {
                context.go(RouteConstants.kycSubmitted);
              } else {
                context.go(RouteConstants.kycUploadSuccess, extra: state.uploadResult);
              }
            }
            return;
          }
          if (state.status == KycStatus.invalidFile && state.fileValidation != null) {
            context.go(
              RouteConstants.kycInvalid,
              extra: KycInvalidFileArgs(
                validation: state.fileValidation!,
                message: state.errorMessage,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == KycStatus.failure) {
            return _KycScaffold(
              title: 'Envoi impossible'.tr(context),
              bottom: SecondaryAuthButton(
                label: 'Retour aux documents'.tr(context),
                onPressed: () => context.go(RouteConstants.kycDocuments),
              ),
              child: AppErrorView(
                message: state.errorMessage ?? "L'envoi du document a echoue. Reessayez.".tr(context),
                onRetry: () => context.read<KycCubit>().uploadDraft(draft),
              ),
            );
          }
          final progress = state.uploadProgress.clamp(0.0, 1.0);
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 64, 32, 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primaryLight,
                      child: MotodigoUploadGreenIcon(size: 46),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Envoi en cours...'.tr(context),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${draft.fileName} · ${_formatSize(context, draft.sizeBytes)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 250,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(999),
                        color: AppColors.primary,
                        backgroundColor: const Color(0xFFE4E7E1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 15),
                        const SizedBox(width: 7),
                        Text(
                          'Chiffrement et envoi sécurisé'.tr(context),
                          style: TextStyle(
                            color: Color(0xFF8A968C),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _KycCancelUploadButton(
                      label: "Annuler l'envoi".tr(context),
                      onPressed: () {
                        context.read<KycCubit>().cancelUpload();
                        context.go(RouteConstants.kycDocuments);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class KycUploadSuccessPage extends StatelessWidget {
  final KycUploadResult? result;

  const KycUploadSuccessPage({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x99000000),
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 46, 28, 28),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.check_rounded, color: AppColors.primary, size: 64),
                ),
                const SizedBox(height: 30),
                Text(
                  'Document envoye'.tr(context),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Votre {type} est maintenant en attente de verification. Vous serez notifie de la decision.'
                      .tr(
                        context,
                        placeholders: {
                          'type': result != null
                              ? _documentLabel(context, result!.document.type).toLowerCase()
                              : 'Document'.tr(context).toLowerCase(),
                        },
                      ),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 36),
                PrimaryAuthButton(
                  label: 'Voir mes documents'.tr(context),
                  onPressed: () => context.go(RouteConstants.kycDocuments),
                ),
                const SizedBox(height: 14),
                SecondaryAuthButton(
                  label: 'Ajouter un autre document'.tr(context),
                  onPressed: () => context.go(RouteConstants.kycDocuments),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KycInvalidFilePage extends StatelessWidget {
  final KycInvalidFileArgs? args;

  const KycInvalidFilePage({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final validation = args?.validation;
    final issues = validation?.issues ?? const <KycFileIssue>[KycFileIssue.unsupportedFormat];
    return _KycScaffold(
      title: 'Fichier invalide'.tr(context),
      bottom: PrimaryAuthButton(
        label: 'Choisir un autre fichier'.tr(context),
        onPressed: () => context.go(RouteConstants.kycDocuments),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFCEDEE),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFF4C7CA)),
            ),
            child: const Center(
              child: CircleAvatar(
                radius: 46,
                backgroundColor: Color(0xFFFBE0E1),
                child: Icon(Icons.close_rounded, color: Color(0xFFC62828), size: 54),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFCE2E3),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF4BFC2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    args?.message ??
                        'Ce fichier ne peut pas etre envoye. Corrigez les points ci-dessous puis reessayez.'.tr(context),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFC62828),
                      fontWeight: FontWeight.w900,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          for (final issue in _allIssueRows(context, issues, validation)) ...[
            _IssueRow(issue: issue.issue, passed: issue.passed, detail: issue.detail),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}

class _KycCancelUploadButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _KycCancelUploadButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: Color(0xFFDEE2DA), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class KycSubmittedPage extends StatelessWidget {
  const KycSubmittedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _KycScaffold(
      title: 'Dossier soumis'.tr(context),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _KycBottomButton(
            label: 'Voir mes documents'.tr(context),
            onPressed: () => context.go(RouteConstants.kycDocuments),
          ),
          const SizedBox(height: 14),
          _KycBottomButton(
            label: "Retour à l'accueil".tr(context),
            backgroundColor: AppColors.textPrimary,
            onPressed: () => context.go(RouteConstants.home),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFDF2CD),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(child: MotodigoPendingYellowIcon(size: 34)),
          ),
          const SizedBox(height: 36),
          Text(
            'Dossier en cours de\nvérification'.tr(context),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Nos équipes examinent vos documents.\nDélai indicatif : '.tr(context),
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                TextSpan(
                  text: '24 à 48 h'.tr(context),
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
                ),
                TextSpan(
                  text: '.',
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            style: TextStyle(fontSize: 18, height: 1.5),
          ),
          const SizedBox(height: 38),
          _SubmittedTimelineStep(
            marker: const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.check_rounded, color: Colors.white, size: 27),
            ),
            title: 'Documents soumis'.tr(context),
            subtitle: "Aujourd'hui · {time}".tr(
              context,
              placeholders: {'time': _formatClock(DateTime.now())},
            ),
            active: true,
          ),
          _SubmittedTimelineStep(
            marker: MotodigoFolderVerificationIcon(size: 42),
            title: 'Vérification en cours'.tr(context),
            subtitle: 'En traitement'.tr(context),
            warning: true,
          ),
          _SubmittedTimelineStep(
            marker: CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFEFF1EC),
              child: MotodigoFolderCheckedWhiteIcon(size: 21, color: Color(0xFF9BA69E)),
            ),
            title: 'Décision'.tr(context),
            subtitle: 'En attente'.tr(context),
            last: true,
          ),
        ],
      ),
    );
  }
}

class _SubmittedTimelineStep extends StatelessWidget {
  final Widget marker;
  final String title;
  final String subtitle;
  final bool active;
  final bool warning;
  final bool last;

  _SubmittedTimelineStep({
    required this.marker,
    required this.title,
    required this.subtitle,
    this.active = false,
    this.warning = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = active || warning ? AppColors.textPrimary : AppColors.textSecondary;
    final subtitleColor = warning ? const Color(0xFF8A6410) : const Color(0xFF8A968C);
    final lineColor = active ? AppColors.primary : const Color(0xFFE4E7E1);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                SizedBox(width: 42, height: 42, child: Center(child: marker)),
                if (!last) Expanded(child: Container(width: 2, color: lineColor)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 3, bottom: last ? 0 : 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KycRejectedDocumentPage extends StatelessWidget {
  final KycDocument? document;

  const KycRejectedDocumentPage({super.key, this.document});

  @override
  Widget build(BuildContext context) {
    final selected = document;
    if (selected == null) {
      return _KycScaffold(
        title: 'Document rejete'.tr(context),
        child: AppErrorView(
          message: 'Aucun document rejete selectionne.'.tr(context),
          onRetry: () => context.go(RouteConstants.kycDocuments),
        ),
      );
    }
    return _KycScaffold(
      title: 'Document rejete'.tr(context),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryAuthButton(
            label: 'Remplacer le document'.tr(context),
            leadingIcon: Icons.sync_rounded,
            onPressed: () => _openUploadSourceSheet(context, selected.type),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => launchUrl(Uri.parse('mailto:support@motodigo.com')),
            child: Text('Contacter le support'.tr(context)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFFBE0E1),
              border: Border.all(color: const Color(0xFFF4BFC2)),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DocumentIcon(status: KycDocumentStatus.rejected),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '{label} rejetee'.tr(
                          context,
                          placeholders: {'label': _documentLabel(context, selected.type)},
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFC62828),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Motif : {reason}'.tr(
                          context,
                          placeholders: {
                            'reason':
                                selected.rejectionReason ?? 'Document non conforme.'.tr(context),
                          },
                        ),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFFC62828),
                          height: 1.45,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _UploadedFileSummary(document: selected),
          const SizedBox(height: 24),
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 18),
            collapsedBackgroundColor: const Color(0xFFF1F2ED),
            backgroundColor: const Color(0xFFF1F2ED),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(
              'Voir les consignes detaillees'.tr(context),
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textSecondary),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Text(
                  'Le document doit etre lisible, complet et montrer clairement les informations obligatoires.'.tr(context),
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class KycVerifiedPage extends StatelessWidget {
  const KycVerifiedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _KycScaffold(
      showBack: false,
      bottom: PrimaryAuthButton(
        label: 'Activer mon profil'.tr(context),
        onPressed: () => context.go(RouteConstants.home),
      ),
      child: Column(
        children: [
          const SizedBox(height: 140),
          const CircleAvatar(
            radius: 66,
            backgroundColor: AppColors.primaryLight,
            child: CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.verified_user_outlined, color: Colors.white, size: 58),
            ),
          ),
          const SizedBox(height: 34),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Profil verifie'.tr(context),
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          Text(
            'Votre profil mototaxi est valide'.tr(context),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Vous avez desormais acces aux fonctions conducteur : disponibilite, trajets et partage de position.'.tr(context),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class KycNotificationDetailPage extends StatelessWidget {
  final KycNotificationPayload? payload;

  const KycNotificationDetailPage({super.key, this.payload});

  @override
  Widget build(BuildContext context) {
    final notification =
        payload ??
        KycNotificationPayload(
          title: 'Votre profil mototaxi est valide'.tr(context),
          body:
              'Bonne nouvelle ! Tous vos documents ont ete acceptes. Vous pouvez maintenant passer en ligne et recevoir des courses.'
                  .tr(context),
          status: ValidationStatus.validated,
          occurredAt: DateTime.now(),
        );
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
              color: const Color(0xFFECEFE8),
              child: Column(
                children: [
                  Text(
                    'Banniere systeme'.tr(context),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 34,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.verified_user_outlined, color: Colors.white),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            "Moto'di Go\n${notification.title}",
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 64,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDDE3DA),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              'DETAIL DE LA NOTIFICATION'.tr(context),
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              notification.title,
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              notification.body,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.55,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                const Icon(Icons.schedule_rounded, color: AppColors.textTertiary),
                                const SizedBox(width: 10),
                                Text(
                                  _formatDate(notification.occurredAt),
                                  style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    PrimaryAuthButton(
                      label: 'Ouvrir le statut KYC'.tr(context),
                      trailingIcon: Icons.arrow_forward_rounded,
                      onPressed: () => context.go(RouteConstants.kycDocuments),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentsList extends StatelessWidget {
  final KycBundle bundle;

  const _DocumentsList({required this.bundle});

  @override
  Widget build(BuildContext context) {
    String? currentSection;
    final children = <Widget>[];
    for (final requirement in bundle.requirements) {
      if (currentSection != requirement.type.sectionLabel) {
        currentSection = requirement.type.sectionLabel;
        children.add(
          Padding(
            padding: EdgeInsets.only(top: children.isEmpty ? 0 : 30, bottom: 20),
            child: Text(
              _documentSectionLabel(context, requirement.type),
              style: const TextStyle(
                color: Color(0xFF98A29A),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.1,
              ),
            ),
          ),
        );
      }
      final document = bundle.latestDocumentFor(requirement.type);
      children.add(
        _DocumentListTile(
          requirement: requirement,
          document: document,
          onAdd: () => _openUploadSourceSheet(context, requirement.type),
          onDetails: document == null
              ? null
              : () => context.push(RouteConstants.kycRejected, extra: document),
        ),
      );
      final isLastInSection = _isLastRequirementInSection(bundle.requirements, requirement);
      if (!isLastInSection) {
        children.add(
          const Padding(
            padding: EdgeInsets.only(left: 64),
            child: Divider(height: 24, color: Color(0xFFE2E6E0), thickness: 1),
          ),
        );
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }
}

class _KycScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? bottom;
  final bool showBack;

  _KycScaffold({this.title, required this.child, this.bottom, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null || showBack) _KycHeader(title: title, showBack: showBack),
              if (title != null || showBack) const SizedBox(height: 30),
              child,
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(minimum: const EdgeInsets.fromLTRB(28, 8, 28, 24), child: bottom!),
    );
  }
}

class _KycBottomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Color backgroundColor;

  const _KycBottomButton({
    required this.label,
    this.onPressed,
    this.leading,
    this.backgroundColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 10,
          shadowColor: backgroundColor.withValues(alpha: 0.22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KycHeader extends StatelessWidget {
  final String? title;
  final bool showBack;

  const _KycHeader({required this.title, required this.showBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack)
          Material(
            color: const Color(0xFFF1F2ED),
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.canPop() ? context.pop() : context.go(RouteConstants.home),
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 30),
              ),
            ),
          ),
        if (showBack) const SizedBox(width: 18),
        if (title != null)
          Expanded(
            child: Text(
              title!,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}

class _DocumentListTile extends StatelessWidget {
  final KycRequirement requirement;
  final KycDocument? document;
  final VoidCallback onAdd;
  final VoidCallback? onDetails;

  const _DocumentListTile({
    required this.requirement,
    required this.document,
    required this.onAdd,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final status = document?.status ?? KycDocumentStatus.missing;
    final rejected = status == KycDocumentStatus.rejected;
    final missing = status == KycDocumentStatus.missing;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 58),
      child: Row(
        children: [
          _DocumentListIcon(status: status, type: requirement.type),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _documentLabel(context, requirement.type),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _documentSubtitle(context, document, status),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: rejected ? const Color(0xFFC62828) : const Color(0xFF8A968C),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (missing)
            _DocumentAddButton(onPressed: onAdd)
          else if (rejected)
            TextButton(
              onPressed: onDetails,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                minimumSize: const Size(48, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Détails'.tr(context),
                style: TextStyle(
                  color: Color(0xFFC62828),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          else
            _DocumentStatusPill(status: status),
        ],
      ),
    );
  }
}

class _DocumentListIcon extends StatelessWidget {
  final KycDocumentStatus status;
  final KycDocumentType type;

  const _DocumentListIcon({required this.status, required this.type});

  @override
  Widget build(BuildContext context) {
    final rejected = status == KycDocumentStatus.rejected;
    final pending =
        status == KycDocumentStatus.pendingReview ||
        status == KycDocumentStatus.uploaded ||
        status == KycDocumentStatus.encrypted;
    final accepted = status == KycDocumentStatus.accepted;
    final iconColor = accepted ? AppColors.primary : _statusColor(status);
    final background = rejected
        ? const Color(0xFFFDE3E3)
        : pending
        ? const Color(0xFFFFF0C7)
        : accepted
        ? const Color(0xFFDFF5E8)
        : const Color(0xFFF1F2ED);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
      child: Center(
        child: _DocumentListGlyph(type: type, status: status, color: iconColor),
      ),
    );
  }
}

class _DocumentListGlyph extends StatelessWidget {
  final KycDocumentType type;
  final KycDocumentStatus status;
  final Color color;

  const _DocumentListGlyph({required this.type, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    if (status == KycDocumentStatus.rejected) {
      return const MotodigoAlertRedIcon(size: 22);
    }
    if (status == KycDocumentStatus.pendingReview ||
        status == KycDocumentStatus.uploaded ||
        status == KycDocumentStatus.encrypted) {
      return const MotodigoPendingYellowIcon(size: 23);
    }
    return switch (type) {
      KycDocumentType.cni => const MotodigoCniGreenIcon(size: 22),
      KycDocumentType.profilePhoto => const MotodigoPictureGreenIcon(size: 22),
      KycDocumentType.vehiclePhoto =>
        status == KycDocumentStatus.accepted
            ? const MotodigoPictureGreenIcon(size: 22)
            : MotodigoPictureGrayIcon(size: 22, color: color),
      KycDocumentType.vehicleRegistration ||
      KycDocumentType.insurance ||
      KycDocumentType.driverLicense ||
      KycDocumentType.unknown => MotodigoFileLeftGrayIcon(size: 22, color: color),
    };
  }
}

class _DocumentAddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DocumentAddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, size: 17),
        label: Text('Ajouter'.tr(context)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _DocumentStatusPill extends StatelessWidget {
  final KycDocumentStatus status;

  const _DocumentStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _statusLabel(context, status),
        style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.w900, height: 1),
      ),
    );
  }
}

class _PreviewFrame extends StatelessWidget {
  final KycFileDraft draft;

  const _PreviewFrame({required this.draft});

  @override
  Widget build(BuildContext context) {
    final isImage = draft.mimeType.startsWith('image/');
    return Container(
      height: 372,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0xFFEDEDE6), Color(0xFFEDEDE6), Color(0xFFF5F5EF), Color(0xFFF5F5EF)],
        ),
        border: Border.all(color: const Color(0xFFE1E1D9)),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: isImage
                  ? Image.file(
                      File(draft.path),
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => _PreviewPlaceholder(draft: draft),
                    )
                  : _PreviewPlaceholder(draft: draft),
            ),
          ),
          const Positioned(
            top: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FloatingIcon(icon: Icons.sync_rounded),
                SizedBox(width: 8),
                _FloatingIcon(icon: Icons.image_outlined),
              ],
            ),
          ),
          Positioned(
            left: 14,
            right: 86,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'aperçu — {label} (recto)'.tr(
                  context,
                  placeholders: {
                    'label': _documentLabel(context, draft.documentType).toLowerCase(),
                  },
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  final KycFileDraft draft;

  const _PreviewPlaceholder({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        draft.mimeType == 'application/pdf'
            ? Icons.picture_as_pdf_outlined
            : Icons.description_outlined,
        color: const Color(0xFFB6BEB6),
        size: 72,
      ),
    );
  }
}

class _SelectedFileCard extends StatelessWidget {
  final KycFileDraft draft;

  const _SelectedFileCard({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7EAE3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1EA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(child: MotodigoFileLeftGrayIcon(size: 22)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${draft.mimeType.startsWith('image/') ? 'Image'.tr(context) : 'PDF'.tr(context)} · ${_formatSize(context, draft.sizeBytes)} · ${draft.extension}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8A968C),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 13,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.check_rounded, color: AppColors.primary, size: 18),
          ),
        ],
      ),
    );
  }
}

class _UploadedFileSummary extends StatelessWidget {
  final KycDocument document;

  const _UploadedFileSummary({required this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        border: Border.all(color: const Color(0xFFDDE3DA)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const _DocumentIcon(status: KycDocumentStatus.missing),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Envoye le {date} - {size}'.tr(
                    context,
                    placeholders: {
                      'date': _formatShortDate(context, document.uploadedAt),
                      'size': _formatSize(context, document.sizeBytes),
                    },
                  ),
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentIcon extends StatelessWidget {
  final KycDocumentStatus status;

  const _DocumentIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final background = color.withValues(alpha: 0.12);
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(18)),
      child: Icon(
        status == KycDocumentStatus.rejected
            ? Icons.warning_amber_rounded
            : Icons.description_outlined,
        color: color,
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final IconData icon;

  const _FloatingIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xCC101512),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

class _IssueRowData {
  final KycFileIssue issue;
  final bool passed;
  final String detail;

  const _IssueRowData({required this.issue, required this.passed, required this.detail});
}

class _IssueRow extends StatelessWidget {
  final KycFileIssue issue;
  final bool passed;
  final String detail;

  const _IssueRow({required this.issue, required this.passed, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_rounded : Icons.close_rounded,
          color: passed ? AppColors.textTertiary : const Color(0xFFC62828),
          size: 28,
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            detail,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _openUploadSourceSheet(BuildContext context, KycDocumentType type) async {
  final draft = await showModalBottomSheet<KycFileDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _UploadSourceSheet(type: type),
  );
  if (draft == null || !context.mounted) return;
  final validation = KycFileValidation.validate(draft);
  if (validation.isValid) {
    context.push(RouteConstants.kycPreview, extra: draft);
  } else {
    context.push(RouteConstants.kycInvalid, extra: KycInvalidFileArgs(validation: validation));
  }
}

class _UploadSourceSheet extends StatelessWidget {
  final KycDocumentType type;

  const _UploadSourceSheet({required this.type});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE3DA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Ajouter un document'.tr(context),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '{label} · JPG, PNG ou PDF · 5 Mo max ·\ndocument lisible.'.tr(
                  context,
                  placeholders: {'label': _documentLabel(context, type)},
                ),
                style: const TextStyle(
                  color: Color(0xFF8A968C),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              _UploadOption(
                icon: const MotodigoCameraGreenIcon(size: 28),
                title: 'Prendre une photo'.tr(context),
                subtitle: 'Utiliser la caméra'.tr(context),
                onTap: () async =>
                    Navigator.of(context).pop(await _pickImage(type, ImageSource.camera)),
              ),
              const SizedBox(height: 14),
              _UploadOption(
                icon: const MotodigoPictureGreenIcon(size: 28),
                title: 'Choisir dans la galerie'.tr(context),
                subtitle: 'Photos existantes'.tr(context),
                onTap: () async =>
                    Navigator.of(context).pop(await _pickImage(type, ImageSource.gallery)),
              ),
              const SizedBox(height: 14),
              _UploadOption(
                icon: const MotodigoFileLeftGrayIcon(size: 28, color: AppColors.primary),
                title: 'Importer un PDF'.tr(context),
                subtitle: 'Depuis vos fichiers'.tr(context),
                onTap: () async => Navigator.of(context).pop(await _pickPdf(type)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadOption extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final Future<void> Function() onTap;

  const _UploadOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 86),
          padding: const EdgeInsets.fromLTRB(20, 14, 18, 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDE3DA), width: 1.2),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 17.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8A968C),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}

Future<KycFileDraft?> _pickImage(KycDocumentType type, ImageSource source) async {
  final file = await ImagePicker().pickImage(source: source, imageQuality: 88);
  if (file == null) return null;
  final size = await file.length();
  final name = file.name.isEmpty ? '${type.apiValue.toLowerCase()}.jpg' : file.name;
  return KycFileDraft(
    documentType: type,
    path: file.path,
    fileName: name,
    mimeType: _mimeTypeFromName(name, fallback: file.mimeType ?? 'image/jpeg'),
    sizeBytes: size,
  );
}

Future<KycFileDraft?> _pickPdf(KycDocumentType type) async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['pdf'],
    withData: false,
  );
  final file = result?.files.single;
  if (file == null || file.path == null) return null;
  return KycFileDraft(
    documentType: type,
    path: file.path!,
    fileName: file.name,
    mimeType: 'application/pdf',
    sizeBytes: file.size,
  );
}

List<_IssueRowData> _allIssueRows(
  BuildContext context,
  List<KycFileIssue> issues,
  KycFileValidation? validation,
) {
  final size = validation?.draft.sizeBytes ?? 0;
  final extension = validation?.draft.extension ?? '';
  return [
    _IssueRowData(
      issue: KycFileIssue.tooLarge,
      passed: !issues.contains(KycFileIssue.tooLarge),
      detail: size > 0
          ? 'Taille trop grande ({size} > 5 Mo)'.tr(
              context,
              placeholders: {'size': _formatSize(context, size)},
            )
          : 'Taille inferieure a 5 Mo'.tr(context),
    ),
    _IssueRowData(
      issue: KycFileIssue.unreadable,
      passed: !issues.contains(KycFileIssue.unreadable) && !issues.contains(KycFileIssue.empty),
      detail: 'Document lisible et non vide'.tr(context),
    ),
    _IssueRowData(
      issue: KycFileIssue.unsupportedFormat,
      passed: !issues.contains(KycFileIssue.unsupportedFormat),
      detail: extension.isEmpty
          ? 'Format accepte (JPG, PNG, PDF)'.tr(context)
          : 'Format accepte ({extension})'.tr(
              context,
              placeholders: {'extension': extension},
            ),
    ),
  ];
}

bool _isLastRequirementInSection(List<KycRequirement> requirements, KycRequirement requirement) {
  final index = requirements.indexOf(requirement);
  if (index < 0 || index == requirements.length - 1) return true;
  return requirements[index + 1].type.sectionLabel != requirement.type.sectionLabel;
}

String _documentSectionLabel(BuildContext context, KycDocumentType type) {
  return switch (type) {
    KycDocumentType.cni || KycDocumentType.profilePhoto => 'IDENTITÉ'.tr(context),
    KycDocumentType.driverLicense => 'AUTORISATION DE CONDUITE'.tr(context),
    KycDocumentType.vehicleRegistration ||
    KycDocumentType.insurance ||
    KycDocumentType.vehiclePhoto => 'VÉHICULE'.tr(context),
    KycDocumentType.unknown => 'DOCUMENTS'.tr(context),
  };
}

String _documentLabel(BuildContext context, KycDocumentType type) {
  return switch (type) {
    KycDocumentType.cni => "Carte d'identité".tr(context),
    KycDocumentType.driverLicense => 'Permis de conduire'.tr(context),
    KycDocumentType.vehicleRegistration => 'Carte grise'.tr(context),
    KycDocumentType.insurance => 'Assurance'.tr(context),
    KycDocumentType.profilePhoto => 'Photo de profil'.tr(context),
    KycDocumentType.vehiclePhoto => 'Photo du véhicule'.tr(context),
    KycDocumentType.unknown => 'Document'.tr(context),
  };
}

String _kycRequirementLabel(BuildContext context, KycDocumentType type) {
  return switch (type) {
    KycDocumentType.cni => "Carte nationale d'identité".tr(context),
    KycDocumentType.driverLicense => 'Permis de conduire'.tr(context),
    KycDocumentType.vehicleRegistration => 'Carte grise'.tr(context),
    KycDocumentType.insurance => 'Assurance'.tr(context),
    KycDocumentType.profilePhoto => 'Photo de profil'.tr(context),
    KycDocumentType.vehiclePhoto => 'Photo du véhicule'.tr(context),
    KycDocumentType.unknown => 'Document'.tr(context),
  };
}

String _documentSubtitle(BuildContext context, KycDocument? document, KycDocumentStatus status) {
  return switch (status) {
    KycDocumentStatus.rejected => 'Rejeté · {reason}'.tr(
      context,
      placeholders: {
        'reason': document?.rejectionReason ?? 'document non conforme'.tr(context),
      },
    ),
    KycDocumentStatus.pendingReview ||
    KycDocumentStatus.uploaded ||
    KycDocumentStatus.encrypted => 'En cours de vérification'.tr(context),
    KycDocumentStatus.accepted => 'Ajouté le {date}'.tr(
      context,
      placeholders: {'date': _formatShortDate(context, document?.uploadedAt)},
    ),
    KycDocumentStatus.expired => 'Document expiré'.tr(context),
    KycDocumentStatus.missing || KycDocumentStatus.unknown => 'Document requis'.tr(context),
  };
}

String _mimeTypeFromName(String name, {required String fallback}) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  return fallback;
}

String _formatSize(BuildContext context, int bytes) {
  if (bytes <= 0) return '{n} Mo'.tr(context, placeholders: {'n': '0'});
  final mb = bytes / (1024 * 1024);
  return '{n} Mo'.tr(
    context,
    placeholders: {'n': mb.toStringAsFixed(mb >= 10 ? 0 : 1)},
  );
}

String _formatShortDate(BuildContext context, DateTime? date) {
  if (date == null) return 'récemment'.tr(context);
  final isEn = Localizations.localeOf(context).languageCode == 'en';
  final months = isEn
      ? const [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ]
      : const [
          'janv.',
          'févr.',
          'mars',
          'avr.',
          'mai',
          'juin',
          'juil.',
          'août',
          'sept.',
          'oct.',
          'nov.',
          'déc.',
        ];
  return '${date.day} ${months[date.month - 1]}';
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String _formatClock(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String _statusLabel(BuildContext context, KycDocumentStatus status) {
  return switch (status) {
    KycDocumentStatus.accepted => 'Validé'.tr(context),
    KycDocumentStatus.pendingReview => 'En attente'.tr(context),
    KycDocumentStatus.rejected => 'Rejeté'.tr(context),
    KycDocumentStatus.expired => 'Expiré'.tr(context),
    KycDocumentStatus.uploaded || KycDocumentStatus.encrypted => 'Fourni'.tr(context),
    KycDocumentStatus.missing || KycDocumentStatus.unknown => 'À fournir'.tr(context),
  };
}

String _kycStatusChecklistLabel(BuildContext context, KycDocumentStatus status) {
  return switch (status) {
    KycDocumentStatus.accepted => 'Validé'.tr(context),
    KycDocumentStatus.pendingReview ||
    KycDocumentStatus.uploaded ||
    KycDocumentStatus.encrypted => 'En attente'.tr(context),
    KycDocumentStatus.rejected => 'Rejeté'.tr(context),
    KycDocumentStatus.expired => 'Expiré'.tr(context),
    KycDocumentStatus.missing || KycDocumentStatus.unknown => 'À fournir'.tr(context),
  };
}

Color _kycStatusChecklistColor(KycDocumentStatus status) {
  return switch (status) {
    KycDocumentStatus.accepted => AppColors.primary,
    KycDocumentStatus.pendingReview ||
    KycDocumentStatus.uploaded ||
    KycDocumentStatus.encrypted => const Color(0xFF8A6410),
    KycDocumentStatus.rejected || KycDocumentStatus.expired => const Color(0xFFC62828),
    KycDocumentStatus.missing || KycDocumentStatus.unknown => const Color(0xFF98A29A),
  };
}

bool _isMissingStatus(KycDocumentStatus status) {
  return status == KycDocumentStatus.missing || status == KycDocumentStatus.unknown;
}

bool _hasSubmittedBundleInProgress(KycBundle bundle) {
  if (!bundle.isComplete ||
      bundle.profileValidationStatus == ValidationStatus.validated ||
      bundle.hasRejectedDocument) {
    return false;
  }
  return bundle.requirements.where((item) => item.required).every((item) {
    final status = bundle.latestDocumentFor(item.type)?.status;
    return status == KycDocumentStatus.pendingReview ||
        status == KycDocumentStatus.uploaded ||
        status == KycDocumentStatus.encrypted ||
        status == KycDocumentStatus.accepted;
  });
}

DateTime? _latestSubmittedAt(KycBundle bundle) {
  DateTime? latest;
  for (final document in bundle.documents) {
    final date = document.uploadedAt ?? document.updatedAt;
    if (date != null && (latest == null || date.isAfter(latest))) {
      latest = date;
    }
  }
  return latest;
}

Color _statusColor(KycDocumentStatus status) {
  return switch (status) {
    KycDocumentStatus.accepted => AppColors.primary,
    KycDocumentStatus.pendingReview => const Color(0xFF9B6B0B),
    KycDocumentStatus.rejected => const Color(0xFFC62828),
    KycDocumentStatus.expired => const Color(0xFFC62828),
    KycDocumentStatus.uploaded || KycDocumentStatus.encrypted => AppColors.primary,
    KycDocumentStatus.missing || KycDocumentStatus.unknown => AppColors.textTertiary,
  };
}
