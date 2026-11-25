import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/summary_dialog.dart';
import 'package:provider/provider.dart';

/// Formulir proyek; field mengikuti `ProjectSerializer` pada backend Django.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  static const int _maxTitleLength = 50;
  static const int _maxDescLength = 255;
  static const List<String> _types = ['personal', 'competition', 'team'];

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _techCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  String _type = _types.first;
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

  String? _validateUrl(String? value, {required bool required}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return required ? 'URL tidak boleh kosong!' : null;
    final uri = Uri.tryParse(text);
    final valid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.');
    return valid ? null : 'URL harus valid (http:// atau https://)!';
  }

  String? _validateRequired(String? value, String label, [int? max]) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label tidak boleh kosong!';
    if (max != null && text.length > max) {
      return '$label maksimal $max karakter!';
    }
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final auth = context.read<AuthState>();
    final api = context.read<ApiClient>();
    final token = auth.token;
    if (token == null) return;

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
    try {
      final created = await api.createProject(newProject, token: token);
      if (!mounted) return;
      await showSummaryDialog(
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
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Token tidak valid/kedaluwarsa: keluar lalu minta login ulang.
        await auth.logout();
        if (!mounted) return;
        _showMessage('Sesi berakhir. Silakan login kembali.');
        await ensureLoggedIn(context);
      } else {
        _showMessage('Gagal menyimpan proyek (status ${e.statusCode}).');
      }
    } catch (_) {
      if (mounted) _showMessage('Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _reset() {
    _formKey.currentState!.reset();
    _titleCtrl.clear();
    _descCtrl.clear();
    _techCtrl.clear();
    _urlCtrl.clear();
    _imageUrlCtrl.clear();
    setState(() => _type = _types.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Project Form')),
      drawer: const LeftDrawer(current: DrawerDestination.addProject),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxContentWidth,
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppSpace.s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          _validateRequired(v, 'Name', _maxTitleLength),
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
                      validator: (v) =>
                          _validateRequired(v, 'Description', _maxDescLength),
                    ),
                    const SizedBox(height: AppSpace.s2),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: [
                        for (final t in _types)
                          DropdownMenuItem(value: t, child: Text(t)),
                      ],
                      onChanged: (v) => setState(() => _type = v ?? _type),
                    ),
                    const SizedBox(height: AppSpace.s4),
                    TextFormField(
                      controller: _techCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Tech Stack (pisahkan dengan koma)',
                        hintText: 'Contoh: Flutter, Django, Figma',
                      ),
                      validator: (v) => _validateRequired(v, 'Tech Stack'),
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
                      validator: (v) => _validateUrl(v, required: false),
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
                      validator: (v) => _validateUrl(v, required: true),
                    ),
                    const SizedBox(height: AppSpace.s6),
                    FilledButton.icon(
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: const Text('Simpan'),
                    ),
                    const SizedBox(height: AppSpace.s2),
                    OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _reset,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
