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
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_booking_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/authenticated_network_image.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_itinerary_map.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_figma_icons.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';
import 'package:motodi_go_mobile/features/profiles/domain/entities/validation_status.dart';

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

class _DetailContent extends StatelessWidget {
  final IntercityAnnouncement announcement;
  final IntercityItineraryStatus itineraryStatus;
  final IntercityItinerary? itinerary;

  const _DetailContent({
    required this.announcement,
    required this.itineraryStatus,
    this.itinerary,
  });

  @override
  Widget build(BuildContext context) {
    final profiles = getIt<SessionCubit>().state.session?.profiles ?? const [];
    final activeProfile = getIt<SessionCubit>().state.activeProfile;
    final kycValidated = activeProfile?.validationStatus == ValidationStatus.validated;
    final ownedByMe = profiles.any((profile) => profile.id == announcement.publisherProfileId);
    final hasSeats = !ownedByMe && announcement.hasSeatsAvailable && announcement.status.isActive;
    final agency = announcement.publisherDisplayName?.trim().isNotEmpty == true
        ? announcement.publisherDisplayName!
        : 'Transporteur';
    final ptRamassage = announcement.ptRamassage?.trim();
    final metaParts = <String>[
      '${formatDayMonth(announcement.departureDate)} ${announcement.departureDate.year}',
      announcement.formattedDepartureTime,
      if (ptRamassage != null && ptRamassage.isNotEmpty) 'Pt. Ramassage $ptRamassage',
    ];
    final metaLine = metaParts.join(' · ');
    final ctaLabel = ownedByMe
        ? 'Émis par vous'
        : hasSeats
            ? 'Souscrire'
            : 'Complet';

    void openSubscribe() {
      if (!kycValidated) {
        showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Validation requise',
                style: _detailText(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              content: Text(
                'Validez votre pièce d’identité (CNI) pour souscrire à un trajet interurbain.',
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
                    'Plus tard',
                    style: _detailText(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF6B756E)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.push(RouteConstants.kyc);
                  },
                  child: Text(
                    'Valider mon profil',
                    style: _detailText(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF16A34A)),
                  ),
                ),
              ],
            );
          },
        );
        return;
      }
      context.push(
        RouteConstants.intercitySubscribe,
        extra: IntercitySubscribeArgs(
          announcementId: announcement.id,
          route: announcement.route,
          pricePerSeat: announcement.priceFcfa,
          maxSeats: announcement.remainingSeats,
        ),
      );
    }

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
                'ITINÉRAIRE',
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
              onTap: hasSeats ? openSubscribe : null,
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
        IntercityItineraryStatus.ready when itinerary != null => IntercityItineraryMap(itinerary: itinerary!),
        IntercityItineraryStatus.failure => const _ItineraryMessage(
            'Itinéraire routier indisponible pour le moment.',
          ),
        IntercityItineraryStatus.idle || IntercityItineraryStatus.loading => const Center(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFF16A34A)),
            ),
          ),
        _ => const _ItineraryMessage('Itinéraire routier indisponible pour le moment.'),
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
    final placesLabel = '$_seats place${_seats > 1 ? 's' : ''}';

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
                  RouteConstants.intercityBooking,
                  extra: state.createdBooking!.id,
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
                          'Validation requise',
                          style: _detailText(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        content: Text(
                          state.subscribeErrorMessage!,
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
                              'Fermer',
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
                              'Valider mon profil',
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.subscribeErrorMessage!)),
                  );
                }
              }
            },
            builder: (context, state) {
              final fieldBorder = _phoneError != null
                  ? AppColors.error
                  : const Color(0xFFE7EAE3);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 14, left: 20, right: 20),
                    child: Row(
                      children: [
                        _SubscribeBackButton(onTap: () => context.pop()),
                        const SizedBox(width: 14),
                        Text(
                          'Souscrire',
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
                                'Nombre de places',
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
                          'Numéro de contact',
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
                                      'Total',
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
                                  'Confirmer la demande',
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
                  message: state.bookingErrorMessage ?? 'Réservation introuvable.',
                  onRetry: () => _cubit.loadBooking(widget.bookingId),
                );
              }
              final announcement = state.announcement?.id == booking.announcementId
                  ? state.announcement
                  : null;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 14, left: 20, right: 20),
                    child: Row(
                      children: [
                        _DetailBackButton(onTap: () => context.pop()),
                        const SizedBox(width: 14),
                        Text(
                          'Ma réservation',
                          style: _detailText(fontSize: 22, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      children: [
                        _BookingTripSummaryCard(
                          booking: booking,
                          announcement: announcement,
                        ),
                        const SizedBox(height: 24),
                        _BookingTimeline(booking: booking),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      children: [
                        if (booking.status.isCancellable) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => _confirmCancel(context, booking),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF101512),
                                side: const BorderSide(color: Color(0xFFDDE3DA), width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.close_rounded, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Annuler la réservation',
                                    style: _detailText(fontSize: 17, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Material(
                          color: const Color(0xFF101512),
                          borderRadius: BorderRadius.circular(999),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => context.go(RouteConstants.home),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              alignment: Alignment.center,
                              child: Text(
                                "Retour à l'accueil",
                                style: _detailText(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                'Annuler cette réservation ?',
                style: _detailText(fontSize: 20, fontWeight: FontWeight.w800),
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
              SecondaryAuthButton(
                label: 'Retour',
                onPressed: () => Navigator.of(sheetContext).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true && context.mounted) {
      final reason =
          reasonController.text.trim().isEmpty ? 'Annulation demandée' : reasonController.text.trim();
      await _cubit.cancelBooking(booking.id, reason);
    }
  }
}

class _BookingTripSummaryCard extends StatelessWidget {
  final IntercityBooking booking;
  final IntercityAnnouncement? announcement;

  const _BookingTripSummaryCard({required this.booking, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final routeLabel = announcement?.route ?? 'Trajet';
    final total = announcement == null
        ? null
        : announcement!.priceFcfa * booking.seatsRequested;
    final metaParts = <String>[
      if (announcement != null) formatDayMonth(announcement!.departureDate),
      if (announcement != null) announcement!.formattedDepartureTime,
      '${booking.seatsRequested} place${booking.seatsRequested > 1 ? 's' : ''}',
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
          'En attente',
          const Color(0xFFB45309),
          const Color(0xFFFFF7ED),
        ),
      IntercityBookingStatus.confirmed || IntercityBookingStatus.pendingPayment => (
          'Confirmée',
          const Color(0xFF16A34A),
          const Color(0xFFEFFAF3),
        ),
      IntercityBookingStatus.paid => (
          'Payée',
          const Color(0xFF16A34A),
          const Color(0xFFEFFAF3),
        ),
      IntercityBookingStatus.cancelled => (
          'Annulée',
          const Color(0xFFDC2626),
          const Color(0xFFFEF2F2),
        ),
      IntercityBookingStatus.expired => (
          'Expirée',
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
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

  const _BookingTimeline({required this.booking});

  @override
  Widget build(BuildContext context) {
    final steps = _stepsFor(booking);
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          _TimelineRow(
            step: steps[i],
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }

  List<_TimelineStepData> _stepsFor(IntercityBooking booking) {
    final confirmed = booking.confirmedAt != null ||
        booking.status == IntercityBookingStatus.confirmed ||
        booking.status == IntercityBookingStatus.pendingPayment ||
        booking.status == IntercityBookingStatus.paid;
    final paid = booking.status == IntercityBookingStatus.paid;
    final cancelled = booking.status == IntercityBookingStatus.cancelled;

    return [
      _TimelineStepData(
        label: 'Demande envoyée',
        subtitle: booking.requestedAt == null ? null : formatRelativeDayTime(booking.requestedAt!),
        visual: _TimelineStepVisual.done,
      ),
      _TimelineStepData(
        label: 'Confirmée par le transporteur',
        subtitle: booking.confirmedAt == null ? null : formatRelativeDayTime(booking.confirmedAt!),
        visual: confirmed ? _TimelineStepVisual.done : _TimelineStepVisual.pending,
      ),
      if (cancelled)
        _TimelineStepData(
          label: 'Annulée',
          subtitle: booking.cancelledAt == null ? null : formatRelativeDayTime(booking.cancelledAt!),
          visual: _TimelineStepVisual.cancelled,
        )
      else if (paid)
        const _TimelineStepData(
          label: 'Payée / terminée',
          visual: _TimelineStepVisual.done,
        )
      else if (confirmed)
        const _TimelineStepData(
          label: 'Paiement',
          subtitle: 'À régler via Wallet avant le départ',
          visual: _TimelineStepVisual.payment,
          accentSubtitle: true,
        )
      else
        const _TimelineStepData(
          label: 'Paiement',
          visual: _TimelineStepVisual.pending,
        ),
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
          decoration: const BoxDecoration(
            color: Color(0xFF16A34A),
            shape: BoxShape.circle,
          ),
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
          decoration: const BoxDecoration(
            color: Color(0xFFDC2626),
            shape: BoxShape.circle,
          ),
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
