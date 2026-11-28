import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/app_navigation.dart';

typedef _NavItem = (DrawerDestination, IconData, IconData, String);

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({required this.current, super.key});

  final DrawerDestination current;

  static const List<_NavItem> _tabs = [
    (
      DrawerDestination.home,
      Icons.home_outlined,
      Icons.home_rounded,
      'Beranda',
    ),
    (
      DrawerDestination.experiences,
      Icons.work_outline_rounded,
      Icons.work_rounded,
      'Pengalaman',
    ),
    (
      DrawerDestination.projects,
      Icons.folder_outlined,
      Icons.folder_rounded,
      'Proyek',
    ),
    (
      DrawerDestination.account,
      Icons.person_outline_rounded,
      Icons.person_rounded,
      'Akun',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final index = _tabs.indexWhere((tab) => tab.$1 == current);

    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (selected) {
        if (selected != index) {
          unawaited(goToDestination(context, _tabs[selected].$1));
        }
      },
      destinations: [
        for (final (_, icon, activeIcon, label) in _tabs)
          NavigationDestination(
            icon: Icon(icon),
            selectedIcon: Icon(activeIcon),
            label: label,
          ),
      ],
    );
  }
}
