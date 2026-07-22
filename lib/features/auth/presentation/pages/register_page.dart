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
          context.go(
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
        return AuthScaffold(
          title: 'Créer un compte',
          showBack: true,
          bottom: PrimaryAuthButton(
            label: 'Créer mon compte',
            isLoading: state.isLoading,
            onPressed: () => context.read<AuthFormCubit>().register(
              rawPhoneNumber: _phoneController.text,
              fullName: _nameController.text,
              password: _passwordController.text,
              confirmPassword: _confirmController.text,
              cguAccepted: _accepted,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel('Numéro de téléphone'),
              CameroonPhoneInput(controller: _phoneController),
              const SizedBox(height: 28),
              const FieldLabel('Nom complet'),
              AuthTextField(
                controller: _nameController,
                hintText: 'Aïcha Ngono',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 28),
              const FieldLabel('Mot de passe'),
              PasswordTextField(controller: _passwordController),
              const SizedBox(height: 10),
              const Text(
                'Au moins 8 caractères, dont un chiffre.',
                style: TextStyle(
                  color: Color(0xFF8E9A91),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              const FieldLabel('Confirmer le mot de passe'),
              PasswordTextField(controller: _confirmController, hintText: 'motdepasse'),
              InlineError(state.errorMessage),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _accepted,
                    activeColor: AppColors.primary,
                    onChanged: (value) => setState(() => _accepted = value ?? false),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "J'accepte les ",
                        children: [
                          TextSpan(
                            text: "Conditions d'utilisation",
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                          ),
                          TextSpan(text: ' et la '),
                          TextSpan(
                            text: 'Politique de confidentialité.',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: Color(0xFF5B6760),
                        fontSize: 17,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
