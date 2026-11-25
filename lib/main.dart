import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp(apiClient: ApiClient()));
}

class MyApp extends StatelessWidget {
  /// [webFont] = false dipakai pada tes agar tidak mengunduh font.
  const MyApp({required this.apiClient, super.key, this.webFont = true});

  final ApiClient apiClient;
  final bool webFont;

  @override
  Widget build(BuildContext context) {
    // MultiProvider menyisipkan ApiClient dan AuthState ke seluruh widget tree.
    return MultiProvider(
      providers: [
        Provider.value(value: apiClient),
        ChangeNotifierProvider(create: (_) => AuthState(apiClient)),
      ],
      child: MaterialApp(
        title: 'MyPortfolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(webFont: webFont),
        darkTheme: AppTheme.dark(webFont: webFont),
        themeMode: ThemeMode.system,
        home: const MyHomePage(),
      ),
    );
  }
}
