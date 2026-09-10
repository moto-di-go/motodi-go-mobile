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
import 'package:motodi_go_mobile/features/intercity/domain/entities/intercity_vehicle.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/cubit/intercity_publish_cubit.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/city_autocomplete_field.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/authenticated_network_image.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_figma_icons.dart';
import 'package:motodi_go_mobile/features/intercity/presentation/widgets/intercity_formatters.dart';
import 'package:motodi_go_mobile/features/urban/data/urban_models.dart';
import 'package:share_plus/share_plus.dart';
import 'package:motodi_go_mobile/core/utils/extensions.dart';

TextStyle _publishText({
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

// Role : Brouillon d'annonce constitue par la page de creation et confirme sur l'apercu.
class CreateAnnouncementDraft {
  final String departureCity;
  final String destinationCity;
  final String? ptRamassage;
  final DateTime departureDate;
  final String departureTime;
  final double priceFcfa;
  final int totalSeats;
  final IntercityVehicle vehicle;
  final String? instructions;

  const CreateAnnouncementDraft({
    required this.departureCity,
    required this.destinationCity,
    this.ptRamassage,
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
          title: Text(
            'Publier une annonce'.tr(context),
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
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
                  state.isEligible
                      ? 'Vous pouvez publier une annonce'.tr(context)
                      : 'Publication non disponible'.tr(context),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  state.isEligible
                      ? 'Renseignez votre trajet, votre véhicule et vos disponibilités.'.tr(context)
                      : (state.eligibilityReason ??
                            'Votre profil ne remplit pas encore les conditions requises.')
                          .tr(context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF8A968C), height: 1.4),
                ),
                const SizedBox(height: 28),
                if (state.vehicles.isNotEmpty) ...[
                  Text(
                    'MES VÉHICULES'.tr(context),
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
                  label: state.isEligible ? 'Continuer'.tr(context) : 'Retour à l\'accueil'.tr(context),
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
                Text(
                  vehicle.type,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  Localizations.localeOf(context).languageCode == 'en'
                    ? '${vehicle.capacity ?? '—'} seats · ${vehicle.isUsable ? 'Validated' : vehicle.validationStatus}'
                    : '${vehicle.capacity ?? '—'} places · ${vehicle.isUsable ? 'Validé' : vehicle.validationStatus}',
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
  final _ptRamassageController = TextEditingController();
  final _priceController = TextEditingController();
  final _instructionsController = TextEditingController();
  UrbanPlace? _departurePlace;
  DateTime? _date;
  TimeOfDay? _time;
  IntercityVehicle? _vehicle;
  int _seats = 4;
  String? _formError;

  int get _maxSeats => _vehicle?.capacity ?? 50;

  @override
  void initState() {
    super.initState();
    final usable = widget.cubit.state.vehicles.where((vehicle) => vehicle.isUsable).toList();
    if (usable.isNotEmpty) {
      _vehicle = usable.first;
      _seats = (usable.first.capacity ?? 4).clamp(1, 50);
    }
  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    _ptRamassageController.dispose();
    _priceController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usableVehicles = widget.cubit.state.vehicles
        .where((vehicle) => vehicle.isUsable)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14, left: 20, right: 20),
              child: Row(
                children: [
                  _CreateBackButton(onTap: () => context.pop()),
                  const SizedBox(width: 14),
                  Text(
                    'Créer une annonce'.tr(context),
                    style: _publishText(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                clipBehavior: Clip.none,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                children: [
                  _CreateLabeledField(
                    label: 'Départ'.tr(context),
                    child: CityAutocompleteField(
                      controller: _departureController,
                      hint: 'Yaoundé',
                      minHeight: 56,
                      boxDecoration: _createFieldDecoration(),
                      boxPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      textStyle: _publishText(fontSize: 16, fontWeight: FontWeight.w700),
                      onPlaceSelected: (place) {
                        setState(() {
                          _departurePlace = place;
                          if (place == null) {
                            // Ville changée à la main : le ramassage doit être resaisi.
                            _ptRamassageController.clear();
                          }
                        });
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        hintStyle: _publishText(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB0B8B1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CreateLabeledField(
                    label: 'Destination'.tr(context),
                    child: CityAutocompleteField(
                      controller: _destinationController,
                      hint: 'Douala',
                      minHeight: 56,
                      boxDecoration: _createFieldDecoration(),
                      boxPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      textStyle: _publishText(fontSize: 16, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        hintStyle: _publishText(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB0B8B1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CreateLabeledField(
                    label: 'Pt. Ramassage'.tr(context),
                    child: CityAutocompleteField(
                      controller: _ptRamassageController,
                      hint: _departurePlace == null
                          ? 'Choisir d\'abord la ville de départ'.tr(context)
                          : 'Ex : quartier, carrefour…'.tr(context),
                      kind: null,
                      suggestionIcon: Icons.place_outlined,
                      requireBias: true,
                      biasLat: _departurePlace?.point.latitude,
                      biasLon: _departurePlace?.point.longitude,
                      missingBiasMessage: 'Choisissez d\'abord une ville de départ'.tr(context),
                      minHeight: 56,
                      leading: const MotodigoMapPinIcon(size: 20, color: Color(0xFF8A968C)),
                      boxDecoration: _createFieldDecoration(),
                      boxPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      textStyle: _publishText(fontSize: 16, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        hintStyle: _publishText(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB0B8B1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CreateLabeledField(
                          label: 'Date'.tr(context),
                          child: _CreateTapBox(
                            onTap: _pickDate,
                            prefix: const MotodigoCalendarIcon(size: 20, color: Color(0xFF8A968C)),
                            value: _date == null ? null : formatShortDate(_date!, context: context),
                            placeholder: 'Choisir'.tr(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CreateLabeledField(
                          label: 'Heure'.tr(context),
                          child: _CreateTapBox(
                            onTap: _pickTime,
                            prefix: const MotodigoClockIcon(size: 20, color: Color(0xFF8A968C)),
                            value: _time == null
                                ? null
                                : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}',
                            placeholder: 'Choisir'.tr(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _CreateLabeledField(
                    label: 'Véhicule'.tr(context),
                    child: usableVehicles.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: _createFieldDecoration(),
                            child: Text(
                              'Aucun véhicule validé disponible'.tr(context),
                              style: _publishText(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                          )
                        : _CreateVehiclePicker(
                            vehicles: usableVehicles,
                            selected: _vehicle,
                            onChanged: (vehicle) {
                              setState(() {
                                _vehicle = vehicle;
                                final max = vehicle.capacity ?? 50;
                                if (_seats > max) _seats = max;
                              });
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CreateLabeledField(
                          label: 'Places totales'.tr(context),
                          child: _CreateSeatsStepper(
                            seats: _seats,
                            maxSeats: _maxSeats,
                            onChanged: (value) => setState(() => _seats = value),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CreateLabeledField(
                          label: 'Prix / place'.tr(context),
                          child: _CreateTextBox(
                            controller: _priceController,
                            hint: '4 500',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            suffix: Text(
                              'F',
                              style: _publishText(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _CreateLabeledField(
                    label: 'Consignes'.tr(context),
                    child: _CreateTextBox(
                      controller: _instructionsController,
                      hint: 'Présentez-vous 15 min avant le départ...'.tr(context),
                      maxLines: 4,
                      minHeight: 110,
                    ),
                  ),
                  if (_formError != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _formError!,
                      style: _publishText(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Material(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: _goToPreview,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    alignment: Alignment.center,
                    child: Text(
                      'Prévisualiser'.tr(context),
                      style: _publishText(
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
        ),
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
    final priceRaw = _priceController.text.trim().replaceAll(' ', '');
    final price = double.tryParse(priceRaw);

    if (departure.isEmpty || destination.isEmpty) {
      setState(() => _formError = 'Renseignez le départ et la destination.'.tr(context));
      return;
    }
    if (_date == null || _time == null) {
      setState(() => _formError = 'Choisissez une date et une heure de départ.'.tr(context));
      return;
    }
    if (price == null || price < 0) {
      setState(() => _formError = 'Le prix par place est invalide.'.tr(context));
      return;
    }
    if (_seats <= 0) {
      setState(() => _formError = 'Le nombre de places est invalide.'.tr(context));
      return;
    }
    if (_vehicle == null) {
      setState(() => _formError = 'Sélectionnez un véhicule.'.tr(context));
      return;
    }
    setState(() => _formError = null);

    final time = _time!;
    final draft = CreateAnnouncementDraft(
      departureCity: departure,
      destinationCity: destination,
      ptRamassage: _ptRamassageController.text.trim().isEmpty
          ? null
          : _ptRamassageController.text.trim(),
      departureDate: _date!,
      departureTime:
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00',
      priceFcfa: price,
      totalSeats: _seats,
      vehicle: _vehicle!,
      instructions: _instructionsController.text.trim().isEmpty
          ? null
          : _instructionsController.text.trim(),
    );
    context.push(RouteConstants.intercityPreview, extra: (widget.cubit, draft));
  }
}

ShapeDecoration _createFieldDecoration() {
  return ShapeDecoration(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      side: const BorderSide(width: 1, color: Color(0xFFE7EAE3)),
      borderRadius: BorderRadius.circular(16),
    ),
  );
}

class _CreateBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateBackButton({required this.onTap});

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

class _CreateLabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _CreateLabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _publishText(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF54615A),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _CreateTextBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget? suffix;
  final int maxLines;
  final double? minHeight;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _CreateTextBox({
    required this.controller,
    required this.hint,
    this.suffix,
    this.maxLines = 1,
    this.minHeight,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight ?? 56),
      padding: EdgeInsets.fromLTRB(16, 4, suffix != null ? 14 : 16, 4),
      alignment: maxLines == 1 ? Alignment.centerLeft : Alignment.topLeft,
      decoration: _createFieldDecoration(),
      child: Row(
        crossAxisAlignment: maxLines == 1 ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              cursorColor: const Color(0xFF16A34A),
              textCapitalization: keyboardType == TextInputType.number
                  ? TextCapitalization.none
                  : TextCapitalization.words,
              style: _publishText(fontSize: 16, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: maxLines == 1 ? 14 : 12),
                hintText: hint,
                hintStyle: _publishText(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB0B8B1),
                ),
              ),
            ),
          ),
          if (suffix != null) ...[const SizedBox(width: 8), suffix!],
        ],
      ),
    );
  }
}

class _CreateTapBox extends StatelessWidget {
  final VoidCallback onTap;
  final Widget? prefix;
  final String? value;
  final String placeholder;

  const _CreateTapBox({required this.onTap, required this.placeholder, this.prefix, this.value});

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: prefix != null ? 14 : 16),
          decoration: _createFieldDecoration(),
          child: Row(
            children: [
              if (prefix != null) ...[prefix!, const SizedBox(width: 10)],
              Expanded(
                child: Text(
                  hasValue ? value! : placeholder,
                  style: _publishText(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: hasValue ? const Color(0xFF101512) : const Color(0xFFB0B8B1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateVehiclePicker extends StatelessWidget {
  final List<IntercityVehicle> vehicles;
  final IntercityVehicle? selected;
  final ValueChanged<IntercityVehicle> onChanged;

  const _CreateVehiclePicker({
    required this.vehicles,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _createFieldDecoration(),
      child: Row(
        children: [
          const MotodigoVanIcon(size: 22, color: Color(0xFF8A968C)),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<IntercityVehicle>(
                value: selected,
                isExpanded: true,
                icon: const MotodigoChevronDownIcon(size: 18, color: Color(0xFF5B6760)),
                style: _publishText(fontSize: 16, fontWeight: FontWeight.w700),
                items: [
                  for (final vehicle in vehicles)
                    DropdownMenuItem(
                      value: vehicle,
                      child: Text(
                        Localizations.localeOf(context).languageCode == 'en' ? '${vehicle.type} · ${vehicle.capacity ?? '—'} seats' : '${vehicle.type} · ${vehicle.capacity ?? '—'} places',
                        overflow: TextOverflow.ellipsis,
                        style: _publishText(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateSeatsStepper extends StatelessWidget {
  final int seats;
  final int maxSeats;
  final ValueChanged<int> onChanged;

  const _CreateSeatsStepper({required this.seats, required this.maxSeats, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: _createFieldDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CreateSeatButton(label: '−', enabled: seats > 1, onTap: () => onChanged(seats - 1)),
          Text('$seats', style: _publishText(fontSize: 18, fontWeight: FontWeight.w800)),
          _CreateSeatButton(
            label: '+',
            enabled: seats < maxSeats,
            onTap: () => onChanged(seats + 1),
          ),
        ],
      ),
    );
  }
}

class _CreateSeatButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _CreateSeatButton({required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1EA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: _publishText(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: enabled ? const Color(0xFF101512) : const Color(0xFFB0B8B1),
          ),
        ),
      ),
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
        backgroundColor: const Color(0xFFFAFAF6),
        body: SafeArea(
          child: BlocConsumer<IntercityPublishCubit, IntercityPublishState>(
            listener: (context, state) {
              if (state.createStatus == IntercityCreateStatus.success &&
                  state.createdAnnouncement != null) {
                context.pushReplacement(
                  RouteConstants.intercityPublishSuccess,
                  extra: state.createdAnnouncement,
                );
              }
              if (state.createStatus == IntercityCreateStatus.failure &&
                  state.createErrorMessage != null) {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    content: Text(state.createErrorMessage!.tr(context)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('OK'.tr(context)),
                      ),
                    ],
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 14, left: 20, right: 20),
                    child: Row(
                      children: [
                        _CreateBackButton(onTap: () => context.pop()),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            "Aperçu de l'annonce".tr(context),
                            style: _publishText(fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 28, color: Color(0xFFF1F2ED)),
                              _PreviewRow(
                                label: 'Date'.tr(context),
                                value: formatWeekdayDate(draft.departureDate, context: context),
                              ),
                              _PreviewRow(
                                label: 'Heure'.tr(context),
                                value: draft.departureTime.substring(0, 5),
                              ),
                              if (draft.ptRamassage != null)
                                _PreviewRow(label: 'Pt. Ramassage'.tr(context), value: draft.ptRamassage!),
                              _PreviewRow(label: 'Sièges'.tr(context), value: '${draft.totalSeats}'),
                              _PreviewRow(
                                label: 'Véhicule'.tr(context),
                                value: Localizations.localeOf(context).languageCode == 'en'
                                    ? '${draft.vehicle.type} · ${draft.vehicle.capacity ?? '—'} seats'
                                    : '${draft.vehicle.type} · ${draft.vehicle.capacity ?? '—'} places',
                              ),
                              if (draft.instructions != null)
                                _PreviewRow(label: 'Instructions'.tr(context), value: draft.instructions!),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      children: [
                        PrimaryAuthButton(
                          label: "Publier l'annonce".tr(context),
                          isLoading: state.isCreating,
                          onPressed: () => cubit.createAnnouncement(
                            departureCity: draft.departureCity,
                            destinationCity: draft.destinationCity,
                            ptRamassage: draft.ptRamassage,
                            departureDate: draft.departureDate,
                            departureTime: draft.departureTime,
                            priceFcfa: draft.priceFcfa,
                            totalSeats: draft.totalSeats,
                            vehicleId: draft.vehicle.id,
                            instructions: draft.instructions,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SecondaryAuthButton(label: 'Modifier'.tr(context), onPressed: () => context.pop()),
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
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF8A968C), fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            ),
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
    final subtitle =
        Localizations.localeOf(context).languageCode == 'en'
        ? 'Your trip ${announcement.route} on ${formatDayMonthLong(announcement.departureDate, context: context)} '
        'is now visible to travelers.'
        : 'Votre trajet ${announcement.route} du ${formatDayMonthLong(announcement.departureDate, context: context)} '
        'est visible par les voyageurs.';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFFDDF5E6), shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 44, color: Color(0xFF16A34A)),
              ),
              const SizedBox(height: 22),
              Text(
                'Annonce publiée'.tr(context),
                textAlign: TextAlign.center,
                style: _publishText(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: _publishText(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF54615A),
                  height: 1.45,
                ),
              ),
              const Spacer(flex: 3),
              Material(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => context.push(RouteConstants.intercityMyAnnouncements),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    alignment: Alignment.center,
                    child: Text(
                      'Voir mes annonces'.tr(context),
                      style: _publishText(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => _share(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1.5, color: Color(0xFF101512)),
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const MotodigoShareIcon(size: 20, color: Color(0xFF101512)),
                        const SizedBox(width: 10),
                        Text(
                          'Partager'.tr(context),
                          style: _publishText(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () => context.push(RouteConstants.intercityPublishGuard),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF101512),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  'Créer une autre annonce'.tr(context),
                  style: _publishText(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF101512),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final date = formatShortDate(announcement.departureDate, context: context);
    final time = announcement.formattedDepartureTime;
    final price = formatPriceFcfa(announcement.priceFcfa);
    final text = isEn
        ? 'Trip ${announcement.route} on $date at $time · $price — Moto\'di Go'
        : 'Trajet ${announcement.route} le $date à $time · $price — Moto\'di Go';
    try {
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (_) {
      if (context.mounted) {
        showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Text(text),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('OK'.tr(context)),
              ),
            ],
          ),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// 76 — IntercityMyAnnouncementsPage
// ---------------------------------------------------------------------------
enum _MyAnnouncementsFilter { actives, completes, cloturees }

class IntercityMyAnnouncementsPage extends StatefulWidget {
  const IntercityMyAnnouncementsPage({super.key});

  @override
  State<IntercityMyAnnouncementsPage> createState() => _IntercityMyAnnouncementsPageState();
}

class _IntercityMyAnnouncementsPageState extends State<IntercityMyAnnouncementsPage> {
  late final IntercityPublishCubit _cubit = getIt<IntercityPublishCubit>();
  _MyAnnouncementsFilter _filter = _MyAnnouncementsFilter.actives;

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

  List<IntercityAnnouncement> _filtered(List<IntercityAnnouncement> items) {
    return items.where((a) {
      return switch (_filter) {
        _MyAnnouncementsFilter.actives => a.status == AnnouncementStatus.published,
        _MyAnnouncementsFilter.completes => a.status == AnnouncementStatus.full,
        _MyAnnouncementsFilter.cloturees =>
          a.status == AnnouncementStatus.closed || a.status == AnnouncementStatus.cancelled,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAF6),
        body: SafeArea(
          child: BlocBuilder<IntercityPublishCubit, IntercityPublishState>(
            builder: (context, state) {
              final filtered = _filtered(state.myAnnouncements);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Mes annonces'.tr(context),
                            style: _publishText(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ),
                        Material(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => context.push(RouteConstants.intercityPublishGuard),
                            child: const SizedBox(
                              width: 44,
                              height: 44,
                              child: Icon(Icons.add_rounded, color: Colors.white, size: 26),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Actives'.tr(context),
                            selected: _filter == _MyAnnouncementsFilter.actives,
                            onTap: () => setState(() => _filter = _MyAnnouncementsFilter.actives),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Complètes'.tr(context),
                            selected: _filter == _MyAnnouncementsFilter.completes,
                            onTap: () => setState(() => _filter = _MyAnnouncementsFilter.completes),
                          ),
                          const SizedBox(width: 8),
                          _FilterChip(
                            label: 'Clôturées'.tr(context),
                            selected: _filter == _MyAnnouncementsFilter.cloturees,
                            onTap: () => setState(() => _filter = _MyAnnouncementsFilter.cloturees),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: state.isLoadingMine && state.myAnnouncements.isEmpty
                        ? const AppLoading()
                        : filtered.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                              const SizedBox(height: 60),
                              const Center(child: MotodigoSearchEmptyIcon(size: 96)),
                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  state.myAnnouncements.isEmpty
                                      ? "Vous n'avez publié aucune annonce".tr(context)
                                      : 'Aucune annonce dans ce filtre'.tr(context),
                                  textAlign: TextAlign.center,
                                  style: _publishText(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          )
                        : RefreshIndicator(
                            onRefresh: () => _cubit.loadMyAnnouncements(),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final announcement = filtered[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _MyAnnouncementCard(
                                    announcement: announcement,
                                    onTap: () => context.push(
                                      RouteConstants.intercityIncomingBookings,
                                      extra: announcement.id,
                                    ),
                                  ),
                                );
                              },
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF101512) : const Color(0xFFEEEEE6),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          child: Text(
            label,
            style: _publishText(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF5C675F),
            ),
          ),
        ),
      ),
    );
  }
}

class _MyAnnouncementCard extends StatelessWidget {
  final IntercityAnnouncement announcement;
  final VoidCallback onTap;

  const _MyAnnouncementCard({required this.announcement, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final reserved = (announcement.totalSeats - announcement.remainingSeats).clamp(
      0,
      announcement.totalSeats,
    );
    final progress = announcement.totalSeats == 0 ? 0.0 : reserved / announcement.totalSeats;
    final isActive = announcement.status == AnnouncementStatus.published;
    final showOccupancy = announcement.status != AnnouncementStatus.cancelled;
    final routeColor = isActive ? const Color(0xFF16A34A) : const Color(0xFF101512);

    return Material(
      color: Colors.white,
      elevation: 0,
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
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        announcement.route,
                        style: _publishText(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: routeColor,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _AnnouncementStatusBadge(status: announcement.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${formatDayMonth(announcement.departureDate, context: context)} • ${announcement.formattedDepartureTime}',
                  style: _publishText(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8B968D),
                    height: 1.3,
                  ),
                ),
                if (showOccupancy) ...[
                  const SizedBox(height: 12),
                  Text(
                    Localizations.localeOf(context).languageCode == 'en' ? '$reserved/${announcement.totalSeats} seats booked' : '$reserved/${announcement.totalSeats} places réservées',
                    style: _publishText(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF54615A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE8ECE5),
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnnouncementStatusBadge extends StatelessWidget {
  final AnnouncementStatus status;

  const _AnnouncementStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      AnnouncementStatus.published => ('Active'.tr(context), const Color(0xFF16A34A), const Color(0xFFE8F8EE)),
      AnnouncementStatus.full => ('Complète'.tr(context), const Color(0xFFB45309), const Color(0xFFFFF7ED)),
      AnnouncementStatus.closed => ('Clôturée'.tr(context), const Color(0xFF6B756E), const Color(0xFFEEEEE6)),
      AnnouncementStatus.cancelled => ('Annulée'.tr(context), const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
      AnnouncementStatus.draft => ('Brouillon'.tr(context), const Color(0xFF6B756E), const Color(0xFFEEEEE6)),
      AnnouncementStatus.unknown => (
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
        style: _publishText(fontSize: 12, fontWeight: FontWeight.w700, color: fg, height: 1.1),
      ),
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
        backgroundColor: const Color(0xFFFAFAF6),
        body: SafeArea(
          child: BlocBuilder<IntercityPublishCubit, IntercityPublishState>(
            builder: (context, state) {
              final announcement = state.incomingAnnouncement;
              final subtitle = announcement == null
                  ? null
                  : '${announcement.route} · ${formatDayMonth(announcement.departureDate, context: context)} · ${announcement.formattedDepartureTime}';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _IncomingBackButton(onTap: () => context.pop()),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Réservations\nreçues'.tr(context),
                                style: _publishText(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  subtitle,
                                  textAlign: TextAlign.left,
                                  style: _publishText(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF8A968C),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _IncomingNotifButton(onTap: () => context.go(RouteConstants.notifications)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: state.isLoadingIncoming && state.incomingBookings.isEmpty
                        ? const AppLoading()
                        : state.incomingStatus == IntercityIncomingStatus.failure
                        ? AppErrorView(
                            message:
                                (state.incomingErrorMessage ??
                                        'Impossible de charger les réservations.')
                                    .tr(context),
                            onRetry: () => _cubit.loadIncomingBookings(widget.announcementId),
                          )
                        : state.incomingBookings.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.fromLTRB(28, 48, 28, 28),
                            children: [
                              const Center(child: MotodigoSearchEmptyIcon(size: 96)),
                              const SizedBox(height: 28),
                              Text(
                                'Aucune réservation'.tr(context),
                                textAlign: TextAlign.center,
                                style: _publishText(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Les demandes de places pour cette annonce apparaîtront ici.'.tr(context),
                                textAlign: TextAlign.center,
                                style: _publishText(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF54615A),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          )
                        : RefreshIndicator(
                            onRefresh: () => _cubit.loadIncomingBookings(widget.announcementId),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              itemCount: state.incomingBookings.length,
                              itemBuilder: (context, index) {
                                final booking = state.incomingBookings[index];
                                final processing = state.processingBookingIds.contains(booking.id);
                                final pricePerSeat = announcement?.priceFcfa;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _IncomingBookingCard(
                                    booking: booking,
                                    pricePerSeat: pricePerSeat,
                                    processing: processing,
                                    onConfirm: booking.status == IntercityBookingStatus.pending
                                        ? () => _cubit.confirmIncomingBooking(booking.id)
                                        : null,
                                    onCancel: booking.status == IntercityBookingStatus.pending
                                        ? () => _cubit.cancelIncomingBooking(
                                            booking.id,
                                            'Refusée par le transporteur'.tr(context),
                                          )
                                        : null,
                                  ),
                                );
                              },
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
}

class _IncomingBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _IncomingBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F1EA),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.arrow_back_rounded, size: 24, color: Color(0xFF101512)),
        ),
      ),
    );
  }
}

class _IncomingNotifButton extends StatelessWidget {
  final VoidCallback onTap;

  const _IncomingNotifButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F1EA),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              CustomPaint(size: Size.square(26), painter: _IncomingBellPainter(Color(0xFF101512))),
              Positioned(
                right: 11,
                top: 10,
                child: CircleAvatar(radius: 4, backgroundColor: Color(0xFFEF4444)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomingBellPainter extends CustomPainter {
  final Color color;
  const _IncomingBellPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 24;
    canvas.save();
    canvas.scale(s, s);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(
      Path()
        ..moveTo(6, 10.5)
        ..cubicTo(6, 6.9, 8.7, 4, 12, 4)
        ..cubicTo(15.3, 4, 18, 6.9, 18, 10.5)
        ..cubicTo(18, 14.5, 19.5, 16, 19.5, 16)
        ..lineTo(4.5, 16)
        ..cubicTo(4.5, 16, 6, 14.5, 6, 10.5),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(9.5, 19)
        ..cubicTo(9.5, 20.4, 10.6, 21.5, 12, 21.5)
        ..cubicTo(13.4, 21.5, 14.5, 20.4, 14.5, 19),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IncomingBellPainter oldDelegate) => oldDelegate.color != color;
}

class _IncomingBookingCard extends StatelessWidget {
  final IntercityBooking booking;
  final double? pricePerSeat;
  final bool processing;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _IncomingBookingCard({
    required this.booking,
    required this.pricePerSeat,
    required this.processing,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status == IntercityBookingStatus.pending;
    final isAccepted =
        booking.status == IntercityBookingStatus.confirmed ||
        booking.status == IntercityBookingStatus.pendingPayment ||
        booking.status == IntercityBookingStatus.paid;
    final showPrice = isAccepted && pricePerSeat != null;
    final total = showPrice ? pricePerSeat! * booking.seatsRequested : null;

    final cardBg = switch (booking.status) {
      IntercityBookingStatus.pending => const Color(0xFFFFF7ED),
      IntercityBookingStatus.confirmed ||
      IntercityBookingStatus.pendingPayment ||
      IntercityBookingStatus.paid => const Color(0xFFEFFAF3),
      IntercityBookingStatus.cancelled => const Color(0xFFFEF2F2),
      IntercityBookingStatus.expired => Colors.white,
      IntercityBookingStatus.unknown => Colors.white,
    };
    final avatarBg = isPending
        ? const Color(0xFFE8E4D9)
        : isAccepted
        ? const Color(0xFF16A34A)
        : booking.status == IntercityBookingStatus.cancelled
        ? const Color(0xFFFECACA)
        : const Color(0xFFE7EAE3);
    final avatarFg = isPending || booking.status == IntercityBookingStatus.expired
        ? const Color(0xFF54615A)
        : booking.status == IntercityBookingStatus.cancelled
        ? const Color(0xFFDC2626)
        : Colors.white;
    final seatsLabel =
        Localizations.localeOf(context).languageCode == 'en'
        ? '${booking.seatsRequested} seat${booking.seatsRequested > 1 ? 's' : ''} requested'
        : '${booking.seatsRequested} place${booking.seatsRequested > 1 ? 's' : ''} demandée${booking.seatsRequested > 1 ? 's' : ''}';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isAccepted || isPending ? cardBg : const Color(0xFFE7EAE3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: avatarBg,
            child: Text(
              booking.passengerInitials,
              style: _publishText(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: avatarFg,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.shortPassengerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _publishText(fontSize: 17, fontWeight: FontWeight.w800, height: 1.2),
                ),
                if (isPending) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8C2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'En attente'.tr(context),
                      style: _publishText(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  seatsLabel,
                  style: _publishText(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF8A968C),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isPending)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onCancel != null)
                  _IncomingSquareAction(
                    background: const Color(0xFFFEE2E2),
                    onTap: processing ? null : onCancel,
                    child: const Icon(Icons.close_rounded, size: 22, color: Color(0xFFEF4444)),
                  ),
                if (onCancel != null && onConfirm != null) const SizedBox(width: 8),
                if (onConfirm != null)
                  _IncomingSquareAction(
                    background: const Color(0xFF16A34A),
                    onTap: processing ? null : onConfirm,
                    child: processing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                          )
                        : const Icon(Icons.check_rounded, size: 22, color: Colors.white),
                  ),
              ],
            )
          else if (total != null)
            Text(
              formatPriceF(total),
              style: _publishText(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF16A34A),
              ),
            )
          else
            _IncomingCompactBadge(status: booking.status),
        ],
      ),
    );
  }
}

class _IncomingSquareAction extends StatelessWidget {
  final Color background;
  final VoidCallback? onTap;
  final Widget child;

  const _IncomingSquareAction({required this.background, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Center(child: child)),
      ),
    );
  }
}

class _IncomingCompactBadge extends StatelessWidget {
  final IntercityBookingStatus status;

  const _IncomingCompactBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      IntercityBookingStatus.cancelled => (
        'Refusée'.tr(context),
        const Color(0xFFDC2626),
        const Color(0xFFFEE2E2),
      ),
      IntercityBookingStatus.expired => (
        'Expirée'.tr(context),
        const Color(0xFF6B756E),
        const Color(0xFFEEEEE6),
      ),
      _ => (status.label, const Color(0xFF6B756E), const Color(0xFFEEEEE6)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: _publishText(fontSize: 12, fontWeight: FontWeight.w700, color: fg, height: 1.1),
      ),
    );
  }
}
