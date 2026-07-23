import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_fields.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/cubit/profile_cubit.dart';

class MotoTaxiProfilePage extends StatelessWidget {
  const MotoTaxiProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>(),
      child: const _MotoTaxiProfileView(),
    );
  }
}

class _MotoTaxiProfileView extends StatefulWidget {
  const _MotoTaxiProfileView();

  @override
  State<_MotoTaxiProfileView> createState() => _MotoTaxiProfileViewState();
}

class _MotoTaxiProfileViewState extends State<_MotoTaxiProfileView> {
  final _nameController = TextEditingController(text: 'Ibrahim M.');
  final _zoneController = TextEditingController(text: 'Bastos, Yaoundé');
  final _licenseController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _zoneController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: _onSaved,
      builder: (context, state) {
        return AuthScaffold(
          title: 'Profil mototaxi',
          showBack: true,
          bottom: PrimaryAuthButton(
            label: 'Continuer vers la validation',
            trailingIcon: Icons.arrow_forward_rounded,
            isLoading: state.isLoading,
            onPressed: () => context.read<ProfileCubit>().createMotoTaxi(
              displayName: _nameController.text,
              operatingZone: _zoneController.text,
              licenseNumber: _licenseController.text.trim().isEmpty
                  ? null
                  : _licenseController.text.trim(),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ValidationNotice(
                text:
                    "Validation obligatoire : vos documents seront vérifiés avant l'activation.",
              ),
              const SizedBox(height: 36),
              const FieldLabel('Nom affiché'),
              AuthTextField(controller: _nameController),
              const SizedBox(height: 28),
              const FieldLabel("Zone d'activité"),
              AuthTextField(
                controller: _zoneController,
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 28),
              const FieldLabel('N° de permis', suffix: 'si disponible'),
              AuthTextField(
                controller: _licenseController,
                hintText: 'CM-YDE-000000',
              ),
              InlineError(state.errorMessage),
            ],
          ),
        );
      },
    );
  }
}

class TransporterProfilePage extends StatelessWidget {
  const TransporterProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>(),
      child: const _TransporterProfileView(),
    );
  }
}

class _TransporterProfileView extends StatefulWidget {
  const _TransporterProfileView();

  @override
  State<_TransporterProfileView> createState() =>
      _TransporterProfileViewState();
}

class _TransporterProfileViewState extends State<_TransporterProfileView> {
  final _companyController = TextEditingController(
    text: 'Express Voyages SARL',
  );
  final _permitController = TextEditingController();

  @override
  void dispose() {
    _companyController.dispose();
    _permitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: _onSaved,
      builder: (context, state) {
        return AuthScaffold(
          title: 'Profil transporteur',
          showBack: true,
          bottom: PrimaryAuthButton(
            label: 'Continuer vers la validation',
            trailingIcon: Icons.arrow_forward_rounded,
            isLoading: state.isLoading,
            onPressed: () => context.read<ProfileCubit>().createTransporter(
              companyName: _companyController.text,
              permitNumber: _permitController.text.trim().isEmpty
                  ? null
                  : _permitController.text.trim(),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ValidationNotice(
                text:
                    'Agrément et documents véhicule requis pour la validation.',
              ),
              const SizedBox(height: 36),
              const FieldLabel('Nom commercial'),
              AuthTextField(controller: _companyController),
              const SizedBox(height: 28),
              const FieldLabel("N° d'agrément / permis"),
              AuthTextField(
                controller: _permitController,
                hintText: 'Ex. AGR-2024-01234',
              ),
              const SizedBox(height: 28),
              const FieldLabel('Véhicule'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFDDE3DA),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.upload_rounded, color: Color(0xFFA8B0AA)),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        "Ajout possible à l'étape KYC",
                        style: TextStyle(
                          color: Color(0xFFA8B0AA),
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      'Bientôt',
                      style: TextStyle(
                        color: Color(0xFFA8B0AA),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              InlineError(state.errorMessage),
            ],
          ),
        );
      },
    );
  }
}

Future<void> _onSaved(BuildContext context, ProfileState state) async {
  if (state.isSaved) {
    await context.read<SessionCubit>().refreshAfterProfileChange();
    if (!context.mounted) return;
    context.go(RouteConstants.home);
  }
}

class _ValidationNotice extends StatelessWidget {
  final String text;

  const _ValidationNotice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4CB),
        border: Border.all(color: const Color(0xFFF3D77B)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF9B6B0B)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF9B6B0B),
                fontWeight: FontWeight.w900,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
