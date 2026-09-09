import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';

class FieldLabel extends StatelessWidget {
  final String text;
  final String? suffix;

  const FieldLabel(this.text, {super.key, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF3E4A42),
            fontWeight: FontWeight.w800,
          ),
          children: [
            TextSpan(text: text),
            if (suffix != null)
              TextSpan(
                text: ' · $suffix',
                style: const TextStyle(color: Color(0xFF8E9A91)),
              ),
          ],
        ),
      ),
    );
  }
}

class CameroonPhoneInput extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;

  const CameroonPhoneInput({super.key, required this.controller, this.hintText = '6 78 90 12 34'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 128,
          height: 62,
          decoration: _fieldDecoration(),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _CameroonFlag(),
                  const SizedBox(width: 12),
                  Text(
                    '+237',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 +()-]'))],
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            decoration: _inputDecoration(hintText?.tr(context)),
          ),
        ),
      ],
    );
  }
}

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int? maxLength;

  const AuthTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.icon,
    this.keyboardType,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      decoration: _inputDecoration(hintText?.tr(context)).copyWith(
        counterText: '',
        prefixIcon: icon == null ? null : Icon(icon, color: const Color(0xFF8F9A91)),
      ),
    );
  }
}

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;

  const PasswordTextField({super.key, required this.controller, this.hintText});

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      decoration: _inputDecoration((widget.hintText ?? 'motdepasse').tr(context)).copyWith(
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF8F9A91)),
        suffixIcon: IconButton(
          tooltip: (_obscure ? 'Afficher' : 'Masquer').tr(context),
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color(0xFF8F9A91),
          ),
        ),
      ),
    );
  }
}

class InlineError extends StatelessWidget {
  final String? message;

  const InlineError(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message!.tr(context),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFC62828),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  final String? message;

  const ErrorBanner(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E6),
        border: Border.all(color: const Color(0xFFF7B8BC)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: Color(0xFFC62828)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message!.tr(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFC62828),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(String? hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFFA8B0AA), fontWeight: FontWeight.w700),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: Color(0xFFDDE3DA), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
  );
}

BoxDecoration _fieldDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0xFFDDE3DA), width: 1.5),
    borderRadius: BorderRadius.circular(22),
  );
}

class _CameroonFlag extends StatelessWidget {
  const _CameroonFlag();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: const SizedBox(
        width: 28,
        height: 20,
        child: Row(
          children: [
            Expanded(child: ColoredBox(color: Color(0xFF179B55))),
            Expanded(child: ColoredBox(color: Color(0xFFE53E3E))),
            Expanded(child: ColoredBox(color: Color(0xFFFACC15))),
          ],
        ),
      ),
    );
  }
}
