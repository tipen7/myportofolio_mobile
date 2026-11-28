import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/app_bottom_nav.dart';
import 'package:myportofolio_mobile/widgets/async_list_view.dart';
import 'package:myportofolio_mobile/widgets/entry_card.dart';
import 'package:myportofolio_mobile/widgets/filter_header.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/pill.dart';
import 'package:provider/provider.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Future<List<Project>> _projects;
  String _query = '';
  String? _type;

  @override
  void initState() {
    super.initState();
    _projects = context.read<ApiClient>().getProjects();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    final future = context.read<ApiClient>().getProjects();
    setState(() {
      _projects = future;
    });
    await future.then<void>((_) {}, onError: (Object _) {});
  }

  bool _matches(Project project) =>
      (_type == null || project.type == _type) &&
      project.name.toLowerCase().contains(_query.trim().toLowerCase());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements: Projects')),
      drawer: const LeftDrawer(current: DrawerDestination.projects),
      bottomNavigationBar: const AppBottomNav(
        current: DrawerDestination.projects,
      ),
      body: Column(
        children: [
          FilterHeader<String>(
            searchHint: 'Cari nama proyek',
            onQueryChanged: (value) => setState(() => _query = value),
            options: Project.types,
            selected: _type,
            labelOf: Project.typeLabel,
            onSelected: (type) => setState(() => _type = type),
          ),
          Expanded(
            child: AsyncListView<Project>(
              future: _projects,
              onRefresh: _reload,
              filter: _matches,
              errorMessage: 'Gagal memuat proyek.',
              emptyMessage: 'No projects found.',
              itemBuilder: (context, project) => EntryCard(
                imageUrl: project.image,
                icon: Icons.folder_rounded,
                title: project.name,
                caption: project.techStack.join(', '),
                description: project.description,
                badges: [Pill(Project.typeLabel(project.type))],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ProjectDetailScreen(project: project),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
