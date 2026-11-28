import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/widgets/detail_layout.dart';
import 'package:myportofolio_mobile/widgets/pill.dart';
import 'package:myportofolio_mobile/widgets/section_card.dart';
import 'package:myportofolio_mobile/widgets/summary_row.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project Detail')),
      body: DetailLayout(
        imageUrl: project.image,
        icon: Icons.folder_rounded,
        title: project.name,
        badges: [
          Pill(Project.typeLabel(project.type)),
          for (final tech in project.techStack) Pill(tech, isNeutral: true),
        ],
        sections: [
          SectionCard(title: 'Tentang', children: [Text(project.description)]),
          if (project.url.isNotEmpty)
            SectionCard(
              title: 'Informasi',
              children: [SummaryRow('Project URL', project.url)],
            ),
        ],
      ),
    );
  }
}
