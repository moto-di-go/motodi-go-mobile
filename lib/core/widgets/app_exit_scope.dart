import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';

/// Intercepte le bouton retour système : dépile si possible, sinon demande
/// de confirmer la sortie de l'application.
class AppExitScope extends StatelessWidget {
  final Widget child;

  const AppExitScope({super.key, required this.child});

  static Future<bool> confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Quitter l\'application ?'.tr(context)),
        content: Text('Voulez-vous vraiment quitter Moto\'di Go ?'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Annuler'.tr(context)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Quitter'.tr(context)),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final router = GoRouter.maybeOf(context);
        if (router != null && router.canPop()) {
          router.pop();
          return;
        }
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          return;
        }
        final shouldExit = await confirmExit(context);
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: child,
    );
  }
}
