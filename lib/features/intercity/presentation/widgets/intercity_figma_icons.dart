import 'package:flutter/material.dart';

// Role : Icones vectorielles (CustomPaint) du module intercity, dans le style
// des icones Motodigo*Icon existantes (home_figma_icons.dart, profile_figma_icons.dart).

/// Figma `location-green` — pin outline vert sur pastille #E4F3E9.
class MotodigoLocationGreenIcon extends StatelessWidget {
  final double size;
  const MotodigoLocationGreenIcon({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE4F3E9),
        borderRadius: BorderRadius.circular(size * 0.29),
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size.square(size * 0.48),
        painter: const _LocationPinStrokePainter(Color(0xFF0F7A35)),
      ),
    );
  }
}

/// Figma `location-red` — pin outline rouge sur pastille #FBE7E7.
class MotodigoLocationRedIcon extends StatelessWidget {
  final double size;
  const MotodigoLocationRedIcon({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFBE7E7),
        borderRadius: BorderRadius.circular(size * 0.29),
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size.square(size * 0.48),
        painter: const _LocationPinStrokePainter(Color(0xFFC23B3B)),
      ),
    );
  }
}

/// Alias compact (pin seul) pour les cartes résultats.
class MotodigoPinGreenIcon extends StatelessWidget {
  final double size;
  const MotodigoPinGreenIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _LocationPinStrokePainter(Color(0xFF16A34A)),
    );
  }
}

class MotodigoPinRedIcon extends StatelessWidget {
  final double size;
  const MotodigoPinRedIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _LocationPinStrokePainter(Color(0xFFEF4444)),
    );
  }
}

/// Figma `date-gray` — calendrier outline gris.
class MotodigoDateGrayIcon extends StatelessWidget {
  final double size;
  const MotodigoDateGrayIcon({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _CalendarPainter(Color(0xFF8A968C)),
    );
  }
}

/// Figma `building-gray` — immeuble outline gris (carte transporteur).
class MotodigoBuildingGrayIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoBuildingGrayIcon({
    super.key,
    this.size = 22,
    this.color = const Color(0xFF8A968C),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _BuildingGrayPainter(color));
  }
}

class MotodigoCalendarIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoCalendarIcon({super.key, this.size = 24, this.color = const Color(0xFF8A968C)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _CalendarPainter(color));
  }
}

class MotodigoClockIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoClockIcon({super.key, this.size = 24, this.color = const Color(0xFF5B6760)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _ClockPainter(color));
  }
}

/// Figma `people-gray` — deux silhouettes outline grises.
class MotodigoPeopleGrayIcon extends StatelessWidget {
  final double size;
  const MotodigoPeopleGrayIcon({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _PeoplePainter(Color(0xFF8A968C)),
    );
  }
}

class MotodigoPeopleIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoPeopleIcon({super.key, this.size = 24, this.color = const Color(0xFF8A968C)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _PeoplePainter(color));
  }
}

/// Figma `list-black` — liste à puces (souvent blanc sur bouton noir actif).
class MotodigoListBlackIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoListBlackIcon({super.key, this.size = 16, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _ListPainter(color));
  }
}

class MotodigoListIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoListIcon({super.key, this.size = 24, this.color = const Color(0xFF101512)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _ListPainter(color));
  }
}

/// Figma `location-gray` — pin outline gris.
class MotodigoLocationGrayIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoLocationGrayIcon({
    super.key,
    this.size = 16,
    this.color = const Color(0xFF8A968C),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _LocationPinStrokePainter(color),
    );
  }
}

class MotodigoMapPinIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoMapPinIcon({super.key, this.size = 24, this.color = const Color(0xFF8A968C)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _LocationPinStrokePainter(color));
  }
}

class MotodigoVerifiedIcon extends StatelessWidget {
  final double size;
  const MotodigoVerifiedIcon({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: const _VerifiedPainter());
  }
}

