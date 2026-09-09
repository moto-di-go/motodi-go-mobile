import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late SessionCubit cubit;

  setUp(() {
    repository = MockAuthRepository();
    cubit = SessionCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('refreshAfterProfileChange does not expire a guest session', () async {
    cubit.continueAsGuest();

    await cubit.refreshAfterProfileChange();

    expect(cubit.state.isGuest, isTrue);
    expect(cubit.state.isExpired, isFalse);
    verifyNever(() => repository.refreshSession());
  });

  test('refreshAfterProfileChange does not expire an unauthenticated session', () async {
    when(() => repository.refreshSession()).thenAnswer(
      (_) async => left(const AuthFailure('Session expirée.', code: 'SESSION_EXPIRED')),
    );

    await cubit.refreshAfterProfileChange();

    expect(cubit.state.isExpired, isFalse);
    verifyNever(() => repository.refreshSession());
  });

  test('rememberReturnLocation keeps trip details for post-auth restore', () {
    cubit.continueAsGuest();
    cubit.rememberReturnLocation(RouteConstants.intercityDetailPath('ann-42'));

    expect(cubit.takePostAuthDestination(), '/intercity/detail?id=ann-42');
    expect(cubit.state.pendingReturnLocation, isNull);
  });

  test('rememberReturnLocation ignores auth entry routes', () {
    cubit.rememberReturnLocation(RouteConstants.login);
    expect(cubit.takePostAuthDestination(), RouteConstants.home);
  });
}
