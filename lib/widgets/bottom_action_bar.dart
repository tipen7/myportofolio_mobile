import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

class BottomActionBar extends StatelessWidget {
  const BottomActionBar({
    required this.secondary,
    required this.primary,
    super.key,
  });

  final Widget secondary;
  final Widget primary;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    // Scaffold tidak menaikkan bottom bar saat keyboard muncul.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(color: t.surface, boxShadow: t.shadowMd),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.s4),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppLayout.maxContentWidth,
                ),
                child: Row(
                  children: [
                    secondary,
                    const SizedBox(width: AppSpace.s3),
                    Expanded(child: primary),
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
