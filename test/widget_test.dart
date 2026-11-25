import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';

const _projectJson = {
  'id': '1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed',
  'name': 'Proyek Satu',
  'type': 'personal',
  'description': 'Deskripsi satu',
  'tech_stack': ['Flutter', 'Django'],
  'url': null,
  'image': 'https://example.com/a.png',
};

ApiClient _fakeApi() => ApiClient(
  baseUrl: 'http://test',
  client: MockClient((request) async {
    final path = request.url.path;
    if (path == '/api/v1/projects/' && request.method == 'GET') {
      return http.Response(jsonEncode([_projectJson]), 200);
    }
    if (path == '/api/v1/auth/token/') {
      return http.Response(jsonEncode({'token': 'abc'}), 200);
    }
    if (path == '/api/v1/auth/logout/') return http.Response('', 204);
    return http.Response('not found', 404);
  }),
);

void main() {
  test('Project.fromJson/toJson memetakan snake_case dan default kosong', () {
    final p = Project.fromJson(_projectJson);
    expect(p.id, _projectJson['id']);
    expect(p.techStack, ['Flutter', 'Django']);
    expect(p.url, '');
    final json = p.toJson();
    expect(json.containsKey('id'), isFalse);
    expect(json['tech_stack'], ['Flutter', 'Django']);
  });

  test('ApiClient: token, daftar proyek, error -> ApiException', () async {
    final api = _fakeApi();
    expect(await api.obtainToken('u', 'p'), 'abc');
    expect((await api.getProjects()).single.name, 'Proyek Satu');
    await api.logout(token: 'abc');
    await expectLater(
      ApiClient(client: MockClient((_) async => http.Response('no', 401)))
          .getProjects(),
      throwsA(isA<ApiException>()),
    );
  });

  testWidgets('Tambah Proyek tanpa login mengarah ke layar Login', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MyApp(apiClient: _fakeApi(), webFont: false));

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.text('Username cannot be empty!'), findsNothing);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Validasi login.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    expect(find.text('Username cannot be empty!'), findsOneWidget);

    // Login berhasil -> langsung ke form proyek.
    await tester.enterText(find.byType(TextFormField).at(0), 'u');
    await tester.enterText(find.byType(TextFormField).at(1), 'p');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);
  });

  testWidgets('Lihat Proyek menampilkan data dari API', (tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MyApp(apiClient: _fakeApi(), webFont: false));

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pumpAndSettle();
    expect(find.text('Proyek Satu'), findsOneWidget);

    await tester.tap(find.text('Proyek Satu'));
    await tester.pumpAndSettle();
    expect(find.text('Project Detail'), findsOneWidget);
    expect(find.text('Deskripsi satu'), findsOneWidget);
  });

  testWidgets('Kartu "Tambah Pengalaman" membuka form dan validasi bekerja', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MyApp(apiClient: _fakeApi(), webFont: false));

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
    await tester.pumpWidget(MyApp(apiClient: _fakeApi(), webFont: false));

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
      final api = _fakeApi();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: api),
            ChangeNotifierProvider(create: (_) => AuthState(api)),
          ],
          child: MaterialApp(
            theme: AppTheme.light(webFont: false),
            darkTheme: AppTheme.dark(webFont: false),
            themeMode: mode,
            home: const MyHomePage(),
          ),
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
