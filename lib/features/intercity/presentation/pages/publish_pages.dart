import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/core/widgets/app_error_view.dart';
import 'package:motodi_go_mobile/core/widgets/app_loading.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_announcement.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_booking.dart';
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_vehicle.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_publish_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/authenticated_network_image.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_figma_icons.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';
import 'package:share_plus/share_plus.dart';

// Role : Brouillon d'annonce constitue par la page de creation et confirme sur l'apercu.
class CreateAnnouncementDraft {
  final String departureCity;
  final String destinationCity;
  final String? departureQuarter;
  final DateTime departureDate;
  final String departureTime;
  final double priceFcfa;
  final int totalSeats;
  final IntercityVehicle vehicle;
  final String? instructions;

  const CreateAnnouncementDraft({
    required this.departureCity,
    required this.destinationCity,
    this.departureQuarter,
    required this.departureDate,
    required this.departureTime,
    required this.priceFcfa,
    required this.totalSeats,
    required this.vehicle,
    this.instructions,
  });
}

// ---------------------------------------------------------------------------
// 72 — IntercityPublishGuardPage
// ---------------------------------------------------------------------------
class IntercityPublishGuardPage extends StatefulWidget {
  const IntercityPublishGuardPage({super.key});

  @override
  State<IntercityPublishGuardPage> createState() => _IntercityPublishGuardPageState();
}

