import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:motodi_go_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/profile_summary.dart';

part 'session_state.dart';

@lazySingleton
class SessionCubit extends Cubit<SessionState> {
  final AuthRepository _authRepository;

  SessionCubit(this._authRepository) : super(const SessionState());

  Future<void> bootstrap() async {
    emit(
      state.copyWith(
        status: SessionStatus.bootstrapping,
        onboardingSeen: _authRepository.readOnboardingSeen(),
        lastPhoneNumber: _authRepository.readLastPhoneNumber(),
      ),
    );

    final result = await _authRepository.bootstrapSession();
    result.fold(
      (failure) {
        if (failure is AuthFailure && failure.code == 'SESSION_EXPIRED') {
          emit(state.copyWith(status: SessionStatus.expired, errorMessage: failure.message));
        } else {
          emit(
            state.copyWith(status: SessionStatus.unauthenticated, errorMessage: failure.message),
          );
        }
      },
      (session) {
        if (session == null) {
          emit(state.copyWith(status: SessionStatus.unauthenticated));
        } else {
          emit(state.copyWith(status: SessionStatus.authenticated, session: session));
        }
      },
    );
  }

  Future<void> completeOnboarding() async {
    await _authRepository.saveOnboardingSeen(true);
    emit(state.copyWith(onboardingSeen: true));
  }

  void setAuthenticated(AuthSession session) {
    emit(
      state.copyWith(
        status: SessionStatus.authenticated,
        session: session,
        lastPhoneNumber: session.phoneNumber,
        errorMessage: null,
      ),
    );
  }

  Future<void> refreshAfterProfileChange() async {
    final result = await _authRepository.refreshSession();
    result.fold((failure) {
      if (failure is AuthFailure) {
        expire(failure.message);
      } else {
        emit(state.copyWith(errorMessage: failure.message));
      }
    }, setAuthenticated);
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(state.copyWith(status: SessionStatus.unauthenticated, session: null, errorMessage: null));
  }

  Future<void> changeAccount() async {
    await _authRepository.clearSession();
    emit(state.copyWith(status: SessionStatus.unauthenticated, session: null));
  }

  void expire([String? message]) {
    emit(
      state.copyWith(
        status: SessionStatus.expired,
        session: null,
        errorMessage: message ?? 'Session expirée.',
      ),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
