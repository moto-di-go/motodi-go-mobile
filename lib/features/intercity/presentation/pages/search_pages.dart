import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/widgets/app_loading.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/search_filters.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_booking_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_search_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/city_autocomplete_field.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_figma_icons.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';

const List<String> _kPopularCities = ['Yaoundé', 'Douala', 'Bafoussam', 'Bamenda', 'Garoua'];

TextStyle _resultsText({
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

/// True si l'annonce a été publiée par l'un des profils du compte connecté.
bool _isOwnAnnouncement(IntercityAnnouncement announcement) {
  final profiles = getIt<SessionCubit>().state.session?.profiles ?? const [];
  return profiles.any((profile) => profile.id == announcement.publisherProfileId);
}

// ---------------------------------------------------------------------------
// 65 — IntercityHubPage
// ---------------------------------------------------------------------------
class IntercityHubPage extends StatelessWidget {
  const IntercityHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<IntercitySearchCubit>(),
      child: const _IntercityHubView(),
    );
  }
}

class _IntercityHubView extends StatefulWidget {
  const _IntercityHubView();

  @override
  State<_IntercityHubView> createState() => _IntercityHubViewState();
}

class _IntercityHubViewState extends State<_IntercityHubView> {
  int _tabIndex = 0;
  final _departureController = TextEditingController();
  final _destinationController = TextEditingController();
  late final IntercityBookingCubit _bookingCubit = getIt<IntercityBookingCubit>();

