import 'package:flutter/material.dart';

// Rôle : Bouton réutilisable avec états loading/disabled.
// Usage : AppButton(label: 'Valider', onPressed: _submit, isLoading: state.isLoading)
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [icon!, const SizedBox(width: 8), Text(label)],
          )
        : Text(label);

    if (isOutlined) {
      return OutlinedButton(onPressed: isLoading ? null : onPressed, child: child);
    }
    return ElevatedButton(onPressed: isLoading ? null : onPressed, child: child);
  }
}
