part of 'session_cubit.dart';

enum SessionStatus { initial, bootstrapping, unauthenticated, authenticated, expired }

class SessionState extends Equatable {
  final SessionStatus status;
  final AuthSession? session;
  final bool onboardingSeen;
  final String? lastPhoneNumber;
  final String? errorMessage;

  const SessionState({
    this.status = SessionStatus.initial,
    this.session,
    this.onboardingSeen = false,
    this.lastPhoneNumber,
    this.errorMessage,
  });

  bool get isBootstrapping =>
      status == SessionStatus.initial || status == SessionStatus.bootstrapping;
  bool get isAuthenticated => status == SessionStatus.authenticated && session != null;
  bool get isExpired => status == SessionStatus.expired;
  bool get hasActiveMobileProfile =>
      session?.hasActiveProfile == true && (session?.activeProfileType?.isSelfService ?? false);
  bool get needsProfileSelection => isAuthenticated && !hasActiveMobileProfile;
  ProfileSummary? get activeProfile => session?.activeProfile;

  SessionState copyWith({
    SessionStatus? status,
    Object? session = _unchanged,
    bool? onboardingSeen,
    String? lastPhoneNumber,
    String? errorMessage,
  }) {
    return SessionState(
      status: status ?? this.status,
      session: identical(session, _unchanged) ? this.session : session as AuthSession?,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      lastPhoneNumber: lastPhoneNumber ?? this.lastPhoneNumber,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, session, onboardingSeen, lastPhoneNumber, errorMessage];
}

const Object _unchanged = Object();
