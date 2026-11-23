import 'package:flutter/material.dart';

import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/summary_dialog.dart';

/// Formulir untuk menambah bagian "Pengalaman" pada portofolio.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  static const int _maxNameLength = 60;
  static const int _maxDescLength = 300;
  static const int _minDescLength = 10;

  static const List<String> _types = [
    'Magang',
    'Kerja Penuh Waktu',
    'Freelance',
    'Organisasi',
    'Kepanitiaan',
  ];

  final _formKey = GlobalKey<FormState>();
  final _institutionCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  String _type = _types.first;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _ongoing = false;

  @override
  void dispose() {
    _institutionCtrl.dispose();
    _roleCtrl.dispose();
    _descCtrl.dispose();
    _linkCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _startDate : _endDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 5),
      helpText: isStart ? 'Pilih tanggal mulai' : 'Pilih tanggal selesai',
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        _startCtrl.text = _formatDate(picked);
      } else {
        _endDate = picked;
        _endCtrl.text = _formatDate(picked);
      }
    });
    // Validasi ulang tanggal selesai jika tanggal mulai berubah.
    if (isStart && _endDate != null) _formKey.currentState?.validate();
  }

  String? _requiredText(String? value, String label, {int? max}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label tidak boleh kosong!';
    if (max != null && text.length > max) {
      return '$label maksimal $max karakter!';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Deskripsi tidak boleh kosong!';
    if (text.length < _minDescLength) {
      return 'Deskripsi minimal $_minDescLength karakter!';
    }
    if (text.length > _maxDescLength) {
      return 'Deskripsi maksimal $_maxDescLength karakter!';
    }
    return null;
  }

  String? _validateStart(String? value) {
    if (_startDate == null) return 'Tanggal mulai wajib dipilih!';
    if (_startDate!.isAfter(DateTime.now())) {
      return 'Tanggal mulai tidak boleh di masa depan!';
    }
    return null;
  }

  String? _validateEnd(String? value) {
    if (_ongoing) return null;
    if (_endDate == null) return 'Tanggal selesai wajib dipilih!';
    if (_startDate != null && _endDate!.isBefore(_startDate!)) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai!';
    }
    return null;
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

  void _resetForm() {
    _formKey.currentState!.reset();
    _institutionCtrl.clear();
    _roleCtrl.clear();
    _descCtrl.clear();
    _linkCtrl.clear();
    _startCtrl.clear();
    _endCtrl.clear();
    setState(() {
      _type = _types.first;
      _startDate = null;
      _endDate = null;
      _ongoing = false;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final link = _linkCtrl.text.trim();
    showSummaryDialog(
      context,
      title: 'Pengalaman berhasil ditambahkan!',
      rows: [
        MapEntry('Institusi', _institutionCtrl.text.trim()),
        MapEntry('Posisi', _roleCtrl.text.trim()),
        MapEntry('Jenis', _type),
        MapEntry('Mulai', _formatDate(_startDate!)),
        MapEntry(
          'Selesai',
          _ongoing ? 'Masih berlangsung' : _formatDate(_endDate!),
        ),
        MapEntry('Deskripsi', _descCtrl.text.trim()),
        MapEntry('Tautan', link.isEmpty ? '-' : link),
      ],
    );
  }

  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Experience Form')),
      drawer: const LeftDrawer(current: DrawerDestination.addExperience),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _institutionCtrl,
                      textInputAction: TextInputAction.next,
                      maxLength: _maxNameLength,
                      decoration: _decoration(
                        'Nama Institusi / Perusahaan',
                        hint: 'Contoh: Universitas Indonesia',
                      ),
                      validator: (v) => _requiredText(
                        v,
                        'Nama institusi',
                        max: _maxNameLength,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _roleCtrl,
                      textInputAction: TextInputAction.next,
                      maxLength: _maxNameLength,
                      decoration: _decoration(
                        'Posisi / Peran',
                        hint: 'Contoh: Asisten Dosen',
                      ),
                      validator: (v) =>
                          _requiredText(v, 'Posisi', max: _maxNameLength),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _type,
                      decoration: _decoration('Jenis Pengalaman'),
                      items: _types
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _type = v ?? _type),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _startCtrl,
                      readOnly: true,
                      onTap: () => _pickDate(isStart: true),
                      decoration: _decoration(
                        'Tanggal Mulai',
                        hint: 'dd/mm/yyyy',
                        suffix: const Icon(Icons.calendar_today_rounded),
                      ),
                      validator: _validateStart,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Masih berlangsung'),
                      value: _ongoing,
                      onChanged: (v) {
                        setState(() {
                          _ongoing = v;
                          if (v) {
                            _endDate = null;
                            _endCtrl.clear();
                          }
                        });
                        _formKey.currentState?.validate();
                      },
                    ),
                    TextFormField(
                      controller: _endCtrl,
                      readOnly: true,
                      enabled: !_ongoing,
                      onTap: () => _pickDate(isStart: false),
                      decoration: _decoration(
                        'Tanggal Selesai',
                        hint: _ongoing ? 'Sekarang' : 'dd/mm/yyyy',
                        suffix: const Icon(Icons.event_rounded),
                      ),
                      validator: _validateEnd,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      maxLength: _maxDescLength,
                      keyboardType: TextInputType.multiline,
                      decoration: _decoration(
                        'Deskripsi',
                        hint: 'Ceritakan tanggung jawab & pencapaianmu',
                      ),
                      validator: _validateDescription,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _linkCtrl,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      decoration: _decoration(
                        'Tautan Sertifikat / Referensi (opsional)',
                        hint: 'https://contoh.com/sertifikat',
                      ),
                      validator: _validateLink,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Simpan'),
                    ),
                    const SizedBox(height: AppSpace.s2),
                    OutlinedButton.icon(
                      onPressed: _resetForm,
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