class _IntercityPublishGuardPageState extends State<IntercityPublishGuardPage> {
  late final IntercityPublishCubit _cubit = getIt<IntercityPublishCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.checkEligibility();
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
            'Publier une annonce',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
          ),
        ),
        body: BlocBuilder<IntercityPublishCubit, IntercityPublishState>(
          builder: (context, state) {
            if (state.isCheckingEligibility) return const AppLoading();
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              children: [
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: state.isEligible ? const Color(0xFFDDF5E6) : const Color(0xFFFBE3E5),
                      shape: BoxShape.circle,
                    ),
                    child: state.isEligible
                        ? const MotodigoAcceptGreenIcon(size: 52)
                        : const MotodigoLockIcon(size: 44, color: AppColors.error),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  state.isEligible ? 'Vous pouvez publier une annonce' : 'Publication non disponible',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  state.isEligible
                      ? 'Renseignez votre trajet, votre véhicule et vos disponibilités.'
                      : state.eligibilityReason ?? 'Votre profil ne remplit pas encore les conditions requises.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF8A968C), height: 1.4),
                ),
                const SizedBox(height: 28),
                if (state.vehicles.isNotEmpty) ...[
                  Text(
                    'MES VÉHICULES',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF9CA7A0),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final vehicle in state.vehicles)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _VehicleTile(vehicle: vehicle),
                    ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 20),
                PrimaryAuthButton(
                  label: state.isEligible ? 'Continuer' : 'Retour à l\'accueil',
                  onPressed: () {
                    if (state.isEligible) {
                      context.push(RouteConstants.intercityCreate, extra: _cubit);
                    } else {
                      context.go(RouteConstants.home);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  final IntercityVehicle vehicle;

  const _VehicleTile({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7ECE6)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AuthenticatedNetworkImage(path: vehicle.photoUrl, width: 52, height: 52),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.type, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(
                  '${vehicle.capacity ?? '—'} places · ${vehicle.isUsable ? 'Validé' : vehicle.validationStatus}',
                  style: TextStyle(
                    color: vehicle.isUsable ? AppColors.primary : const Color(0xFF9AA49D),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
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

// ---------------------------------------------------------------------------
// 73 — IntercityCreateAnnouncementPage
// ---------------------------------------------------------------------------
class IntercityCreateAnnouncementPage extends StatefulWidget {
  final IntercityPublishCubit cubit;

  const IntercityCreateAnnouncementPage({super.key, required this.cubit});

  @override
  State<IntercityCreateAnnouncementPage> createState() => _IntercityCreateAnnouncementPageState();
}

class _IntercityCreateAnnouncementPageState extends State<IntercityCreateAnnouncementPage> {
  final _departureController = TextEditingController();
  final _destinationController = TextEditingController();
  final _quarterController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController(text: '4');
  final _instructionsController = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  IntercityVehicle? _vehicle;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final usable = widget.cubit.state.vehicles.where((vehicle) => vehicle.isUsable).toList();
    if (usable.isNotEmpty) _vehicle = usable.first;
  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    _quarterController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usableVehicles = widget.cubit.state.vehicles.where((vehicle) => vehicle.isUsable).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text('Nouvelle annonce', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          _LabeledField(
            label: 'Ville de départ',
            child: TextField(controller: _departureController, decoration: const InputDecoration(hintText: 'Ex : Douala')),
          ),
          const SizedBox(height: 14),
          _LabeledField(
            label: 'Ville de destination',
            child: TextField(controller: _destinationController, decoration: const InputDecoration(hintText: 'Ex : Yaoundé')),
          ),
          const SizedBox(height: 14),
          _LabeledField(
            label: 'Quartier de départ (optionnel)',
            child: TextField(controller: _quarterController, decoration: const InputDecoration(hintText: 'Ex : Bonanjo')),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Date',
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(),
                      child: Text(_date == null ? 'Choisir' : formatShortDate(_date!)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LabeledField(
                  label: 'Heure',
                  child: InkWell(
                    onTap: _pickTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(),
                      child: Text(_time == null ? 'Choisir' : _time!.format(context)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: 'Prix par siège (FCFA)',
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Ex : 6000'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LabeledField(
                  label: 'Sièges disponibles',
                  child: TextField(
                    controller: _seatsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Ex : 4'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _LabeledField(
            label: 'Véhicule',
            child: usableVehicles.isEmpty
                ? const Text('Aucun véhicule validé disponible', style: TextStyle(color: AppColors.error))
                : DropdownButtonFormField<IntercityVehicle>(
                    initialValue: _vehicle,
                    decoration: const InputDecoration(),
                    items: [
                      for (final vehicle in usableVehicles)
                        DropdownMenuItem(
                          value: vehicle,
                          child: Text('${vehicle.type} · ${vehicle.capacity ?? '—'} places'),
                        ),
                    ],
                    onChanged: (value) => setState(() => _vehicle = value),
                  ),
          ),
          const SizedBox(height: 14),
          _LabeledField(
            label: 'Instructions (optionnel)',
            child: TextField(
              controller: _instructionsController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Ex : Bagages limités, point de rendez-vous...'),
            ),
          ),
          if (_formError != null) ...[
            const SizedBox(height: 14),
            Text(_formError!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: 28),
          PrimaryAuthButton(label: 'Aperçu', onPressed: _goToPreview),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) setState(() => _time = picked);
  }

  void _goToPreview() {
    final departure = _departureController.text.trim();
    final destination = _destinationController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final seats = int.tryParse(_seatsController.text.trim());

    if (departure.isEmpty || destination.isEmpty) {
      setState(() => _formError = 'Renseignez la ville de départ et de destination.');
      return;
    }
    if (_date == null || _time == null) {
      setState(() => _formError = 'Choisissez une date et une heure de départ.');
      return;
    }
    if (price == null || price < 0) {
      setState(() => _formError = 'Le prix par siège est invalide.');
      return;
    }
    if (seats == null || seats <= 0) {
      setState(() => _formError = 'Le nombre de sièges est invalide.');
      return;
    }
    if (_vehicle == null) {
      setState(() => _formError = 'Sélectionnez un véhicule.');
      return;
    }
    setState(() => _formError = null);

    final time = _time!;
    final draft = CreateAnnouncementDraft(
      departureCity: departure,
      destinationCity: destination,
      departureQuarter: _quarterController.text.trim().isEmpty ? null : _quarterController.text.trim(),
      departureDate: _date!,
      departureTime:
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
      priceFcfa: price,
      totalSeats: seats,
      vehicle: _vehicle!,
      instructions: _instructionsController.text.trim().isEmpty ? null : _instructionsController.text.trim(),
    );
    context.push(RouteConstants.intercityPreview, extra: (widget.cubit, draft));
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8A968C), fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 74 — IntercityPreviewPage
// ---------------------------------------------------------------------------
class IntercityPreviewPage extends StatelessWidget {
  final IntercityPublishCubit cubit;
  final CreateAnnouncementDraft draft;

  const IntercityPreviewPage({super.key, required this.cubit, required this.draft});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: const Text('Aperçu', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
        ),
        body: BlocConsumer<IntercityPublishCubit, IntercityPublishState>(
          listener: (context, state) {
            if (state.createStatus == IntercityCreateStatus.success && state.createdAnnouncement != null) {
              context.pushReplacement(RouteConstants.intercityPublishSuccess, extra: state.createdAnnouncement);
            }
            if (state.createStatus == IntercityCreateStatus.failure && state.createErrorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.createErrorMessage!)));
            }
          },
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE7ECE6)),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${draft.departureCity} → ${draft.destinationCity}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            formatPriceFcfa(draft.priceFcfa),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const Divider(height: 28, color: Color(0xFFF1F2ED)),
                      _PreviewRow(label: 'Date', value: formatWeekdayDate(draft.departureDate)),
                      _PreviewRow(label: 'Heure', value: draft.departureTime.substring(0, 5)),
                      if (draft.departureQuarter != null)
                        _PreviewRow(label: 'Quartier', value: draft.departureQuarter!),
                      _PreviewRow(label: 'Sièges', value: '${draft.totalSeats}'),
                      _PreviewRow(label: 'Véhicule', value: '${draft.vehicle.type} · ${draft.vehicle.capacity ?? '—'} places'),
                      if (draft.instructions != null) _PreviewRow(label: 'Instructions', value: draft.instructions!),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                PrimaryAuthButton(
                  label: 'Publier l\'annonce',
                  isLoading: state.isCreating,
                  onPressed: () => cubit.createAnnouncement(
                    departureCity: draft.departureCity,
                    destinationCity: draft.destinationCity,
                    departureQuarter: draft.departureQuarter,
                    departureDate: draft.departureDate,
                    departureTime: draft.departureTime,
                    priceFcfa: draft.priceFcfa,
                    totalSeats: draft.totalSeats,
                    vehicleId: draft.vehicle.id,
                    instructions: draft.instructions,
                  ),
                ),
                const SizedBox(height: 12),
                SecondaryAuthButton(label: 'Modifier', onPressed: () => context.pop()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Color(0xFF8A968C), fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 75 — IntercityPublishSuccessPage
// ---------------------------------------------------------------------------
class IntercityPublishSuccessPage extends StatelessWidget {
  final IntercityAnnouncement announcement;

  const IntercityPublishSuccessPage({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const MotodigoCheckCircleGreenIcon(size: 96),
              const SizedBox(height: 24),
              Text(
                'Annonce publiée !',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${announcement.route} · ${formatShortDate(announcement.departureDate)} à ${announcement.formattedDepartureTime}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8A968C), height: 1.4),
              ),
              const Spacer(),
              SecondaryAuthButton(
                label: 'Partager',
                icon: Icons.ios_share_rounded,
                onPressed: () => _share(context),
              ),
              const SizedBox(height: 12),
              PrimaryAuthButton(
                label: 'Voir mes annonces',
                onPressed: () => context.go(RouteConstants.intercityMyAnnouncements),
              ),
              const SizedBox(height: 12),
              SecondaryAuthButton(
                label: "Retour à l'accueil",
                onPressed: () => context.go(RouteConstants.home),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    final text =
        'Trajet ${announcement.route} le ${formatShortDate(announcement.departureDate)} à '
        '${announcement.formattedDepartureTime} · ${formatPriceFcfa(announcement.priceFcfa)} — Moto\'di Go';
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
      }
    }
  }
}

// ---------------------------------------------------------------------------
// 76 — IntercityMyAnnouncementsPage
// ---------------------------------------------------------------------------
class IntercityMyAnnouncementsPage extends StatefulWidget {
  const IntercityMyAnnouncementsPage({super.key});

  @override
  State<IntercityMyAnnouncementsPage> createState() => _IntercityMyAnnouncementsPageState();
}

class _IntercityMyAnnouncementsPageState extends State<IntercityMyAnnouncementsPage> {
  late final IntercityPublishCubit _cubit = getIt<IntercityPublishCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.loadMyAnnouncements();
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
            'Mes annonces',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => context.push(RouteConstants.intercityPublishGuard),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
        body: BlocBuilder<IntercityPublishCubit, IntercityPublishState>(
          builder: (context, state) {
            if (state.isLoadingMine && state.myAnnouncements.isEmpty) return const AppLoading();
            if (state.myAnnouncements.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 60),
                  Center(child: MotodigoSearchEmptyIcon(size: 96)),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Vous n'avez publié aucune annonce",
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              );
            }
            return RefreshIndicator(
              onRefresh: () => _cubit.loadMyAnnouncements(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 90),
                itemCount: state.myAnnouncements.length,
                itemBuilder: (context, index) {
                  final announcement = state.myAnnouncements[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _MyAnnouncementCard(
                      announcement: announcement,
                      onTap: () => context.push(RouteConstants.intercityIncomingBookings, extra: announcement.id),
                      onClose: announcement.status.isActive
                          ? () => _cubit.closeAnnouncement(announcement.id)
                          : null,
                      onCancel: announcement.status.isActive
                          ? () => _cubit.cancelAnnouncement(announcement.id)
                          : null,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MyAnnouncementCard extends StatelessWidget {
  final IntercityAnnouncement announcement;
  final VoidCallback onTap;
  final VoidCallback? onClose;
  final VoidCallback? onCancel;

  const _MyAnnouncementCard({
    required this.announcement,
    required this.onTap,
    this.onClose,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE7ECE6)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    announcement.route,
                    style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                ),
                _StatusBadge(status: announcement.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${formatShortDate(announcement.departureDate)} · ${announcement.formattedDepartureTime} · ${announcement.remainingSeats}/${announcement.totalSeats} places',
              style: const TextStyle(color: Color(0xFF8A968C), fontSize: 13, fontWeight: FontWeight.w600),
            ),
            if (onClose != null || onCancel != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (onClose != null)
                    Expanded(
                      child: OutlinedButton(onPressed: onClose, child: const Text('Clôturer')),
                    ),
                  if (onClose != null && onCancel != null) const SizedBox(width: 10),
                  if (onCancel != null)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                        onPressed: onCancel,
                        child: const Text('Annuler'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AnnouncementStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AnnouncementStatus.published => AppColors.primary,
      AnnouncementStatus.full => const Color(0xFFF59E0B),
      AnnouncementStatus.closed => const Color(0xFF9AA49D),
      AnnouncementStatus.cancelled => AppColors.error,
      AnnouncementStatus.draft => const Color(0xFF9AA49D),
      AnnouncementStatus.unknown => const Color(0xFF9AA49D),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
      child: Text(status.label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
    );
  }
}

// ---------------------------------------------------------------------------
// 77 — IntercityIncomingBookingsPage
// ---------------------------------------------------------------------------
class IntercityIncomingBookingsPage extends StatefulWidget {
  final String announcementId;

  const IntercityIncomingBookingsPage({super.key, required this.announcementId});

  @override
  State<IntercityIncomingBookingsPage> createState() => _IntercityIncomingBookingsPageState();
}

class _IntercityIncomingBookingsPageState extends State<IntercityIncomingBookingsPage> {
  late final IntercityPublishCubit _cubit = getIt<IntercityPublishCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.loadIncomingBookings(widget.announcementId);
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
            'Réservations reçues',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
          ),
        ),
        body: BlocBuilder<IntercityPublishCubit, IntercityPublishState>(
          builder: (context, state) {
            if (state.isLoadingIncoming && state.incomingBookings.isEmpty) return const AppLoading();
            if (state.incomingStatus == IntercityIncomingStatus.failure) {
              return AppErrorView(
                message: state.incomingErrorMessage ?? 'Impossible de charger les réservations.',
                onRetry: () => _cubit.loadIncomingBookings(widget.announcementId),
              );
            }
            if (state.incomingBookings.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 60),
                  Center(child: MotodigoSearchEmptyIcon(size: 96)),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Aucune réservation pour cette annonce',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              itemCount: state.incomingBookings.length,
              itemBuilder: (context, index) {
                final booking = state.incomingBookings[index];
                final processing = state.processingBookingIds.contains(booking.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _IncomingBookingCard(
                    booking: booking,
                    processing: processing,
                    onConfirm: booking.status == IntercityBookingStatus.pending
                        ? () => _cubit.confirmIncomingBooking(booking.id)
                        : null,
                    onCancel: booking.status.isCancellable
                        ? () => _cubit.cancelIncomingBooking(booking.id, 'Refusée par le transporteur')
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _IncomingBookingCard extends StatelessWidget {
  final IntercityBooking booking;
  final bool processing;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _IncomingBookingCard({
    required this.booking,
    required this.processing,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7ECE6)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MotodigoPeopleIcon(size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${booking.seatsRequested} siège(s) · ${booking.contactPhone}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              Text(
                booking.status.label,
                style: TextStyle(color: _statusColor(booking.status), fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
          ),
          if (onConfirm != null || onCancel != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onConfirm != null)
                  Expanded(
                    child: FilledButton(
                      onPressed: processing ? null : onConfirm,
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                      child: processing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Confirmer'),
                    ),
                  ),
                if (onConfirm != null && onCancel != null) const SizedBox(width: 10),
                if (onCancel != null)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                      onPressed: processing ? null : onCancel,
                      child: const Text('Refuser'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
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