  @override
  void initState() {
    super.initState();
    _bookingCubit.loadMyBookings();
  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    _bookingCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchCubit = context.read<IntercitySearchCubit>();
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14, left: 18, right: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trajets',
                    style: _resultsText(fontSize: 32, fontWeight: FontWeight.w800, height: 1.1),
                  ),
                  const SizedBox(height: 16),
                  _SegmentedToggle(
                    index: _tabIndex,
                    labels: const ['Rechercher', 'Mes réservations'],
                    onChanged: (index) => setState(() => _tabIndex = index),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _tabIndex == 0
                  ? _SearchForm(
                      cubit: searchCubit,
                      departureController: _departureController,
                      destinationController: _destinationController,
                    )
                  : BlocProvider.value(value: _bookingCubit, child: const _MyBookingsTab()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchForm extends StatefulWidget {
  final IntercitySearchCubit cubit;
  final TextEditingController departureController;
  final TextEditingController destinationController;

  const _SearchForm({
    required this.cubit,
    required this.departureController,
    required this.destinationController,
  });

  @override
  State<_SearchForm> createState() => _SearchFormState();
}

class _SearchFormState extends State<_SearchForm> {
  DateTime? _date;
  int _seats = 2;
  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFE7EAE3)),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Column(
                  children: [
                    CityAutocompleteField(
                      leading: const MotodigoLocationGreenIcon(size: 46),
                      label: 'Ville de départ',
                      controller: widget.departureController,
                      hint: 'Ex : Yaoundé',
                      textStyle: const TextStyle(
                        color: Color(0xFF101512),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintStyle: TextStyle(
                          color: Color(0xFFB0B8B1),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      color: const Color(0xFFECEEE8),
                    ),
                    CityAutocompleteField(
                      leading: const MotodigoLocationRedIcon(size: 46),
                      label: 'Ville de destination',
                      controller: widget.destinationController,
                      hint: 'Ex : Douala',
                      textStyle: const TextStyle(
                        color: Color(0xFF101512),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintStyle: TextStyle(
                          color: Color(0xFFB0B8B1),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DatePlacesCard(
                      onTap: _pickDate,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              MotodigoDateGrayIcon(size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Date',
                                style: TextStyle(
                                  color: Color(0xFF8A968C),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _date == null ? 'Choisir' : formatShortDate(_date!),
                            style: const TextStyle(
                              color: Color(0xFF101512),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePlacesCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              MotodigoPeopleGrayIcon(size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Places',
                                style: TextStyle(
                                  color: Color(0xFF8A968C),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _SeatStepperButton(
                                label: '−',
                                onTap: _seats > 1 ? () => setState(() => _seats--) : null,
                              ),
                              Text(
                                '$_seats',
                                style: const TextStyle(
                                  color: Color(0xFF101512),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              _SeatStepperButton(
                                label: '+',
                                onTap: _seats < 9 ? () => setState(() => _seats++) : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              const Text(
                'DESTINATIONS POPULAIRES',
                style: TextStyle(
                  color: Color(0xFF98A29A),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final city in _kPopularCities)
                    _PopularChip(
                      label: city,
                      onTap: () => setState(() => widget.destinationController.text = city),
                    ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _searching ? null : () => _search(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF16A34A).withValues(alpha: 0.6),
                elevation: 0,
                shadowColor: const Color(0x8C16A34A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: _searching
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.6, color: Colors.white),
                    )
                  : const Text(
                      'Rechercher',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _search(BuildContext context) async {
    final departure = widget.departureController.text.trim();
    final destination = widget.destinationController.text.trim();
    widget.cubit.updateFilters(
      (current) => current.copyWith(
        departureCity: departure.isEmpty ? null : departure,
        clearDepartureCity: departure.isEmpty,
        destinationCity: destination.isEmpty ? null : destination,
        clearDestinationCity: destination.isEmpty,
        date: _date,
        clearDate: _date == null,
        seats: _seats,
      ),
    );
    setState(() => _searching = true);
    await widget.cubit.search();
    if (!context.mounted) return;
    setState(() => _searching = false);
    final route = widget.cubit.state.isEmptyResult
        ? RouteConstants.intercityEmpty
        : RouteConstants.intercityResults;
    await context.push(route, extra: widget.cubit);
  }
}

class _DatePlacesCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _DatePlacesCard({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE7EAE3)),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap, child: card);
  }
}

class _SeatStepperButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SeatStepperButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1EA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: onTap == null ? const Color(0xFFB0B8B1) : const Color(0xFF101512),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _MyBookingsTab extends StatelessWidget {
  const _MyBookingsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IntercityBookingCubit, IntercityBookingState>(
      builder: (context, state) {
        if (state.isMyBookingsLoading && state.myBookings.isEmpty) {
          return const AppLoading();
        }
        if (state.myBookings.isEmpty) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(28, 48, 28, 28),
            children: [
              const Center(child: MotodigoSearchEmptyIcon(size: 96)),
              const SizedBox(height: 28),
              Text(
                'Aucune réservation',
                textAlign: TextAlign.center,
                style: _resultsText(fontSize: 26, fontWeight: FontWeight.w800, height: 1.25),
              ),
              const SizedBox(height: 12),
              Text(
                'Recherchez un trajet pour réserver votre premier siège.',
                textAlign: TextAlign.center,
                style: _resultsText(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF54615A),
                  height: 1.45,
                ),
              ),
            ],
          );
        }
        return RefreshIndicator(
          onRefresh: () => context.read<IntercityBookingCubit>().loadMyBookings(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
            itemCount: state.myBookings.length,
            itemBuilder: (context, index) {
              final booking = state.myBookings[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _BookingListTile(
                  booking: booking,
                  onTap: () => context.push(RouteConstants.intercityBooking, extra: booking.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _BookingListTile extends StatelessWidget {
  final IntercityBooking booking;
  final VoidCallback onTap;

  const _BookingListTile({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final seatsLabel =
        '${booking.seatsRequested} place${booking.seatsRequested > 1 ? 's' : ''} réservée${booking.seatsRequested > 1 ? 's' : ''}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 14, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const MotodigoPeopleIcon(size: 18, color: Color(0xFF16A34A)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    seatsLabel,
                                    style: _resultsText(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          _MyBookingStatusBadge(status: booking.status),
                        ],
                      ),
                      if (booking.requestedAt != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          formatRelativeDayTime(booking.requestedAt!),
                          style: _resultsText(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF8B968D),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFB9C1B7), size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MyBookingStatusBadge extends StatelessWidget {
  final IntercityBookingStatus status;

  const _MyBookingStatusBadge({required this.status});

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
        const Color(0xFFE8F8EE),
      ),
      IntercityBookingStatus.paid => ('Payée', const Color(0xFF16A34A), const Color(0xFFE8F8EE)),
      IntercityBookingStatus.cancelled => (
        'Annulée',
        const Color(0xFFDC2626),
        const Color(0xFFFEF2F2),
      ),
      IntercityBookingStatus.expired => (
        'Expirée',
        const Color(0xFF6B756E),
        const Color(0xFFEEEEE6),
      ),
      IntercityBookingStatus.unknown => (
        status.label,
        const Color(0xFF6B756E),
        const Color(0xFFEEEEE6),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: _resultsText(fontSize: 12, fontWeight: FontWeight.w700, color: fg, height: 1.1),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 67 — IntercityResultsPage
// ---------------------------------------------------------------------------
class IntercityResultsPage extends StatefulWidget {
  final IntercitySearchCubit cubit;

  const IntercityResultsPage({super.key, required this.cubit});

  @override
  State<IntercityResultsPage> createState() => _IntercityResultsPageState();
}

class _IntercityResultsPageState extends State<IntercityResultsPage> {
  bool _redirectingToEmpty = false;

  @override
  void initState() {
    super.initState();
    if (widget.cubit.state.status == IntercitySearchStatus.initial ||
        widget.cubit.state.status == IntercitySearchStatus.failure) {
      widget.cubit.search();
    } else if (widget.cubit.state.isEmptyResult) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goToEmpty());
    }
  }

  void _goToEmpty() {
    if (!mounted || _redirectingToEmpty) return;
    _redirectingToEmpty = true;
    context.pushReplacement(RouteConstants.intercityEmpty, extra: widget.cubit);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: BlocConsumer<IntercitySearchCubit, IntercitySearchState>(
        listener: (context, state) {
          if (state.isEmptyResult) {
            _goToEmpty();
          }
        },
        builder: (context, state) {
          if (state.isEmptyResult || _redirectingToEmpty) {
            return const Scaffold(backgroundColor: Color(0xFFFAFAF6), body: AppLoading());
          }

          final routeTitle = state.filters.hasRoute
              ? '${state.filters.departureCity ?? 'Partout'} → ${state.filters.destinationCity ?? 'Partout'}'
              : 'Résultats';
          final dateLabel = state.filters.date != null
              ? formatDayMonth(state.filters.date!)
              : 'Toutes dates';
          final countLabel =
              '${state.results.length} annonce${state.results.length > 1 ? 's' : ''} · $dateLabel';

          return Scaffold(
            backgroundColor: const Color(0xFFFAFAF6),
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ResultsBackButton(onTap: () => context.pop()),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                routeTitle,
                                overflow: TextOverflow.ellipsis,
                                style: _resultsText(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  letterSpacing: -0.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          countLabel,
                          style: _resultsText(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF757575),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.isLoading)
                    const Expanded(child: AppLoading())
                  else
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 200) {
                            context.read<IntercitySearchCubit>().loadMore();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                          itemCount: state.results.length + (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.results.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            }
                            final announcement = state.results[index];
                            final ownedByMe = _isOwnAnnouncement(announcement);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 11),
                              child: _AnnouncementCard(
                                announcement: announcement,
                                ownedByMe: ownedByMe,
                                onTap: ownedByMe
                                    ? null
                                    : () => context.push(
                                        RouteConstants.intercityDetail,
                                        extra: announcement.id,
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ResultsBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ResultsBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1EA),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 19, color: Color(0xFF101512)),
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final IntercityAnnouncement announcement;
  final VoidCallback? onTap;
  final bool ownedByMe;

  const _AnnouncementCard({
    required this.announcement,
    required this.onTap,
    this.ownedByMe = false,
  });

  @override
  Widget build(BuildContext context) {
    final ptRamassage = announcement.ptRamassage?.trim();
    final timeLine = ptRamassage == null || ptRamassage.isEmpty
        ? announcement.formattedDepartureTime
        : '${announcement.formattedDepartureTime} · $ptRamassage';
    final vehicleLabel = [
      if (announcement.vehicleType != null && announcement.vehicleType!.trim().isNotEmpty)
        announcement.vehicleType,
      if (announcement.vehicleCapacity != null) '${announcement.vehicleCapacity} places',
    ].join(' · ');
    final seatsColor = announcement.remainingSeats <= 2
        ? const Color(0xFF8A6410)
        : const Color(0xFF15803D);

    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: const Color(0x14101512),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
          decoration: ShapeDecoration(
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
                    child: Text(
                      timeLine,
                      style: _resultsText(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF16A34A),
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    formatPriceF(announcement.priceFcfa),
                    style: _resultsText(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF16A34A),
                      height: 1.15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      announcement.route,
                      overflow: TextOverflow.ellipsis,
                      style: _resultsText(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF101512),
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (announcement.publisherVerified) ...[
                    const SizedBox(width: 8),
                    const MotodigoVerifiedIcon(size: 19),
                  ],
                  if (ownedByMe) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEEE6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Émis par vous',
                        style: _resultsText(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF54615A),
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      vehicleLabel.isEmpty ? 'Véhicule' : vehicleLabel,
                      style: _resultsText(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8A968C),
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${announcement.remainingSeats} place${announcement.remainingSeats > 1 ? 's' : ''} restante${announcement.remainingSeats > 1 ? 's' : ''}',
                    style: _resultsText(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: seatsColor,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 68 — IntercityEmptyResultsPage
// ---------------------------------------------------------------------------
class IntercityEmptyResultsPage extends StatelessWidget {
  final IntercitySearchCubit cubit;

  const IntercityEmptyResultsPage({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<IntercitySearchCubit, IntercitySearchState>(
        builder: (context, state) {
          final filters = state.filters;
          final from = filters.departureCity?.trim().isNotEmpty == true
              ? filters.departureCity!
              : 'Partout';
          final to = filters.destinationCity?.trim().isNotEmpty == true
              ? filters.destinationCity!
              : 'Partout';
          final datePart = filters.date != null ? ' le ${formatDayMonthLong(filters.date!)}' : '';

          // Toujours les 3 CTA Figma (indépendamment des filtres actifs).
          final actions = <_EmptyAction>[
            _EmptyAction(
              label: 'Changer de date',
              primary: true,
              onTap: () => _changeDate(context),
            ),
            _EmptyAction(label: 'Élargir le budget', onTap: () => _widenBudget(context)),
            _EmptyAction(label: 'Retirer le pt. ramassage', onTap: () => _dropPtRamassage(context)),
          ];

          final subtitleStyle = _resultsText(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF54615A),
            height: 1.5,
          );

          return Scaffold(
            backgroundColor: const Color(0xFFFAFAF6),
            body: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 4),
                      child: _ResultsBackButton(onTap: () => context.pop()),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const MotodigoSearchEmptyIcon(size: 96),
                            const SizedBox(height: 28),
                            Text(
                              'Aucune annonce trouvée',
                              textAlign: TextAlign.center,
                              style: _resultsText(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text.rich(
                                TextSpan(
                                  style: subtitleStyle,
                                  children: [
                                    const TextSpan(text: 'Aucun trajet '),
                                    TextSpan(text: from),
                                    const WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 6),
                                        child: MotodigoRightArrowGrayIcon(
                                          size: 14,
                                          color: Color(0xFF54615A),
                                        ),
                                      ),
                                    ),
                                    TextSpan(text: '$to$datePart avec ces critères.'),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 28),
                            for (var i = 0; i < actions.length; i++) ...[
                              if (i > 0) const SizedBox(height: 12),
                              _EmptyActionButton(action: actions[i]),
                            ],
                            const SizedBox(height: 22),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Les alertes trajets arriveront bientôt. Fonctionnalité en préparation.',
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const MotodigoBellGreenIcon(size: 22),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Créer une alerte sur ce trajet',
                                      style: _resultsText(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF16A34A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _changeDate(BuildContext context) async {
    final current = cubit.state.filters.date ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(DateTime.now()) ? DateTime.now() : current,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !context.mounted) return;
    cubit.updateFilters((f) => f.copyWith(date: picked));
    await cubit.search();
    if (!context.mounted) return;
    _navigateAfterSearch(context);
  }

  Future<void> _widenBudget(BuildContext context) async {
    final filters = cubit.state.filters;
    if (filters.maxPrice != null) {
      await _applyCode(context, 'RAISE_MAX_PRICE');
      return;
    }
    // Pas de plafond : élargir en incluant les annonces complètes si possible.
    final includeFull = cubit.state.wideningSuggestions.where((s) => s.code == 'INCLUDE_FULL');
    if (includeFull.isNotEmpty) {
      await _applySuggestion(context, includeFull.first);
      return;
    }
    cubit.updateFilters((f) => f.copyWith(onlyAvailable: false));
    await cubit.search();
    if (!context.mounted) return;
    _navigateAfterSearch(context);
  }

  Future<void> _dropPtRamassage(BuildContext context) async {
    if (cubit.state.filters.ptRamassage == null ||
        cubit.state.filters.ptRamassage!.trim().isEmpty) {
      cubit.updateFilters((f) => f.copyWith(clearDate: true, clearTimeSlot: true));
      await cubit.search();
      if (!context.mounted) return;
      _navigateAfterSearch(context);
      return;
    }
    await _applyCode(context, 'DROP_PT_RAMASSAGE');
  }

  Future<void> _applyCode(BuildContext context, String code) async {
    final match = cubit.state.wideningSuggestions.where((s) => s.code == code);
    final suggestion = match.isNotEmpty
        ? match.first
        : WideningSuggestion(code: code, message: '', suggestedQuery: const {});
    await _applySuggestion(context, suggestion);
  }

  Future<void> _applySuggestion(BuildContext context, WideningSuggestion suggestion) async {
    await cubit.applyWideningSuggestion(suggestion);
    if (!context.mounted) return;
    _navigateAfterSearch(context);
  }

  void _navigateAfterSearch(BuildContext context) {
    if (cubit.state.isEmptyResult) return;
    context.pushReplacement(RouteConstants.intercityResults, extra: cubit);
  }
}

class _EmptyAction {
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _EmptyAction({required this.label, required this.onTap, this.primary = false});
}

class _EmptyActionButton extends StatelessWidget {
  final _EmptyAction action;

  const _EmptyActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: action.primary ? const Color(0xFF16A34A) : Colors.white,
      borderRadius: BorderRadius.circular(999),
      elevation: action.primary ? 4 : 0,
      shadowColor: const Color(0x6616A34A),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: action.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: action.primary
                  ? BorderSide.none
                  : const BorderSide(width: 1.2, color: Color(0xFFDEE2DA)),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            action.label,
            textAlign: TextAlign.center,
            style: _resultsText(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: action.primary ? Colors.white : const Color(0xFF101512),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets partagés
// ---------------------------------------------------------------------------
class _SegmentedToggle extends StatelessWidget {
  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _SegmentedToggle({required this.index, required this.labels, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1EA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: index == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: index == i
                        ? const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: _resultsText(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: index == i ? const Color(0xFF101512) : const Color(0xFF8A968C),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PopularChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PopularChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1EA),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF3C4741),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
