import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/l10n/app_locale_controller.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/di/injection.dart';
import 'package:motodi_go_mobile/features/auth/domain/entities/auth_validators.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_figma_icons.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/cubit/profile_cubit.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/profile_figma_icons.dart';
import 'package:motodi_go_mobile/l10n/app_localizations.dart';

class PassengerProfilePage extends StatelessWidget {
  const PassengerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<ProfileCubit>(), child: const _PassengerProfileView());
  }
}

class _PassengerProfileView extends StatefulWidget {
  const _PassengerProfileView();

  @override
  State<_PassengerProfileView> createState() => _PassengerProfileViewState();
}

class _PassengerProfileViewState extends State<_PassengerProfileView> {
  final _emergencyController = TextEditingController();
  String _language = 'fr';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localeCode = AppLocalizations.of(context)?.localeName.split('_').first;
    _language = localeCode == 'en' ? 'en' : 'fr';
  }

  @override
  void dispose() {
    _emergencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = context.read<SessionCubit>().state.session;
    final displayName = session?.phoneNumber ?? 'Passager';

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) async {
        if (state.isSaved) {
          await context.read<SessionCubit>().refreshAfterProfileChange();
          if (context.mounted) context.go(RouteConstants.home);
        }
      },
      builder: (context, state) {
        return AuthScaffold(
          title: l10n.passenger_profile_title,
          showBack: true,
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
          bottom: _PassengerSubmitButton(
            label: l10n.passenger_profile_submit,
            isLoading: state.isLoading,
            onPressed: () => context.read<ProfileCubit>().createPassenger(
              displayName: displayName,
              preferredLanguage: _language,
              emergencyContact: _normalizedEmergencyContact(),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF5E8),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(child: MotodigoProfilePersonIcon(size: 38)),
              ),
              const SizedBox(height: 36),
              Text(
                l10n.passenger_profile_description,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF54615A),
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 34),
              _PassengerFieldLabel(l10n.passenger_profile_language_label),
              _LanguageSelector(
                value: _language,
                frenchLabel: l10n.passenger_profile_language_fr,
                englishLabel: l10n.passenger_profile_language_en,
                onChanged: (value) async {
                  if (value == null) return;
                  setState(() => _language = value);
                  await AppLocaleController.of(context).setLocale(Locale(value));
                },
              ),
              const SizedBox(height: 28),
              _PassengerFieldLabel(
                l10n.passenger_profile_emergency_label,
                suffix: l10n.passenger_profile_optional,
              ),
              _EmergencyPhoneInput(
                controller: _emergencyController,
                hintText: l10n.passenger_profile_emergency_hint,
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

  String? _normalizedEmergencyContact() {
    final raw = _emergencyController.text.trim();
    if (raw.isEmpty) return null;
    return CameroonPhoneValidator.normalize(raw);
  }
}

class _PassengerFieldLabel extends StatelessWidget {
  final String text;
  final String? suffix;

  const _PassengerFieldLabel(this.text, {this.suffix});

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

class _LanguageSelector extends StatelessWidget {
  final String value;
  final String frenchLabel;
  final String englishLabel;
  final ValueChanged<String?> onChanged;

  const _LanguageSelector({
    required this.value,
    required this.frenchLabel,
    required this.englishLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 30, right: 22),
      decoration: _passengerFieldDecoration(),
      child: Row(
        children: [
          const MotodigoNetworkGrayIcon(size: 28),
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
                items: [
                  DropdownMenuItem(value: 'fr', child: Text(frenchLabel)),
                  DropdownMenuItem(value: 'en', child: Text(englishLabel)),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyPhoneInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _EmergencyPhoneInput({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 112,
          height: 60,
          decoration: _passengerFieldDecoration(),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MotodigoFlagCmrIcon(),
              SizedBox(width: 4),
              Text(
                '+237',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 60,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 +()-]'))],
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFFA8B0AA),
                  fontSize: 20,
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
          ),
        ),
      ],
    );
  }
}

class _PassengerSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PassengerSubmitButton({
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
            : Text(
                label,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}

BoxDecoration _passengerFieldDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: const Color(0xFFDEE2DA), width: 1.5),
    borderRadius: BorderRadius.circular(24),
  );
}
