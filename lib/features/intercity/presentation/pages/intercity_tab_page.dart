import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/home/presentation/pages/main_shell.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/pages/publish_pages.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/pages/search_pages.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';

/// Onglet Trajets (passager) ou Mes annonces (transporteur / agence / mototaxi).
class IntercityTabPage extends StatelessWidget {
  const IntercityTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      buildWhen: (previous, next) =>
          previous.activeProfile?.type != next.activeProfile?.type ||
          previous.activeProfile?.id != next.activeProfile?.id,
      builder: (context, state) {
        final type = state.activeProfile?.type ?? ProfileType.passenger;
        if (MainShell.usesAnnouncementsTab(type)) {
          return const IntercityMyAnnouncementsPage();
        }
        return const IntercityHubPage();
      },
    );
  }
}
