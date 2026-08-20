import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/features/urban/presentation/pages/urban_ride_page.dart';

/// Deep link `/urban/map` : même parcours passager que `/home`.
class UrbanMapPage extends StatelessWidget {
  const UrbanMapPage({super.key});

  @override
  Widget build(BuildContext context) => const UrbanRidePage();
}
