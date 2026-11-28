import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_detail_screen.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/utils/date_format.dart';
import 'package:myportofolio_mobile/widgets/app_bottom_nav.dart';
import 'package:myportofolio_mobile/widgets/async_list_view.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/entry_card.dart';
import 'package:myportofolio_mobile/widgets/filter_header.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/pill.dart';
import 'package:provider/provider.dart';

class ExperienceListScreen extends StatefulWidget {
  const ExperienceListScreen({this.autofocusSearch = false, super.key});

  final bool autofocusSearch;

  @override
  State<ExperienceListScreen> createState() => _ExperienceListScreenState();
}

class _ExperienceListScreenState extends State<ExperienceListScreen> {
  late Future<List<Experience>> _experiences;
  String _query = '';
  ExperienceCategory? _category;

  @override
  void initState() {
    super.initState();
    // Created once here so rebuilds do not repeat the request.
    _experiences = context.read<ApiClient>().getExperiences();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    final future = context.read<ApiClient>().getExperiences();
    setState(() {
      _experiences = future;
    });
    await future.then<void>((_) {}, onError: (Object _) {});
  }

  bool _matches(Experience experience) =>
      (_category == null || experience.category == _category) &&
      experience.title.toLowerCase().contains(_query.trim().toLowerCase());

  Future<void> _add() async {
    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final created = await Navigator.push<Experience>(
      context,
      MaterialPageRoute(
        builder: (_) => const ExperienceFormPage(returnToCaller: true),
      ),
    );
    if (created != null) await _reload();
  }

  void _open(Experience experience) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ExperienceDetailScreen(experience: experience, onChanged: _reload),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Experiences')),
      drawer: const LeftDrawer(current: DrawerDestination.experiences),
      bottomNavigationBar: const AppBottomNav(
        current: DrawerDestination.experiences,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
      body: Column(
        children: [
          FilterHeader<ExperienceCategory>(
            searchHint: 'Cari judul pengalaman',
            autofocus: widget.autofocusSearch,
            onQueryChanged: (value) => setState(() => _query = value),
            options: ExperienceCategory.values,
            selected: _category,
            labelOf: (category) => category.label,
            onSelected: (category) => setState(() => _category = category),
          ),
          Expanded(
            child: AsyncListView<Experience>(
              future: _experiences,
              onRefresh: _reload,
              filter: _matches,
              errorMessage: 'Gagal memuat pengalaman.',
              emptyMessage: 'Belum ada pengalaman.',
              itemBuilder: (context, experience) => EntryCard(
                imageUrl: experience.thumbnail,
                icon: Icons.work_rounded,
                title: experience.title,
                caption: formatPeriod(experience.startedAt, experience.endedAt),
                description: experience.description,
                badges: [
                  Pill(experience.category.label),
                  if (experience.starCount > 0)
                    Pill(
                      '${experience.starCount}',
                      icon: Icons.star_rounded,
                      isNeutral: true,
                    ),
                ],
                onTap: () => _open(experience),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
