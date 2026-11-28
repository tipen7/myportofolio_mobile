import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/utils/validators.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/bottom_action_bar.dart';
import 'package:myportofolio_mobile/widgets/chip_selector.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/page_body.dart';
import 'package:myportofolio_mobile/widgets/section_card.dart';
import 'package:myportofolio_mobile/widgets/sheets.dart';
import 'package:myportofolio_mobile/widgets/submit_button.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  static const int _maxTitleLength = 50;
  static const int _maxDescLength = 255;

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _techCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  String _type = Project.types.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _techCtrl.dispose();
    _urlCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final token = context.read<AuthState>().token;
    if (token == null) return;
    final api = context.read<ApiClient>();

    final newProject = Project(
      name: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      type: _type,
      techStack: _techCtrl.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      url: _urlCtrl.text.trim(),
      image: _imageUrlCtrl.text.trim(),
    );

    setState(() => _isSubmitting = true);
    final Project created;
    try {
      created = await api.createProject(newProject, token: token);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await handleWriteError(context, error);
      return;
    }
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    await showSuccessSheet(
      context,
      title: 'Proyek berhasil ditambahkan!',
      rows: [
        MapEntry('Name', created.name),
        MapEntry('Description', created.description),
        MapEntry('Type', created.type),
        MapEntry('Tech Stack', created.techStack.join(', ')),
        MapEntry('Project URL', created.url.isEmpty ? '-' : created.url),
        MapEntry('Project Image URL', created.image),
      ],
    );
    if (mounted) _reset();
  }

  void _reset() {
    _formKey.currentState!.reset();
    _titleCtrl.clear();
    _descCtrl.clear();
    _techCtrl.clear();
    _urlCtrl.clear();
    _imageUrlCtrl.clear();
    setState(() => _type = Project.types.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Project Form')),
      drawer: const LeftDrawer(current: DrawerDestination.addProject),
      bottomNavigationBar: BottomActionBar(
        secondary: OutlinedButton(
          onPressed: _isSubmitting ? null : _reset,
          child: const Text('Reset'),
        ),
        primary: SubmitButton(isSubmitting: _isSubmitting, onPressed: _submit),
      ),
      body: SafeArea(
        child: PageBody(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(AppSpace.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpace.s3,
                children: [
                  SectionCard(
                    title: 'Info utama',
                    children: [
                      TextFormField(
                        controller: _titleCtrl,
                        textInputAction: TextInputAction.next,
                        maxLength: _maxTitleLength,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          hintText: 'Contoh: MyPortfolio Mobile',
                        ),
                        validator: (v) =>
                            validateRequired(v, 'Name', max: _maxTitleLength),
                      ),
                      const SizedBox(height: AppSpace.s2),
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 5,
                        maxLength: _maxDescLength,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Jelaskan tujuan dan hasil proyek',
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => validateRequired(
                          v,
                          'Description',
                          max: _maxDescLength,
                        ),
                      ),
                      const SizedBox(height: AppSpace.s2),
                      const Text('Type'),
                      const SizedBox(height: AppSpace.s2),
                      ChipSelector<String>(
                        options: Project.types,
                        selected: _type,
                        labelOf: Project.typeLabel,
                        onSelected: (type) => setState(() => _type = type),
                      ),
                    ],
                  ),
                  SectionCard(
                    title: 'Teknologi & tautan',
                    children: [
                      TextFormField(
                        controller: _techCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Tech Stack (pisahkan dengan koma)',
                          hintText: 'Contoh: Flutter, Django, Figma',
                        ),
                        validator: (v) => validateRequired(v, 'Tech Stack'),
                      ),
                      const SizedBox(height: AppSpace.s4),
                      TextFormField(
                        controller: _urlCtrl,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Project URL (Optional)',
                          hintText: 'https://github.com/username/proyek',
                        ),
                        validator: validateUrl,
                      ),
                      const SizedBox(height: AppSpace.s4),
                      TextFormField(
                        controller: _imageUrlCtrl,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Project Image URL',
                          hintText: 'https://example.com/gambar.png',
                        ),
                        validator: (v) => validateUrl(v, required: true),
                      ),
                    ],
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
