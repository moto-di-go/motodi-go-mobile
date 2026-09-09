import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/core/widgets/app_loading.dart';
import 'package:motodi_go_mobile/core/widgets/guest_action_blocker.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_booking_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/authenticated_network_image.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_itinerary_map.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_figma_icons.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';
import 'package:motodi_go_mobile/features/wallet/presentation/pages/pay_booking_page.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';

final RegExp _kPhonePattern = RegExp(r'^\+237[6-9]\d{8}$');

// These are translated inline via .tr(context) where used.
const _kDefaultInstructionsFr =
    'Présentez-vous 15 min avant le départ, point de rendez-vous carrefour Mvan.';
const _kDefaultCancellationPolicyFr = "Remboursable jusqu'à 24 h avant le départ.";

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
                  message: (state.detailErrorMessage ?? "Impossible de charger l'annonce.").tr(context),
                  onRetry: () => _cubit.loadDetail(widget.announcementId),
                );
              }
              return _DetailContent(
                announcement: announcement,
                itineraryStatus: state.itineraryStatus,
                itinerary: state.itinerary,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatefulWidget {
  final IntercityAnnouncement announcement;
  final IntercityItineraryStatus itineraryStatus;
  final IntercityItinerary? itinerary;

  const _DetailContent({required this.announcement, required this.itineraryStatus, this.itinerary});

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  bool _checkingKyc = false;

  @override
  void initState() {
    super.initState();
    // Session JWT can lag behind admin KYC decisions — refresh on open.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionCubit = getIt<SessionCubit>();
      if (!sessionCubit.state.isAuthenticated) return;
      unawaited(sessionCubit.refreshAfterProfileChange());
    });
  }

  Future<void> _openSubscribe() async {
    if (_checkingKyc) return;
    if (!guardGuestAction(context)) return;
    setState(() => _checkingKyc = true);
    try {
      final sessionCubit = getIt<SessionCubit>();
      await sessionCubit.refreshAfterProfileChange();
      if (!mounted) return;

      final activeProfile = sessionCubit.state.activeProfile;
      final kycValidated = activeProfile?.isValidated == true ||
          activeProfile?.validationStatus == ValidationStatus.validated;

      if (!kycValidated) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Validation requise'.tr(context),
                style: _detailText(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              content: Text(
                'Validez votre pièce d’identité (CNI) pour souscrire à un trajet interurbain.'.tr(context),
                style: _detailText(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF54615A),
                  height: 1.4,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Plus tard'.tr(context),
                    style: _detailText(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B756E),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.push(RouteConstants.kyc);
                  },
                  child: Text(
                    'Valider mon profil'.tr(context),
                    style: _detailText(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ),
              ],
            );
          },
        );
        return;
      }

      final announcement = widget.announcement;
      if (!mounted) return;
      context.push(
        RouteConstants.intercitySubscribe,
        extra: IntercitySubscribeArgs(
          announcementId: announcement.id,
          route: announcement.route,
          pricePerSeat: announcement.priceFcfa,
          maxSeats: announcement.remainingSeats,
        ),
      );
    } finally {
      if (mounted) setState(() => _checkingKyc = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcement = widget.announcement;
    final itineraryStatus = widget.itineraryStatus;
    final itinerary = widget.itinerary;
    final profiles = getIt<SessionCubit>().state.session?.profiles ?? const [];
    final ownedByMe = profiles.any((profile) => profile.id == announcement.publisherProfileId);
    final hasSeats = !ownedByMe && announcement.hasSeatsAvailable && announcement.status.isActive;
    final agency = announcement.publisherDisplayName?.trim().isNotEmpty == true
        ? announcement.publisherDisplayName!
        : 'Transporteur'.tr(context);
    final ptRamassage = announcement.ptRamassage?.trim();
    final metaParts = <String>[
      '${formatDayMonth(announcement.departureDate, context: context)} ${announcement.departureDate.year}',
      announcement.formattedDepartureTime,
      if (ptRamassage != null && ptRamassage.isNotEmpty)
        '${'Pt. Ramassage'.tr(context)} $ptRamassage',
    ];
    final metaLine = metaParts.join(' · ');
    final ctaLabel = ownedByMe
        ? 'Émis par vous'.tr(context)
        : hasSeats
        ? (_checkingKyc ? 'Vérification…'.tr(context) : 'Souscrire'.tr(context))
        : 'Complet'.tr(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, left: 20, right: 20),
          child: Row(
            children: [
              _DetailBackButton(onTap: () => context.pop()),
              const SizedBox(width: 14),
              Text(
                'Détail du trajet'.tr(context),
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
                                ? 'Transporteur vérifié'.tr(context)
                                : 'Transporteur'.tr(context),
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
                              Localizations.localeOf(context).languageCode == 'en'
                              ? '${announcement.remainingSeats} remaining'
                              : '${announcement.remainingSeats} restante${announcement.remainingSeats > 1 ? 's' : ''}',
                              textAlign: TextAlign.center,
                              style: _detailText(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF15803D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Places'.tr(context),
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
                'CONSIGNES'.tr(context),
                style: _detailText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7A857E),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _kDefaultInstructionsFr.tr(context),
                style: _detailText(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF54615A),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'ITINÉRAIRE'.tr(context),
                style: _detailText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7A857E),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              _ItineraryBlock(status: itineraryStatus, itinerary: itinerary),
              const SizedBox(height: 22),
              Text(
                "POLITIQUE D'ANNULATION".tr(context),
                style: _detailText(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7A857E),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _kDefaultCancellationPolicyFr.tr(context),
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
              onTap: hasSeats && !_checkingKyc ? _openSubscribe : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: Text(
                  ctaLabel,
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

class _ItineraryBlock extends StatelessWidget {
  final IntercityItineraryStatus status;
  final IntercityItinerary? itinerary;

  const _ItineraryBlock({required this.status, this.itinerary});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: switch (status) {
        IntercityItineraryStatus.ready when itinerary != null => IntercityItineraryMap(
          itinerary: itinerary!,
        ),
        IntercityItineraryStatus.failure => _ItineraryMessage(
          'Itinéraire routier indisponible pour le moment.'.tr(context),
        ),
        IntercityItineraryStatus.idle || IntercityItineraryStatus.loading => const Center(
          child: SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFF16A34A)),
          ),
        ),
        _ => _ItineraryMessage('Itinéraire routier indisponible pour le moment.'.tr(context)),
      },
    );
  }
}

class _ItineraryMessage extends StatelessWidget {
  final String text;
  const _ItineraryMessage(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE7EAE3)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: _detailText(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF54615A),
        ),
      ),
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
                Localizations.localeOf(context).languageCode == 'en' ? '$capacity seats' : '$capacity places',
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
  void initState() {
    super.initState();
    final sessionState = getIt<SessionCubit>().state;
    final registeredPhone = sessionState.session?.phoneNumber ?? sessionState.lastPhoneNumber;
    if (registeredPhone != null && registeredPhone.isNotEmpty) {
      _phoneController.text = _nationalPhoneDigits(registeredPhone);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _cubit.close();
    super.dispose();
  }

  /// Extrait les 9 chiffres nationaux (sans +237) pour le champ de saisie.
  static String _nationalPhoneDigits(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('237') && digits.length >= 12) {
      return digits.substring(3, 12);
    }
    if (digits.length > 9) return digits.substring(digits.length - 9);
    return digits;
  }

  @override
  Widget build(BuildContext context) {
    final unitPrice = widget.args.pricePerSeat;
    final total = unitPrice * _seats;
    final _isEn = Localizations.localeOf(context).languageCode == 'en';
    final placesLabel = _isEn ? '$_seats seat${_seats > 1 ? 's' : ''}' : '$_seats place${_seats > 1 ? 's' : ''}';

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAF6),
        body: SafeArea(
          child: BlocConsumer<IntercityBookingCubit, IntercityBookingState>(
            listener: (context, state) {
              if (state.subscribeStatus == IntercitySubscribeStatus.success &&
                  state.createdBooking != null) {
                context.pushReplacement(
                  RouteConstants.intercityBookingPath(state.createdBooking!.id),
                );
              }
              if (state.subscribeStatus == IntercitySubscribeStatus.failure &&
                  state.subscribeErrorMessage != null) {
                if (state.subscribeErrorCode == 'BOOKING_KYC_REQUIRED') {
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text(
                          'Validation requise'.tr(context),
                          style: _detailText(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        content: Text(
                          state.subscribeErrorMessage!.tr(context),
                          style: _detailText(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF54615A),
                            height: 1.4,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: Text(
                              'Fermer'.tr(context),
                              style: _detailText(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B756E),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              context.push(RouteConstants.kyc);
                            },
                            child: Text(
                              'Valider mon profil'.tr(context),
                              style: _detailText(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.subscribeErrorMessage!.tr(context))));
                }
              }
            },
            builder: (context, state) {
              final fieldBorder = _phoneError != null ? AppColors.error : const Color(0xFFE7EAE3);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 14, left: 20, right: 20),
                    child: Row(
                      children: [
                        _SubscribeBackButton(onTap: () => context.pop()),
                        const SizedBox(width: 14),
                        Text(
                          'Souscrire'.tr(context),
                          style: _detailText(fontSize: 28, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Nombre de places'.tr(context),
                                style: _detailText(fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                            ),
                            _SubscribeStepperButton(
                              icon: Icons.remove_rounded,
                              filled: false,
                              enabled: _seats > 1,
                              onTap: () => setState(() => _seats--),
                            ),
                            SizedBox(
                              width: 36,
                              child: Text(
                                '$_seats',
                                textAlign: TextAlign.center,
                                style: _detailText(fontSize: 20, fontWeight: FontWeight.w800),
                              ),
                            ),
                            _SubscribeStepperButton(
                              icon: Icons.add_rounded,
                              filled: true,
                              enabled: _seats < widget.args.maxSeats,
                              onTap: () => setState(() => _seats++),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Numéro de contact'.tr(context),
                          style: _detailText(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(width: 1, color: fieldBorder),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                '+237',
                                style: _detailText(fontSize: 17, fontWeight: FontWeight.w800),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                alignment: Alignment.centerLeft,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(width: 1, color: fieldBorder),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  cursorColor: const Color(0xFF16A34A),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(9),
                                  ],
                                  decoration: InputDecoration(
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    isCollapsed: true,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    hintText: '6XXXXXXXX',
                                    hintStyle: _detailText(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFB7C0B9),
                                    ),
                                  ),
                                  style: _detailText(fontSize: 17, fontWeight: FontWeight.w800),
                                  onChanged: (_) {
                                    if (_phoneError != null) {
                                      setState(() => _phoneError = null);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_phoneError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _phoneError!,
                            style: _detailText(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(width: 1, color: Color(0xFFE7EAE3)),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$placesLabel × ${formatPriceF(unitPrice)}',
                                      style: _detailText(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF54615A),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formatPriceF(total),
                                    style: _detailText(fontSize: 17, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Total'.tr(context),
                                      style: _detailText(fontSize: 18, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  Text(
                                    formatPriceF(total),
                                    style: _detailText(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Material(
                      color: const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(28),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: state.isSubscribing ? null : () => _submit(context),
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          alignment: Alignment.center,
                          child: state.isSubscribing
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Confirmer la demande'.tr(context),
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
            },
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final phone = '+237${_phoneController.text.trim()}';
    if (!_kPhonePattern.hasMatch(phone)) {
      setState(() => _phoneError = 'Numéro invalide. Format attendu : +237 6/7/8/9XXXXXXXX'.tr(context));
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

class _SubscribeBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SubscribeBackButton({required this.onTap});

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

class _SubscribeStepperButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final bool enabled;
  final VoidCallback onTap;

  const _SubscribeStepperButton({
    required this.icon,
    required this.filled,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = !enabled
        ? const Color(0xFFF1F1EA)
        : filled
        ? const Color(0xFF16A34A)
        : Colors.white;
    final fg = !enabled
        ? const Color(0xFFB7C0B9)
        : filled
        ? Colors.white
        : const Color(0xFF101512);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: filled || !enabled
                ? null
                : Border.all(color: const Color(0xFFDEE2DA), width: 1.2),
          ),
          child: Icon(icon, size: 20, color: fg),
        ),
      ),
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
  Timer? _ticker;
  Duration? _remaining;
  bool _expirySnackShown = false;

  @override
  void initState() {
    super.initState();
    _cubit.loadBooking(widget.bookingId);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tickCountdown());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _cubit.close();
    super.dispose();
  }

  void _tickCountdown() {
    final booking = _cubit.state.booking;
    final expiresAt = booking?.expiresAt;
    if (booking == null ||
        expiresAt == null ||
        (booking.status != IntercityBookingStatus.pending &&
            booking.status != IntercityBookingStatus.pendingPayment)) {
      if (_remaining != null && mounted) setState(() => _remaining = null);
      return;
    }
    final remaining = expiresAt.difference(DateTime.now());
    if (!mounted) return;
    setState(() => _remaining = remaining.isNegative ? Duration.zero : remaining);
    if (!_expirySnackShown && remaining.inMinutes <= 5 && remaining.inSeconds > 0) {
      _expirySnackShown = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            remaining.inMinutes <= 1
                ? 'Votre place expire dans moins d’une minute.'.tr(context)
                : Localizations.localeOf(context).languageCode == 'en' ? 'Your seat expires in ${remaining.inMinutes} min.' : 'Votre place expire dans ${remaining.inMinutes} min.',
          ),
          backgroundColor: const Color(0xFFB45309),
        ),
      );
    }
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
              if (state.isBookingLoading && state.booking == null) {
                return const AppLoading();
              }
              final booking = state.booking;
              if (booking == null) {
                return AppErrorView(
                  message: (state.bookingErrorMessage ?? 'Réservation introuvable.').tr(context),
                  onRetry: () => _cubit.loadBooking(widget.bookingId),
                );
              }
              final announcement = state.announcement?.id == booking.announcementId
                  ? state.announcement
                  : null;
              final needsPaymentLock =
                  booking.status == IntercityBookingStatus.pending ||
                  booking.status == IntercityBookingStatus.pendingPayment;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 14, left: 20, right: 20),
                    child: Row(
                      children: [
                        _DetailBackButton(onTap: () => context.pop()),
                        const SizedBox(width: 14),
                        Text(
                          'Ma réservation'.tr(context),
                          style: _detailText(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      children: [
                        _BookingTripSummaryCard(booking: booking, announcement: announcement),
                        if (needsPaymentLock && _remaining != null) ...[
                          const SizedBox(height: 14),
                          _PaymentLockBanner(remaining: _remaining!),
                        ],
                        if (state.itineraryStatus == IntercityItineraryStatus.ready &&
                            state.itinerary != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            'APERÇU DU TRAJET'.tr(context),
                            style: _detailText(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF7A857E),
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 180,
                            child: IntercityItineraryMap(itinerary: state.itinerary!),
                          ),
                        ] else if (announcement?.departureLat != null &&
                            announcement?.departureLon != null) ...[
                          const SizedBox(height: 14),
                          _MapCoordsHint(
                            lat: announcement!.departureLat!,
                            lon: announcement.departureLon!,
                            label: announcement.departureCity,
                          ),
                        ],
                        const SizedBox(height: 24),
                        _BookingTimeline(booking: booking, announcement: announcement),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: _BookingActions(
                      booking: booking,
                      announcement: announcement,
                      onCancel: () => _confirmCancel(context, booking),
                    ),
                  ),
                ],
              );
            },
          ),
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
              Text(
                'Annuler cette réservation ?'.tr(context),
                style: _detailText(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: "Motif de l'annulation".tr(context),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryAuthButton(
                label: 'Confirmer'.tr(context),
                backgroundColor: AppColors.error,
                onPressed: () => Navigator.of(sheetContext).pop(true),
              ),
              const SizedBox(height: 10),
              SecondaryAuthButton(
                label: 'Retour'.tr(context),
                onPressed: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      final reason = reasonController.text.trim().isEmpty
          ? 'Annulation demandée'.tr(context)
          : reasonController.text.trim();
      await _cubit.cancelBooking(booking.id, reason);
    }
  }
}

class _PaymentLockBanner extends StatelessWidget {
  final Duration remaining;

  const _PaymentLockBanner({required this.remaining});

  @override
  Widget build(BuildContext context) {
    final mm = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hh = remaining.inHours;
    final label = hh > 0 ? '${hh.toString().padLeft(2, '0')}:$mm:$ss' : '$mm:$ss';
    final urgent = remaining.inMinutes < 5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: urgent ? const Color(0xFFFFF7ED) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: urgent ? const Color(0xFFFDBA74) : const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_outlined,
            color: urgent ? const Color(0xFFC2410C) : const Color(0xFFCA8A04),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Place verrouillée'.tr(context),
                  style: _detailText(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  remaining == Duration.zero ? 'Délai de paiement expiré'.tr(context) : '${Localizations.localeOf(context).languageCode == "en" ? "Expires in" : "Expire dans"} $label',
                  style: _detailText(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: urgent ? const Color(0xFFC2410C) : const Color(0xFFCA8A04),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCoordsHint extends StatelessWidget {
  final double lat;
  final double lon;
  final String label;

  const _MapCoordsHint({required this.lat, required this.lon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE7EAE3)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.place_rounded, color: Color(0xFF16A34A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label · ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}',
              style: _detailText(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF54615A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingActions extends StatelessWidget {
  final IntercityBooking booking;
  final IntercityAnnouncement? announcement;
  final VoidCallback onCancel;

  const _BookingActions({
    required this.booking,
    required this.announcement,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final needsPay =
        booking.status == IntercityBookingStatus.pending ||
        booking.status == IntercityBookingStatus.pendingPayment ||
        booking.status == IntercityBookingStatus.confirmed;
    final canTrack = booking.tripId != null && booking.tripId!.isNotEmpty;
    final showReceipt = booking.status == IntercityBookingStatus.paid;

    return Column(
      children: [
        if (needsPay) ...[
          Material(
            color: const Color(0xFF16A34A),
            borderRadius: BorderRadius.circular(999),
            elevation: 8,
            shadowColor: const Color(0x8C16A34A),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                final amount = announcement == null
                    ? null
                    : announcement!.priceFcfa * booking.seatsRequested;
                context.push(
                  RouteConstants.walletPayPath(booking.id),
                  extra: PayBookingArgs(
                    bookingId: booking.id,
                    amount: amount,
                    label: announcement?.route,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                alignment: Alignment.center,
                child: Text(
                  'Payer maintenant'.tr(context),
                  style: _detailText(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (canTrack) ...[
          Material(
            color: const Color(0xFF101512),
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => context.push(RouteConstants.tripTrackPath(booking.tripId!)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                alignment: Alignment.center,
                child: Text(
                  'Suivre le trajet'.tr(context),
                  style: _detailText(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (showReceipt) ...[
          OutlinedButton(
            onPressed: () => context.push(RouteConstants.walletReceiptPath(booking.id)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF16A34A),
              side: const BorderSide(color: Color(0xFFBBF7D0), width: 1.5),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Text(
              'Voir le reçu'.tr(context),
              style: _detailText(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF16A34A),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (booking.status.isCancellable) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF101512),
                side: const BorderSide(color: Color(0xFFDDE3DA), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text('Annuler'.tr(context), style: _detailText(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextButton(
          onPressed: () => context.go(RouteConstants.home),
          child: Text(
            "Retour à l'accueil".tr(context),
            style: _detailText(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF54615A),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingTripSummaryCard extends StatelessWidget {
  final IntercityBooking booking;
  final IntercityAnnouncement? announcement;

  const _BookingTripSummaryCard({required this.booking, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final routeLabel = announcement?.route ?? 'Trajet'.tr(context);
    final total = announcement == null ? null : announcement!.priceFcfa * booking.seatsRequested;
    final metaParts = <String>[
      if (announcement != null) formatDayMonth(announcement!.departureDate, context: context),
      if (announcement != null) announcement!.formattedDepartureTime,
      Localizations.localeOf(context).languageCode == 'en' ? '${booking.seatsRequested} seat${booking.seatsRequested > 1 ? 's' : ''}' : '${booking.seatsRequested} place${booking.seatsRequested > 1 ? 's' : ''}',
      if (total != null) formatPriceF(total),
    ];

    return Container(
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
            children: [
              Expanded(
                child: Text(
                  routeLabel,
                  style: _detailText(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              _BookingStatusBadge(status: booking.status),
            ],
          ),
          if (metaParts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              metaParts.join(' • '),
              style: _detailText(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF54615A),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingStatusBadge extends StatelessWidget {
  final IntercityBookingStatus status;

  const _BookingStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      IntercityBookingStatus.pending => (
        'En attente'.tr(context),
        const Color(0xFFB45309),
        const Color(0xFFFFF7ED),
      ),
      IntercityBookingStatus.confirmed || IntercityBookingStatus.pendingPayment => (
        'Confirmée'.tr(context),
        const Color(0xFF16A34A),
        const Color(0xFFEFFAF3),
      ),
      IntercityBookingStatus.paid => ('Payée'.tr(context), const Color(0xFF16A34A), const Color(0xFFEFFAF3)),
      IntercityBookingStatus.cancelled => (
        'Annulée'.tr(context),
        const Color(0xFFDC2626),
        const Color(0xFFFEF2F2),
      ),
      IntercityBookingStatus.expired => (
        'Expirée'.tr(context),
        const Color(0xFF6B7280),
        const Color(0xFFF3F4F6),
      ),
      IntercityBookingStatus.unknown => (
        status.label,
        const Color(0xFF6B7280),
        const Color(0xFFF3F4F6),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: _detailText(fontSize: 13, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

enum _TimelineStepVisual { done, payment, pending, cancelled }

class _TimelineStepData {
  final String label;
  final String? subtitle;
  final _TimelineStepVisual visual;
  final bool accentSubtitle;

  const _TimelineStepData({
    required this.label,
    required this.visual,
    this.subtitle,
    this.accentSubtitle = false,
  });
}

class _BookingTimeline extends StatelessWidget {
  final IntercityBooking booking;
  final IntercityAnnouncement? announcement;

  const _BookingTimeline({required this.booking, this.announcement});

  @override
  Widget build(BuildContext context) {
    final steps = _stepsFor(context, booking, announcement);
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _TimelineRow(step: steps[i], isLast: i == steps.length - 1),
      ],
    );
  }

  List<_TimelineStepData> _stepsFor(BuildContext context, IntercityBooking booking, IntercityAnnouncement? announcement) {
    final locked =
        booking.confirmedAt != null ||
        booking.status == IntercityBookingStatus.confirmed ||
        booking.status == IntercityBookingStatus.pendingPayment ||
        booking.status == IntercityBookingStatus.paid;
    final paymentRequested =
        booking.status == IntercityBookingStatus.pendingPayment ||
        booking.status == IntercityBookingStatus.confirmed ||
        booking.status == IntercityBookingStatus.paid;
    final paid = booking.status == IntercityBookingStatus.paid;
    final cancelled = booking.status == IntercityBookingStatus.cancelled;
    final expired = booking.status == IntercityBookingStatus.expired;
    final departureLabel = announcement == null
        ? null
        : '${formatDayMonth(announcement.departureDate, context: context)} · ${announcement.formattedDepartureTime}';

    return [
      _TimelineStepData(
        label: 'Demande créée'.tr(context),
        subtitle: booking.requestedAt == null ? null : formatRelativeDayTime(booking.requestedAt!, context: context),
        visual: _TimelineStepVisual.done,
      ),
      _TimelineStepData(
        label: 'Place verrouillée'.tr(context),
        subtitle: booking.confirmedAt == null
            ? (locked ? 'Place réservée'.tr(context) : 'En attente du transporteur'.tr(context))
            : formatRelativeDayTime(booking.confirmedAt!, context: context),
        visual: locked ? _TimelineStepVisual.done : _TimelineStepVisual.pending,
      ),
      if (cancelled || expired)
        _TimelineStepData(
          label: cancelled ? 'Annulée'.tr(context) : 'Expirée'.tr(context),
          subtitle: booking.cancelledAt == null
              ? null
              : formatRelativeDayTime(booking.cancelledAt!, context: context),
          visual: _TimelineStepVisual.cancelled,
        )
      else ...[
        _TimelineStepData(
          label: 'Paiement demandé'.tr(context),
          subtitle: paymentRequested
              ? 'À régler via Wallet avant le départ'.tr(context)
              : 'Après confirmation du transporteur'.tr(context),
          visual: paid
              ? _TimelineStepVisual.done
              : paymentRequested
              ? _TimelineStepVisual.payment
              : _TimelineStepVisual.pending,
          accentSubtitle: paymentRequested && !paid,
        ),
        _TimelineStepData(
          label: 'Paiement confirmé'.tr(context),
          subtitle: paid ? 'Wallet · payé'.tr(context) : null,
          visual: paid ? _TimelineStepVisual.done : _TimelineStepVisual.pending,
        ),
        _TimelineStepData(
          label: 'Départ prévu'.tr(context),
          subtitle: departureLabel,
          visual: paid ? _TimelineStepVisual.done : _TimelineStepVisual.pending,
        ),
        _TimelineStepData(
          label: 'Trajet terminé'.tr(context),
          subtitle: booking.tripId != null ? 'Suivi disponible'.tr(context) : null,
          visual: _TimelineStepVisual.pending,
        ),
      ],
    ];
  }
}

class _TimelineRow extends StatelessWidget {
  final _TimelineStepData step;
  final bool isLast;

  const _TimelineRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final connectorColor = switch (step.visual) {
      _TimelineStepVisual.done => const Color(0xFF16A34A),
      _TimelineStepVisual.payment => const Color(0xFFEAB308),
      _TimelineStepVisual.cancelled => const Color(0xFFDC2626),
      _TimelineStepVisual.pending => const Color(0xFFD8DED6),
    };
    final labelColor = switch (step.visual) {
      _TimelineStepVisual.pending => const Color(0xFF9AA49D),
      _TimelineStepVisual.payment => const Color(0xFFCA8A04),
      _ => const Color(0xFF101512),
    };
    final subtitleColor = switch (step.visual) {
      _TimelineStepVisual.payment => const Color(0xFFCA8A04),
      _TimelineStepVisual.pending => const Color(0xFF9AA49D),
      _ => const Color(0xFF6B756E),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _TimelineDot(visual: step.visual),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: connectorColor.withValues(alpha: 0.55),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.label,
                    style: _detailText(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: labelColor,
                    ),
                  ),
                  if (step.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      step.subtitle!,
                      style: _detailText(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                      ),
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

class _TimelineDot extends StatelessWidget {
  final _TimelineStepVisual visual;

  const _TimelineDot({required this.visual});

  @override
  Widget build(BuildContext context) {
    return switch (visual) {
      _TimelineStepVisual.done => Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
      ),
      _TimelineStepVisual.payment => Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFEAB308), width: 2),
        ),
        alignment: Alignment.center,
        child: const MotodigoWalletYellowIcon(size: 18),
      ),
      _TimelineStepVisual.cancelled => Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
      ),
      _TimelineStepVisual.pending => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD8DED6), width: 2),
        ),
      ),
    };
  }
}
