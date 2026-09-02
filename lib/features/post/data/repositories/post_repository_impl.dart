import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/core/network/network_info.dart';
import 'package:motodi_go_mobile/features/auth/data/models/api_error_model.dart';
import 'package:motodi_go_mobile/features/offline/domain/entities/offline_entities.dart';
import 'package:motodi_go_mobile/features/offline/domain/repositories/offline_repository.dart';
import 'package:motodi_go_mobile/features/post/data/datasources/post_remote_datasource.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/domain/repositories/post_repository.dart';

@LazySingleton(as: PostRepository)
class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final OfflineRepository _offlineRepository;

  PostRepositoryImpl(this._remoteDataSource, this._networkInfo, this._offlineRepository);

  @override
  Future<Either<Failure, TripHistoryResult>> getTripHistory({
    TripHistoryTab tab = TripHistoryTab.past,
    DateTime? from,
    DateTime? to,
    String? status,
    String? paymentStatus,
    String? tripType,
    int page = 0,
    int size = 20,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.getTripHistory(
        tab: tab.apiValue,
        from: from?.toUtc().toIso8601String(),
        to: to?.toUtc().toIso8601String(),
        status: status,
        paymentStatus: paymentStatus,
        tripType: tripType,
        page: page,
        size: size,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, List<TripRating>>> getTripRatings(String tripId) {
    return _guard(() async {
      final models = await _remoteDataSource.getTripRatings(tripId);
      return models.map((e) => e.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, TripRating>> submitRating({
    required String tripId,
    required String ratedProfileId,
    required int stars,
    String? comment,
    List<RatingTag> tags = const [],
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.submitRating(
        tripId: tripId,
        ratedProfileId: ratedProfileId,
        stars: stars,
        comment: comment,
        tags: tags.map((t) => t.apiValue).toList(),
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, ReceiptListResult>> getReceipts({int page = 0, int size = 20}) {
    return _guard(() async {
      final model = await _remoteDataSource.getReceipts(page: page, size: size);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, PostReceipt>> getReceipt(String id) {
    return _guard(() async {
      final model = await _remoteDataSource.getReceipt(id);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, SupportTicket>> createSupportTicket({
    required SupportCategory category,
    required SupportPriority priority,
    required String subject,
    required String message,
    String? tripId,
    String? bookingId,
    String? paymentTransactionId,
  }) async {
    if (!await _networkInfo.isConnected) {
      final op = await _offlineRepository.enqueue(
        type: OfflineOperationType.supportTicket,
        payload: {
          'category': category.apiValue,
          'priority': priority.apiValue,
          'subject': subject,
          'message': message,
          if (tripId != null) 'tripId': tripId,
          if (bookingId != null) 'bookingId': bookingId,
          if (paymentTransactionId != null) 'paymentTransactionId': paymentTransactionId,
        },
      );
      final short = op.id.length >= 8 ? op.id.substring(0, 8) : op.id;
      return right(
        SupportTicket(
          id: op.id,
          ticketNumber: 'LOCAL-$short',
          category: category,
          priority: priority,
          status: SupportTicketStatus.open,
          subject: subject,
          message: message,
          tripId: tripId,
          bookingId: bookingId,
          paymentTransactionId: paymentTransactionId,
          offlineOperationId: op.id,
          createdAt: op.queuedAt,
        ),
      );
    }
    return _guard(() async {
      final model = await _remoteDataSource.createSupportTicket(
        category: category.apiValue,
        priority: priority.apiValue,
        subject: subject,
        message: message,
        tripId: tripId,
        bookingId: bookingId,
        paymentTransactionId: paymentTransactionId,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, SupportTicketListResult>> getSupportTickets({
    SupportTicketStatus? status,
    int page = 0,
    int size = 20,
  }) {
    return _guard(() async {
      final model = await _remoteDataSource.getSupportTickets(
        status: status == null || status == SupportTicketStatus.unknown
            ? null
            : status.apiValue,
        page: page,
        size: size,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, SupportTicket>> getSupportTicket(String id) {
    return _guard(() async {
      final model = await _remoteDataSource.getSupportTicket(id);
      return model.toEntity();
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await _networkInfo.isConnected) {
      return left(const NetworkFailure('Pas de connexion internet.', code: 'NETWORK_OFFLINE'));
    }
    try {
      return right(await action());
    } catch (error) {
      return left(_failureFromException(error));
    }
  }

  Failure _failureFromException(Object error) {
    if (error is ApiException) {
      return switch (error.code) {
        'SESSION_EXPIRED' => AuthFailure(error.message, code: error.code),
        'RATING_ALREADY_EXISTS' ||
        'TRIP_NOT_COMPLETED' ||
        'RATING_FORBIDDEN' ||
        'RATED_PROFILE_INVALID' ||
        'RATING_VALIDATION_FAILED' ||
        'SUPPORT_VALIDATION_FAILED' ||
        'SUPPORT_TICKET_NOT_FOUND' ||
        'TRIP_NOT_FOUND' ||
        'VALIDATION_ERROR' => ValidationFailure(error.message, code: error.code),
        _ => ServerFailure(error.message, code: error.code),
      };
    }
    return ServerFailure(error.toString());
  }
}
