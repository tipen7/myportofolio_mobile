import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

import '../helpers/fake_backend.dart';

void main() {
  test('login menyimpan token, logout mencabutnya', () async {
    final backend = FakeBackend();
    final auth = AuthState(backend.api);
    var notifications = 0;
    auth.addListener(() => notifications++);

    await auth.login('u', 'p');
    expect(auth.token, FakeBackend.token);
    expect(auth.isLoggedIn, isTrue);

    await auth.logout();
    expect(auth.isLoggedIn, isFalse);
    expect(backend.requests.last.url.path, '/api/v1/auth/logout/');
    expect(notifications, 2);
  });

  test('clearSession membuang token tanpa memanggil server', () {
    final backend = FakeBackend();
    final auth = AuthState(backend.api, initialToken: 'abc')..clearSession();

    expect(auth.isLoggedIn, isFalse);
    expect(backend.requests, isEmpty);
  });

  final failures = <String, MockClient>{
    'server menolak': MockClient((_) async => http.Response('', 401)),
    'jaringan putus': MockClient((_) => throw http.ClientException('offline')),
  };
  for (final MapEntry(:key, :value) in failures.entries) {
    test('logout tetap membersihkan sesi saat $key', () async {
      final auth = AuthState(ApiClient(client: value), initialToken: 'abc');

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
    });
  }
}
