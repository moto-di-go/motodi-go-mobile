import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
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
  ProfileType _selectedType = ProfileType.passenger;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) async {
        if (state.isSaved) {
          await context.read<SessionCubit>().refreshAfterProfileChange();
          if (context.mounted) context.go(RouteConstants.home);
        }
      },
      builder: (context, state) {
        return AuthScaffold(
          scrollable: false,
          bottom: PrimaryAuthButton(
            label: 'Continuer',
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
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  "Vous pourrez en ajouter d'autres à tout moment.",
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760), height: 1.4),
                ),
                const SizedBox(height: 48),
                if (state.status == ProfileStatus.loading)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
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
                          selected: _selectedType == type,
                          onTap: () => setState(() => _selectedType = type),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    state.errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w800),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _continue(BuildContext context, ProfileState state) {
    final profile = _profileOf(state.profiles, _selectedType);
    if (profile == null) {
      final path = switch (_selectedType) {
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
