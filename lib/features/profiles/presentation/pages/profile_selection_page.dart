import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/user_profile.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/cubit/profile_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_widgets.dart';

class ProfileSelectionPage extends StatelessWidget {
  const ProfileSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..loadProfiles(),
      child: const _ProfileSelectionView(),
    );
  }
}

class _ProfileSelectionView extends StatefulWidget {
  const _ProfileSelectionView();

  @override
  State<_ProfileSelectionView> createState() => _ProfileSelectionViewState();
}

class _ProfileSelectionViewState extends State<_ProfileSelectionView> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) async {
        if (state.isSaved) {
          await context.read<SessionCubit>().refreshAfterProfileChange();
          if (context.mounted) context.go(RouteConstants.home);
        } else if (state.status == ProfileStatus.failure &&
            state.errorMessage != null &&
            state.profiles.isNotEmpty) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Impossible de continuer pour le moment.'),
              ),
            );
        }
      },
      builder: (context, state) {
        return AuthScaffold(
          scrollable: false,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          bottom: _ProfileContinueButton(
            isLoading: state.status == ProfileStatus.saving,
            onPressed: () => _continue(context, state),
          ),
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 42),
                Text(
                  'Choisissez votre profil',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Vous pourrez en ajouter d'autres à tout moment.",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF54615A),
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 42),
                if (state.status == ProfileStatus.loading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.status == ProfileStatus.failure &&
                    state.profiles.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Impossible de charger vos profils.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF54615A),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (final type in const [
                        ProfileType.passenger,
                        ProfileType.mototaxi,
                        ProfileType.transporter,
                      ]) ...[
                        ProfileChoiceCard(
                          type: type,
                          profile: _profileOf(state.profiles, type),
                          selected: state.selectedType == type,
                          onTap: () =>
                              context.read<ProfileCubit>().selectType(type),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _continue(BuildContext context, ProfileState state) {
    final selectedType = state.selectedType;
    final profile = _profileOf(state.profiles, selectedType);
    if (profile == null) {
      final path = switch (selectedType) {
        ProfileType.passenger => RouteConstants.profilePassenger,
        ProfileType.mototaxi => RouteConstants.profileMototaxi,
        ProfileType.transporter => RouteConstants.profileTransporter,
        _ => RouteConstants.profileSelection,
      };
      context.go(path);
      return;
    }
    if (profile.validationStatus == ValidationStatus.suspended) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ce profil est suspendu.')));
      return;
    }
    if (profile.active) {
      context.go(RouteConstants.home);
      return;
    }
    context.read<ProfileCubit>().activateProfile(profile.id);
  }

  UserProfile? _profileOf(List<UserProfile> profiles, ProfileType type) {
    for (final profile in profiles) {
      if (profile.type == type) return profile;
    }
    return null;
  }
}

class _ProfileContinueButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _ProfileContinueButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.62),
          elevation: 10,
          shadowColor: AppColors.primary.withValues(alpha: 0.34),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.7,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Continuer',
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
