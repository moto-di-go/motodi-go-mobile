import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_template_app/di/injection.dart';
import 'package:flutter_template_app/core/theme/app_theme.dart';
import 'package:flutter_template_app/routes/app_router.dart';
import 'package:flutter_template_app/l10n/app_localizations.dart';

// TODO: [TEMPLATE] Importer firebase_options.dart généré par FlutterFire CLI
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Chargement des variables d'environnement
  await dotenv.load(fileName: '.env');

  // Initialisation Firebase
  // TODO: [TEMPLATE] Décommenter après avoir configuré Firebase
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  // Configuration de l'injection de dépendances
  await configureDependencies();

  // Initialisation des services globaux
  // TODO: [TEMPLATE] Décommenter après configuration Firebase
  // await getIt<NotificationService>().initialize();

  // Observateur BLoC global (debug / analytics)
  // TODO: [TEMPLATE] Remplacer par AnalyticsBlocObserver si analytics activés
  if (kDebugMode) {
    Bloc.observer = _AppBlocObserver();
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // TODO: [TEMPLATE] Remplacer par le nom de votre application
      title: 'Flutter Template App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      // TODO: [TEMPLATE] Configurer le thème par défaut (light / dark / system)
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
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
      '[BLoC] ${bloc.runtimeType}: ${transition.event.runtimeType} -> ${transition.nextState.runtimeType}',
    );
  }
}
