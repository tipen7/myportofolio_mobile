import 'package:flutter/material.dart';

import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/summary_dialog.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  static const int _maxNameLength = 60;
  static const int _maxDescLength = 300;

  static const List<String> _categories = [
    'Web Development',
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _techCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  String _category = _categories.first;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _techCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  String? _validateLink(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null; // opsional
    final uri = Uri.tryParse(text);
    final valid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.contains('.');
    return valid
        ? null
        : 'Tautan harus berupa URL valid (http:// atau https://)!';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final tech = _techCtrl.text.trim();
    final link = _linkCtrl.text.trim();
    showSummaryDialog(
      context,
      title: 'Proyek berhasil ditambahkan!',
      rows: [
        MapEntry('Nama Proyek', _nameCtrl.text.trim()),
        MapEntry('Deskripsi', _descCtrl.text.trim()),
        MapEntry('Kategori', _category),
        MapEntry('Teknologi', tech.isEmpty ? '-' : tech),
        MapEntry('Tautan', link.isEmpty ? '-' : link),
      ],
    );
  }

  void _reset() {
    _formKey.currentState!.reset();
    _nameCtrl.clear();
    _descCtrl.clear();
    _techCtrl.clear();
    _linkCtrl.clear();
    setState(() => _category = _categories.first);
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
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      maxLength: _maxNameLength,
                      decoration: const InputDecoration(
                        labelText: 'Nama Proyek',
                        hintText: 'Contoh: MyPortfolio Mobile',
                      ),
                      validator: (v) {
                        final text = v?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Nama proyek tidak boleh kosong!';
                        }
                        if (text.length > _maxNameLength) {
                          return 'Nama proyek maksimal $_maxNameLength karakter!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpace.s2),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 5,
                      maxLength: _maxDescLength,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Proyek',
                        hintText: 'Jelaskan tujuan dan hasil proyek',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) {
                        final text = v?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Deskripsi proyek tidak boleh kosong!';
                        }
                        if (text.length > _maxDescLength) {
                          return 'Deskripsi maksimal $_maxDescLength karakter!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpace.s2),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Kategori Proyek',
                      ),
                      items: [
                        for (final c in _categories)
                          DropdownMenuItem(value: c, child: Text(c)),
                      ],
                      onChanged: (v) =>
                          setState(() => _category = v ?? _category),
                    ),
                    const SizedBox(height: AppSpace.s4),
                    TextFormField(
                      controller: _techCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Teknologi yang Digunakan',
                        hintText: 'Contoh: Flutter, Django, Figma',
                      ),
                    ),
                    const SizedBox(height: AppSpace.s4),
                    TextFormField(
                      controller: _linkCtrl,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Tautan Proyek (opsional)',
                        hintText: 'https://github.com/username/proyek',
                      ),
                      validator: _validateLink,
                    ),
                    const SizedBox(height: AppSpace.s6),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Simpan'),
                    ),
                    const SizedBox(height: AppSpace.s2),
                    OutlinedButton.icon(
                      onPressed: _reset,
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
