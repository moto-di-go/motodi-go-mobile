import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_template_app/di/injection.config.dart';

// Rôle : Point d'entrée de l'injection de dépendances via GetIt + Injectable.
// Dépendances : get_it, injectable
// Génération : dart run build_runner build
final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
