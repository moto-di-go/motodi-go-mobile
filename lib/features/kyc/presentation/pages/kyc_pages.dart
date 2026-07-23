import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
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
                title: 'Mes documents',
                child: AppErrorView(
                  message: state.errorMessage ?? 'Chargement KYC impossible.',
                  onRetry: () => context.read<KycCubit>().load(),
                ),
              );
            }
            return const _KycScaffold(
              title: 'Mes documents',
              child: AppLoading(),
            );
          }
          return _KycScaffold(
            title: 'Mes documents',
            child: _DocumentsList(bundle: state.bundle!),
          );
        },
      ),
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
        title: 'Apercu du document',
        child: AppErrorView(
          message: 'Aucun document selectionne.',
          onRetry: () => context.go(RouteConstants.kycDocuments),
        ),
      );
    }
    return _KycScaffold(
      title: 'Apercu du document',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryAuthButton(
            label: 'Envoyer',
            leadingIcon: Icons.file_upload_outlined,
            onPressed: () =>
                context.push(RouteConstants.kycUploading, extra: selectedDraft),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => context.go(RouteConstants.kycDocuments),
            child: const Text('Reprendre'),
          ),
        ],
      ),
      child: Column(
        children: [
          _PreviewFrame(draft: selectedDraft),
          const SizedBox(height: 26),
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
        title: 'Envoi en cours',
        child: AppErrorView(
          message: 'Aucun document selectionne.',
          onRetry: () => context.go(RouteConstants.kycDocuments),
        ),
      );
    }
    return BlocProvider(
      create: (_) {
        final cubit = getIt<KycCubit>();
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => cubit.uploadDraft(draft),
        );
        return cubit;
      },
      child: BlocConsumer<KycCubit, KycState>(
        listener: (context, state) async {
          if (state.status == KycStatus.uploadSuccess ||
              state.status == KycStatus.submitted) {
            final sessionCubit = context.read<SessionCubit>();
            await sessionCubit.refreshAfterProfileChange();
            if (context.mounted) {
              context.go(
                RouteConstants.kycUploadSuccess,
                extra: state.uploadResult,
              );
            }
            return;
          }
          if (state.status == KycStatus.invalidFile &&
              state.fileValidation != null) {
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
              title: 'Envoi impossible',
              bottom: SecondaryAuthButton(
                label: 'Retour aux documents',
                onPressed: () => context.go(RouteConstants.kycDocuments),
              ),
              child: AppErrorView(
                message:
                    state.errorMessage ??
                    "L'envoi du document a echoue. Reessayez.",
                onRetry: () => context.read<KycCubit>().uploadDraft(draft),
              ),
            );
          }
          final progress = state.uploadProgress.clamp(0.0, 1.0);
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 80, 32, 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    const CircleAvatar(
                      radius: 58,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(
                        Icons.file_upload_outlined,
                        color: AppColors.primary,
                        size: 62,
                      ),
                    ),
                    const SizedBox(height: 34),
                    Text(
                      'Envoi en cours...',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${draft.fileName} - ${_formatSize(draft.sizeBytes)}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 32),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.primary,
                      backgroundColor: const Color(0xFFE2E5DF),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Chiffrement et envoi securise',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SecondaryAuthButton(
                      label: "Annuler l'envoi",
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
    final documentType =
        result?.document.type.shortLabel.toLowerCase() ?? 'document';
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
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Document envoye',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Votre $documentType est maintenant en attente de verification. Vous serez notifie de la decision.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 36),
                PrimaryAuthButton(
                  label: 'Voir mes documents',
                  onPressed: () => context.go(RouteConstants.kycDocuments),
                ),
                const SizedBox(height: 14),
                SecondaryAuthButton(
                  label: 'Ajouter un autre document',
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
    final issues =
        validation?.issues ??
        const <KycFileIssue>[KycFileIssue.unsupportedFormat];
    return _KycScaffold(
      title: 'Fichier invalide',
      bottom: PrimaryAuthButton(
        label: 'Choisir un autre fichier',
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
                child: Icon(
                  Icons.close_rounded,
                  color: Color(0xFFC62828),
                  size: 54,
                ),
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
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFC62828),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    args?.message ??
                        'Ce fichier ne peut pas etre envoye. Corrigez les points ci-dessous puis reessayez.',
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
          for (final issue in _allIssueRows(issues, validation)) ...[
            _IssueRow(
              issue: issue.issue,
              passed: issue.passed,
              detail: issue.detail,
            ),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}

class KycSubmittedPage extends StatelessWidget {
  const KycSubmittedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _KycScaffold(
      title: 'Dossier soumis',
      bottom: PrimaryAuthButton(
        label: "Retour a l'accueil",
        backgroundColor: AppColors.textPrimary,
        onPressed: () => context.go(RouteConstants.home),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StatusHeroIcon(icon: Icons.schedule_rounded, warning: true),
          const SizedBox(height: 36),
          Text(
            'Dossier en cours de verification',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Nos equipes examinent vos documents.\nDelai indicatif : 24 a 48 h.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 42),
          const _TimelineStep(
            icon: Icons.check_rounded,
            title: 'Documents soumis',
            subtitle: "Aujourd'hui",
            active: true,
          ),
          const _TimelineStep(
            icon: Icons.circle,
            title: 'Verification en cours',
            subtitle: 'En traitement',
            warning: true,
          ),
          const _TimelineStep(
            icon: Icons.verified_user_outlined,
            title: 'Decision',
            subtitle: 'En attente',
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
        title: 'Document rejete',
        child: AppErrorView(
          message: 'Aucun document rejete selectionne.',
          onRetry: () => context.go(RouteConstants.kycDocuments),
        ),
      );
    }
    return _KycScaffold(
      title: 'Document rejete',
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryAuthButton(
            label: 'Remplacer le document',
            leadingIcon: Icons.sync_rounded,
            onPressed: () => _openUploadSourceSheet(context, selected.type),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                launchUrl(Uri.parse('mailto:support@motodigo.com')),
            child: const Text('Contacter le support'),
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
                        '${selected.type.shortLabel} rejetee',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFC62828),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Motif : ${selected.rejectionReason ?? 'Document non conforme.'}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text(
              'Voir les consignes detaillees',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Text(
                  'Le document doit etre lisible, complet et montrer clairement les informations obligatoires.',
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
        label: 'Activer mon profil',
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
              child: Icon(
                Icons.verified_user_outlined,
                color: Colors.white,
                size: 58,
              ),
            ),
          ),
          const SizedBox(height: 34),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Profil verifie',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 34),
          Text(
            'Votre profil mototaxi est valide',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Vous avez desormais acces aux fonctions conducteur : disponibilite, trajets et partage de position.',
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
          title: 'Votre profil mototaxi est valide',
          body:
              'Bonne nouvelle ! Tous vos documents ont ete acceptes. Vous pouvez maintenant passer en ligne et recevoir des courses.',
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
                    'Banniere systeme',
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
                          child: Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            "Moto'di Go\n${notification.title}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
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
                            const Text(
                              'DETAIL DE LA NOTIFICATION',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              notification.title,
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              notification.body,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.55,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  color: AppColors.textTertiary,
                                ),
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
                      label: 'Ouvrir le statut KYC',
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
            padding: EdgeInsets.only(
              top: children.isEmpty ? 0 : 26,
              bottom: 18,
            ),
            child: Text(
              currentSection,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
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
      children.add(const Divider(height: 30, color: Color(0xFFE2E6E0)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _KycScaffold extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? bottom;
  final bool showBack;

  const _KycScaffold({
    this.title,
    required this.child,
    this.bottom,
    this.showBack = true,
  });

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
              if (title != null || showBack)
                _KycHeader(title: title, showBack: showBack),
              if (title != null || showBack) const SizedBox(height: 30),
              child,
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(28, 8, 28, 24),
              child: bottom!,
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
              onTap: () => context.canPop()
                  ? context.pop()
                  : context.go(RouteConstants.home),
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary,
                  size: 30,
                ),
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
    return Row(
      children: [
        _DocumentIcon(status: status, type: requirement.type),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                requirement.type.shortLabel,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rejected
                    ? 'Rejete - ${document?.rejectionReason ?? 'document non conforme'}'
                    : missing
                    ? 'Document requis'
                    : status == KycDocumentStatus.pendingReview
                    ? 'En cours de verification'
                    : 'Ajoute le ${_formatShortDate(document?.uploadedAt)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: rejected
                      ? const Color(0xFFC62828)
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (missing)
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          )
        else if (rejected)
          TextButton(
            onPressed: onDetails,
            child: const Text(
              'Details',
              style: TextStyle(
                color: Color(0xFFC62828),
                fontWeight: FontWeight.w900,
              ),
            ),
          )
        else
          _StatusPill(
            label: _statusLabel(status),
            color: _statusColor(status),
            background: _statusColor(status).withValues(alpha: 0.12),
          ),
      ],
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
      height: 430,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        border: Border.all(color: const Color(0xFFDDE3DA)),
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: isImage
                ? Image.file(
                    File(draft.path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _PreviewPlaceholder(draft: draft),
                  )
                : _PreviewPlaceholder(draft: draft),
          ),
          const Positioned(
            top: 18,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FloatingIcon(icon: Icons.sync_rounded),
                SizedBox(width: 12),
                _FloatingIcon(icon: Icons.image_outlined),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'apercu - ${draft.documentType.shortLabel.toLowerCase()}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
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
        color: AppColors.textSecondary,
        size: 96,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        border: Border.all(color: const Color(0xFFDDE3DA)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const _DocumentIcon(status: KycDocumentStatus.missing),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.fileName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${draft.mimeType.startsWith('image/') ? 'Image' : 'PDF'} - ${_formatSize(draft.sizeBytes)} - ${draft.extension}',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.check_rounded, color: AppColors.primary),
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
                  'Envoye le ${_formatShortDate(document.uploadedAt)} - ${_formatSize(document.sizeBytes)}',
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
  final KycDocumentType? type;

  const _DocumentIcon({required this.status, this.type});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final background = color.withValues(alpha: 0.12);
    final icon = switch (type) {
      KycDocumentType.profilePhoto => Icons.image_outlined,
      KycDocumentType.cni => Icons.badge_outlined,
      _ => Icons.description_outlined,
    };
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        status == KycDocumentStatus.rejected
            ? Icons.warning_amber_rounded
            : icon,
        color: color,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _StatusHeroIcon extends StatelessWidget {
  final IconData icon;
  final bool warning;

  const _StatusHeroIcon({required this.icon, this.warning = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: warning ? const Color(0xFFFFF0BD) : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Icon(
        icon,
        color: warning ? const Color(0xFF9B6B0B) : AppColors.primary,
        size: 54,
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;
  final bool warning;

  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(
              icon,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: active || warning
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: warning
                        ? const Color(0xFF9B6B0B)
                        : AppColors.textTertiary,
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

class _FloatingIcon extends StatelessWidget {
  final IconData icon;

  const _FloatingIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF3F4640),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _IssueRowData {
  final KycFileIssue issue;
  final bool passed;
  final String detail;

  const _IssueRowData({
    required this.issue,
    required this.passed,
    required this.detail,
  });
}

class _IssueRow extends StatelessWidget {
  final KycFileIssue issue;
  final bool passed;
  final String detail;

  const _IssueRow({
    required this.issue,
    required this.passed,
    required this.detail,
  });

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

Future<void> _openUploadSourceSheet(
  BuildContext context,
  KycDocumentType type,
) async {
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
    context.push(
      RouteConstants.kycInvalid,
      extra: KycInvalidFileArgs(validation: validation),
    );
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
        padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 32),
              Text(
                'Ajouter un document',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${type.shortLabel} - JPG, PNG ou PDF - 5 Mo max - document lisible.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 30),
              _UploadOption(
                icon: Icons.camera_alt_outlined,
                title: 'Prendre une photo',
                subtitle: 'Utiliser la camera',
                onTap: () async => Navigator.of(
                  context,
                ).pop(await _pickImage(type, ImageSource.camera)),
              ),
              const SizedBox(height: 16),
              _UploadOption(
                icon: Icons.image_outlined,
                title: 'Choisir dans la galerie',
                subtitle: 'Photos existantes',
                onTap: () async => Navigator.of(
                  context,
                ).pop(await _pickImage(type, ImageSource.gallery)),
              ),
              const SizedBox(height: 16),
              _UploadOption(
                icon: Icons.description_outlined,
                title: 'Importer un PDF',
                subtitle: 'Depuis vos fichiers',
                onTap: () async =>
                    Navigator.of(context).pop(await _pickPdf(type)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadOption extends StatelessWidget {
  final IconData icon;
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
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDDE3DA)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<KycFileDraft?> _pickImage(
  KycDocumentType type,
  ImageSource source,
) async {
  final file = await ImagePicker().pickImage(source: source, imageQuality: 88);
  if (file == null) return null;
  final size = await file.length();
  final name = file.name.isEmpty
      ? '${type.apiValue.toLowerCase()}.jpg'
      : file.name;
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
          ? 'Taille trop grande (${_formatSize(size)} > 5 Mo)'
          : 'Taille inferieure a 5 Mo',
    ),
    _IssueRowData(
      issue: KycFileIssue.unreadable,
      passed:
          !issues.contains(KycFileIssue.unreadable) &&
          !issues.contains(KycFileIssue.empty),
      detail: 'Document lisible et non vide',
    ),
    _IssueRowData(
      issue: KycFileIssue.unsupportedFormat,
      passed: !issues.contains(KycFileIssue.unsupportedFormat),
      detail: extension.isEmpty
          ? 'Format accepte (JPG, PNG, PDF)'
          : 'Format accepte ($extension)',
    ),
  ];
}

String _mimeTypeFromName(String name, {required String fallback}) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.pdf')) return 'application/pdf';
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  return fallback;
}

String _formatSize(int bytes) {
  if (bytes <= 0) return '0 Mo';
  final mb = bytes / (1024 * 1024);
  return '${mb.toStringAsFixed(mb >= 10 ? 0 : 1)} Mo';
}

String _formatShortDate(DateTime? date) {
  if (date == null) return 'recemment';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String _statusLabel(KycDocumentStatus status) {
  return switch (status) {
    KycDocumentStatus.accepted => 'Valide',
    KycDocumentStatus.pendingReview => 'En attente',
    KycDocumentStatus.rejected => 'Rejete',
    KycDocumentStatus.expired => 'Expire',
    KycDocumentStatus.uploaded || KycDocumentStatus.encrypted => 'Fourni',
    KycDocumentStatus.missing || KycDocumentStatus.unknown => 'A fournir',
  };
}

Color _statusColor(KycDocumentStatus status) {
  return switch (status) {
    KycDocumentStatus.accepted => AppColors.primary,
    KycDocumentStatus.pendingReview => const Color(0xFF9B6B0B),
    KycDocumentStatus.rejected => const Color(0xFFC62828),
    KycDocumentStatus.expired => const Color(0xFFC62828),
    KycDocumentStatus.uploaded ||
    KycDocumentStatus.encrypted => AppColors.primary,
    KycDocumentStatus.missing ||
    KycDocumentStatus.unknown => AppColors.textTertiary,
  };
}
