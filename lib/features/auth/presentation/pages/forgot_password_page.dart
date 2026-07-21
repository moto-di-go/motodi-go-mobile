import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
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
          title: 'Réinitialiser',
          showBack: true,
          bottom: PrimaryAuthButton(
            label: 'Envoyer le code',
            isLoading: state.isLoading,
            onPressed: () => context.read<AuthFormCubit>().forgotPassword(_phoneController.text),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ResetStepper(step: 1, label: 'Étape 1 sur 4 · Numéro'),
              const SizedBox(height: 36),
              Text(
                'Quel est votre numéro ?',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Nous vous enverrons un code de vérification par SMS.',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760), height: 1.45),
              ),
              const SizedBox(height: 40),
              const FieldLabel('Numéro de téléphone'),
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
        title: 'Réinitialiser',
        showBack: true,
        bottom: PrimaryAuthButton(
          label: 'Envoyer le code',
          onPressed: () => context.go(RouteConstants.forgotPassword),
        ),
        child: const Text('Saisissez votre numéro pour recevoir un code.'),
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
          title: 'Réinitialiser',
          showBack: true,
          bottom: PrimaryAuthButton(
            label: 'Vérifier',
            isLoading: state.isLoading,
            onPressed: () {
              if (_codeController.text.length != 6) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Entrez le code à 6 chiffres.')));
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
              const _ResetStepper(step: 2, label: 'Étape 2 sur 4 · Vérification'),
              const SizedBox(height: 36),
              Text(
                'Entrez le code',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Code envoyé au ${widget.args.phoneNumber}.',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760)),
              ),
              const SizedBox(height: 34),
              OtpCodeField(controller: _codeController),
              const SizedBox(height: 26),
              const Center(
                child: Text(
                  'Expire dans  0:52',
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
        title: 'Réinitialiser',
        showBack: true,
        bottom: PrimaryAuthButton(
          label: 'Retour',
          onPressed: () => context.go(RouteConstants.forgotPassword),
        ),
        child: const Text('Relancez la récupération pour obtenir un code.'),
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
          title: 'Réinitialiser',
          showBack: true,
          bottom: PrimaryAuthButton(
            label: 'Réinitialiser',
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
              const _ResetStepper(step: 3, label: 'Étape 3 sur 4 · Nouveau mot de passe'),
              const SizedBox(height: 36),
              Text(
                'Nouveau mot de passe',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 36),
              const FieldLabel('Mot de passe'),
              PasswordTextField(controller: _passwordController, hintText: 'Yaounde2024'),
              const SizedBox(height: 18),
              const _StrengthMeter(),
              const SizedBox(height: 28),
              const FieldLabel('Confirmer le mot de passe'),
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
      backgroundColor: const Color(0xFFFBFCF8),
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
                'Mot de passe modifié',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760), height: 1.45),
              ),
              const Spacer(flex: 5),
              PrimaryAuthButton(
                label: 'Se connecter',
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
        const Text(
          'Force : moyenne — ajoutez un caractère spécial.',
          style: TextStyle(color: Color(0xFF9B6B0B), fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
