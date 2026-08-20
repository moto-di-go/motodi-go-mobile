import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:motodi_go_mobile/features/notifications/data/models/notification_models.dart';
import 'package:motodi_go_mobile/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:motodi_go_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:motodi_go_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:motodi_go_mobile/features/notifications/presentation/cubit/notifications_cubit.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

class MockNotificationRemote extends Mock implements NotificationRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

AppNotification _notif({
  String id = 'n1',
  bool unread = true,
  AppNotificationType type = AppNotificationType.confirmation,
  String title = 'Réservation confirmée',
}) {
  return AppNotification(
    id: id,
    type: type,
    title: title,
    body: 'Votre trajet est confirmé',
    status: 'SENT',
    createdAt: DateTime(2026, 8, 20),
    unread: unread,
  );
}

void main() {
  group('notification models and entities', () {
    test('parses page and infers unread from missing readAt', () {
      final model = NotificationPageModel.fromJson({
        'items': [
          {
            'id': 'n1',
            'type': 'KYC_DECISION',
            'title': 'Dossier validé',
            'body': 'OK',
            'status': 'SENT',
            'createdAt': '2026-08-20T10:00:00.000Z',
            'metadata': {'status': 'VALIDATED'},
          },
        ],
        'page': '0',
        'size': 20,
        'hasMore': false,
        'unreadCount': 1,
      });
      final page = model.toEntity();
      expect(page.items.single.unread, isTrue);
      expect(page.items.single.type, AppNotificationType.kycDecision);
      expect(page.items.single.visualKind, NotificationVisualKind.success);
      expect(page.unreadCount, 1);
    });

    test('visualKind covers warning, welcome and cancellation', () {
      expect(
        _notif(type: AppNotificationType.cancellation, title: 'Annulée').visualKind,
        NotificationVisualKind.warning,
      );
      expect(
        _notif(type: AppNotificationType.statusChange, title: 'Bienvenue').visualKind,
        NotificationVisualKind.welcome,
      );
      expect(
        _notif(
          type: AppNotificationType.kycDecision,
          title: 'Pièces à corriger',
        ).copyWith(unread: false).visualKind,
        NotificationVisualKind.warning,
      );
      expect(AppNotificationType.fromApi('PAYMENT'), AppNotificationType.payment);
      expect(AppNotificationType.fromApi('nope'), AppNotificationType.unknown);
    });
  });

  group('NotificationRepositoryImpl', () {
    late MockNotificationRemote remote;
    late MockNetworkInfo network;
    late NotificationRepositoryImpl repository;

    setUp(() {
      remote = MockNotificationRemote();
      network = MockNetworkInfo();
      repository = NotificationRepositoryImpl(remote, network);
    });

    test('list returns NetworkFailure offline', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);
      final result = await repository.list();
      result.fold((failure) => expect(failure, isA<NetworkFailure>()), (_) => fail('no data'));
    });

    test('markRead maps NOTIFICATION_NOT_FOUND', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(
        () => remote.markRead(any()),
      ).thenThrow(const ApiException('NOTIFICATION_NOT_FOUND', 'Introuvable'));
      final result = await repository.markRead('n1');
      result.fold((failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.code, 'NOTIFICATION_NOT_FOUND');
      }, (_) => fail('expected failure'));
    });

    test('list maps remote page', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(
        () => remote.list(
          unreadOnly: any(named: 'unreadOnly'),
          page: any(named: 'page'),
          size: any(named: 'size'),
        ),
      ).thenAnswer(
        (_) async => NotificationPageModel.fromJson({
          'items': [
            {
              'id': 'n1',
              'type': 'CONFIRMATION',
              'title': 'OK',
              'body': 'body',
              'status': 'SENT',
              'createdAt': '2026-08-20T10:00:00.000Z',
              'unread': true,
            },
          ],
          'page': 0,
          'size': 20,
          'hasMore': false,
          'unreadCount': 1,
        }),
      );
      final result = await repository.list();
      result.fold((_) => fail('expected data'), (page) => expect(page.items.single.id, 'n1'));
    });
  });

  group('NotificationsCubit', () {
    late MockNotificationRepository repository;

    setUp(() {
      repository = MockNotificationRepository();
    });

    blocTest<NotificationsCubit, NotificationsState>(
      'load emits success page',
      build: () {
        when(
          () => repository.list(
            unreadOnly: any(named: 'unreadOnly'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          ),
        ).thenAnswer(
          (_) async => right(
            NotificationPage(items: [_notif()], page: 0, size: 20, hasMore: true, unreadCount: 1),
          ),
        );
        return NotificationsCubit(repository);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<NotificationsState>().having((s) => s.status, 'status', NotificationsStatus.loading),
        isA<NotificationsState>()
            .having((s) => s.status, 'status', NotificationsStatus.success)
            .having((s) => s.items, 'items', hasLength(1)),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'markRead optimistically decrements unread count',
      build: () {
        when(
          () => repository.markRead(any()),
        ).thenAnswer((_) async => right(_notif(unread: false)));
        return NotificationsCubit(repository);
      },
      seed: () => NotificationsState(
        status: NotificationsStatus.success,
        unreadOnly: false,
        items: [_notif()],
        unreadCount: 1,
      ),
      act: (cubit) => cubit.markRead('n1'),
      expect: () => [
        isA<NotificationsState>()
            .having((s) => s.unreadCount, 'unread', 0)
            .having((s) => s.items.single.unread, 'unread flag', isFalse),
        isA<NotificationsState>().having((s) => s.items.single.unread, 'updated', isFalse),
      ],
    );

    blocTest<NotificationsCubit, NotificationsState>(
      'markAllRead clears unread items in unread-only mode',
      build: () {
        when(() => repository.markAllRead()).thenAnswer(
          (_) async => right(
            const NotificationPage(items: [], page: 0, size: 20, hasMore: false, unreadCount: 0),
          ),
        );
        return NotificationsCubit(repository);
      },
      seed: () => NotificationsState(
        status: NotificationsStatus.success,
        unreadOnly: true,
        items: [_notif()],
        unreadCount: 1,
      ),
      act: (cubit) => cubit.markAllRead(),
      expect: () => [
        isA<NotificationsState>()
            .having((s) => s.items, 'items', isEmpty)
            .having((s) => s.unreadCount, 'count', 0),
      ],
    );
  });
}
