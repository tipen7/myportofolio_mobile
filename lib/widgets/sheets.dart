import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/summary_row.dart';

Future<void> showSuccessSheet(
  BuildContext context, {
  required String title,
  required List<MapEntry<String, String>> rows,
  String actionLabel = 'Tutup',
}) {
  return _showSheet<void>(
    context,
    (sheetContext) => _SheetBody(
      icon: Icons.check_rounded,
      title: title,
      content: Column(
        children: [for (final row in rows) SummaryRow(row.key, row.value)],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(sheetContext),
          child: Text(actionLabel),
        ),
      ],
    ),
  );
}

Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final confirmed = await _showSheet<bool>(context, (sheetContext) {
    final t = sheetContext.tokens;
    return _SheetBody(
      icon: Icons.delete_outline_rounded,
      isDanger: true,
      title: title,
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        FilledButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(t.dangerStrong),
          ),
          onPressed: () => Navigator.pop(sheetContext, true),
          child: Text(confirmLabel),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(sheetContext, false),
          child: const Text('Batal'),
        ),
      ],
    );
  });
  return confirmed ?? false;
}

Future<T?> _showSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: builder,
  );
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.icon,
    required this.title,
    required this.content,
    required this.actions,
    this.isDanger = false,
  });

  final IconData icon;
  final String title;
  final Widget content;
  final List<Widget> actions;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.s5,
        0,
        AppSpace.s5,
        AppSpace.s5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: AppSpace.s8,
              backgroundColor: isDanger ? t.dangerSoft : t.actionSoft,
              child: Icon(
                icon,
                size: AppSpace.s8,
                color: isDanger ? t.dangerText : t.actionText,
              ),
            ),
          ),
          const SizedBox(height: AppSpace.s4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpace.s3),
          Flexible(child: SingleChildScrollView(child: content)),
          const SizedBox(height: AppSpace.s4),
          for (final action in actions) ...[
            action,
            const SizedBox(height: AppSpace.s2),
          ],
        ],
      ),
    );
  }
}
