import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/auth_validators.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/register_result.dart';
import 'package:motodi_go_mobile/features/auth/domain/repositories/auth_repository.dart';

part 'auth_form_state.dart';

@injectable
class AuthFormCubit extends Cubit<AuthFormState> {
  final AuthRepository _authRepository;

  AuthFormCubit(this._authRepository) : super(const AuthFormState());

  Future<void> register({
    required String rawPhoneNumber,
    required String fullName,
    required String password,
    required String confirmPassword,
    required bool cguAccepted,
  }) async {
    final phoneNumber = CameroonPhoneValidator.normalize(rawPhoneNumber);
    if (phoneNumber == null) {
      return _fail('Numéro de téléphone camerounais invalide.', 'INVALID_PHONE_NUMBER');
    }
    final passwordError = PasswordValidator.error(password);
    if (passwordError != null) {
      return _fail('Au moins 8 caractères, dont un chiffre.', passwordError);
    }
    if (password != confirmPassword) {
      return _fail('Les mots de passe ne correspondent pas.', 'PASSWORD_MISMATCH');
    }
    if (!cguAccepted) {
      return _fail('Vous devez accepter les conditions.', 'CGU_REQUIRED');
    }
    if (fullName.trim().isEmpty) {
      return _fail('Le nom complet est requis.', 'FULL_NAME_REQUIRED');
    }

    emit(state.loading(phoneNumber: phoneNumber));
    final result = await _authRepository.register(
      phoneNumber: phoneNumber,
      password: password,
      fullName: fullName.trim(),
      cguAccepted: cguAccepted,
    );
    result.fold(
      (failure) => _fail(failure.message, failure.code),
      (registerResult) => emit(
        state.success(
          registerResult: registerResult,
          phoneNumber: phoneNumber,
          pendingPassword: password,
        ),
      ),
    );
  }

  Future<void> verifyRegistrationOtp({
    required String phoneNumber,
    required String code,
    required String password,
  }) async {
    if (!OtpValidator.isValid(code)) {
      return _fail('Entrez le code à 6 chiffres.', 'OTP_INVALID');
    }
    emit(state.loading(phoneNumber: phoneNumber));
    final result = await _authRepository.verifyRegistrationOtpAndLogin(
      phoneNumber: phoneNumber,
      code: code,
      password: password,
    );
    result.fold(
      (failure) => _fail(failure.message, failure.code),
      (session) => emit(state.success(session: session, phoneNumber: phoneNumber)),
    );
  }

  Future<void> resendRegistrationOtp(String phoneNumber) async {
    emit(state.copyWith(status: AuthFormStatus.loading, errorMessage: null));
    final result = await _authRepository.resendOtp(
      phoneNumber: phoneNumber,
      purpose: 'REGISTRATION',
    );
    result.fold(
      (failure) => _fail(failure.message, failure.code),
      (resendResult) =>
          emit(state.success(resendResult: resendResult, phoneNumber: resendResult.phoneNumber)),
    );
  }

  Future<void> login({required String rawPhoneNumber, required String password}) async {
    final phoneNumber = CameroonPhoneValidator.normalize(rawPhoneNumber);
    if (phoneNumber == null) {
      return _fail('Numéro de téléphone camerounais invalide.', 'INVALID_PHONE_NUMBER');
    }
    if (password.isEmpty) {
      return _fail('Le mot de passe est requis.', 'PASSWORD_REQUIRED');
    }
    emit(state.loading(phoneNumber: phoneNumber));
    final result = await _authRepository.login(phoneNumber: phoneNumber, password: password);
    result.fold(
      (failure) => _fail(failure.message, failure.code),
      (session) => emit(state.success(session: session, phoneNumber: phoneNumber)),
    );
  }

  Future<void> forgotPassword(String rawPhoneNumber) async {
    final phoneNumber = CameroonPhoneValidator.normalize(rawPhoneNumber);
    if (phoneNumber == null) {
      return _fail('Numéro de téléphone camerounais invalide.', 'INVALID_PHONE_NUMBER');
    }
    emit(state.loading(phoneNumber: phoneNumber));
    final result = await _authRepository.forgotPassword(phoneNumber);
    result.fold(
      (failure) => _fail(failure.message, failure.code),
      (_) => emit(state.success(phoneNumber: phoneNumber)),
    );
  }

  Future<void> resetPassword({
    required String phoneNumber,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    if (!OtpValidator.isValid(code)) {
      return _fail('Entrez le code à 6 chiffres.', 'OTP_INVALID');
    }
    final passwordError = PasswordValidator.error(password);
    if (passwordError != null) {
      return _fail('Au moins 8 caractères, dont un chiffre.', passwordError);
    }
    if (password != confirmPassword) {
      return _fail('Les mots de passe ne correspondent pas.', 'PASSWORD_MISMATCH');
    }
    emit(state.loading(phoneNumber: phoneNumber));
    final result = await _authRepository.resetPassword(
      phoneNumber: phoneNumber,
      code: code,
      newPassword: password,
    );
    result.fold(
      (failure) => _fail(failure.message, failure.code),
      (_) => emit(state.success(phoneNumber: phoneNumber)),
    );
  }

  void _fail(String message, String? code) {
    emit(state.copyWith(status: AuthFormStatus.failure, errorMessage: message, errorCode: code));
  }
}
