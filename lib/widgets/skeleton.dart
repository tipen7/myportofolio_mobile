import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({this.count = 4, super.key});

  final int count;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppMotion.slow * 2,
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(min: 0.45, max: 1, reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget block(double height, {double? width}) => Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: t.surfaceSunken,
        borderRadius: AppRadius.mdAll,
      ),
    );

    return Semantics(
      label: 'Memuat',
      child: FadeTransition(
        opacity: _pulse,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpace.s4),
          child: Column(
            spacing: AppSpace.s4,
            children: [
              for (var i = 0; i < widget.count; i++)
                Row(
                  children: [
                    block(AppSpace.s16, width: AppSpace.s16),
                    const SizedBox(width: AppSpace.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: AppSpace.s2,
                        children: [
                          block(AppSpace.s4),
                          block(AppSpace.s3, width: AppSpace.s16 * 2),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
