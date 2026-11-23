import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/pressable_scale.dart';

/// Kartu layanan ala Gojek: ikon dalam kotak membulat berwarna lembut,
/// label di bawahnya, dan efek tenggelam + ripple saat ditekan.
class ItemCard extends StatelessWidget {
  final ItemHomepage item;
  final VoidCallback onTap;

  const ItemCard(this.item, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: item.name,
      child: PressableScale(
        child: InkWell(
          borderRadius: AppRadius.lgAll,
          onTap: () {
            HapticFeedback.selectionClick();
            // Counter & SnackBar ditangani oleh halaman pemilik kartu.
            onTap();

            // Buka halaman tujuan (jika ada); tombol kembali bawaan tersedia.
            final page = item.page;
            if (page != null) {
              Navigator.push(context, MaterialPageRoute(builder: page));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.s2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.14),
                    borderRadius: AppRadius.lgAll,
                  ),
                  child: Icon(item.icon, color: item.color, size: 28),
                ),
                const SizedBox(height: AppSpace.s2),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelMedium?.copyWith(
                    color: t.text,
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
