import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_figma_icons.dart';

TextStyle _tabText({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = const Color(0xFF101512),
  double? height,
}) {
  return GoogleFonts.outfit(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
  );
}

/// Placeholder Wallet — page réelle à brancher plus tard.
class WalletTabPage extends StatelessWidget {
  const WalletTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderTabScaffold(
      title: 'Wallet',
      message: 'Le portefeuille arrive bientôt.',
    );
  }
}

class _PlaceholderTabScaffold extends StatelessWidget {
  final String title;
  final String message;

  const _PlaceholderTabScaffold({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: _tabText(fontSize: 32, fontWeight: FontWeight.w800, height: 1.1),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MotodigoSearchEmptyIcon(size: 96),
                      const SizedBox(height: 28),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: _tabText(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF54615A),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
