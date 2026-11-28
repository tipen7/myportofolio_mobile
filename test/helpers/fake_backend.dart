import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

const experienceId = 'af7f763e-55c0-46e6-badc-33324f71de12';

Map<String, dynamic> experienceJson({
  String id = experienceId,
  String title = 'Backend Intern',
}) => {
  'id': id,
  'title': title,
  'description': 'Membangun REST API dengan DRF',
  'category': 'part-time',
  'category_display': 'Part-Time',
  'thumbnail': null,
  'started_at': '2026-01-05T00:00:00Z',
  'ended_at': '2026-03-20T00:00:00Z',
  'is_ongoing': false,
  'star_count': 2,
  'is_starred': false,
  'starred_by_names': 'ani, budi',
  'comments': [
    {
      'id': 'c1',
      'text': 'Keren sekali',
      'username': 'ani',
      'created_at': '2026-02-01T10:00:00Z',
    },
  ],
  'user_comment': null,
};

const projectJson = <String, dynamic>{
  'id': '1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed',
  'name': 'Proyek Satu',
  'type': 'personal',
  'description': 'Deskripsi satu',
  'tech_stack': ['Flutter', 'Django'],
  'url': null,
  'image': 'https://example.com/a.png',
};

class FakeBackend {
  FakeBackend({List<Map<String, dynamic>>? experiences})
    : experiences = experiences ?? [experienceJson()];

  static const token = 'abc';

  final List<Map<String, dynamic>> experiences;

  final List<http.Request> requests = [];

  http.Response? failure;

  Completer<void>? gate;

  /// Set to `false` to simulate a token deleted in Django Admin.
  bool tokenValid = true;

  late final ApiClient api = ApiClient(
    baseUrl: 'http://test',
    client: MockClient(_handle),
  );

  Iterable<http.Request> sent(String method) =>
      requests.where((r) => r.method == method);

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    await gate?.future;
    final path = request.url.path;

    if (path == '/api/v1/auth/token/') return jsonResponse({'token': token});
    if (path == '/api/v1/auth/logout/') return http.Response('', 204);
    if (path == '/api/v1/projects/') return jsonResponse([projectJson]);
    if (!path.startsWith('/api/v1/experiences/')) {
      return jsonResponse({'detail': 'Not found.'}, 404);
    }
    final forced = failure;
    if (forced != null) return forced;
    if (request.method == 'GET') return jsonResponse(experiences);

    if (!tokenValid || request.headers['Authorization'] != 'Token $token') {
      return jsonResponse({'detail': 'Invalid token.'}, 401);
    }
    final body = request.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(request.body) as Map<String, dynamic>;
    switch (request.method) {
      case 'POST':
        final created = {
          ...experienceJson(id: 'new-id'),
          ...body,
          'comments': <Object>[],
        };
        experiences.insert(0, created);
        return jsonResponse(created, 201);
      case 'PATCH':
        final index = _indexOf(path);
        experiences[index] = {...experiences[index], ...body};
        return jsonResponse(experiences[index]);
      case 'DELETE':
        experiences.removeAt(_indexOf(path));
        return http.Response('', 204);
    }
    return jsonResponse({'detail': 'Method not allowed.'}, 405);
  }

  int _indexOf(String path) {
    final id = path.split('/').where((part) => part.isNotEmpty).last;
    return experiences.indexWhere((e) => e['id'] == id);
  }
}

http.Response jsonResponse(Object body, [int status = 200]) =>
    http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: const {'content-type': 'application/json'},
    );

Future<void> pumpApp(
  WidgetTester tester,
  FakeBackend backend, {
  Size size = const Size(1200, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MyApp(apiClient: backend.api, webFont: false));
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> logIn(WidgetTester tester) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'u');
  await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'p');
  await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Login'));
}
