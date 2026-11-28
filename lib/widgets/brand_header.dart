import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

/// Green header whose background stops [overlap] pixels above the bottom of
/// [child], so the last card appears to float over the edge.
class BrandHeader extends StatelessWidget {
  const BrandHeader({required this.child, this.overlap = 0, super.key});

  final Widget child;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          Positioned.fill(
            bottom: overlap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: t.heroGradient,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppRadius.xl),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.s4,
                AppSpace.s3,
                AppSpace.s4,
                0,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
