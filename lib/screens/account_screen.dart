import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_tokens.dart';
import 'package:myportofolio_mobile/widgets/app_bottom_nav.dart';
import 'package:myportofolio_mobile/widgets/app_snack_bar.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/page_body.dart';
import 'package:myportofolio_mobile/widgets/profile_card.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    showAppSnackBar(context, 'Berhasil logout.');
    await context.read<AuthState>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Scaffold(
      appBar: AppBar(title: const Text('Akun')),
      drawer: const LeftDrawer(current: DrawerDestination.account),
      bottomNavigationBar: const AppBottomNav(
        current: DrawerDestination.account,
      ),
      body: PageBody(
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.s4),
          children: [
            const ProfileCard(),
            const SizedBox(height: AppSpace.s4),
            Text(
              isLoggedIn
                  ? 'Kamu bisa menambah, mengubah, dan menghapus data sesuai '
                        'hak akses akunmu.'
                  : 'Kamu bisa membaca semua data. Masuk untuk mengubahnya.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: t.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpace.s4),
            if (isLoggedIn)
              OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar'),
              )
            else
              FilledButton.icon(
                onPressed: () => ensureLoggedIn(context),
                icon: const Icon(Icons.login_rounded),
                label: const Text('Masuk'),
              ),
          ],
        ),
      ),
    );
  }
}
