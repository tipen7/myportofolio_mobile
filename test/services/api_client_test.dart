import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

import '../helpers/fake_backend.dart';

const _draft = Experience(title: 'Asisten', description: 'Membantu praktikum');

void main() {
  late FakeBackend backend;

  setUp(() => backend = FakeBackend());

  group('experiences', () {
    test('GET publik tidak mengirim header Authorization', () async {
      final items = await backend.api.getExperiences();

      expect(items.single.title, 'Backend Intern');
      final request = backend.requests.single;
      expect(request.method, 'GET');
      expect(request.url.toString(), 'http://test/api/v1/experiences/');
      expect(request.headers.containsKey('Authorization'), isFalse);
    });

    test('POST mengirim token dan body JSON', () async {
      final created = await backend.api.createExperience(_draft, token: 'abc');

      expect(created.id, 'new-id');
      final request = backend.requests.single;
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/experiences/');
      expect(request.headers['Authorization'], 'Token abc');
      expect(request.headers['Content-Type'], startsWith('application/json'));
      expect(jsonDecode(request.body), _draft.toJson());
    });

    test('PATCH menuju URL detail dengan token', () async {
      final updated = await backend.api.updateExperience(
        experienceId,
        _draft,
        token: 'abc',
      );

      expect(updated.title, 'Asisten');
      final request = backend.requests.single;
      expect(request.method, 'PATCH');
      expect(request.url.path, '/api/v1/experiences/$experienceId/');
      expect(request.headers['Authorization'], 'Token abc');
    });

    test('DELETE menerima 204 tanpa body', () async {
      await backend.api.deleteExperience(experienceId, token: 'abc');

      expect(backend.requests.single.method, 'DELETE');
      expect(backend.experiences, isEmpty);
    });

    test('token salah menjadi ApiException 401', () async {
      await expectLater(
        backend.api.createExperience(_draft, token: 'kedaluwarsa'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue)
              .having((e) => e.detail, 'detail', 'Invalid token.'),
        ),
      );
    });

    for (final status in [400, 403, 404, 500]) {
      test('status $status melempar ApiException', () async {
        backend.failure = http.Response('gagal', status);

        await expectLater(
          backend.api.getExperiences(),
          throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'status', status),
          ),
        );
      });
    }

    test('teks non-ASCII di-decode sebagai UTF-8', () async {
      backend.failure = jsonResponse([experienceJson(title: 'Café – 研究')]);

      final items = await backend.api.getExperiences();

      expect(items.single.title, 'Café – 研究');
    });

    test('server yang tidak merespons memicu TimeoutException', () async {
      final api = ApiClient(
        client: MockClient((_) => Completer<http.Response>().future),
        timeout: const Duration(milliseconds: 10),
      );

      await expectLater(api.getExperiences(), throwsA(isA<TimeoutException>()));
    });
  });

  group('auth & projects', () {
    test('obtainToken, logout, getProjects, createProject', () async {
      expect(await backend.api.obtainToken('u', 'p'), 'abc');
      await backend.api.logout(token: 'abc');
      expect((await backend.api.getProjects()).single.name, 'Proyek Satu');

      expect(backend.requests[1].headers['Authorization'], 'Token abc');
    });

    test('createProject mengirim token', () async {
      final api = ApiClient(
        client: MockClient((request) async {
          expect(request.headers['Authorization'], 'Token abc');
          return jsonResponse(projectJson, 201);
        }),
      );

      final created = await api.createProject(
        Project.fromJson(projectJson),
        token: 'abc',
      );

      expect(created.name, 'Proyek Satu');
    });
  });

  group('ApiException.detail & describeError', () {
    test('menggabungkan galat per field dari DRF', () {
      const error = ApiException(
        400,
        '{"ended_at": ["Tanggal salah."], "non_field_errors": ["Umum."]}',
      );

      expect(error.detail, 'ended_at: Tanggal salah.\nUmum.');
      expect(describeError(error), error.detail);
    });

    test('body HTML tidak ditampilkan mentah', () {
      const error = ApiException(500, '<html>Server Error</html>');

      expect(error.detail, isNull);
      expect(describeError(error), 'Server menolak (status 500).');
      expect(error.toString(), contains('500'));
    });

    test('galat non-HTTP punya pesan yang jelas', () {
      expect(describeError(TimeoutException('x')), contains('terlalu lama'));
      expect(
        describeError(const FormatException()),
        contains('tidak dikenali'),
      );
      expect(describeError(http.ClientException('x')), contains('terhubung'));
    });
  });
}
