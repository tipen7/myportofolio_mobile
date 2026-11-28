import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

class Pill extends StatelessWidget {
  const Pill(this.label, {this.icon, this.isNeutral = false, super.key});

  final String label;
  final IconData? icon;
  final bool isNeutral;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final color = isNeutral ? t.textMuted : t.actionText;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s2,
        vertical: AppSpace.s1,
      ),
      decoration: BoxDecoration(
        color: isNeutral ? t.surfaceSunken : t.actionSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSpace.s3, color: color),
            const SizedBox(width: AppSpace.s1),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
