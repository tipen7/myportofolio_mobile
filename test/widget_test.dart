import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';

void main() {
  testWidgets('Kartu "Tambah Pengalaman" membuka form dan validasi bekerja', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp(webFont: false));

    await tester.tap(find.text('Tambah Pengalaman'));
    await tester.pumpAndSettle();
    expect(find.text('Add Experience Form'), findsOneWidget);

    // Simpan dalam keadaan kosong -> muncul error, tanpa dialog.
    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Nama institusi tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    // Input hanya spasi tetap ditolak.
    await tester.enterText(find.byType(TextFormField).at(0), '   ');
    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Nama institusi tidak boleh kosong!'), findsOneWidget);
  });

  testWidgets('Drawer membuka form pengalaman dan Home kembali ke utama', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MyApp(webFont: false));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Experience'));
    await tester.pumpAndSettle();
    expect(find.text('Add Experience Form'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('Tidak ada overflow di layar sempit (${mode.name})', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(webFont: false),
          darkTheme: AppTheme.dark(webFont: false),
          themeMode: mode,
          home: const MyHomePage(),
        ),
      );
      expect(tester.takeException(), isNull);

      for (final label in ['Tambah Proyek', 'Tambah Pengalaman']) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: label);
        tester.state<NavigatorState>(find.byType(Navigator)).pop();
        await tester.pumpAndSettle();
      }
    });
  }
}
