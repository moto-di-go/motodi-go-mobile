import 'package:fpdart/fpdart.dart';
import 'package:motodi_go_mobile/core/error/failure.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';

abstract class PostRepository {
  Future<Either<Failure, TripHistoryResult>> getTripHistory({
    TripHistoryTab tab = TripHistoryTab.past,
    DateTime? from,
    DateTime? to,
    String? status,
    String? paymentStatus,
    String? tripType,
    int page = 0,
    int size = 20,
  });

  Future<Either<Failure, List<TripRating>>> getTripRatings(String tripId);

  Future<Either<Failure, TripRating>> submitRating({
    required String tripId,
    required String ratedProfileId,
    required int stars,
    String? comment,
    List<RatingTag> tags = const [],
  });

  Future<Either<Failure, ReceiptListResult>> getReceipts({int page = 0, int size = 20});

  Future<Either<Failure, PostReceipt>> getReceipt(String id);

  Future<Either<Failure, SupportTicket>> createSupportTicket({
    required SupportCategory category,
    required SupportPriority priority,
    required String subject,
    required String message,
    String? tripId,
    String? bookingId,
    String? paymentTransactionId,
  });

  Future<Either<Failure, SupportTicketListResult>> getSupportTickets({
    SupportTicketStatus? status,
    int page = 0,
    int size = 20,
  });

  Future<Either<Failure, SupportTicket>> getSupportTicket(String id);
}
