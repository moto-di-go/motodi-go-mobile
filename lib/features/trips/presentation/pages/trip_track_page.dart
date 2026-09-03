import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/core/widgets/app_loading.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';
import 'package:motodi_go_mobile/features/trips/domain/entities/trip.dart';
import 'package:motodi_go_mobile/features/trips/presentation/cubit/trip_track_cubit.dart';
import 'package:motodi_go_mobile/features/trips/presentation/cubit/trip_track_state.dart';
import 'package:motodi_go_mobile/features/trips/presentation/widgets/trip_track_map.dart';

TextStyle _trackText({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = const Color(0xFF101512),
  double? height,
}) {
  return GoogleFonts.outfit(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
  );
}

class TripTrackPage extends StatelessWidget {
  final String tripId;

  const TripTrackPage({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TripTrackCubit>()..start(tripId),
      child: const _TripTrackView(),
    );
  }
}

class _TripTrackView extends StatelessWidget {
  const _TripTrackView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF6),
      body: BlocBuilder<TripTrackCubit, TripTrackState>(
        builder: (context, state) {
          if (state.isLoading) return const AppLoading();
          final trip = state.trip;
          if (trip == null) {
            return AppErrorView(
              message: state.errorMessage ?? 'Trajet introuvable.',
              onRetry: () => context.read<TripTrackCubit>().refresh(),
            );
          }
          if (state.isCompleted) {
            return _CompletedTripView(trip: trip);
          }
          return Stack(
            children: [
              Positioned.fill(child: TripTrackMap(trip: trip)),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () =>
                            context.canPop() ? context.pop() : context.go(RouteConstants.intercity),
                      ),
                      const Spacer(),
                      _ConnectionChip(mode: state.connectionMode),
                    ],
                  ),
                ),
              ),
              DraggableScrollableSheet(
                initialChildSize: 0.38,
                minChildSize: 0.22,
                maxChildSize: 0.72,
                builder: (context, controller) {
                  return _TripBottomSheet(
                    trip: trip,
                    events: state.events,
                    nextStep: state.nextStepLabel,
                    scrollController: controller,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompletedTripView extends StatelessWidget {
  final Trip trip;

  const _CompletedTripView({required this.trip});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _RoundIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => context.go(RouteConstants.intercity),
              ),
            ),
            const Spacer(),
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xFFE8F8EE), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, size: 44, color: Color(0xFF16A34A)),
            ),
            const SizedBox(height: 22),
            Text(
              'Trajet terminé',
              textAlign: TextAlign.center,
              style: _trackText(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              trip.routeLabel,
              textAlign: TextAlign.center,
              style: _trackText(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF54615A),
              ),
            ),
            if (trip.finalPriceFcfa != null) ...[
              const SizedBox(height: 8),
              Text(
                formatPriceF(trip.finalPriceFcfa!),
                textAlign: TextAlign.center,
                style: _trackText(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
            const Spacer(),
            Material(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  final rated = trip.driverProfileId ?? trip.transporterProfileId;
                  context.push(RouteConstants.tripRatePath(trip.id), extra: rated);
                },
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  child: Text(
                    'Noter',
                    style: _trackText(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                if (trip.bookingId != null) {
                  context.push(RouteConstants.walletReceiptPath(trip.bookingId!));
                } else {
                  context.push(RouteConstants.receipts);
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF101512),
                side: const BorderSide(color: Color(0xFFDDE3DA), width: 1.5),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: Text(
                'Voir reçu',
                style: _trackText(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(RouteConstants.tripsHistory),
              child: Text(
                'Retour à l’historique',
                style: _trackText(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripBottomSheet extends StatelessWidget {
  final Trip trip;
  final List<TripEvent> events;
  final String nextStep;
  final ScrollController scrollController;

  const _TripBottomSheet({
    required this.trip,
    required this.events,
    required this.nextStep,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAF6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Color(0x1A101512), blurRadius: 24, offset: Offset(0, -4))],
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD8DED6),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  trip.routeLabel,
                  style: _trackText(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              _TripStatusBadge(status: trip.status),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Color(0xFFE7EAE3)),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prochaine étape',
                  style: _trackText(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7A857E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nextStep,
                  style: _trackText(fontSize: 15, fontWeight: FontWeight.w600, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Suivi', style: _trackText(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _TripStatusTimeline(current: trip.status),
          if (events.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Événements', style: _trackText(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            for (final event in events.take(6))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.label,
                        style: _trackText(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      formatRelativeDayTime(event.occurredAt),
                      style: _trackText(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8B968D),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TripStatusTimeline extends StatelessWidget {
  final TripStatus current;

  const _TripStatusTimeline({required this.current});

  static const _steps = [
    TripStatus.confirmed,
    TripStatus.approaching,
    TripStatus.onBoard,
    TripStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    if (current == TripStatus.cancelled) {
      return Text(
        'Trajet annulé',
        style: _trackText(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFDC2626),
        ),
      );
    }
    final activeIndex = current.timelineIndex.clamp(0, _steps.length - 1);
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          _TimelineRow(
            label: _steps[i].label,
            done: i <= activeIndex,
            isLast: i == _steps.length - 1,
            active: i == activeIndex,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  final bool isLast;

  const _TimelineRow({
    required this.label,
    required this.done,
    required this.active,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final color = done ? const Color(0xFF16A34A) : const Color(0xFFD8DED6);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: done ? const Color(0xFF16A34A) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? const Color(0xFFEAB308) : color,
                    width: active ? 2.5 : 2,
                  ),
                ),
                child: done ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: color.withValues(alpha: 0.55),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 1),
              child: Text(
                label,
                style: _trackText(
                  fontSize: 15,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: done ? const Color(0xFF101512) : const Color(0xFF9AA49D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripStatusBadge extends StatelessWidget {
  final TripStatus status;

  const _TripStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (status) {
      TripStatus.completed => (const Color(0xFF16A34A), const Color(0xFFEFFAF3)),
      TripStatus.cancelled => (const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
      TripStatus.approaching ||
      TripStatus.onBoard => (const Color(0xFFB45309), const Color(0xFFFFF7ED)),
      _ => (const Color(0xFF16A34A), const Color(0xFFEFFAF3)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        status.label,
        style: _trackText(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _ConnectionChip extends StatelessWidget {
  final TripConnectionMode mode;

  const _ConnectionChip({required this.mode});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (mode) {
      TripConnectionMode.live => ('En direct', const Color(0xFF16A34A)),
      TripConnectionMode.polling => ('Actualisation', const Color(0xFFB45309)),
      TripConnectionMode.offline => ('Hors ligne', const Color(0xFF6B7280)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: _trackText(fontSize: 13, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      shadowColor: const Color(0x22000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, size: 20, color: const Color(0xFF101512)),
        ),
      ),
    );
  }
}
