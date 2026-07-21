import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/auth_validators.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_fields.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/cubit/profile_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_widgets.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';

class PassengerProfilePage extends StatelessWidget {
  const PassengerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<ProfileCubit>(), child: const _PassengerProfileView());
  }
}

class _PassengerProfileView extends StatefulWidget {
  const _PassengerProfileView();

  @override
  State<_PassengerProfileView> createState() => _PassengerProfileViewState();
}

class _PassengerProfileViewState extends State<_PassengerProfileView> {
  final _emergencyController = TextEditingController();
  String _language = 'fr';

  @override
  void dispose() {
    _emergencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionCubit>().state.session;
    final displayName = session?.phoneNumber ?? 'Passager';
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) async {
        if (state.isSaved) {
          await context.read<SessionCubit>().refreshAfterProfileChange();
          if (context.mounted) context.go(RouteConstants.home);
        }
      },
      builder: (context, state) {
        return AuthScaffold(
          title: 'Profil passager',
          showBack: true,
          bottom: PrimaryAuthButton(
            label: 'Terminer',
            isLoading: state.isLoading,
            onPressed: () => context.read<ProfileCubit>().createPassenger(
              displayName: displayName,
              preferredLanguage: _language,
              emergencyContact: _normalizedEmergencyContact(),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF5E6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(profileIcon(ProfileType.passenger), color: AppColors.primary, size: 40),
              ),
              const SizedBox(height: 40),
              Text(
                'Quelques préférences pour finaliser votre profil passager.',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760), height: 1.45),
              ),
              const SizedBox(height: 34),
              const FieldLabel('Langue préférée'),
              DropdownButtonFormField<String>(
                initialValue: _language,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.language_rounded)),
                items: const [
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (value) => setState(() => _language = value ?? 'fr'),
              ),
              const SizedBox(height: 28),
              const FieldLabel("Contact d'urgence", suffix: 'optionnel'),
              CameroonPhoneInput(controller: _emergencyController, hintText: "Numéro d'un proche"),
              InlineError(state.errorMessage),
            ],
          ),
        );
      },
    );
  }

  String? _normalizedEmergencyContact() {
    final raw = _emergencyController.text.trim();
    if (raw.isEmpty) return null;
    return CameroonPhoneValidator.normalize(raw);
  }
}
