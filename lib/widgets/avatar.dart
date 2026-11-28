import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/profile.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';

class Avatar extends StatelessWidget {
  const Avatar({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: t.onBrand, shape: BoxShape.circle),
      child: Text(
        ownerName.substring(0, 1),
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(color: t.action, fontWeight: FontWeight.w800),
      ),
    );
  }
}