class MotodigoWalletYellowIcon extends StatelessWidget {
  final double size;
  const MotodigoWalletYellowIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _WalletYellowPainter(Color(0xFFEAB308)),
    );
  }
}

class MotodigoCheckCircleGreenIcon extends StatelessWidget {
  final double size;
  const MotodigoCheckCircleGreenIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: const _CheckCirclePainter(Color(0xFF16A34A)));
  }
}

class MotodigoLockIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoLockIcon({super.key, this.size = 24, this.color = const Color(0xFF9AA49D)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _LockPainter(color));
  }
}

class MotodigoCancelRedIcon extends StatelessWidget {
  final double size;
  const MotodigoCancelRedIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: const _CrossCirclePainter(Color(0xFFEF4444)));
  }
}

class MotodigoAcceptGreenIcon extends StatelessWidget {
  final double size;
  const MotodigoAcceptGreenIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: const _CheckCirclePainter(Color(0xFF16A34A)));
  }
}

/// Figma `loupe-gray` — loupe outline grise (sans pastille).
class MotodigoLoupeGrayIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoLoupeGrayIcon({
    super.key,
    this.size = 38,
    this.color = const Color(0xFF9AA49D),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _LoupeGrayPainter(color));
  }
}

/// Figma `right-arrow-gray` — flèche droite fine grise (trajets / sous-titres).
class MotodigoRightArrowGrayIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoRightArrowGrayIcon({
    super.key,
    this.size = 14,
    this.color = const Color(0xFF54615A),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 1.15, size),
      painter: _RightArrowGrayPainter(color),
    );
  }
}

/// Pastille empty-state (cercle #F1F1EA + [MotodigoLoupeGrayIcon]).
class MotodigoSearchEmptyIcon extends StatelessWidget {
  final double size;
  const MotodigoSearchEmptyIcon({super.key, this.size = 78});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1EA),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: MotodigoLoupeGrayIcon(size: size * 0.49),
    );
  }
}

class MotodigoBellGreenIcon extends StatelessWidget {
  final double size;
  const MotodigoBellGreenIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: const _BellPainter(Color(0xFF16A34A)));
  }
}

class MotodigoShareIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoShareIcon({super.key, this.size = 24, this.color = const Color(0xFF101512)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _SharePainter(color));
  }
}

class MotodigoVanIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoVanIcon({super.key, this.size = 24, this.color = const Color(0xFF16A34A)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _VanPainter(color));
  }
}

class MotodigoChevronDownIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoChevronDownIcon({super.key, this.size = 20, this.color = const Color(0xFF5B6760)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _ChevronDownPainter(color));
  }
}

class MotodigoDocumentIcon extends StatelessWidget {
  final double size;
  final Color color;
  const MotodigoDocumentIcon({super.key, this.size = 24, this.color = const Color(0xFF101512)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _DocumentPainter(color));
  }
}

// Boutons +/- reutilisables pour les steppers (sieges, etc.) via Icons.add/remove.
class MotodigoStepperButton extends StatelessWidget {
  final bool increment;
  final VoidCallback? onTap;
  final bool enabled;

  const MotodigoStepperButton({
    super.key,
    required this.increment,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? const Color(0xFF101512) : const Color(0xFFB9C1B7);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2ED),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(increment ? Icons.add_rounded : Icons.remove_rounded, color: color),
      ),
    );
  }
}

// --- Painters ---

/// Pin location stroke (trou central) — Figma location-green / location-red.
class _LocationPinStrokePainter extends CustomPainter {
  final Color color;
  const _LocationPinStrokePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 24, 24, (canvas) {
      final paint = _strokePaint(color, 1.8);
      final pin = Path()
        ..moveTo(12, 3)
        ..cubicTo(8.13, 3, 5, 6.13, 5, 10)
        ..cubicTo(5, 15.25, 12, 21, 12, 21)
        ..cubicTo(12, 21, 19, 15.25, 19, 10)
        ..cubicTo(19, 6.13, 15.87, 3, 12, 3)
        ..close();
      canvas.drawPath(pin, paint);
      canvas.drawCircle(const Offset(12, 10), 2.6, paint);
    });
  }

  @override
  bool shouldRepaint(covariant _LocationPinStrokePainter oldDelegate) => oldDelegate.color != color;
}

