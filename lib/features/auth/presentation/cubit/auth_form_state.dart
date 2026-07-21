part of 'auth_form_cubit.dart';

enum AuthFormStatus { initial, loading, success, failure }

class AuthFormState extends Equatable {
  final AuthFormStatus status;
  final String? errorMessage;
  final String? errorCode;
  final String? phoneNumber;
  final String? pendingPassword;
  final RegisterResult? registerResult;
  final OtpResendResult? resendResult;
  final AuthSession? session;

  const AuthFormState({
    this.status = AuthFormStatus.initial,
    this.errorMessage,
    this.errorCode,
    this.phoneNumber,
    this.pendingPassword,
    this.registerResult,
    this.resendResult,
    this.session,
  });

  bool get isLoading => status == AuthFormStatus.loading;
  bool get isSuccess => status == AuthFormStatus.success;
  bool get isFailure => status == AuthFormStatus.failure;

  AuthFormState loading({String? phoneNumber}) {
    return copyWith(
      status: AuthFormStatus.loading,
      phoneNumber: phoneNumber,
      errorMessage: null,
      errorCode: null,
    );
  }

  AuthFormState success({
    String? phoneNumber,
    String? pendingPassword,
    RegisterResult? registerResult,
    OtpResendResult? resendResult,
    AuthSession? session,
  }) {
    return AuthFormState(
      status: AuthFormStatus.success,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pendingPassword: pendingPassword,
      registerResult: registerResult,
      resendResult: resendResult,
      session: session,
    );
  }

  AuthFormState copyWith({
    AuthFormStatus? status,
    String? errorMessage,
    String? errorCode,
    String? phoneNumber,
    String? pendingPassword,
    RegisterResult? registerResult,
    OtpResendResult? resendResult,
    AuthSession? session,
  }) {
    return AuthFormState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      errorCode: errorCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pendingPassword: pendingPassword ?? this.pendingPassword,
      registerResult: registerResult ?? this.registerResult,
      resendResult: resendResult ?? this.resendResult,
      session: session ?? this.session,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    errorCode,
    phoneNumber,
    pendingPassword,
    registerResult,
    resendResult,
    session,
  ];
}
