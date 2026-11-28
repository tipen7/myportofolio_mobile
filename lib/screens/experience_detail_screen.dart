import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/utils/date_format.dart';
import 'package:myportofolio_mobile/widgets/app_snack_bar.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/bottom_action_bar.dart';
import 'package:myportofolio_mobile/widgets/detail_layout.dart';
import 'package:myportofolio_mobile/widgets/pill.dart';
import 'package:myportofolio_mobile/widgets/section_card.dart';
import 'package:myportofolio_mobile/widgets/sheets.dart';
import 'package:myportofolio_mobile/widgets/summary_row.dart';
import 'package:provider/provider.dart';

class ExperienceDetailScreen extends StatefulWidget {
  const ExperienceDetailScreen({
    required this.experience,
    this.onChanged,
    super.key,
  });

  final Experience experience;

  final VoidCallback? onChanged;

  @override
  State<ExperienceDetailScreen> createState() => _ExperienceDetailScreenState();
}

class _ExperienceDetailScreenState extends State<ExperienceDetailScreen> {
  late Experience _experience = widget.experience;
  bool _isDeleting = false;

  Future<void> _edit() async {
    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;

    final updated = await Navigator.push<Experience>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ExperienceFormPage(experience: _experience, returnToCaller: true),
      ),
    );
    if (updated == null) return;
    widget.onChanged?.call();
    if (mounted) setState(() => _experience = updated);
  }

  Future<void> _delete() async {
    final loggedIn = await ensureLoggedIn(context);
    if (!loggedIn || !mounted) return;
    final confirmed = await showConfirmSheet(
      context,
      title: 'Hapus pengalaman?',
      message: '"${_experience.title}" akan dihapus permanen.',
      confirmLabel: 'Ya, hapus',
    );
    if (!confirmed || !mounted) return;

    final token = context.read<AuthState>().token;
    final id = _experience.id;
    if (token == null || id == null) return;
    final api = context.read<ApiClient>();

    setState(() => _isDeleting = true);
    try {
      await api.deleteExperience(id, token: token);
      widget.onChanged?.call();
      if (!mounted) return;
      showAppSnackBar(context, 'Pengalaman dihapus.');
      Navigator.pop(context);
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      await handleWriteError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final e = _experience;
    final start = e.startedAt;
    final end = e.endedAt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Experience Detail'),
        bottom: _isDeleting
            ? const PreferredSize(
                preferredSize: Size.fromHeight(AppSpace.s1),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      bottomNavigationBar: BottomActionBar(
        secondary: OutlinedButton.icon(
          style: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll(t.dangerText),
          ),
          onPressed: _isDeleting ? null : _delete,
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Hapus'),
        ),
        primary: FilledButton.icon(
          onPressed: _isDeleting ? null : _edit,
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Edit'),
        ),
      ),
      body: DetailLayout(
        imageUrl: e.thumbnail,
        icon: Icons.work_rounded,
        title: e.title,
        badges: [
          Pill(
            e.categoryDisplay.isEmpty ? e.category.label : e.categoryDisplay,
          ),
          Pill(
            e.isOngoing ? 'Masih berlangsung' : 'Selesai',
            icon: e.isOngoing
                ? Icons.timelapse_rounded
                : Icons.check_circle_rounded,
            isNeutral: !e.isOngoing,
          ),
        ],
        sections: [
          SectionCard(title: 'Tentang', children: [Text(e.description)]),
          SectionCard(
            title: 'Periode',
            children: [
              SummaryRow('Start Date', start == null ? '-' : formatDate(start)),
              SummaryRow(
                'End Date',
                end == null ? 'Belum ada' : formatDate(end),
              ),
            ],
          ),
          SectionCard(
            title: 'Bintang',
            children: [
              SummaryRow('Star Count', '${e.starCount}'),
              SummaryRow('Starred By', _orDash(e.starredByNames)),
              // Daftar dibaca anonim, jadi nilai pribadi ini baru akurat
              // setelah respons dari request bertoken.
              SummaryRow('Starred By You', e.isStarred ? 'Ya' : 'Tidak'),
              SummaryRow('Your Comment', e.userComment?.text ?? '-'),
            ],
          ),
          SectionCard(
            title: 'Comments (${e.comments.length})',
            children: [
              if (e.comments.isEmpty) const Text('Belum ada komentar.'),
              for (final comment in e.comments) _CommentTile(comment),
            ],
          ),
          SectionCard(
            title: 'Informasi',
            children: [
              SummaryRow('ID', e.id ?? '-'),
              SummaryRow('Thumbnail URL', _orDash(e.thumbnail)),
            ],
          ),
        ],
      ),
    );
  }

  static String _orDash(String value) => value.isEmpty ? '-' : value;
}

class _CommentTile extends StatelessWidget {
  const _CommentTile(this.comment);

  final ExperienceComment comment;

  @override
  Widget build(BuildContext context) {
    final createdAt = comment.createdAt;
    final date = createdAt == null
        ? ''
        : ' · ${formatDate(createdAt.toLocal())}';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
      title: Text(comment.text),
      subtitle: Text('${comment.username}$date'),
    );
  }
}
