import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/auth_form_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/pages/auth_route_args.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_fields.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_figma_icons.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_scaffold.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<AuthFormCubit>(), child: const _RegisterView());
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _accepted = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthFormCubit, AuthFormState>(
      listener: (context, state) {
        if (state.isSuccess && state.registerResult != null) {
          context.push(
            RouteConstants.otp,
            extra: RegistrationOtpArgs(
              phoneNumber: state.registerResult!.phoneNumber,
              password: state.pendingPassword!,
              expiresAt: state.registerResult!.otpExpiresAt,
            ),
          );
        }
      },
      builder: (context, state) {
        final passwordMismatch = state.errorCode == 'PASSWORD_MISMATCH';
        return AuthScaffold(
          title: 'Créer un compte'.tr(context),
          showBack: true,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RegisterFieldLabel('Numéro de téléphone'.tr(context)),
              _RegisterPhoneInput(controller: _phoneController),
              const SizedBox(height: 12),
              _RegisterFieldLabel('Nom complet'.tr(context)),
              _RegisterTextField(
                controller: _nameController,
                hintText: 'Nom & Prénom'.tr(context),
                prefixIcon: const MotodigoPersonGrayIcon(),
              ),
              const SizedBox(height: 12),
              _RegisterFieldLabel('Mot de passe'.tr(context)),
              _RegisterPasswordField(controller: _passwordController, hintText: 'mot de passe'.tr(context)),
              const SizedBox(height: 10),
              Text(
                'Au moins 8 caractères, dont un chiffre.'.tr(context),
                style: TextStyle(
                  color: Color(0xFF8E9A91),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _RegisterFieldLabel('Confirmer le mot de passe'.tr(context)),
              _RegisterPasswordField(
                controller: _confirmController,
                hintText: 'mot de passe'.tr(context),
                hasError: passwordMismatch,
              ),
              if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _RegisterInlineError(state.errorMessage!),
              ],
              const SizedBox(height: 12),
              _TermsAcceptanceRow(
                accepted: _accepted,
                onChanged: (value) => setState(() => _accepted = value),
              ),
              const SizedBox(height: 40),
              _RegisterSubmitButton(
                label: 'Créer mon compte'.tr(context),
                isLoading: state.isLoading,
                onPressed: () => context.read<AuthFormCubit>().register(
                  rawPhoneNumber: _phoneController.text,
                  fullName: _nameController.text,
                  password: _passwordController.text,
                  confirmPassword: _confirmController.text,
                  cguAccepted: _accepted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RegisterFieldLabel extends StatelessWidget {
  final String text;

  const _RegisterFieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: const Color(0xFF3C4741),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RegisterPhoneInput extends StatelessWidget {
  final TextEditingController controller;

  const _RegisterPhoneInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 112,
          height: 60,
          decoration: _registerFieldDecoration(),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MotodigoFlagCmrIcon(),
              SizedBox(width: 4),
              Text(
                '+237',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _RegisterTextField(
            controller: controller,
            hintText: 'XXX XXX XXX',
            keyboardType: TextInputType.phone,
            inputFormatters: const [CameroonNationalPhoneInputFormatter()],
          ),
        ),
      ],
    );
  }
}

class _RegisterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool hasError;

  const _RegisterTextField({
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError ? const Color(0xFFE5484D) : const Color(0xFFDEE2DA);
    return SizedBox(
      height: 60,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          prefixIcon: prefixIcon == null
              ? null
              : SizedBox(
                  width: 74,
                  height: 60,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(padding: const EdgeInsets.only(right: 18), child: prefixIcon),
                  ),
                ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 74,
            maxWidth: 74,
            minHeight: 60,
            maxHeight: 60,
          ),
          suffixIcon: suffixIcon == null
              ? null
              : SizedBox(
                  width: 64,
                  height: 60,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(padding: const EdgeInsets.only(left: 8), child: suffixIcon),
                  ),
                ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 64,
            maxWidth: 64,
            minHeight: 60,
            maxHeight: 60,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: borderColor, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: hasError ? const Color(0xFFE5484D) : AppColors.primary,
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool hasError;

  const _RegisterPasswordField({
    required this.controller,
    this.hintText = 'mot de passe',
    this.hasError = false,
  });

  @override
  State<_RegisterPasswordField> createState() => _RegisterPasswordFieldState();
}

class _RegisterPasswordFieldState extends State<_RegisterPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return _RegisterTextField(
      controller: widget.controller,
      hintText: widget.hintText,
      obscureText: _obscure,
      hasError: widget.hasError,
      prefixIcon: widget.hasError
          ? const MotodigoWrongPasswordRedIcon()
          : const MotodigoPasswordGrayIcon(),
      suffixIcon: IconButton(
        tooltip: (_obscure ? 'Afficher' : 'Masquer').tr(context),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 42, height: 42),
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: const MotodigoShowPasswordGrayIcon(),
      ),
    );
  }
}

class _RegisterInlineError extends StatelessWidget {
  final String message;

  const _RegisterInlineError(this.message);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.warning_amber_rounded, color: Color(0xFFB42318), size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message.tr(context),
            style: const TextStyle(
              color: Color(0xFFB42318),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsAcceptanceRow extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onChanged;

  const _TermsAcceptanceRow({required this.accepted, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!accepted),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 140),
            child: accepted
                ? const MotodigoGpuAcceptedGreenIcon(key: ValueKey('accepted'), size: 32)
                : Container(
                    key: const ValueKey('pending'),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFDEE2DA), width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: "J'accepte les ".tr(context),
                children: [
                  TextSpan(
                    text: "Conditions d'utilisation".tr(context),
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                  ),
                  TextSpan(text: ' et la '.tr(context)),
                  TextSpan(
                    text: 'Politique de confidentialité.'.tr(context),
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              style: TextStyle(
                color: Color(0xFF54615A),
                fontSize: 18,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _RegisterSubmitButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.62),
          elevation: 10,
          shadowColor: AppColors.primary.withValues(alpha: 0.34),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.7, color: Colors.white),
              )
            : Text(
                label,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

BoxDecoration _registerFieldDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0xFFDEE2DA), width: 1.5),
    borderRadius: BorderRadius.circular(24),
  );
}
