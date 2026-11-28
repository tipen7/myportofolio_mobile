import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/app_snack_bar.dart';
import 'package:provider/provider.dart';

/// Ensures the user is authenticated, pushing [LoginScreen] when needed.
Future<bool> ensureLoggedIn(BuildContext context) async {
  if (context.read<AuthState>().isLoggedIn) return true;

  final loggedIn = await Navigator.push<bool>(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
  );
  return loggedIn ?? false;
}

Future<void> handleWriteError(BuildContext context, Object error) async {
  if (error is ApiException && error.isUnauthorized) {
    context.read<AuthState>().clearSession();
    showAppSnackBar(context, 'Sesi berakhir. Silakan login kembali.');
    await ensureLoggedIn(context);
    return;
  }
  showAppSnackBar(context, describeError(error), isError: true);
}
