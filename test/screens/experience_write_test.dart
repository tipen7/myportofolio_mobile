import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/screens/experience_form.dart';

import '../helpers/fake_backend.dart';

Finder _field(String label) => find.widgetWithText(TextFormField, label);

Future<void> _fillForm(WidgetTester tester) async {
  await tester.enterText(_field('Title'), 'Asisten Dosen');
  await tapAndSettle(tester, _field('Start Date'));
  await tapAndSettle(tester, find.text('OK'));
  await tapAndSettle(tester, find.text('Masih berlangsung'));
  await tester.enterText(_field('Description'), 'Membantu praktikum PBP');
}

Future<void> _openAddForm(WidgetTester tester, FakeBackend backend) async {
  await pumpApp(tester, backend);
  await tapAndSettle(tester, find.text('Lihat Pengalaman'));
  await tapAndSettle(tester, find.text('Tambah'));
  await logIn(tester);
}

Future<void> _openDetail(WidgetTester tester, FakeBackend backend) async {
  await pumpApp(tester, backend);
  await tapAndSettle(tester, find.text('Lihat Pengalaman'));
  await tapAndSettle(tester, find.text('Backend Intern'));
}

void main() {
  group('auth guard', () {
    testWidgets('kartu "Tambah Pengalaman" meminta login', (tester) async {
      await pumpApp(tester, FakeBackend());

      await tapAndSettle(tester, find.text('Tambah Pengalaman'));
      expect(find.byType(ExperienceFormPage), findsNothing);

      await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Login'));
      expect(find.text('Username cannot be empty!'), findsOneWidget);

      await logIn(tester);
      expect(find.text('Add Experience Form'), findsOneWidget);
    });

    testWidgets('menutup layar login membatalkan aksi', (tester) async {
      await pumpApp(tester, FakeBackend());

      await tapAndSettle(tester, find.text('Tambah Pengalaman'));
      await tapAndSettle(tester, find.byType(BackButton));

      expect(find.byType(ExperienceFormPage), findsNothing);
    });

    testWidgets('drawer "Add Experience" meminta login', (tester) async {
      await pumpApp(tester, FakeBackend());

      await tapAndSettle(tester, find.byTooltip('Open navigation menu'));
      await tapAndSettle(tester, find.text('Add Experience'));
      await logIn(tester);

      expect(find.text('Add Experience Form'), findsOneWidget);
    });

    testWidgets('kartu "Tambah Proyek" meminta login', (tester) async {
      await pumpApp(tester, FakeBackend());

      await tapAndSettle(tester, find.text('Tambah Proyek'));
      await logIn(tester);

      expect(find.text('Add Project Form'), findsOneWidget);
    });

    testWidgets('logout dari drawer mencabut token', (tester) async {
      final backend = FakeBackend();
      await pumpApp(tester, backend);
      await tapAndSettle(tester, find.text('Tambah Pengalaman'));
      await logIn(tester);

      await tapAndSettle(tester, find.byTooltip('Open navigation menu'));
      await tapAndSettle(tester, find.text('Logout'));

      expect(backend.requests.last.url.path, '/api/v1/auth/logout/');
      expect(find.text('Berhasil logout.'), findsOneWidget);
    });
  });

  group('tambah', () {
    testWidgets('input tidak valid tidak mengirim apa pun', (tester) async {
      final backend = FakeBackend();
      await _openAddForm(tester, backend);

      await tester.enterText(_field('Title'), '   ');
      await tapAndSettle(tester, find.text('Simpan'));

      expect(find.text('Title tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Tanggal mulai wajib dipilih!'), findsOneWidget);
      expect(find.text('Tanggal selesai wajib dipilih!'), findsOneWidget);
      expect(find.text('Deskripsi tidak boleh kosong!'), findsOneWidget);
      expect(
        backend.sent('POST').where((r) => r.url.path.contains('experiences')),
        isEmpty,
      );
    });

    testWidgets('Simpan mengirim POST lalu entri muncul di daftar', (
      tester,
    ) async {
      final backend = FakeBackend();
      await _openAddForm(tester, backend);
      await _fillForm(tester);

      await tapAndSettle(tester, find.text('Simpan'));
      expect(find.text('Pengalaman berhasil ditambahkan!'), findsOneWidget);

      final post = backend.sent('POST').last;
      expect(post.headers['Authorization'], 'Token abc');
      final body = jsonDecode(post.body) as Map<String, dynamic>;
      expect(body['title'], 'Asisten Dosen');
      expect(body['category'], 'freelance');
      expect(body['ended_at'], isNull);
      expect(body['started_at'], endsWith('T00:00:00.000Z'));

      await tapAndSettle(tester, find.text('Kembali'));
      expect(find.text('Experiences'), findsOneWidget);
      expect(find.text('Asisten Dosen'), findsOneWidget);
    });

    testWidgets('form dari halaman utama berlanjut ke daftar', (tester) async {
      await pumpApp(tester, FakeBackend());
      await tapAndSettle(tester, find.text('Tambah Pengalaman'));
      await logIn(tester);
      await _fillForm(tester);

      await tapAndSettle(tester, find.text('Simpan'));
      await tapAndSettle(tester, find.text('Lihat daftar'));

      expect(find.text('Asisten Dosen'), findsOneWidget);
    });

    testWidgets('401 menghapus sesi, meminta login, isian tetap ada', (
      tester,
    ) async {
      final backend = FakeBackend();
      await _openAddForm(tester, backend);
      await _fillForm(tester);
      backend.tokenValid = false;

      await tapAndSettle(tester, find.text('Simpan'));
      expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
      expect(find.textContaining('Sesi berakhir'), findsOneWidget);

      backend.tokenValid = true;
      await logIn(tester);
      expect(find.text('Asisten Dosen'), findsOneWidget);

      await tapAndSettle(tester, find.text('Simpan'));
      expect(find.text('Pengalaman berhasil ditambahkan!'), findsOneWidget);
    });

    testWidgets('galat validasi server tampil di SnackBar', (tester) async {
      final backend = FakeBackend();
      await _openAddForm(tester, backend);
      await _fillForm(tester);
      backend.failure = jsonResponse({
        'title': ['Experience title is required.'],
      }, 400);

      await tapAndSettle(tester, find.text('Simpan'));

      expect(find.text('title: Experience title is required.'), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('jaringan putus ditangani dengan pesan', (tester) async {
      final backend = FakeBackend();
      await _openAddForm(tester, backend);
      await _fillForm(tester);
      backend.failure = http.Response('', 502);

      await tapAndSettle(tester, find.text('Simpan'));

      expect(find.text('Server menolak (status 502).'), findsOneWidget);
    });

    testWidgets('Reset mengosongkan form', (tester) async {
      await _openAddForm(tester, FakeBackend());
      await _fillForm(tester);

      await tapAndSettle(tester, find.text('Reset'));

      expect(find.text('Asisten Dosen'), findsNothing);
      expect(find.text('Membantu praktikum PBP'), findsNothing);
    });
  });

  group('edit & hapus', () {
    testWidgets('edit mengirim PATCH dan memperbarui detail serta daftar', (
      tester,
    ) async {
      final backend = FakeBackend();
      await _openDetail(tester, backend);
      await tapAndSettle(tester, find.text('Edit'));
      await logIn(tester);

      expect(find.text('05/01/2026'), findsOneWidget);
      expect(find.text('20/03/2026'), findsOneWidget);

      await tester.enterText(_field('Title'), 'Judul Baru');
      await tapAndSettle(tester, find.text('Simpan'));
      await tapAndSettle(tester, find.text('Kembali'));

      final patch = backend.sent('PATCH').single;
      expect(patch.headers['Authorization'], 'Token abc');
      final body = jsonDecode(patch.body) as Map<String, dynamic>;
      expect(body['category'], 'part-time');
      expect(body['ended_at'], '2026-03-20T00:00:00.000Z');
      expect(find.text('Experience Detail'), findsOneWidget);
      expect(find.text('Judul Baru'), findsOneWidget);

      await tapAndSettle(tester, find.byType(BackButton));
      expect(find.text('Judul Baru'), findsOneWidget);
    });

    testWidgets('hapus meminta konfirmasi lalu mengirim DELETE', (
      tester,
    ) async {
      final backend = FakeBackend();
      await _openDetail(tester, backend);

      await tapAndSettle(tester, find.text('Hapus'));
      await logIn(tester);
      await tapAndSettle(tester, find.text('Batal'));
      expect(backend.sent('DELETE'), isEmpty);

      await tapAndSettle(tester, find.text('Hapus'));
      await tapAndSettle(tester, find.text('Ya, hapus'));

      expect(
        backend.sent('DELETE').single.headers['Authorization'],
        'Token abc',
      );
      expect(find.text('Pengalaman dihapus.'), findsOneWidget);
      expect(find.text('Belum ada pengalaman.'), findsOneWidget);
    });

    testWidgets('403 saat menghapus hanya menampilkan pesan', (tester) async {
      final backend = FakeBackend();
      await _openDetail(tester, backend);
      await tapAndSettle(tester, find.text('Hapus'));
      await logIn(tester);
      backend.failure = jsonResponse({'detail': 'Tidak diizinkan.'}, 403);

      await tapAndSettle(tester, find.text('Ya, hapus'));

      expect(find.text('Tidak diizinkan.'), findsOneWidget);
      expect(find.text('Experience Detail'), findsOneWidget);
    });

    testWidgets('401 saat menghapus meminta login kembali', (tester) async {
      final backend = FakeBackend();
      await _openDetail(tester, backend);
      await tapAndSettle(tester, find.text('Hapus'));
      await logIn(tester);
      backend.tokenValid = false;

      await tapAndSettle(tester, find.text('Ya, hapus'));

      expect(find.widgetWithText(FilledButton, 'Login'), findsOneWidget);
      expect(backend.experiences, hasLength(1));
    });
  });
}
