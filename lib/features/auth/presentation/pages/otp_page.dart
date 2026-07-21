import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/auth_validators.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/auth_form_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/pages/auth_route_args.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_fields.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/otp_code_field.dart';

class OtpPage extends StatelessWidget {
  final RegistrationOtpArgs? args;

  const OtpPage({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    if (args == null) return const _MissingOtpArgs();
    return BlocProvider(
      create: (_) => getIt<AuthFormCubit>(),
      child: _OtpView(args: args!),
    );
  }
}

class _OtpView extends StatefulWidget {
  final RegistrationOtpArgs args;

  const _OtpView({required this.args});

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  final _codeController = TextEditingController();
  Timer? _timer;
  late DateTime _expiresAt;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _expiresAt = widget.args.expiresAt;
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _tick() {
    final remaining = _expiresAt.difference(DateTime.now()).inSeconds;
    if (mounted) setState(() => _remainingSeconds = remaining < 0 ? 0 : remaining);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthFormCubit, AuthFormState>(
      listener: (context, state) {
        if (state.resendResult != null) {
          _expiresAt = state.resendResult!.otpExpiresAt;
          _tick();
        }
        if (state.session != null) {
          context.read<SessionCubit>().setAuthenticated(state.session!);
          context.go(RouteConstants.accountReady);
        }
      },
      builder: (context, state) {
        final phone = widget.args.phoneNumber;
        return AuthScaffold(
          title: 'Vérification',
          showBack: true,
          bottom: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryAuthButton(
                label: 'Vérifier',
                isLoading: state.isLoading,
                onPressed: () => context.read<AuthFormCubit>().verifyRegistrationOtp(
                  phoneNumber: phone,
                  code: _codeController.text,
                  password: widget.args.password,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: state.isLoading
                    ? null
                    : () => context.read<AuthFormCubit>().resendRegistrationOtp(phone),
                child: const Text(
                  "Vous n'avez rien reçu ? Renvoyer le code",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entrez le code reçu',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 22),
              Text.rich(
                TextSpan(
                  text: 'Un code à 6 chiffres a été envoyé par SMS au ',
                  children: [
                    TextSpan(
                      text: CameroonPhoneValidator.displayNational(
                        phone,
                      ).replaceFirst('6', '+237 6'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const TextSpan(
                      text: '. Modifier',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760), height: 1.35),
              ),
              const SizedBox(height: 34),
              OtpCodeField(controller: _codeController),
              const SizedBox(height: 26),
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(Icons.schedule_rounded, color: Color(0xFF92A099), size: 24),
                      ),
                      const TextSpan(text: '  Le code expire dans  '),
                      TextSpan(
                        text: _formatRemaining(_remainingSeconds),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF92A099),
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

  String _formatRemaining(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }
}

class _MissingOtpArgs extends StatelessWidget {
  const _MissingOtpArgs();

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Vérification',
      showBack: true,
      bottom: PrimaryAuthButton(
        label: 'Créer un compte',
        onPressed: () => context.go(RouteConstants.register),
      ),
      child: const Text('Relancez la création de compte pour recevoir un nouveau code.'),
    );
  }
}
