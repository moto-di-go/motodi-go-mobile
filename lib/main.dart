import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/l10n/app_locale_controller.dart';
import 'package:motodi_go_mobile/core/services/notification_service.dart';
import 'package:motodi_go_mobile/core/theme/app_theme.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/kyc/presentation/pages/kyc_pages.dart';
import 'package:motodi_go_mobile/l10n/app_localizations.dart';
import 'package:motodi_go_mobile/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await configureDependencies();

  if (kDebugMode) {
    Bloc.observer = _AppBlocObserver();
  }

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final SessionCubit _sessionCubit;
  late final GoRouter _router;
  late final AppLocaleController _localeController;

  @override
  void initState() {
    super.initState();
    _localeController = AppLocaleController()..load();
    _sessionCubit = getIt<SessionCubit>();
    _router = createAppRouter(_sessionCubit);
    _sessionCubit.bootstrap();
    _initializeNotifications();
  }

  @override
  void dispose() {
    _router.dispose();
    _localeController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    try {
      if (Firebase.apps.isEmpty) {
        // Prefer DefaultFirebaseOptions after `flutterfire configure`
        // (copy lib/firebase_options.dart.example → lib/firebase_options.dart).
        // See docs/FIREBASE_SETUP.md
        await Firebase.initializeApp();
      }
      await getIt<NotificationService>().initialize(
        onKycDecision: (payload) {
          unawaited(_handleKycDecision(payload));
        },
        onDeepLink: (link) {
          final context = rootNavigatorKey.currentContext;
          if (context == null) return;
          switch (link.kind) {
            case NotificationDeepLinkKind.kyc:
              unawaited(_sessionCubit.refreshAfterProfileChange());
              break;
            case NotificationDeepLinkKind.booking:
              if (link.bookingId != null) {
                context.push(RouteConstants.intercityBookingPath(link.bookingId!));
              } else {
                context.go(RouteConstants.intercity);
              }
            case NotificationDeepLinkKind.payment:
              if (link.bookingId != null) {
                context.push(RouteConstants.walletPayPath(link.bookingId!));
              } else {
                context.go(RouteConstants.wallet);
              }
            case NotificationDeepLinkKind.trip:
              if (link.tripId != null) {
                context.push(RouteConstants.tripTrackPath(link.tripId!));
              } else if (link.bookingId != null) {
                context.push(RouteConstants.intercityBookingPath(link.bookingId!));
              }
            case NotificationDeepLinkKind.wallet:
              context.go(RouteConstants.wallet);
            case NotificationDeepLinkKind.unknown:
              break;
          }
        },
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Notifications disabled: $error');
      }
    }
  }

  Future<void> _handleKycDecision(KycNotificationPayload payload) async {
    await _sessionCubit.refreshAfterProfileChange();
    final context = rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.go(RouteConstants.kycNotification, extra: payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      controller: _localeController,
      child: BlocProvider.value(
        value: _sessionCubit,
        child: AnimatedBuilder(
          animation: _localeController,
          builder: (context, _) {
            return MaterialApp.router(
              title: "Moto'di Go",
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: ThemeMode.light,
              routerConfig: _router,
              locale: _localeController.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      ),
    );
  }
}

class _AppBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('[BLoC ERROR] ${bloc.runtimeType}: $error');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint(
      '[BLoC] ${bloc.runtimeType}: ${transition.event.runtimeType} -> '
      '${transition.nextState.runtimeType}',
    );
  }
}
