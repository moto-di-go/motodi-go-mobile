import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/auth_form_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_fields.dart';
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
    _phoneController.text = context.read<SessionCubit>().state.lastPhoneNumber ?? '';
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
          context.read<SessionCubit>().setAuthenticated(state.session!);
          final next = state.session!.hasActiveProfile
              ? RouteConstants.home
              : RouteConstants.profileSelection;
          context.go(next);
        }
      },
      builder: (context, state) {
        return AuthScaffold(
          title: 'Se connecter',
          showBack: true,
          bottom: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryAuthButton(
                label: 'Se connecter',
                isLoading: state.isLoading,
                onPressed: () => context.read<AuthFormCubit>().login(
                  rawPhoneNumber: _phoneController.text,
                  password: _passwordController.text,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.go(RouteConstants.register),
                child: const Text.rich(
                  TextSpan(
                    text: 'Pas encore de compte ? ',
                    children: [
                      TextSpan(
                        text: 'Créer un compte',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: Color(0xFF95A099),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Content de vous revoir',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Connectez-vous avec votre numéro camerounais.',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: const Color(0xFF5B6760), height: 1.4),
              ),
              const SizedBox(height: 34),
              ErrorBanner(state.errorMessage),
              if (state.errorMessage != null) const SizedBox(height: 28),
              const FieldLabel('Numéro de téléphone'),
              CameroonPhoneInput(controller: _phoneController),
              const SizedBox(height: 28),
              const FieldLabel('Mot de passe'),
              PasswordTextField(controller: _passwordController),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go(RouteConstants.forgotPassword),
                  child: const Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
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
