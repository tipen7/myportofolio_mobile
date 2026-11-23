import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  /// [webFont] = false dipakai pada tes agar tidak mengunduh font.
  const MyApp({super.key, this.webFont = true});

  final bool webFont;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPortfolio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(webFont: webFont),
      darkTheme: AppTheme.dark(webFont: webFont),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}
