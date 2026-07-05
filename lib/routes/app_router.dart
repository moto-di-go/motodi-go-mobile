import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_template_app/core/constants/route_constants.dart';
import 'package:flutter_template_app/features/example/presentation/pages/example_list_page.dart';
import 'package:flutter_template_app/features/example/presentation/pages/example_detail_page.dart';

// Rôle : Configuration centralisée de la navigation avec GoRouter.
// Dépendances : go_router, flutter_bloc
// TODO: [TEMPLATE] Remplacer les routes d'exemple par vos propres routes.
// Pour ajouter une route : ajouter un GoRoute dans la liste routes.

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteConstants.splash,
  debugLogDiagnostics: true,
  redirect: (context, state) {
    // TODO: [TEMPLATE] Ajouter ici la logique de garde (auth check, deep links, etc.)
    // Exemple :
    // final authState = context.read<AuthBloc>().state;
    // final isLoggedIn = authState.status == AuthStatus.authenticated;
    // final isGoingToLogin = state.matchedLocation == RouteConstants.login;
    // if (!isLoggedIn && !isGoingToLogin) return RouteConstants.login;
    return null;
  },
  routes: [
    GoRoute(path: RouteConstants.splash, builder: (context, state) => const _SplashPage()),
    GoRoute(
      path: RouteConstants.login,
      builder: (context, state) => const _PlaceholderPage(title: 'Connexion'),
    ),
    // === Feature d'exemple ===
    GoRoute(
      path: RouteConstants.exampleList,
      builder: (context, state) => const ExampleListPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ExampleDetailPage(itemId: id);
          },
        ),
      ],
    ),
    // TODO: [TEMPLATE] Ajouter vos routes ici
  ],
);

class _SplashPage extends StatefulWidget {
  const _SplashPage();

  @override
  State<_SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<_SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go(RouteConstants.exampleList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: [TEMPLATE] Remplacer par votre logo
            const FlutterLogo(size: 80),
            const SizedBox(height: 16),
            Text('Flutter Template App', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title — Page à implémenter')),
    );
  }
}
