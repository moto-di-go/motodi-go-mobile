import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:pinput/pinput.dart';

class OtpCodeField extends StatelessWidget {
  final TextEditingController controller;

  const OtpCodeField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = PinTheme(
      width: 54,
      height: 62,
      textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE3DA), width: 1.5),
      ),
    );
    return Pinput(
      controller: controller,
      length: 6,
      defaultPinTheme: theme,
      focusedPinTheme: theme.copyDecorationWith(
        border: Border.all(color: AppColors.textPrimary, width: 2),
        borderRadius: BorderRadius.circular(18),
      ),
      submittedPinTheme: theme.copyDecorationWith(
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}
