import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

/// Dialog ringkasan isian formulir (dipakai semua form).
Future<void> showSummaryDialog(
  BuildContext context, {
  required String title,
  required List<MapEntry<String, String>> rows,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final t = dialogContext.tokens;
      return AlertDialog(
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: t.actionSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, color: t.actionText, size: 32),
        ),
        title: Text(title, textAlign: TextAlign.center),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final r in rows) SummaryRow(r.key, r.value)],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      );
    },
  );
}

class SummaryRow extends StatelessWidget {
  const SummaryRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpace.s2),
      padding: const EdgeInsets.all(AppSpace.s3),
      decoration: BoxDecoration(
        color: t.surface2,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: t.actionText, letterSpacing: 0.8),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: t.text, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
