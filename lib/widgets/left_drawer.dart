import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/app_navigation.dart';
import 'package:myportofolio_mobile/widgets/app_snack_bar.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/avatar.dart';
import 'package:provider/provider.dart';

export 'package:myportofolio_mobile/widgets/app_navigation.dart'
    show DrawerDestination;

typedef _NavItem = (DrawerDestination, IconData, IconData, String);

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key, this.current = DrawerDestination.home});

  final DrawerDestination current;

  static const List<_NavItem> _items = [
    (DrawerDestination.home, Icons.home_outlined, Icons.home_rounded, 'Home'),
    (
      DrawerDestination.projects,
      Icons.folder_outlined,
      Icons.folder_rounded,
      'Projects',
    ),
    (
      DrawerDestination.addProject,
      Icons.add_circle_outline_rounded,
      Icons.add_circle_rounded,
      'Add Project',
    ),
    (
      DrawerDestination.experiences,
      Icons.work_outline_rounded,
      Icons.work_rounded,
      'Experiences',
    ),
    (
      DrawerDestination.addExperience,
      Icons.post_add_outlined,
      Icons.post_add_rounded,
      'Add Experience',
    ),
    (
      DrawerDestination.account,
      Icons.person_outline_rounded,
      Icons.person_rounded,
      'Account',
    ),
  ];

  Future<void> _go(BuildContext context, DrawerDestination destination) async {
    if (destination == current) {
      Navigator.pop(context);
      return;
    }
    await goToDestination(context, destination);
  }

  Future<void> _toggleSession(BuildContext context) async {
    final auth = context.read<AuthState>();
    final navigator = Navigator.of(context);
    if (auth.isLoggedIn) {
      showAppSnackBar(context, 'Berhasil logout.');
      navigator.pop();
      await auth.logout();
    } else {
      await ensureLoggedIn(context);
      if (navigator.canPop()) navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              AppSpace.s5,
              MediaQuery.paddingOf(context).top + AppSpace.s6,
              AppSpace.s5,
              AppSpace.s6,
            ),
            decoration: BoxDecoration(gradient: t.heroGradient),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Avatar(size: 56),
                const SizedBox(height: AppSpace.s3),
                Text(
                  'My Portfolio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.headlineSmall?.copyWith(color: t.onBrand),
                ),
                const SizedBox(height: AppSpace.s1),
                Text(
                  'Explore personal projects and experiences!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(color: t.onBrand),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpace.s3),
              children: [
                for (final (destination, icon, activeIcon, label) in _items)
                  ListTile(
                    selected: destination == current,
                    leading: Icon(destination == current ? activeIcon : icon),
                    title: Text(label),
                    onTap: () => _go(context, destination),
                  ),
                const Divider(),
                ListTile(
                  leading: Icon(
                    isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                  ),
                  title: Text(isLoggedIn ? 'Logout' : 'Login'),
                  onTap: () => _toggleSession(context),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.s4),
              child: Text(
                'MyPortfolio Mobile · v1.0',
                style: text.bodySmall?.copyWith(color: t.textSubtle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
