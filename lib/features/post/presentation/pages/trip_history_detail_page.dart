import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/core/widgets/rating_stars.dart';
import 'package:motodi_go_mobile/core/widgets/receipt_card.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';
import 'package:motodi_go_mobile/features/post/domain/entities/post_entities.dart';
import 'package:motodi_go_mobile/features/post/domain/repositories/post_repository.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';
import 'package:motodi_go_mobile/features/post/presentation/widgets/post_ui.dart';
import 'package:motodi_go_mobile/features/trips/domain/entities/trip.dart';
import 'package:motodi_go_mobile/features/trips/domain/repositories/trip_repository.dart';

class TripHistoryDetailPage extends StatefulWidget {
  final String itemId;
  final TripHistoryItem? initialItem;

  const TripHistoryDetailPage({super.key, required this.itemId, this.initialItem});

  @override
  State<TripHistoryDetailPage> createState() => _TripHistoryDetailPageState();
}

class _TripHistoryDetailPageState extends State<TripHistoryDetailPage> {
  bool _loading = true;
  String? _error;
  TripHistoryItem? _item;
  Trip? _trip;
  PostReceipt? _receipt;
  List<TripRating> _ratings = const [];

  @override
  void initState() {
    super.initState();
    _item = widget.initialItem;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final postRepo = getIt<PostRepository>();
    final tripRepo = getIt<TripRepository>();

    // Prefer treating id as trip id when possible.
    final tripResult = await tripRepo.getTrip(widget.itemId);
    tripResult.fold((_) {}, (trip) => _trip = trip);

    if (_trip != null) {
      final ratingsResult = await postRepo.getTripRatings(widget.itemId);
      ratingsResult.fold((_) {}, (list) => _ratings = list);

      _item ??= TripHistoryItem(
        id: _trip!.id,
        kind: 'TRIP',
        tripType: _trip!.type,
        status: _trip!.status.apiValue,
        origin: _trip!.departureCity,
        destination: _trip!.destinationCity,
        amount: _trip!.finalPriceFcfa,
        ratingSubmitted: _ratings.isNotEmpty,
        createdAt: _trip!.createdAt ?? DateTime.now(),
        completedAt: _trip!.completedAt,
      );
    }

    final receiptId = _item?.receiptId;
    if (receiptId != null && receiptId.isNotEmpty) {
      final receiptResult = await postRepo.getReceipt(receiptId);
      receiptResult.fold((_) {}, (r) => _receipt = r);
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
      if (_item == null && _trip == null) {
        _error = 'Détail du trajet introuvable.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _error != null
            ? AppErrorView(message: _error!.tr(context), onRetry: _load)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        PostBackButton(onTap: () => context.pop()),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text('Détail trajet'.tr(context), style: postText(fontSize: 26, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _item?.routeLabel ?? _trip?.routeLabel ?? 'Trajet'.tr(context),
                                style: postText(fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _item?.status ?? _trip?.status.apiValue ?? '',
                                style: postText(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if ((_item?.amount ?? _trip?.finalPriceFcfa) != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  formatPriceFcfa((_item?.amount ?? _trip!.finalPriceFcfa)!),
                                  style: postText(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (_receipt != null) ...[
                          const SizedBox(height: 16),
                          Text('Reçu'.tr(context), style: postText(fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          ReceiptCard(receipt: _receipt!),
                        ],
                        if (_ratings.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text('Votre note'.tr(context), style: postText(fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: AppColors.outline),
                            ),
                            child: Column(
                              children: [
                                RatingStars(value: _ratings.first.stars, readOnly: true, size: 32),
                                if (_ratings.first.comment != null && _ratings.first.comment!.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    _ratings.first.comment!,
                                    textAlign: TextAlign.center,
                                    style: postText(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        if ((_trip?.status == TripStatus.completed ||
                                (_item?.status.toUpperCase() == 'COMPLETED')) &&
                            _ratings.isEmpty &&
                            (_item?.isTrip != false || _trip != null))
                          PostPrimaryButton(
                            label: 'Noter le trajet'.tr(context),
                            onPressed: () => context.push(RouteConstants.tripRatePath(widget.itemId)),
                          ),
                        if (_ratings.isEmpty) const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            final ctx = SupportContext(
                              tripId: _trip?.id ?? (widget.itemId),
                              bookingId: _trip?.bookingId ?? (_item?.kind.toUpperCase() == 'BOOKING' ? widget.itemId : null),
                              routeLabel: _item?.routeLabel ?? _trip?.routeLabel,
                              statusLabel: _item?.status ?? _trip?.status.label,
                            );
                            context.push(RouteConstants.support, extra: ctx);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            minimumSize: const Size.fromHeight(56),
                            side: const BorderSide(color: AppColors.outline, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          ),
                          child: Text('Contacter le support'.tr(context), style: postText(fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
