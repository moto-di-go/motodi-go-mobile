import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';

/// Shows a modal dialog when a guest user tries to perform a protected action.
///
/// Returns `true` if the user is authenticated (action allowed),
/// `false` if the user is a guest (dialog shown, action blocked).
///
/// After sign-in, [SessionCubit.takePostAuthDestination] restores this screen.
///
/// Usage:
/// ```dart
/// if (!guardGuestAction(context)) return;
/// // proceed with protected action
/// ```
bool guardGuestAction(BuildContext context) {
  final sessionCubit = context.read<SessionCubit>();
  if (sessionCubit.state.isAuthenticated) return true;

  _rememberReturnLocation(context, sessionCubit);
  showDialog<void>(
    context: context,
    builder: (ctx) => const _GuestBlockerDialog(),
  );
  return false;
}

void _rememberReturnLocation(BuildContext context, SessionCubit sessionCubit) {
  final goState = GoRouterState.of(context);
  var location = goState.uri.toString();
  final extra = goState.extra;
  final onDetail =
      goState.matchedLocation == RouteConstants.intercityDetail ||
      goState.uri.path == RouteConstants.intercityDetail;
  if (onDetail && extra is String && extra.isNotEmpty && !goState.uri.queryParameters.containsKey('id')) {
    location = RouteConstants.intercityDetailPath(extra);
  }
  sessionCubit.rememberReturnLocation(location);
}

class _GuestBlockerDialog extends StatelessWidget {
  const _GuestBlockerDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Action non disponible'.tr(context),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Vous devez vous connecter ou créer un compte pour effectuer cette action.'.tr(context),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7770),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push(RouteConstants.register);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: Text(
                  'Créer un compte'.tr(context),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push(RouteConstants.login);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: Color(0xFFDEE2DA)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: Text(
                  'Se connecter'.tr(context),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
