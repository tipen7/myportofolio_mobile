import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/summary_dialog.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Project Detail')),
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
                  if (project.image.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: AppRadius.lgAll,
                      child: Image.network(
                        project.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: AppSpace.s4),
                  ],
                  Text(project.name, style: text.headlineSmall),
                  const SizedBox(height: AppSpace.s4),
                  SummaryRow('Description', project.description),
                  SummaryRow('Type', project.type),
                  SummaryRow('Tech Stack', project.techStack.join(', ')),
                  if (project.url.isNotEmpty)
                    SummaryRow('Project URL', project.url),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
