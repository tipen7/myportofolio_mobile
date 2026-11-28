import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/profile.dart';
import 'package:myportofolio_mobile/screens/experience_detail_screen.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/app_bottom_nav.dart';
import 'package:myportofolio_mobile/widgets/app_navigation.dart';
import 'package:myportofolio_mobile/widgets/app_snack_bar.dart';
import 'package:myportofolio_mobile/widgets/avatar.dart';
import 'package:myportofolio_mobile/widgets/brand_header.dart';
import 'package:myportofolio_mobile/widgets/latest_experiences.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/page_body.dart';
import 'package:myportofolio_mobile/widgets/profile_card.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Kartu yang punya `page` membuka halaman tersebut lewat Navigator.push().
  final List<ItemHomepage> items = [
    ItemHomepage(
      'Lihat Proyek',
      Icons.folder_rounded,
      AppPalette.blue500,
      page: (_) => const ProjectListScreen(),
    ),
    ItemHomepage(
      'Tambah Proyek',
      Icons.add_circle_rounded,
      AppPalette.green500,
      page: (_) => const ProjectFormPage(),
      requiresAuth: true,
    ),
    ItemHomepage(
      'Lihat Pengalaman',
      Icons.work_rounded,
      AppPalette.orange500,
      page: (_) => const ExperienceListScreen(),
    ),
    ItemHomepage(
      'Tambah Pengalaman',
      Icons.post_add_rounded,
      AppPalette.orange500,
      page: (_) => const ExperienceFormPage(),
      requiresAuth: true,
    ),
    const ItemHomepage(
      'Logout',
      Icons.logout_rounded,
      AppPalette.red500,
      isLogout: true,
    ),
  ];

  int _totalTaps = 0;
  String? _lastPressed;
  late Future<List<Experience>> _latest;

  @override
  void initState() {
    super.initState();
    _latest = context.read<ApiClient>().getExperiences();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    final future = context.read<ApiClient>().getExperiences();
    setState(() {
      _latest = future;
    });
    await future.then<void>((_) {}, onError: (Object _) {});
  }

  void _onItemTap(ItemHomepage item) {
    setState(() {
      _totalTaps++;
      _lastPressed = item.name;
    });
    showAppSnackBar(context, 'Kamu telah menekan tombol ${item.name}!');
  }

  void _resetCounter() {
    setState(() {
      _totalTaps = 0;
      _lastPressed = null;
    });
  }

  void _openSearch() {
    unawaited(_push(const ExperienceListScreen(autofocusSearch: true)));
  }

  Future<void> _push(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => page),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      drawer: const LeftDrawer(),
      bottomNavigationBar: const AppBottomNav(current: DrawerDestination.home),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BrandHeader(
                overlap: AppSpace.s12,
                child: PageBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SearchBar(onSearch: _openSearch),
                      const SizedBox(height: AppSpace.s5),
                      const _Greeting(),
                      const SizedBox(height: AppSpace.s4),
                      const ProfileCard(),
                    ],
                  ),
                ),
              ),
              PageBody(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpace.s2),
                        decoration: BoxDecoration(
                          color: t.surface,
                          borderRadius: AppRadius.xlAll,
                          border: Border.all(color: t.border),
                        ),
                        child: GridView(
                          primary: false,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisExtent: 116,
                              ),
                          children: [
                            for (final item in items)
                              ItemCard(
                                item,
                                onTap: () => _onItemTap(item),
                                onReturn: _reload,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpace.s6),
                      _SectionHeader(
                        title: 'Pengalaman terbaru',
                        subtitle: 'Langsung dari server portofolio',
                        onSeeAll: () => _push(const ExperienceListScreen()),
                      ),
                      const SizedBox(height: AppSpace.s3),
                      LatestExperiences(
                        future: _latest,
                        onRetry: _reload,
                        onTap: (experience) => _push(
                          ExperienceDetailScreen(experience: experience),
                        ),
                      ),
                      const SizedBox(height: AppSpace.s6),
                      const _SectionHeader(
                        title: 'Aktivitas',
                        subtitle: 'Tombol layanan yang kamu tekan',
                      ),
                      const SizedBox(height: AppSpace.s3),
                      ActivityCard(
                        totalTaps: _totalTaps,
                        lastPressed: _lastPressed,
                        onReset: _resetCounter,
                      ),
                    ],
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Row(
      children: [
        IconButton(
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          color: t.onBrand,
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(t.onBrand),
          ),
          onPressed: Scaffold.of(context).openDrawer,
          icon: const Icon(Icons.menu_rounded),
        ),
        const SizedBox(width: AppSpace.s1),
        Expanded(
          child: Material(
            color: t.surface,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onSearch,
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.s3),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: t.textMuted),
                    const SizedBox(width: AppSpace.s2),
                    Expanded(
                      child: Text(
                        'Cari pengalaman',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: t.textSubtle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpace.s2),
        Semantics(
          button: true,
          label: 'Buka akun',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => goToDestination(context, DrawerDestination.account),
            child: const Avatar(size: AppLayout.minTapTarget),
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, $ownerName',
          style: text.bodyMedium?.copyWith(color: t.onBrand),
        ),
        const SizedBox(height: AppSpace.s1),
        Text(
          'Selamat datang di MyPortfolio Mobile!',
          style: text.headlineSmall?.copyWith(color: t.onBrand),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.onSeeAll,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.titleLarge),
              Text(
                subtitle,
                style: text.bodySmall?.copyWith(color: t.textMuted),
              ),
            ],
          ),
        ),
        if (onSeeAll != null)
          TextButton(onPressed: onSeeAll, child: const Text('Lihat semua')),
      ],
    );
  }
}

class ItemHomepage {
  const ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.page,
    this.requiresAuth = false,
    this.isLogout = false,
  });

  final String name;
  final IconData icon;
  final Color color;

  /// Halaman tujuan saat kartu ditekan (null = tidak berpindah halaman).
  final WidgetBuilder? page;
  final bool requiresAuth;
  final bool isLogout;
}

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    required this.totalTaps,
    required this.onReset,
    super.key,
    this.lastPressed,
  });

  final int totalTaps;
  final String? lastPressed;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.s4),
        child: Row(
          children: [
            Container(
              width: AppSpace.s12,
              height: AppSpace.s12,
              decoration: BoxDecoration(
                color: t.actionSoft,
                borderRadius: AppRadius.mdAll,
              ),
              child: Icon(Icons.touch_app_rounded, color: t.actionText),
            ),
            const SizedBox(width: AppSpace.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total tombol ditekan: $totalTaps',
                    style: text.titleSmall,
                  ),
                  const SizedBox(height: AppSpace.s1),
                  AnimatedSwitcher(
                    duration: AppMotion.normal,
                    switchInCurve: AppMotion.easeOut,
                    child: Text(
                      lastPressed == null
                          ? 'Belum ada tombol yang ditekan'
                          : 'Terakhir: $lastPressed',
                      key: ValueKey(lastPressed),
                      style: text.bodyMedium?.copyWith(color: t.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Reset penghitung',
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