class _BuildingGrayPainter extends CustomPainter {
  final Color color;
  const _BuildingGrayPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 24, 24, (canvas) {
      final paint = _strokePaint(color, 1.8);
      // Corps principal
      canvas.drawPath(
        Path()
          ..moveTo(5, 20.5)
          ..lineTo(5, 7.5)
          ..lineTo(12, 3.5)
          ..lineTo(19, 7.5)
          ..lineTo(19, 20.5)
          ..close(),
        paint,
      );
      // Porte
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(10, 14.5, 4, 6), const Radius.circular(1)),
        paint,
      );
      // Fenêtres (traits simples, pas une grille remplie)
      canvas.drawLine(const Offset(7.5, 10), const Offset(9.5, 10), paint);
      canvas.drawLine(const Offset(14.5, 10), const Offset(16.5, 10), paint);
      canvas.drawLine(const Offset(7.5, 13), const Offset(9.5, 13), paint);
      canvas.drawLine(const Offset(14.5, 13), const Offset(16.5, 13), paint);
    });
  }

  @override
  bool shouldRepaint(covariant _BuildingGrayPainter oldDelegate) => oldDelegate.color != color;
}

class _CalendarPainter extends CustomPainter {
  final Color color;
  const _CalendarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 24, 24, (canvas) {
      final paint = _strokePaint(color, 1.7);
      final rect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(3, 5, 18, 16),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);
      canvas.drawLine(const Offset(3, 10), const Offset(21, 10), paint);
      canvas.drawLine(const Offset(8, 2.5), const Offset(8, 7), paint);
      canvas.drawLine(const Offset(16, 2.5), const Offset(16, 7), paint);
    });
  }

  @override
  bool shouldRepaint(covariant _CalendarPainter oldDelegate) => oldDelegate.color != color;
}

class _ClockPainter extends CustomPainter {
  final Color color;
  const _ClockPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 24, 24, (canvas) {
      final paint = _strokePaint(color, 1.7);
      canvas.drawCircle(const Offset(12, 12), 9, paint);
      canvas.drawPath(
        Path()
          ..moveTo(12, 7)
          ..lineTo(12, 12)
          ..lineTo(15.5, 14),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) => oldDelegate.color != color;
}

class _PeoplePainter extends CustomPainter {
  final Color color;
  const _PeoplePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 24, 24, (canvas) {
      final paint = _strokePaint(color, 1.7);
      canvas.drawCircle(const Offset(9, 8), 3, paint);
      canvas.drawPath(
        Path()
          ..moveTo(3, 20)
          ..cubicTo(3, 16.5, 5.5, 14.5, 9, 14.5)
          ..cubicTo(12.5, 14.5, 15, 16.5, 15, 20),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(15.5, 6.2)
          ..cubicTo(16.9, 6.6, 18, 7.9, 18, 9.5)
          ..cubicTo(18, 11.1, 16.9, 12.4, 15.5, 12.8),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(16.5, 14.8)
          ..cubicTo(19.2, 15.3, 21, 17.2, 21, 20),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _PeoplePainter oldDelegate) => oldDelegate.color != color;
}

class _ListPainter extends CustomPainter {
  final Color color;
  const _ListPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 24, 24, (canvas) {
      final paint = _strokePaint(color, 1.7);
      for (final y in [6.0, 12.0, 18.0]) {
        canvas.drawCircle(Offset(3.5, y), 1.1, Paint()..color = color);
        canvas.drawLine(Offset(7, y), Offset(21, y), paint);
      }
    });
  }

  @override
  bool shouldRepaint(covariant _ListPainter oldDelegate) => oldDelegate.color != color;
}

