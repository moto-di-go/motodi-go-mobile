import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/auth_form_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/pages/auth_route_args.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_fields.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/otp_code_field.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<AuthFormCubit>(), child: const _ForgotPasswordView());
  }
}

class _ForgotPasswordView extends StatefulWidget {
  const _ForgotPasswordView();

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthFormCubit, AuthFormState>(
      listener: (context, state) {
        if (state.isSuccess && state.phoneNumber != null) {
          context.go(RouteConstants.resetOtp, extra: ResetOtpArgs(phoneNumber: state.phoneNumber!));
        }
      },
      builder: (context, state) {
        return AuthScaffold(
          title: 'Réinitialiser'.tr(context),
          showBack: true,
          bottom: PrimaryAuthButton(
            label: 'Envoyer le code'.tr(context),
            isLoading: state.isLoading,
            onPressed: () => context.read<AuthFormCubit>().forgotPassword(_phoneController.text),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResetStepper(step: 1, label: 'Étape 1 sur 4 · Numéro'.tr(context)),
              const SizedBox(height: 36),
              Text(
                'Quel est votre numéro ?'.tr(context),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Nous vous enverrons un code de vérification par SMS.'.tr(context),
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760), height: 1.45),
              ),
              const SizedBox(height: 40),
              FieldLabel('Numéro de téléphone'.tr(context)),
              CameroonPhoneInput(controller: _phoneController),
              InlineError(state.errorMessage),
            ],
          ),
        );
      },
    );
  }
}

class ResetOtpPage extends StatelessWidget {
  final ResetOtpArgs? args;

  const ResetOtpPage({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    if (args == null) {
      return AuthScaffold(
        title: 'Réinitialiser'.tr(context),
        showBack: true,
        bottom: PrimaryAuthButton(
          label: 'Envoyer le code'.tr(context),
          onPressed: () => context.go(RouteConstants.forgotPassword),
        ),
        child: Text('Saisissez votre numéro pour recevoir un code.'.tr(context)),
      );
    }
    return BlocProvider(
      create: (_) => getIt<AuthFormCubit>(),
      child: _ResetOtpView(args: args!),
    );
  }
}

class _ResetOtpView extends StatefulWidget {
  final ResetOtpArgs args;

  const _ResetOtpView({required this.args});

  @override
  State<_ResetOtpView> createState() => _ResetOtpViewState();
}

class _ResetOtpViewState extends State<_ResetOtpView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthFormCubit, AuthFormState>(
      builder: (context, state) {
        return AuthScaffold(
          title: 'Réinitialiser'.tr(context),
          showBack: true,
          bottom: PrimaryAuthButton(
            label: 'Vérifier'.tr(context),
            isLoading: state.isLoading,
            onPressed: () {
              if (_codeController.text.length != 6) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Entrez le code à 6 chiffres.'.tr(context))));
                return;
              }
              context.go(
                RouteConstants.resetPassword,
                extra: ResetOtpArgs(
                  phoneNumber: widget.args.phoneNumber,
                  code: _codeController.text,
                ),
              );
            },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResetStepper(step: 2, label: 'Étape 2 sur 4 · Vérification'.tr(context)),
              const SizedBox(height: 36),
              Text(
                'Entrez le code'.tr(context),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Code envoyé au {phone}.'.tr(
                  context,
                  placeholders: {'phone': widget.args.phoneNumber},
                ),
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760)),
              ),
              const SizedBox(height: 34),
              OtpCodeField(controller: _codeController),
              const SizedBox(height: 26),
              Center(
                child: Text(
                  'Expire dans  0:52'.tr(context),
                  style: TextStyle(
                    color: Color(0xFF92A099),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              InlineError(state.errorMessage),
            ],
          ),
        );
      },
    );
  }
}

class NewPasswordPage extends StatelessWidget {
  final ResetOtpArgs? args;

  const NewPasswordPage({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    if (args?.code == null) {
      return AuthScaffold(
        title: 'Réinitialiser'.tr(context),
        showBack: true,
        bottom: PrimaryAuthButton(
          label: 'Retour'.tr(context),
          onPressed: () => context.go(RouteConstants.forgotPassword),
        ),
        child: Text('Relancez la récupération pour obtenir un code.'.tr(context)),
      );
    }
    return BlocProvider(
      create: (_) => getIt<AuthFormCubit>(),
      child: _NewPasswordView(args: args!),
    );
  }
}

class _NewPasswordView extends StatefulWidget {
  final ResetOtpArgs args;

  const _NewPasswordView({required this.args});

  @override
  State<_NewPasswordView> createState() => _NewPasswordViewState();
}

class _NewPasswordViewState extends State<_NewPasswordView> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthFormCubit, AuthFormState>(
      listener: (context, state) {
        if (state.isSuccess) context.go(RouteConstants.passwordResetSuccess);
      },
      builder: (context, state) {
        return AuthScaffold(
          title: 'Réinitialiser'.tr(context),
          showBack: true,
          bottom: PrimaryAuthButton(
            label: 'Réinitialiser'.tr(context),
            isLoading: state.isLoading,
            onPressed: () => context.read<AuthFormCubit>().resetPassword(
              phoneNumber: widget.args.phoneNumber,
              code: widget.args.code!,
              password: _passwordController.text,
              confirmPassword: _confirmController.text,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResetStepper(step: 3, label: 'Étape 3 sur 4 · Nouveau mot de passe'.tr(context)),
              const SizedBox(height: 36),
              Text(
                'Nouveau mot de passe'.tr(context),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 36),
              FieldLabel('Mot de passe'.tr(context)),
              PasswordTextField(controller: _passwordController, hintText: 'Yaounde2024'),
              const SizedBox(height: 18),
              const _StrengthMeter(),
              const SizedBox(height: 28),
              FieldLabel('Confirmer le mot de passe'.tr(context)),
              PasswordTextField(controller: _confirmController, hintText: '••••••••••'),
              InlineError(state.errorMessage),
            ],
          ),
        );
      },
    );
  }
}

class PasswordResetSuccessPage extends StatelessWidget {
  const PasswordResetSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            children: [
              const Spacer(flex: 4),
              Container(
                width: 126,
                height: 126,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.check_rounded, size: 70, color: Colors.white),
                ),
              ),
              const SizedBox(height: 56),
              Text(
                'Mot de passe modifié'.tr(context),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.'.tr(context),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760), height: 1.45),
              ),
              const Spacer(flex: 5),
              PrimaryAuthButton(
                label: 'Se connecter'.tr(context),
                onPressed: () => context.go(RouteConstants.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResetStepper extends StatelessWidget {
  final int step;
  final String label;

  const _ResetStepper({required this.step, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Container(
                height: 7,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 12),
                decoration: BoxDecoration(
                  color: index < step ? AppColors.primary : const Color(0xFFD9E0DC),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF8E9A91),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Container(
                height: 7,
                margin: EdgeInsets.only(right: index == 3 ? 0 : 12),
                decoration: BoxDecoration(
                  color: index < 2
                      ? AppColors.primary
                      : index == 2
                      ? const Color(0xFFF6C400)
                      : const Color(0xFFD9E0DC),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Force : moyenne — ajoutez un caractère spécial.'.tr(context),
          style: TextStyle(color: Color(0xFF9B6B0B), fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
