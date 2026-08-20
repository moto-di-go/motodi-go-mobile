import 'package:chopper/chopper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_remote_datasource.dart';
import 'package:motodi_go_mobile/features/urban/presentation/driver_availability_cubit.dart';

class DriverAvailabilityPage extends StatelessWidget {
  const DriverAvailabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DriverAvailabilityCubit(UrbanRemoteDataSource(getIt<ChopperClient>())),
      child: const _DriverAvailabilityView(),
    );
  }
}

class _DriverAvailabilityView extends StatelessWidget {
  const _DriverAvailabilityView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Disponibilite conducteur')),
      body: BlocBuilder<DriverAvailabilityCubit, DriverAvailabilityState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('Etat: ${state.availability}', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(state.sharing ? 'GPS diffuse toutes les 5 secondes' : 'Diffusion GPS arretee'),
              const SizedBox(height: 8),
              Text('GPS: ${state.gpsOk ? 'OK' : 'inactif'} · Consentement: ${state.gpsConsent ? 'oui' : 'non'}'),
              if (state.lastSentAt != null) Text('Dernier envoi: ${state.lastSentAt}'),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.read<DriverAvailabilityCubit>().setAvailability(
                      'AVAILABLE',
                      gpsConsent: true,
                    ),
                child: const Text('Passer disponible'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => context.read<DriverAvailabilityCubit>().setAvailability(
                      'OCCUPIED',
                      gpsConsent: true,
                    ),
                child: const Text('Occupe'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.read<DriverAvailabilityCubit>().setAvailability(
                      'OFFLINE',
                      gpsConsent: true,
                    ),
                child: const Text('Hors ligne'),
              ),
            ],
          );
        },
      ),
    );
  }
}