class _VerifiedPainter extends CustomPainter {
  const _VerifiedPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 20, 20, (canvas) {
      final fill = Paint()..color = const Color(0xFF16A34A);
      canvas.drawPath(
        Path()
          ..moveTo(10, 1.5)
          ..lineTo(12.2, 3.3)
          ..lineTo(15, 3)
          ..lineTo(15.7, 5.7)
          ..lineTo(18.2, 7)
          ..lineTo(17, 9.5)
          ..lineTo(18.2, 12)
          ..lineTo(15.7, 13.3)
          ..lineTo(15, 16)
          ..lineTo(12.2, 15.7)
          ..lineTo(10, 17.5)
          ..lineTo(7.8, 15.7)
          ..lineTo(5, 16)
          ..lineTo(4.3, 13.3)
          ..lineTo(1.8, 12)
          ..lineTo(3, 9.5)
          ..lineTo(1.8, 7)
          ..lineTo(4.3, 5.7)
          ..lineTo(5, 3)
          ..lineTo(7.8, 3.3)
          ..close(),
        fill,
      );
      final stroke = _strokePaint(Colors.white, 1.6);
      canvas.drawPath(
        Path()
          ..moveTo(6.5, 10)
          ..lineTo(8.8, 12.3)
          ..lineTo(13.5, 7.2),
        stroke,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _VerifiedPainter oldDelegate) => false;
}

/// Wallet rempli style `motodigo-wallet-gray` (home), teinte jaune Figma paiement.
class _WalletYellowPainter extends CustomPainter {
  final Color color;
  const _WalletYellowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 22, 22, (canvas) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawPath(
        Path()
          ..moveTo(18.7091, 9.03835)
          ..cubicTo(18.6557, 9.03587, 18.6022, 9.03496, 18.5487, 9.0356)
          ..lineTo(16.3166, 9.0356)
          ..cubicTo(14.4906, 9.0356, 12.9268, 10.4848, 12.9268, 12.375)
          ..cubicTo(12.9268, 14.2652, 14.4906, 15.7144, 16.3175, 15.7144)
          ..lineTo(18.5478, 15.7144)
          ..cubicTo(18.604, 15.715, 18.6575, 15.7138, 18.7082, 15.7108)
          ..cubicTo(19.085, 15.6863, 19.44, 15.5259, 19.7074, 15.2593)
          ..cubicTo(19.9748, 14.9928, 20.1364, 14.6382, 20.162, 14.2615)
          ..cubicTo(20.1657, 14.2074, 20.1657, 14.1497, 20.1657, 14.0965)
          ..lineTo(20.1657, 10.6535)
          ..cubicTo(20.1657, 10.6003, 20.1657, 10.5426, 20.162, 10.4885)
          ..cubicTo(20.1364, 10.112, 19.975, 9.75751, 19.7078, 9.49097)
          ..cubicTo(19.4406, 9.22443, 19.0857, 9.06393, 18.7091, 9.03927)
          ..moveTo(16.1213, 13.266)
          ..cubicTo(16.5916, 13.266, 16.9738, 12.8682, 16.9738, 12.3759)
          ..cubicTo(16.9738, 11.8837, 16.5916, 11.4858, 16.1213, 11.4858)
          ..cubicTo(15.6511, 11.4858, 15.2698, 11.8837, 15.2698, 12.3759)
          ..cubicTo(15.2698, 12.8682, 15.6502, 13.266, 16.1213, 13.266),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(18.5475, 17.0499)
          ..cubicTo(18.5782, 17.0488, 18.6088, 17.055, 18.6366, 17.0679)
          ..cubicTo(18.6645, 17.0808, 18.689, 17.1, 18.7081, 17.1241)
          ..cubicTo(18.7272, 17.1482, 18.7404, 17.1764, 18.7465, 17.2065)
          ..cubicTo(18.7527, 17.2366, 18.7517, 17.2678, 18.7437, 17.2974)
          ..cubicTo(18.5658, 17.9318, 18.2844, 18.4726, 17.8325, 18.9273)
          ..cubicTo(17.1716, 19.5937, 16.3328, 19.8898, 15.297, 20.03)
          ..cubicTo(14.2905, 20.1666, 13.0053, 20.1666, 11.381, 20.1666)
          ..lineTo(9.51376, 20.1666)
          ..cubicTo(7.89034, 20.1666, 6.60426, 20.1666, 5.59776, 20.03)
          ..cubicTo(4.56192, 19.8898, 3.72317, 19.5937, 3.06226, 18.9273)
          ..cubicTo(2.40134, 18.2627, 2.10801, 17.4166, 1.96867, 16.3734)
          ..cubicTo(1.83301, 15.3578, 1.83301, 14.0616, 1.83301, 12.4253)
          ..lineTo(1.83301, 12.3245)
          ..cubicTo(1.83301, 10.6883, 1.83301, 9.39117, 1.96867, 8.37734)
          ..cubicTo(2.10801, 7.33325, 2.40134, 6.48992, 3.06134, 5.82167)
          ..cubicTo(3.72226, 5.15617, 4.56101, 4.85917, 5.59684, 4.71984)
          ..cubicTo(6.60426, 4.58325, 7.89034, 4.58325, 9.51376, 4.58325)
          ..lineTo(11.381, 4.58325)
          ..cubicTo(13.0044, 4.58325, 14.2905, 4.58325, 15.297, 4.71984)
          ..cubicTo(16.3328, 4.86009, 17.1716, 5.15617, 17.8325, 5.82167)
          ..cubicTo(18.2844, 6.27725, 18.5658, 6.81808, 18.7437, 7.45333)
          ..cubicTo(18.7516, 7.48293, 18.7524, 7.51396, 18.7462, 7.54394)
          ..cubicTo(18.7399, 7.57392, 18.7267, 7.60202, 18.7076, 7.62599)
          ..cubicTo(18.6886, 7.64996, 18.6642, 7.66913, 18.6364, 7.68197)
          ..cubicTo(18.6085, 7.6948, 18.5781, 7.70095, 18.5475, 7.69992)
          ..lineTo(16.3173, 7.69992)
          ..cubicTo(13.8111, 7.69992, 11.6028, 9.6955, 11.6028, 12.3749)
          ..cubicTo(11.6028, 15.0543, 13.812, 17.0499, 16.3182, 17.0499)
          ..lineTo(18.5475, 17.0499)
          ..moveTo(5.14584, 8.14542)
          ..cubicTo(5.05857, 8.14578, 4.97222, 8.16333, 4.89172, 8.19706)
          ..cubicTo(4.81123, 8.23079, 4.73817, 8.28005, 4.67671, 8.34201)
          ..cubicTo(4.61526, 8.40398, 4.56661, 8.47745, 4.53354, 8.55822)
          ..cubicTo(4.50048, 8.63899, 4.48365, 8.72548, 4.48401, 8.81275)
          ..cubicTo(4.48401, 9.18217, 4.78009, 9.481, 5.14584, 9.481)
          ..lineTo(8.68051, 9.481)
          ..cubicTo(9.04718, 9.481, 9.34326, 9.18217, 9.34326, 8.81275)
          ..cubicTo(9.34375, 8.63641, 9.27422, 8.46708, 9.14996, 8.34196)
          ..cubicTo(9.0257, 8.21683, 8.85685, 8.14615, 8.68051, 8.14542)
          ..lineTo(5.14584, 8.14542),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(7.12891, 3.68866)
          ..lineTo(8.92374, 2.36591)
          ..cubicTo(9.39216, 2.01979, 9.95923, 1.83301, 10.5417, 1.83301)
          ..cubicTo(11.1241, 1.83301, 11.6912, 2.01979, 12.1596, 2.36591)
          ..lineTo(13.9645, 3.69599)
          ..cubicTo(13.2092, 3.66666, 12.3658, 3.66666, 11.4427, 3.66666)
          ..lineTo(9.45357, 3.66666)
          ..cubicTo(8.60841, 3.66666, 7.83199, 3.66666, 7.12891, 3.68866),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _WalletYellowPainter oldDelegate) => oldDelegate.color != color;
}

class _CheckCirclePainter extends CustomPainter {
  final Color color;
  const _CheckCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 24, 24, (canvas) {
      canvas.drawCircle(const Offset(12, 12), 10, Paint()..color = color);
      canvas.drawPath(
        Path()
          ..moveTo(7.5, 12.3)
          ..lineTo(10.3, 15.2)
          ..lineTo(16.5, 8.5),
        _strokePaint(Colors.white, 2),
      );
    });
  }

  @override
  bool shouldRepaint(covariant _CheckCirclePainter oldDelegate) => oldDelegate.color != color;
}

