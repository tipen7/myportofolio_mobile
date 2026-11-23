import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

/// Tujuan di drawer; dipakai untuk menandai halaman yang sedang aktif.
enum DrawerDestination { home, addProject, addExperience }

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key, this.current = DrawerDestination.home});

  final DrawerDestination current;

  void _go(
    BuildContext context,
    DrawerDestination dest,
    Widget Function() page,
  ) {
    // Sudah di halaman tujuan: cukup tutup drawer.
    if (dest == current) {
      Navigator.pop(context);
      return;
    }
    if (dest == DrawerDestination.home) {
      // Kosongkan stack agar Home tidak menumpuk.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => page()),
        (route) => false,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    Widget item(
      IconData icon,
      IconData activeIcon,
      String label,
      DrawerDestination dest,
      Widget Function() page,
    ) {
      final selected = dest == current;
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s3,
          vertical: AppSpace.s1,
        ),
        child: ListTile(
          selected: selected,
          leading: Icon(selected ? activeIcon : icon),
          title: Text(
            label,
            style: text.titleSmall?.copyWith(
              color: selected ? t.actionText : t.text,
            ),
          ),
          onTap: () => _go(context, dest, page),
        ),
      );
    }

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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppPalette.green500, AppPalette.green800],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    'S',
                    style: text.headlineSmall?.copyWith(
                      color: AppPalette.green700,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.s3),
                Text(
                  'My Portfolio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.headlineSmall?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppSpace.s1),
                Text(
                  'Explore personal projects and experiences!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s2),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                item(
                  Icons.home_outlined,
                  Icons.home_rounded,
                  'Home',
                  DrawerDestination.home,
                  () => const MyHomePage(),
                ),
                item(
                  Icons.add_circle_outline_rounded,
                  Icons.add_circle_rounded,
                  'Add Project',
                  DrawerDestination.addProject,
                  () => const ProjectFormPage(),
                ),
                item(
                  Icons.work_outline_rounded,
                  Icons.work_rounded,
                  'Add Experience',
                  DrawerDestination.addExperience,
                  () => const ExperienceFormPage(),
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
