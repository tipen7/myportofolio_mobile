import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/app_snack_bar.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/pressable_scale.dart';
import 'package:provider/provider.dart';

/// Kartu layanan ala Gojek: ikon putih di lingkaran berwarna, label di
/// bawahnya, dan efek tenggelam + ripple saat ditekan.
class ItemCard extends StatelessWidget {
  const ItemCard(this.item, {required this.onTap, this.onReturn, super.key});

  final ItemHomepage item;
  final VoidCallback onTap;

  final VoidCallback? onReturn;

  Future<void> _handleTap(BuildContext context) async {
    unawaited(HapticFeedback.selectionClick());
    onTap();

    if (item.isLogout) {
      final auth = context.read<AuthState>();
      final wasLoggedIn = auth.isLoggedIn;
      showAppSnackBar(
        context,
        wasLoggedIn ? 'Berhasil logout.' : 'Kamu belum login.',
      );
      await auth.logout();
      return;
    }

    if (item.requiresAuth) {
      final ok = await ensureLoggedIn(context);
      if (!ok || !context.mounted) return;
    }

    final page = item.page;
    if (page == null) return;
    await Navigator.push(context, MaterialPageRoute<void>(builder: page));
    onReturn?.call();
  }

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
          onTap: () => _handleTap(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.s2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: t.onBrand, size: 28),
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
