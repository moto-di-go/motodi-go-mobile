import 'package:flutter/material.dart';
import 'package:motodi_go_mobile/core/theme/app_colors.dart';
import 'package:motodi_go_mobile/features/home/presentation/widgets/home_figma_icons.dart';

class AppBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String tripsTabLabel;

  const AppBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.tripsTabLabel = 'Trajets',
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      const _NavItemData(
        label: 'Accueil',
        activeIcon: MotodigoHomeGreenIcon(size: 30),
        inactiveIcon: MotodigoHomeGrayIcon(size: 30),
      ),
      _NavItemData(
        label: tripsTabLabel,
        activeIcon: const MotodigoTrajetGreenIcon(size: 30),
        inactiveIcon: const MotodigoTrajetGrayIcon(size: 30),
      ),
      const _NavItemData(
        label: 'Wallet',
        activeIcon: MotodigoWalletGreenIcon(size: 30),
        inactiveIcon: MotodigoWalletGrayIcon(size: 30),
      ),
      const _NavItemData(
        label: 'Notifs',
        activeIcon: MotodigoNotifGreenIcon(size: 30),
        inactiveIcon: MotodigoNotifGrayIcon(size: 30),
      ),
      const _NavItemData(
        label: 'Profil',
        activeIcon: MotodigoProfileGreenIcon(size: 30),
        inactiveIcon: MotodigoProfileGrayIcon(size: 30),
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 86,
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: Color(0xFFE4E7DF))),
        ),
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var index = 0; index < items.length; index++)
              _NavItem(
                data: items[index],
                selected: index == selectedIndex,
                onTap: () => onSelected(index),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final Widget activeIcon;
  final Widget inactiveIcon;

  const _NavItemData({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : const Color(0xFF98A29A);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          height: 66,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              selected ? data.activeIcon : data.inactiveIcon,
              const SizedBox(height: 4),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
