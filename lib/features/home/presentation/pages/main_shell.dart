import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/core/widgets/app_exit_scope.dart';
import 'package:motodi_go_mobile/core/widgets/guest_action_blocker.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/home/presentation/widgets/app_bottom_navigation.dart';
import 'package:motodi_go_mobile/features/offline/presentation/widgets/offline_widgets.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_type.dart';

/// Shell principal : conserve la tab bar sur Accueil / Trajets|Annonces / Wallet / Notifs / Profil.
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  static bool usesAnnouncementsTab(ProfileType type) {
    return type == ProfileType.transporter ||
        type == ProfileType.agency ||
        type == ProfileType.mototaxi;
  }

  @override
  Widget build(BuildContext context) {
    return AppExitScope(
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, state) {
          final type = state.activeProfile?.type ?? ProfileType.passenger;
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                const OfflineBanner(),
                Expanded(child: navigationShell),
              ],
            ),
            bottomNavigationBar: AppBottomNavigation(
              selectedIndex: navigationShell.currentIndex,
              tripsTabLabel: usesAnnouncementsTab(type)
                  ? 'Annonces'.tr(context)
                  : 'Trajets'.tr(context),
              onSelected: (index) {
                // Wallet (2), Notifs (3), Profil (4) are blocked for guests
                if (state.isGuest && index >= 2) {
                  guardGuestAction(context);
                  return;
                }
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
