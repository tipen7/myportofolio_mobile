import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/account_screen.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';

enum DrawerDestination {
  home,
  projects,
  addProject,
  experiences,
  addExperience,
  account;

  bool get requiresAuth => this == addProject || this == addExperience;

  Widget get page => switch (this) {
    home => const MyHomePage(),
    projects => const ProjectListScreen(),
    addProject => const ProjectFormPage(),
    experiences => const ExperienceListScreen(),
    addExperience => const ExperienceFormPage(),
    account => const AccountScreen(),
  };
}

Future<void> goToDestination(
  BuildContext context,
  DrawerDestination destination,
) async {
  if (destination.requiresAuth) {
    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !context.mounted) return;
  }
  final route = MaterialPageRoute<void>(builder: (_) => destination.page);
  if (destination == DrawerDestination.home) {
    // Kosongkan stack agar Home tidak menumpuk.
    await Navigator.pushAndRemoveUntil(context, route, (_) => false);
  } else {
    await Navigator.pushReplacement(context, route);
  }
}
