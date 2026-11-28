import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/utils/date_format.dart';
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

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({
    this.experience,
    this.returnToCaller = false,
    super.key,
  });

  final Experience? experience;

  /// Setelah tersimpan: `true` menutup form dengan hasilnya, `false` membuka
  /// daftar pengalaman.
  final bool returnToCaller;

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  static const int _minDescLength = 10;
  // Batas bawaan `URLField` Django.
  static const int _maxUrlLength = 200;

  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _thumbnailCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();

  late ExperienceCategory _category;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _ongoing = false;
  bool _isSubmitting = false;

  bool get _isEditing => widget.experience != null;

  @override
  void initState() {
    super.initState();
    _fillFields();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _thumbnailCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  void _fillFields() {
    final e = widget.experience;
    final start = e?.startedAt;
    final end = e?.endedAt;

    _titleCtrl.text = e?.title ?? '';
    _descCtrl.text = e?.description ?? '';
    _thumbnailCtrl.text = e?.thumbnail ?? '';
    _category = e?.category ?? ExperienceCategory.freelance;
    _startDate = start == null ? null : dateOnlyUtc(start.toUtc());
    _endDate = end == null ? null : dateOnlyUtc(end.toUtc());
    _ongoing = e != null && end == null;
    _startCtrl.text = _startDate == null ? '' : formatDate(_startDate!);
    _endCtrl.text = _endDate == null ? '' : formatDate(_endDate!);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final first = DateTime(1990);
    final last = DateTime(DateTime.now().year + 5);
    var initial = (isStart ? _startDate : _endDate) ?? DateTime.now();
    initial = DateTime(initial.year, initial.month, initial.day);
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      helpText: isStart ? 'Pilih tanggal mulai' : 'Pilih tanggal selesai',
    );
    if (picked == null || !mounted) return;
    setState(() {
      final date = dateOnlyUtc(picked);
      if (isStart) {
        _startDate = date;
        _startCtrl.text = formatDate(date);
      } else {
        _endDate = date;
        _endCtrl.text = formatDate(date);
      }
    });
    if (isStart && _endDate != null) _formKey.currentState?.validate();
  }

  String? _validateDescription(String? value) {
    final error = validateRequired(value, 'Deskripsi');
    if (error != null) return error;
    if (value!.trim().length < _minDescLength) {
      return 'Deskripsi minimal $_minDescLength karakter!';
    }
    return null;
  }

  String? _validateStart(String? _) {
    final start = _startDate;
    if (start == null) return 'Tanggal mulai wajib dipilih!';
    // Dibandingkan per tanggal agar "hari ini" sah di semua zona waktu.
    if (start.isAfter(dateOnlyUtc(DateTime.now()))) {
      return 'Tanggal mulai tidak boleh di masa depan!';
    }
    return null;
  }

  String? _validateEnd(String? _) {
    if (_ongoing) return null;
    final end = _endDate;
    if (end == null) return 'Tanggal selesai wajib dipilih!';
    if (_startDate != null && end.isBefore(_startDate!)) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai!';
    }
    return null;
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(_fillFields);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final token = context.read<AuthState>().token;
    if (token == null) return;
    final api = context.read<ApiClient>();

    final draft = Experience(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      thumbnail: _thumbnailCtrl.text.trim(),
      startedAt: _startDate,
      endedAt: _ongoing ? null : _endDate,
    );

    setState(() => _isSubmitting = true);
    final Experience saved;
    try {
      final id = widget.experience?.id;
      saved = id == null
          ? await api.createExperience(draft, token: token)
          : await api.updateExperience(id, draft, token: token);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await handleWriteError(context, error);
      return;
    }
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    await _confirmAndLeave(saved);
  }

  Future<void> _confirmAndLeave(Experience saved) async {
    await showSuccessSheet(
      context,
      title: _isEditing
          ? 'Pengalaman berhasil diperbarui!'
          : 'Pengalaman berhasil ditambahkan!',
      rows: [
        MapEntry('Title', saved.title),
        MapEntry('Category', saved.category.label),
        MapEntry('Period', formatPeriod(saved.startedAt, saved.endedAt)),
        MapEntry('Description', saved.description),
        MapEntry(
          'Thumbnail URL',
          saved.thumbnail.isEmpty ? '-' : saved.thumbnail,
        ),
      ],
      actionLabel: widget.returnToCaller ? 'Kembali' : 'Lihat daftar',
    );
    if (!mounted) return;

    if (widget.returnToCaller) {
      Navigator.pop(context, saved);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const ExperienceListScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Experience Form' : 'Add Experience Form',
        ),
      ),
      drawer: widget.returnToCaller
          ? null
          : const LeftDrawer(current: DrawerDestination.addExperience),
      bottomNavigationBar: BottomActionBar(
        secondary: OutlinedButton(
          onPressed: _isSubmitting ? null : _resetForm,
          child: const Text('Reset'),
        ),
        primary: SubmitButton(isSubmitting: _isSubmitting, onPressed: _save),
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
                        maxLength: Experience.maxTitleLength,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Contoh: Asisten Dosen PBP',
                        ),
                        validator: (v) => validateRequired(
                          v,
                          'Title',
                          max: Experience.maxTitleLength,
                        ),
                      ),
                      const SizedBox(height: AppSpace.s2),
                      const Text('Category'),
                      const SizedBox(height: AppSpace.s2),
                      ChipSelector<ExperienceCategory>(
                        options: ExperienceCategory.values,
                        selected: _category,
                        labelOf: (c) => c.label,
                        onSelected: (c) => setState(() => _category = c),
                      ),
                    ],
                  ),
                  SectionCard(
                    title: 'Periode',
                    children: [
                      TextFormField(
                        controller: _startCtrl,
                        readOnly: true,
                        onTap: () => _pickDate(isStart: true),
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          hintText: 'dd/mm/yyyy',
                          suffixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                        validator: _validateStart,
                      ),
                      const SizedBox(height: AppSpace.s2),
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
                      const SizedBox(height: AppSpace.s2),
                      TextFormField(
                        controller: _endCtrl,
                        readOnly: true,
                        enabled: !_ongoing,
                        onTap: () => _pickDate(isStart: false),
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          hintText: _ongoing ? 'Sekarang' : 'dd/mm/yyyy',
                          suffixIcon: const Icon(Icons.event_rounded),
                        ),
                        validator: _validateEnd,
                      ),
                    ],
                  ),
                  SectionCard(
                    title: 'Cerita',
                    children: [
                      TextFormField(
                        controller: _descCtrl,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Ceritakan tanggung jawab & pencapaianmu',
                          alignLabelWithHint: true,
                        ),
                        validator: _validateDescription,
                      ),
                      const SizedBox(height: AppSpace.s4),
                      TextFormField(
                        controller: _thumbnailCtrl,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        decoration: const InputDecoration(
                          labelText: 'Thumbnail URL (Optional)',
                          hintText: 'https://example.com/gambar.png',
                        ),
                        validator: (v) => validateUrl(v, max: _maxUrlLength),
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
