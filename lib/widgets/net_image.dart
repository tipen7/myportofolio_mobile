import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

class NetImage extends StatelessWidget {
  const NetImage({
    required this.url,
    required this.icon,
    this.width,
    this.height,
    super.key,
  });

  final String url;
  final IconData icon;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fallback = Container(
      width: width,
      height: height,
      color: t.actionSoft,
      alignment: Alignment.center,
      child: Icon(icon, size: AppSpace.s8, color: t.actionText),
    );
    if (url.isEmpty) return fallback;

    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}