class _CrossCirclePainter extends CustomPainter {
  final Color color;
  const _CrossCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 24, 24, (canvas) {
      canvas.drawCircle(const Offset(12, 12), 10, Paint()..color = color);
      final stroke = _strokePaint(Colors.white, 2);
      canvas.drawLine(const Offset(8.5, 8.5), const Offset(15.5, 15.5), stroke);
      canvas.drawLine(const Offset(15.5, 8.5), const Offset(8.5, 15.5), stroke);
    });
  }

  @override
  bool shouldRepaint(covariant _CrossCirclePainter oldDelegate) => oldDelegate.color != color;
}

class _LockPainter extends CustomPainter {
  final Color color;
  const _LockPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 24, 24, (canvas) {
      final paint = _strokePaint(color, 1.7);
      final rect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(5, 11, 14, 10),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);
      canvas.drawPath(
        Path()
          ..moveTo(8, 11)
          ..lineTo(8, 7.5)
          ..cubicTo(8, 5, 9.8, 3, 12, 3)
          ..cubicTo(14.2, 3, 16, 5, 16, 7.5)
          ..lineTo(16, 11),
        paint,
      );
      canvas.drawCircle(const Offset(12, 15.5), 1.4, Paint()..color = color);
    });
  }

  @override
  bool shouldRepaint(covariant _LockPainter oldDelegate) => oldDelegate.color != color;
}

