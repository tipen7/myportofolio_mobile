import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/widgets/skeleton.dart';

import '../helpers/fake_backend.dart';

void main() {
  Future<void> openList(WidgetTester tester) =>
      tapAndSettle(tester, find.text('Lihat Pengalaman'));

  testWidgets('daftar dan detail dapat dibaca tanpa login', (tester) async {
    final backend = FakeBackend();
    await pumpApp(tester, backend);

    await openList(tester);
    expect(find.text('Backend Intern'), findsOneWidget);

    await tapAndSettle(tester, find.text('Backend Intern'));
    expect(find.text('Experience Detail'), findsOneWidget);
    for (final value in [
      experienceId,
      'Membangun REST API dengan DRF',
      'Part-Time',
      '05/01/2026',
      '20/03/2026',
      'Selesai',
      '2',
      'ani, budi',
      'Tidak',
      'Comments (1)',
      'Keren sekali',
    ]) {
      expect(find.text(value), findsOneWidget, reason: value);
    }
    expect(backend.requests.every((r) => r.method == 'GET'), isTrue);
  });

  testWidgets('menampilkan loading sebelum data tiba', (tester) async {
    final backend = FakeBackend()..gate = Completer<void>();
    await pumpApp(tester, backend);

    await tester.tap(find.text('Lihat Pengalaman'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(Skeleton), findsOneWidget);
    backend.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('Backend Intern'), findsOneWidget);
  });

  testWidgets('galat menampilkan tombol Retry yang memuat ulang', (
    tester,
  ) async {
    final backend = FakeBackend()..failure = http.Response('boom', 500);
    await pumpApp(tester, backend);

    await openList(tester);
    expect(find.textContaining('Gagal memuat pengalaman.'), findsOneWidget);

    backend.failure = null;
    await tapAndSettle(tester, find.text('Retry'));
    expect(find.text('Backend Intern'), findsOneWidget);
  });

  testWidgets('daftar kosong dapat ditarik untuk memuat ulang', (tester) async {
    final backend = FakeBackend(experiences: []);
    await pumpApp(tester, backend);

    await openList(tester);
    expect(find.text('Belum ada pengalaman.'), findsOneWidget);

    backend.experiences.add(experienceJson(title: 'Baru dari web'));
    await tester.fling(
      find.text('Belum ada pengalaman.'),
      const Offset(0, 600),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('Baru dari web'), findsOneWidget);
  });

  testWidgets('rebuild tidak mengulang permintaan GET', (tester) async {
    final backend = FakeBackend();
    await pumpApp(tester, backend);
    await openList(tester);
    final requests = backend.sent('GET').length;

    tester.view.physicalSize = const Size(900, 1600);
    await tester.pumpAndSettle();

    expect(backend.sent('GET'), hasLength(requests));
  });

  testWidgets('drawer membuka daftar pengalaman', (tester) async {
    await pumpApp(tester, FakeBackend());

    await tapAndSettle(tester, find.byTooltip('Open navigation menu'));
    await tapAndSettle(tester, find.text('Experiences'));

    expect(find.text('Backend Intern'), findsOneWidget);
  });

  testWidgets('daftar proyek tetap menampilkan data dan detail', (
    tester,
  ) async {
    await pumpApp(tester, FakeBackend());

    await tapAndSettle(tester, find.text('Lihat Proyek'));
    await tapAndSettle(tester, find.text('Proyek Satu'));

    expect(find.text('Project Detail'), findsOneWidget);
    expect(find.text('Deskripsi satu'), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('tidak ada overflow di layar sempit (${brightness.name})', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await pumpApp(tester, FakeBackend(), size: const Size(360, 640));
      expect(tester.takeException(), isNull);

      await openList(tester);
      await tapAndSettle(tester, find.text('Backend Intern'));
      expect(tester.takeException(), isNull);

      await tapAndSettle(tester, find.text('Edit'));
      await logIn(tester);
      expect(find.text('Edit Experience Form'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('pencarian dan chip menyaring tanpa meminta ulang', (
    tester,
  ) async {
    final backend = FakeBackend(
      experiences: [
        experienceJson(),
        {
          ...experienceJson(id: 'r1', title: 'Peneliti Data'),
          'category': 'research',
        },
      ],
    );
    await pumpApp(tester, backend);
    await openList(tester);
    final requests = backend.sent('GET').length;

    await tester.enterText(find.byType(TextField), 'peneliti');
    await tester.pumpAndSettle();
    expect(find.text('Peneliti Data'), findsOneWidget);
    expect(find.text('Backend Intern'), findsNothing);

    await tapAndSettle(tester, find.widgetWithText(ChoiceChip, 'Part-Time'));
    expect(find.text('Tidak ada yang cocok.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(find.text('Backend Intern'), findsOneWidget);
    expect(backend.sent('GET'), hasLength(requests));
  });

  testWidgets('bottom navigation berpindah antarhalaman', (tester) async {
    await pumpApp(tester, FakeBackend());

    await tapAndSettle(tester, find.text('Pengalaman'));
    expect(find.text('Experiences'), findsOneWidget);
    await tapAndSettle(tester, find.text('Proyek'));
    expect(find.text('Proyek Satu'), findsOneWidget);
    await tapAndSettle(tester, find.text('Akun'));
    await tapAndSettle(tester, find.text('Masuk'));
    await logIn(tester);
    expect(find.text('Sudah login'), findsOneWidget);
    await tapAndSettle(tester, find.text('Keluar'));
    expect(find.text('Tamu'), findsOneWidget);
    await tapAndSettle(tester, find.text('Beranda'));
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('beranda: feed, cari, dan reset penghitung', (tester) async {
    await pumpApp(tester, FakeBackend());
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.text('Backend Intern'));
    expect(find.text('Experience Detail'), findsOneWidget);
    await tapAndSettle(tester, find.byType(BackButton));

    await tapAndSettle(tester, find.text('Logout'));
    expect(find.text('Total tombol ditekan: 1'), findsOneWidget);
    await tapAndSettle(tester, find.byTooltip('Reset penghitung'));
    expect(find.text('Total tombol ditekan: 0'), findsOneWidget);

    await tapAndSettle(tester, find.text('Cari pengalaman'));
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('beranda menawarkan coba lagi saat server gagal', (tester) async {
    final backend = FakeBackend()..failure = http.Response('boom', 500);
    await pumpApp(tester, backend);
    await tester.pumpAndSettle();

    backend.failure = null;
    await tapAndSettle(tester, find.text('Coba lagi'));

    expect(find.text('Backend Intern'), findsOneWidget);
  });
}
