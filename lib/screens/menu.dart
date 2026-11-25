import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String npm = "2506616112";
  final String nama = "Steven";
  final String kelas = "PBP A";

  // Kartu yang punya `page` membuka halaman tersebut lewat Navigator.push().
  final List<ItemHomepage> items = [
    ItemHomepage(
      "Lihat Proyek",
      Icons.folder_rounded,
      AppPalette.blue500,
      page: (_) => const ProjectListScreen(),
    ),
    ItemHomepage(
      "Tambah Proyek",
      Icons.add_circle_rounded,
      AppPalette.green500,
      page: (_) => const ProjectFormPage(),
      requiresAuth: true,
    ),
    ItemHomepage(
      "Tambah Pengalaman",
      Icons.work_rounded,
      AppPalette.orange500,
      page: (_) => const ExperienceFormPage(),
    ),
    const ItemHomepage(
      "Logout",
      Icons.logout_rounded,
      AppPalette.red500,
      isLogout: true,
    ),
  ];

  // Interaktivitas tambahan: hitung total tekan & simpan tombol terakhir.
  int _totalTaps = 0;
  String? _lastPressed;

  void _onItemTap(ItemHomepage item) {
    setState(() {
      _totalTaps++;
      _lastPressed = item.name;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text("Kamu telah menekan tombol ${item.name}!")),
      );
  }

  void _resetCounter() {
    setState(() {
      _totalTaps = 0;
      _lastPressed = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MyPortfolio',
          style: text.titleLarge?.copyWith(
            color: t.actionText,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset penghitung',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetCounter,
          ),
          const SizedBox(width: AppSpace.s2),
        ],
      ),
      drawer: const LeftDrawer(current: DrawerDestination.home),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxContentWidth,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpace.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Hero(
                    greeting: 'Halo, $nama',
                    stats: [
                      InfoCard(title: 'NPM', content: npm),
                      InfoCard(title: 'Name', content: nama),
                      InfoCard(title: 'Class', content: kelas),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s6),
                  const _SectionTitle('Layanan'),
                  const SizedBox(height: AppSpace.s2),
                  Container(
                    padding: const EdgeInsets.all(AppSpace.s2),
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: AppRadius.xlAll,
                      border: Border.all(color: t.border),
                      boxShadow: t.shadowSm,
                    ),
                    child: GridView(
                      primary: false,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisExtent: 116,
                          ),
                      children: [
                        for (final item in items)
                          ItemCard(item, onTap: () => _onItemTap(item)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.s6),
                  const _SectionTitle('Aktivitas'),
                  const SizedBox(height: AppSpace.s2),
                  ActivityCard(
                    totalTaps: _totalTaps,
                    lastPressed: _lastPressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleMedium);
  }
}

/// Header hijau bergradien dengan kartu profil di dalamnya
/// (mirip kartu saldo di aplikasi Gojek).
class _Hero extends StatelessWidget {
  const _Hero({required this.greeting, required this.stats});

  final String greeting;
  final List<Widget> stats;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpace.s5),
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPalette.green500, AppPalette.green800],
        ),
        boxShadow: t.shadowBrand,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: text.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpace.s1),
          Text(
            'Selamat datang di MyPortfolio Mobile!',
            style: text.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpace.s4),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.s3),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: AppRadius.lgAll,
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    if (i > 0)
                      VerticalDivider(width: 1, thickness: 1, color: t.border),
                    Expanded(child: stats[i]),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            style: text.labelSmall?.copyWith(color: t.textSubtle),
          ),
          const SizedBox(height: AppSpace.s1),
          Text(
            content,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.titleSmall,
          ),
        ],
      ),
    );
  }
}

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  /// Halaman tujuan saat kartu ditekan (null = tidak berpindah halaman).
  final WidgetBuilder? page;

  /// Halaman tujuan hanya boleh dibuka setelah login.
  final bool requiresAuth;

  /// Kartu ini melakukan logout (bukan berpindah halaman).
  final bool isLogout;

  const ItemHomepage(
    this.name,
    this.icon,
    this.color, {
    this.page,
    this.requiresAuth = false,
    this.isLogout = false,
  });
}

class ActivityCard extends StatelessWidget {
  final int totalTaps;
  final String? lastPressed;

  const ActivityCard({super.key, required this.totalTaps, this.lastPressed});

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
              width: 48,
              height: 48,
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
                  const SizedBox(height: 2),
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
          ],
        ),
      ),
    );
  }
}
