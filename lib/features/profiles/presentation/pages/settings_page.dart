import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motodi_go_mobile/core/constants/route_constants.dart';
import 'package:motodi_go_mobile/core/l10n/app_locale_controller.dart';
import 'package:motodi_go_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:motodi_go_mobile/features/auth/presentation/widgets/auth_buttons.dart';
import 'package:motodi_go_mobile/features/profiles/presentation/widgets/settings_figma_icons.dart';

TextStyle _settingsText({
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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// Stubs UI — pas de persistance backend (plan).
  bool _notificationsEnabled = true;
  bool _shareLocationEnabled = false;

  void _soon() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bientôt disponible')));
  }

  void _showLogoutSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 44,
                backgroundColor: Color(0xFFFEE2E2),
                child: MotodigoSettingsLogoutIcon(size: 36),
              ),
              const SizedBox(height: 26),
              Text(
                'Se déconnecter ?',
                textAlign: TextAlign.center,
                style: _settingsText(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Text(
                'Vous devrez saisir à nouveau votre numéro et votre mot de passe pour vous reconnecter.',
                textAlign: TextAlign.center,
                style: _settingsText(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5B6760),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 34),
              PrimaryAuthButton(
                label: 'Se déconnecter',
                backgroundColor: const Color(0xFFDC2626),
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  await context.read<SessionCubit>().logout();
                  if (mounted) context.go(RouteConstants.login);
                },
              ),
              const SizedBox(height: 14),
              SecondaryAuthButton(
                label: 'Annuler',
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeController = AppLocaleController.of(context);

    return ListenableBuilder(
      listenable: localeController,
      builder: (context, _) {
        final langCode =
            localeController.locale?.languageCode ?? Localizations.localeOf(context).languageCode;
        final isFr = langCode != 'en';

        return Scaffold(
          backgroundColor: const Color(0xFFFAFAF6),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => context.pop(),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F1EA),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF101512),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Paramètres',
                      style: _settingsText(fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const _SectionLabel('PRÉFÉRENCES'),
                const SizedBox(height: 10),
                _SettingsGroup(
                  children: [
                    _SettingsRow(
                      icon: const MotodigoSettingsGlobeIcon(size: 22),
                      title: 'Langue',
                      trailing: _LanguageSegment(
                        isFr: isFr,
                        onFr: () => localeController.setLocale(const Locale('fr')),
                        onEn: () => localeController.setLocale(const Locale('en')),
                      ),
                    ),
                    _SettingsRow(
                      icon: const MotodigoSettingsBellIcon(size: 22),
                      title: 'Notifications',
                      trailing: _SettingsSwitch(
                        value: _notificationsEnabled,
                        onChanged: (v) => setState(() => _notificationsEnabled = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const _SectionLabel('CONFIDENTIALITÉ'),
                const SizedBox(height: 10),
                _SettingsGroup(
                  children: [
                    _SettingsRow(
                      icon: const MotodigoSettingsCrosshairIcon(size: 22),
                      title: 'Partager ma localisation',
                      trailing: _SettingsSwitch(
                        value: _shareLocationEnabled,
                        onChanged: (v) => setState(() => _shareLocationEnabled = v),
                      ),
                    ),
                    const _SettingsRow(
                      icon: MotodigoSettingsShieldIcon(size: 22),
                      title: 'Confidentialité des données',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFC2C8C0),
                        size: 26,
                      ),
                      onTap: null,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const _SectionLabel('SÉCURITÉ'),
                const SizedBox(height: 10),
                _SettingsGroup(
                  children: [
                    _SettingsRow(
                      icon: const MotodigoSettingsLockIcon(size: 22),
                      title: 'Changer mon mot de passe',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFC2C8C0),
                        size: 26,
                      ),
                      onTap: _soon,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Material(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(999),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: _showLogoutSheet,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MotodigoSettingsLogoutIcon(size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Se déconnecter',
                            style: _settingsText(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFDC2626),
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
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: _settingsText(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF9CA7A0),
        height: 1.2,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4E7DF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFECEEE8), indent: 54),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final Widget icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsRow({required this.icon, required this.title, required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(width: 26, height: 26, child: Center(child: icon)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: _settingsText(fontSize: 16, fontWeight: FontWeight.w700, height: 1.25),
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );

    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

class _LanguageSegment extends StatelessWidget {
  final bool isFr;
  final VoidCallback onFr;
  final VoidCallback onEn;

  const _LanguageSegment({required this.isFr, required this.onFr, required this.onEn});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2ED),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SegmentChip(label: 'FR', selected: isFr, onTap: onFr),
          _SegmentChip(label: 'EN', selected: !isFr, onTap: onEn),
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF16A34A) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: _settingsText(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF6B756E),
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Transform.scale(
        scale: 0.92,
        alignment: Alignment.centerRight,
        child: CupertinoSwitch(
          value: value,
          activeTrackColor: const Color(0xFF16A34A),
          inactiveTrackColor: const Color(0xFFD5DAD4),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