class _LoupeGrayPainter extends CustomPainter {
  final Color color;
  const _LoupeGrayPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 38, 38, (canvas) {
      final paint = _strokePaint(color, 2.4);
      canvas.drawCircle(const Offset(16.5, 16.5), 11.5, paint);
      canvas.drawLine(const Offset(24.8, 24.8), const Offset(33.2, 33.2), paint);
    });
  }

  @override
  bool shouldRepaint(covariant _LoupeGrayPainter oldDelegate) => oldDelegate.color != color;
}

class _RightArrowGrayPainter extends CustomPainter {
  final Color color;
  const _RightArrowGrayPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 16, 14, (canvas) {
      final paint = _strokePaint(color, 1.6);
      canvas.drawLine(const Offset(1.5, 7), const Offset(12.5, 7), paint);
      canvas.drawPath(
        Path()
          ..moveTo(9.2, 3.4)
          ..lineTo(14.2, 7)
          ..lineTo(9.2, 10.6),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _RightArrowGrayPainter oldDelegate) => oldDelegate.color != color;
}

class _BellPainter extends CustomPainter {
  final Color color;
  const _BellPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 24, 24, (canvas) {
      final paint = _strokePaint(color, 1.7);
      canvas.drawPath(
        Path()
          ..moveTo(6, 10.5)
          ..cubicTo(6, 6.9, 8.7, 4, 12, 4)
          ..cubicTo(15.3, 4, 18, 6.9, 18, 10.5)
          ..cubicTo(18, 14.5, 19.5, 16, 19.5, 16)
          ..lineTo(4.5, 16)
          ..cubicTo(4.5, 16, 6, 14.5, 6, 10.5),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(9.5, 19)
          ..cubicTo(9.5, 20.4, 10.6, 21.5, 12, 21.5)
          ..cubicTo(13.4, 21.5, 14.5, 20.4, 14.5, 19),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _BellPainter oldDelegate) => oldDelegate.color != color;
}

class _SharePainter extends CustomPainter {
  final Color color;
  const _SharePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 24, 24, (canvas) {
      final paint = _strokePaint(color, 1.7);
      final fill = Paint()..color = color;
      canvas.drawCircle(const Offset(18, 5), 2.4, fill);
      canvas.drawCircle(const Offset(6, 12), 2.4, fill);
      canvas.drawCircle(const Offset(18, 19), 2.4, fill);
      canvas.drawLine(const Offset(8, 10.8), const Offset(16, 6.2), paint);
      canvas.drawLine(const Offset(8, 13.2), const Offset(16, 17.8), paint);
    });
  }

