import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/core/widgets/app_loading.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_booking_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/authenticated_network_image.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_figma_icons.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';

final RegExp _kPhonePattern = RegExp(r'^\+237[6-9]\d{8}$');

const _kDefaultInstructions =
    'Présentez-vous 15 min avant le départ, point de rendez-vous carrefour Mvan.';
const _kDefaultCancellationPolicy = "Remboursable jusqu'à 24 h avant le départ.";

TextStyle _detailText({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = const Color(0xFF101512),
  double? height,
  double? letterSpacing,
}) {
  return GoogleFonts.outfit(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

// Role : Arguments passes de la page detail vers la page de souscription.
class IntercitySubscribeArgs {
  final String announcementId;
  final String route;
  final double pricePerSeat;
  final int maxSeats;

  const IntercitySubscribeArgs({
    required this.announcementId,
    required this.route,
    required this.pricePerSeat,
    required this.maxSeats,
  });
}

// ---------------------------------------------------------------------------
// 69 — IntercityDetailPage
// ---------------------------------------------------------------------------
class IntercityDetailPage extends StatefulWidget {
  final String announcementId;

  const IntercityDetailPage({super.key, required this.announcementId});

  @override
  State<IntercityDetailPage> createState() => _IntercityDetailPageState();
}

class _IntercityDetailPageState extends State<IntercityDetailPage> {
  late final IntercityBookingCubit _cubit = getIt<IntercityBookingCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.loadDetail(widget.announcementId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAF6),
        body: SafeArea(
          child: BlocBuilder<IntercityBookingCubit, IntercityBookingState>(
            builder: (context, state) {
              if (state.isDetailLoading) return const AppLoading();
              final announcement = state.announcement;
              if (announcement == null) {
                return AppErrorView(
                  message: state.detailErrorMessage ?? "Impossible de charger l'annonce.",
                  onRetry: () => _cubit.loadDetail(widget.announcementId),
                );
              }
              return _DetailContent(announcement: announcement);
            },
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final IntercityAnnouncement announcement;

  const _DetailContent({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final hasSeats = announcement.hasSeatsAvailable && announcement.status.isActive;
    final agency = announcement.publisherDisplayName?.trim().isNotEmpty == true
        ? announcement.publisherDisplayName!
        : 'Transporteur';
    final quarter = announcement.departureQuarter?.trim();
    final metaParts = <String>[
      '${formatDayMonth(announcement.departureDate)} ${announcement.departureDate.year}',
      announcement.formattedDepartureTime,
      if (quarter != null && quarter.isNotEmpty) 'Départ $quarter',
    ];
    final metaLine = metaParts.join(' · ');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, left: 20, right: 20),
          child: Row(
            children: [
              _DetailBackButton(onTap: () => context.pop()),
              const SizedBox(width: 14),
              Text(
                'Détail du trajet',
                style: _detailText(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFE7EAE3)),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  announcement.departureCity,
                                  overflow: TextOverflow.ellipsis,
                                  style: _detailText(fontSize: 20, fontWeight: FontWeight.w800),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 7),
                                child: MotodigoRightArrowGrayIcon(
                                  size: 15,
                                  color: Color(0xFF101512),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  announcement.destinationCity,
                                  overflow: TextOverflow.ellipsis,
                                  style: _detailText(fontSize: 20, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          formatPriceF(announcement.priceFcfa),
                          style: _detailText(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const MotodigoDateGrayIcon(size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            metaLine,
                            style: _detailText(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF54615A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFE7EAE3)),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1EA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const MotodigoBuildingGrayIcon(size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  agency,
                                  overflow: TextOverflow.ellipsis,
                                  style: _detailText(fontSize: 17, fontWeight: FontWeight.w700),
                                ),
                              ),
                              if (announcement.publisherVerified) ...[
                                const SizedBox(width: 8),
                                const MotodigoVerifiedIcon(size: 18),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            announcement.publisherVerified
                                ? 'Transporteur vérifié'
                                : 'Transporteur',
                            style: _detailText(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B756E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _VehiclePhotoCard(
                        photoUrl: announcement.vehiclePhotoUrl,
                        capacity: announcement.vehicleCapacity ?? announcement.totalSeats,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFE4F3E9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${announcement.remainingSeats} restante${announcement.remainingSeats > 1 ? 's' : ''}',
                              textAlign: TextAlign.center,
                              style: _detailText(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF15803D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Places',
                              textAlign: TextAlign.center,
                              style: _detailText(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'CONSIGNES',
                style: _detailText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7A857E),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _kDefaultInstructions,
                style: _detailText(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF54615A),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                "POLITIQUE D'ANNULATION",
                style: _detailText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7A857E),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _kDefaultCancellationPolicy,
                style: _detailText(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF54615A),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Material(
            color: hasSeats ? const Color(0xFF16A34A) : const Color(0xFFB7C0B9),
            borderRadius: BorderRadius.circular(999),
            elevation: hasSeats ? 8 : 0,
            shadowColor: const Color(0x8C16A34A),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: hasSeats
                  ? () => context.push(
                        RouteConstants.intercitySubscribe,
                        extra: IntercitySubscribeArgs(
                          announcementId: announcement.id,
                          route: announcement.route,
                          pricePerSeat: announcement.priceFcfa,
                          maxSeats: announcement.remainingSeats,
                        ),
                      )
                  : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: Text(
                  hasSeats ? 'Souscrire' : 'Complet',
                  style: _detailText(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _DetailBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1EA),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF101512)),
      ),
    );
  }
}

class _VehiclePhotoCard extends StatelessWidget {
  final String? photoUrl;
  final int capacity;

  const _VehiclePhotoCard({required this.photoUrl, required this.capacity});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: hasPhoto ? () => _openFullscreen(context, photoUrl!) : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFE7EAE3)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: hasPhoto
                      ? AuthenticatedNetworkImage(
                          path: photoUrl!,
                          width: double.infinity,
                          height: 56,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: const Color(0xFFF1F1EA),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.directions_car_filled_rounded,
                            color: Color(0xFF8A968C),
                            size: 28,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$capacity places',
                textAlign: TextAlign.center,
                style: _detailText(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B756E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, String path) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: AuthenticatedNetworkImage(
                      path: path,
                      fit: BoxFit.contain,
                      width: MediaQuery.sizeOf(dialogContext).width,
                      height: MediaQuery.sizeOf(dialogContext).height * 0.75,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// 70 — IntercitySubscribePage
// ---------------------------------------------------------------------------
class IntercitySubscribePage extends StatefulWidget {
  final IntercitySubscribeArgs args;

  const IntercitySubscribePage({super.key, required this.args});

  @override
  State<IntercitySubscribePage> createState() => _IntercitySubscribePageState();
}

class _IntercitySubscribePageState extends State<IntercitySubscribePage> {
  late final IntercityBookingCubit _cubit = getIt<IntercityBookingCubit>();
  final _phoneController = TextEditingController();
  int _seats = 1;
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: const Text('Souscrire', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
        ),
        body: BlocConsumer<IntercityBookingCubit, IntercityBookingState>(
          listener: (context, state) {
            if (state.subscribeStatus == IntercitySubscribeStatus.success && state.createdBooking != null) {
              context.pushReplacement(RouteConstants.intercityBooking, extra: state.createdBooking!.id);
            }
            if (state.subscribeStatus == IntercitySubscribeStatus.failure &&
                state.subscribeErrorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.subscribeErrorMessage!)));
            }
          },
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFFAF3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const MotodigoPinGreenIcon(size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.args.route,
                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Nombre de sièges',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE7ECE6)),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MotodigoStepperButton(
                        increment: false,
                        enabled: _seats > 1,
                        onTap: () => setState(() => _seats--),
                      ),
                      Text(
                        '$_seats',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      MotodigoStepperButton(
                        increment: true,
                        enabled: _seats < widget.args.maxSeats,
                        onTap: () => setState(() => _seats++),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.args.maxSeats} siège(s) disponible(s) au maximum',
                  style: const TextStyle(color: Color(0xFF8A968C), fontSize: 13),
                ),
                const SizedBox(height: 24),
                Text(
                  'Numéro de contact',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: _phoneError != null ? AppColors.error : const Color(0xFFE7ECE6),
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9)],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixText: '+237 ',
                      prefixStyle: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      hintText: '6XXXXXXXX',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
                if (_phoneError != null) ...[
                  const SizedBox(height: 8),
                  Text(_phoneError!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE7ECE6)),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total estimé', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF8A968C))),
                      Text(
                        formatPriceFcfa(widget.args.pricePerSeat * _seats),
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                PrimaryAuthButton(
                  label: 'Confirmer la demande',
                  isLoading: state.isSubscribing,
                  onPressed: () => _submit(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final phone = '+237${_phoneController.text.trim()}';
    if (!_kPhonePattern.hasMatch(phone)) {
      setState(() => _phoneError = 'Numéro invalide. Format attendu : +237 6/7/8/9XXXXXXXX');
      return;
    }
    setState(() => _phoneError = null);
    _cubit.subscribe(
      announcementId: widget.args.announcementId,
      seatsRequested: _seats,
      contactPhone: phone,
    );
  }
}

// ---------------------------------------------------------------------------
// 71 — IntercityBookingStatusPage
// ---------------------------------------------------------------------------
class IntercityBookingStatusPage extends StatefulWidget {
  final String bookingId;

  const IntercityBookingStatusPage({super.key, required this.bookingId});

  @override
  State<IntercityBookingStatusPage> createState() => _IntercityBookingStatusPageState();
}

class _IntercityBookingStatusPageState extends State<IntercityBookingStatusPage> {
  late final IntercityBookingCubit _cubit = getIt<IntercityBookingCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.loadBooking(widget.bookingId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: const Text(
            'Ma réservation',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
          ),
        ),
        body: BlocBuilder<IntercityBookingCubit, IntercityBookingState>(
          builder: (context, state) {
            if (state.isBookingLoading && state.booking == null) return const AppLoading();
            final booking = state.booking;
            if (booking == null) {
              return AppErrorView(
                message: state.bookingErrorMessage ?? 'Réservation introuvable.',
                onRetry: () => _cubit.loadBooking(widget.bookingId),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              children: [
                _StatusHeader(status: booking.status),
                const SizedBox(height: 28),
                _BookingTimeline(booking: booking),
                const SizedBox(height: 24),
                _BookingSummaryCard(booking: booking),
                if (booking.status.isCancellable) ...[
                  const SizedBox(height: 30),
                  SecondaryAuthButton(
                    label: 'Annuler la réservation',
                    icon: Icons.close_rounded,
                    onPressed: () => _confirmCancel(context, booking),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context, IntercityBooking booking) async {
    final reasonController = TextEditingController();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Annuler cette réservation ?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText: "Motif de l'annulation",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryAuthButton(
                label: 'Confirmer',
                backgroundColor: AppColors.error,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
              const SizedBox(height: 10),
              SecondaryAuthButton(label: 'Retour', onPressed: () => Navigator.of(sheetContext).pop(false)),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      final reason = reasonController.text.trim().isEmpty ? 'Annulation demandée' : reasonController.text.trim();
      await _cubit.cancelBooking(booking.id, reason);
    }
  }
}

class _StatusHeader extends StatelessWidget {
  final IntercityBookingStatus status;

  const _StatusHeader({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.14), shape: BoxShape.circle),
          child: Icon(_statusIcon(status), color: color, size: 40),
        ),
        const SizedBox(height: 16),
        Text(
          status.longLabel,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  IconData _statusIcon(IntercityBookingStatus status) {
    return switch (status) {
      IntercityBookingStatus.pending => Icons.hourglass_top_rounded,
      IntercityBookingStatus.confirmed => Icons.check_circle_rounded,
      IntercityBookingStatus.pendingPayment => Icons.payments_rounded,
      IntercityBookingStatus.paid => Icons.verified_rounded,
      IntercityBookingStatus.cancelled => Icons.cancel_rounded,
      IntercityBookingStatus.expired => Icons.timer_off_rounded,
      IntercityBookingStatus.unknown => Icons.help_outline_rounded,
    };
  }
}

Color _statusColor(IntercityBookingStatus status) {
  return switch (status) {
    IntercityBookingStatus.pending => const Color(0xFFF59E0B),
    IntercityBookingStatus.confirmed => AppColors.primary,
    IntercityBookingStatus.pendingPayment => AppColors.primary,
    IntercityBookingStatus.paid => AppColors.primary,
    IntercityBookingStatus.cancelled => AppColors.error,
    IntercityBookingStatus.expired => const Color(0xFF9AA49D),
    IntercityBookingStatus.unknown => const Color(0xFF9AA49D),
  };
}

class _BookingTimeline extends StatelessWidget {
  final IntercityBooking booking;

  const _BookingTimeline({required this.booking});

  @override
  Widget build(BuildContext context) {
    final steps = <(String, DateTime?, bool)>[
      ('Demande envoyée', booking.requestedAt, true),
      ('Confirmée par le transporteur', booking.confirmedAt, booking.confirmedAt != null),
      (
        booking.status == IntercityBookingStatus.cancelled ? 'Annulée' : 'Payée / terminée',
        booking.status == IntercityBookingStatus.cancelled ? booking.cancelledAt : null,
        booking.status == IntercityBookingStatus.paid || booking.status == IntercityBookingStatus.cancelled,
      ),
    ];
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _TimelineRow(
            label: steps[i].$1,
            date: steps[i].$2,
            done: steps[i].$3,
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool done;
  final bool isLast;

  const _TimelineRow({required this.label, required this.date, required this.done, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.primary : const Color(0xFFD8DED6);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: done ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
              ),
              if (!isLast) Expanded(child: Container(width: 2, color: color.withValues(alpha: 0.4))),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: done ? AppColors.textPrimary : const Color(0xFF9AA49D),
                    ),
                  ),
                  if (date != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${formatShortDate(date!)} · ${date!.hour.toString().padLeft(2, '0')}:${date!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Color(0xFF8A968C), fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingSummaryCard extends StatelessWidget {
  final IntercityBooking booking;

  const _BookingSummaryCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7ECE6)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Sièges réservés', value: '${booking.seatsRequested}'),
          const Divider(height: 24, color: Color(0xFFF1F2ED)),
          _SummaryRow(label: 'Contact', value: booking.contactPhone),
          if (booking.expiresAt != null && !booking.status.isFinal) ...[
            const Divider(height: 24, color: Color(0xFFF1F2ED)),
            _SummaryRow(
              label: 'Expire le',
              value:
                  '${formatShortDate(booking.expiresAt!)} à ${booking.expiresAt!.hour.toString().padLeft(2, '0')}:${booking.expiresAt!.minute.toString().padLeft(2, '0')}',
            ),
          ],
          if (booking.cancellationReason != null) ...[
            const Divider(height: 24, color: Color(0xFFF1F2ED)),
            _SummaryRow(label: 'Motif', value: booking.cancellationReason!),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: Color(0xFF8A968C), fontWeight: FontWeight.w700)),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}
