import 'package:flutter/material.dart';

// Rôle : Indicateur de chargement centré standardisé.
class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
