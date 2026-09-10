import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/auth_validators.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/auth_form_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_fields.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_figma_icons.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_scaffold.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<AuthFormCubit>(), child: const _LoginView());
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final lastPhone = context.read<SessionCubit>().state.lastPhoneNumber;
    if (lastPhone != null && lastPhone.isNotEmpty) {
      _phoneController.text = CameroonPhoneValidator.displayNational(lastPhone);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthFormCubit, AuthFormState>(
      listener: (context, state) {
        if (state.session != null) {
          final sessionCubit = context.read<SessionCubit>();
          sessionCubit.setAuthenticated(state.session!);
          final next = sessionCubit.state.needsProfileSelection
              ? RouteConstants.profileSelection
              : (sessionCubit.state.pendingReturnLocation ?? RouteConstants.home);
          context.go(next);
        }
      },
      builder: (context, state) {
        return AuthScaffold(
          title: 'Se connecter'.tr(context),
          showBack: true,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          bottom: _LoginFooter(
            isLoading: state.isLoading,
            onLogin: () => context.read<AuthFormCubit>().login(
              rawPhoneNumber: _phoneController.text,
              password: _passwordController.text,
            ),
            onRegister: () => context.push(RouteConstants.register),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Content de vous revoir'.tr(context),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Connectez-vous avec votre numéro camerounais.'.tr(context),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF54615A),
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                ),
              ),
              if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
                const SizedBox(height: 34),
                _LoginErrorBanner(state.errorMessage!),
              ],
              const SizedBox(height: 34),
              _LoginFieldLabel('Numéro de téléphone'.tr(context)),
              _LoginPhoneInput(controller: _phoneController),
              const SizedBox(height: 28),
              _LoginFieldLabel('Mot de passe'.tr(context)),
              _LoginPasswordField(controller: _passwordController),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(RouteConstants.forgotPassword),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Mot de passe oublié ?'.tr(context),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoginFieldLabel extends StatelessWidget {
  final String text;

  const _LoginFieldLabel(this.text);

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

class _LoginPhoneInput extends StatelessWidget {
  final TextEditingController controller;

  const _LoginPhoneInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 112,
          height: 60,
          decoration: _loginFieldDecoration(),
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
          child: _LoginTextField(
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

class _LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;

  const _LoginTextField({
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
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
            borderSide: const BorderSide(color: Color(0xFFDEE2DA), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
          ),
        ),
      ),
    );
  }
}

class _LoginPasswordField extends StatefulWidget {
  final TextEditingController controller;

  const _LoginPasswordField({required this.controller});

  @override
  State<_LoginPasswordField> createState() => _LoginPasswordFieldState();
}

class _LoginPasswordFieldState extends State<_LoginPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return _LoginTextField(
      controller: widget.controller,
      hintText: 'mot de passe'.tr(context),
      obscureText: _obscure,
      prefixIcon: const MotodigoPasswordGrayIcon(),
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

class _LoginErrorBanner extends StatelessWidget {
  final String message;

  const _LoginErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8EA),
        border: Border.all(color: const Color(0xFFF7B8BC), width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: Color(0xFFB42318), size: 30),
          const SizedBox(width: 18),
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
      ),
    );
  }
}

class _LoginFooter extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onRegister;

  const _LoginFooter({required this.isLoading, required this.onLogin, required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: 72,
          child: ElevatedButton(
            onPressed: isLoading ? null : onLogin,
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
                    'Se connecter'.tr(context),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: onRegister,
          child: Text.rich(
            TextSpan(
              text: 'Pas encore de compte ? '.tr(context),
              children: [
                TextSpan(
                  text: 'Créer un compte'.tr(context),
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF8A968C), fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

BoxDecoration _loginFieldDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0xFFDEE2DA), width: 1.5),
    borderRadius: BorderRadius.circular(24),
  );
}
