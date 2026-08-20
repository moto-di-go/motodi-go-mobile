import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/cubit/profile_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_figma_icons.dart';
import 'package:motodi_go_mobile/l10n/app_localizations.dart';

class MotoTaxiProfilePage extends StatelessWidget {
  const MotoTaxiProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<ProfileCubit>(), child: const _MotoTaxiProfileView());
  }
}

class _MotoTaxiProfileView extends StatefulWidget {
  const _MotoTaxiProfileView();

  @override
  State<_MotoTaxiProfileView> createState() => _MotoTaxiProfileViewState();
}

class _MotoTaxiProfileViewState extends State<_MotoTaxiProfileView> {
  final _nameController = TextEditingController(text: '');
  final _licenseController = TextEditingController();
  String _zone = 'Bastos, Yaoundé';

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: _onSaved,
      builder: (context, state) {
        return AuthScaffold(
          title: l10n.mototaxiProfileTitle,
          showBack: true,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          bottom: _DriverSubmitButton(
            label: l10n.mototaxiProfileSubmit,
            isLoading: state.isLoading,
            onPressed: () => context.read<ProfileCubit>().createMotoTaxi(
              displayName: _nameController.text,
              operatingZone: _zone,
              licenseNumber: _licenseController.text.trim().isEmpty
                  ? null
                  : _licenseController.text.trim(),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ValidationNotice(text: l10n.mototaxiProfileWarning),
              const SizedBox(height: 34),
              _DriverFieldLabel(l10n.mototaxiProfileDisplayNameLabel),
              _DriverTextField(
                controller: _nameController,
                hintText: l10n.mototaxiProfileDisplayNameHint,
              ),
              const SizedBox(height: 28),
              _DriverFieldLabel(l10n.mototaxiProfileZoneLabel),
              _ZoneSelector(
                value: _zone,
                onChanged: (value) {
                  if (value != null) setState(() => _zone = value);
                },
              ),
              const SizedBox(height: 28),
              _DriverFieldLabel(
                l10n.mototaxiProfileLicenseLabel,
                suffix: l10n.mototaxiProfileLicenseOptional,
              ),
              _DriverTextField(
                controller: _licenseController,
                hintText: l10n.mototaxiProfileLicenseHint,
              ),
              if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class TransporterProfilePage extends StatelessWidget {
  const TransporterProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>(),
      child: const _TransporterProfileView(),
    );
  }
}

class _TransporterProfileView extends StatefulWidget {
  const _TransporterProfileView();

  @override
  State<_TransporterProfileView> createState() => _TransporterProfileViewState();
}

class _TransporterProfileViewState extends State<_TransporterProfileView> {
  final _companyController = TextEditingController(text: '');
  final _permitController = TextEditingController();

  @override
  void dispose() {
    _companyController.dispose();
    _permitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: _onSaved,
      builder: (context, state) {
        return AuthScaffold(
          title: l10n.transporterProfileTitle,
          showBack: true,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          bottom: _DriverSubmitButton(
            label: l10n.transporterProfileSubmit,
            isLoading: state.isLoading,
            onPressed: () => context.read<ProfileCubit>().createTransporter(
              companyName: _companyController.text,
              permitNumber: _permitController.text.trim().isEmpty
                  ? null
                  : _permitController.text.trim(),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ValidationNotice(text: l10n.transporterProfileWarning),
              const SizedBox(height: 34),
              _DriverFieldLabel(l10n.transporterProfileCompanyNameLabel),
              _DriverTextField(
                controller: _companyController,
                hintText: l10n.transporterProfileCompanyNameHint,
              ),
              const SizedBox(height: 28),
              _DriverFieldLabel(l10n.transporterProfilePermitLabel),
              _DriverTextField(
                controller: _permitController,
                hintText: l10n.transporterProfilePermitHint,
              ),
              const SizedBox(height: 28),
              _DriverFieldLabel(l10n.transporterProfileVehicleLabel),
              _VehicleKycNotice(
                text: l10n.transporterProfileVehicleKycText,
                badge: l10n.transporterProfileVehicleSoon,
              ),
              if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DriverFieldLabel extends StatelessWidget {
  final String text;
  final String? suffix;

  const _DriverFieldLabel(this.text, {this.suffix});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (suffix != null)
              TextSpan(
                text: ' · $suffix',
                style: const TextStyle(color: Color(0xFF8A968C)),
              ),
          ],
        ),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: const Color(0xFF3C4741),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DriverTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;

  const _DriverTextField({required this.controller, this.hintText});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFA8B0AA),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: Color(0xFFDEE2DA), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
          ),
        ),
      ),
    );
  }
}

class _ZoneSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _ZoneSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const zones = ['Bastos, Yaoundé', 'Mvan, Yaoundé', 'Akwa, Douala'];

    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 30, right: 22),
      decoration: _driverFieldDecoration(),
      child: Row(
        children: [
          const MotodigoLocalisationGrayIcon(size: 28),
          const SizedBox(width: 22),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF8A968C),
                  size: 34,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(18),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
                items: [for (final zone in zones) DropdownMenuItem(value: zone, child: Text(zone))],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _DriverSubmitButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.62),
          elevation: 10,
          shadowColor: AppColors.primary.withValues(alpha: 0.34),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 2.7, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.arrow_forward_rounded, size: 30),
                ],
              ),
      ),
    );
  }
}

class _VehicleKycNotice extends StatelessWidget {
  final String text;
  final String badge;

  const _VehicleKycNotice({required this.text, required this.badge});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DashedRoundedBorderPainter(color: Color(0xFFDDE3DA), radius: 22),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.fromLTRB(28, 18, 26, 18),
        child: Row(
          children: [
            const MotodigoUploadGrayIcon(size: 30),
            const SizedBox(width: 22),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Color(0xFFA8B0AA),
                  fontSize: 19,
                  height: 1.18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2ED),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Color(0xFFA8B0AA),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedRoundedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + 8;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

BoxDecoration _driverFieldDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0xFFDEE2DA), width: 1.5),
    borderRadius: BorderRadius.circular(24),
  );
}

Future<void> _onSaved(BuildContext context, ProfileState state) async {
  if (state.isSaved) {
    await context.read<SessionCubit>().refreshAfterProfileChange();
    if (!context.mounted) return;
    context.go(RouteConstants.home);
  }
}

class _ValidationNotice extends StatelessWidget {
  final String text;

  const _ValidationNotice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4CB),
        border: Border.all(color: const Color(0xFFF3D77B)),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const MotodigoWarningYellowIcon(size: 26),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF9B6B0B),
                fontWeight: FontWeight.w900,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
