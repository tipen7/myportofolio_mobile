import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

/// Efek "tenggelam" saat disentuh (ala kartu layanan Gojek). Tidak mencuri
/// gesture: anak (mis. InkWell) tetap menangani tap-nya sendiri.
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, this.scale = 0.95});

  final Widget child;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: AppMotion.fast,
        curve: AppMotion.easeOut,
        child: widget.child,
      ),
    );
  }
}