  @override
  bool shouldRepaint(covariant _SharePainter oldDelegate) => oldDelegate.color != color;
}

class _VanPainter extends CustomPainter {
  final Color color;
  const _VanPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 24, 24, (canvas) {
      final paint = _strokePaint(color, 1.7);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(2, 8, 15, 8), const Radius.circular(2.5)),
        paint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(17, 11)
          ..lineTo(20.5, 11)
          ..lineTo(22, 14)
          ..lineTo(22, 16)
          ..lineTo(17, 16)
          ..close(),
        paint,
      );
      canvas.drawCircle(const Offset(7, 18), 1.8, paint);
      canvas.drawCircle(const Offset(18, 18), 1.8, paint);
    });
  }

  @override
  bool shouldRepaint(covariant _VanPainter oldDelegate) => oldDelegate.color != color;
}

class _ChevronDownPainter extends CustomPainter {
  final Color color;
  const _ChevronDownPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 20, 20, (canvas) {
      final paint = _strokePaint(color, 1.8);
      canvas.drawPath(
        Path()
          ..moveTo(5, 7.5)
          ..lineTo(10, 12.5)
          ..lineTo(15, 7.5),
        paint,
      );
    });
  }

  @override
  bool shouldRepaint(covariant _ChevronDownPainter oldDelegate) => oldDelegate.color != color;
}

class _DocumentPainter extends CustomPainter {
  final Color color;
  const _DocumentPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _drawScaled(canvas, size, 24, 24, (canvas) {
      final paint = _strokePaint(color, 1.7);
      canvas.drawPath(
        Path()
          ..moveTo(6, 2.5)
          ..lineTo(14.5, 2.5)
          ..lineTo(18.5, 6.5)
          ..lineTo(18.5, 21.5)
          ..lineTo(6, 21.5)
          ..close(),
        paint,
      );
      canvas.drawPath(Path()..moveTo(14.5, 2.5)..lineTo(14.5, 6.5)..lineTo(18.5, 6.5), paint);
      canvas.drawLine(const Offset(9, 12), const Offset(15.5, 12), paint);
      canvas.drawLine(const Offset(9, 16), const Offset(15.5, 16), paint);
    });
  }

  @override
  bool shouldRepaint(covariant _DocumentPainter oldDelegate) => oldDelegate.color != color;
}

Paint _strokePaint(Color color, double width) {
  return Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
}

void _drawScaled(
  Canvas canvas,
  Size size,
  double viewBoxWidth,
  double viewBoxHeight,
  void Function(Canvas canvas) draw,
) {
  final scale = size.shortestSide / viewBoxWidth;
  final dx = (size.width - viewBoxWidth * scale) / 2;
  final dy = (size.height - viewBoxHeight * scale) / 2;
  canvas.save();
  canvas.translate(dx, dy);
  canvas.scale(scale);
  draw(canvas);
  canvas.restore();
}
