import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_exception.dart';

export 'package:myportofolio_mobile/services/api_exception.dart';

/// HTTP client for the MyPortfolio Django REST Framework backend.
class ApiClient {
  ApiClient({
    http.Client? client,
    this.baseUrl = apiBaseUrl,
    this.timeout = const Duration(seconds: 20),
  }) : _client = client ?? http.Client();

  final http.Client _client;

  final String baseUrl;

  final Duration timeout;

  static const String _experiences = '/api/v1/experiences/';
  static const String _projects = '/api/v1/projects/';

  Future<List<Experience>> getExperiences() async {
    final body = await _send('GET', _experiences);
    return _decodeList(body, Experience.fromJson);
  }

  Future<Experience> createExperience(
    Experience experience, {
    required String token,
  }) async {
    final body = await _send(
      'POST',
      _experiences,
      token: token,
      json: experience.toJson(),
    );
    return Experience.fromJson(_decodeObject(body));
  }

  Future<Experience> updateExperience(
    String id,
    Experience experience, {
    required String token,
  }) async {
    final body = await _send(
      'PATCH',
      '$_experiences$id/',
      token: token,
      json: experience.toJson(),
    );
    return Experience.fromJson(_decodeObject(body));
  }

  Future<void> deleteExperience(String id, {required String token}) async {
    await _send('DELETE', '$_experiences$id/', token: token);
  }

  Future<List<Project>> getProjects() async {
    final body = await _send('GET', _projects);
    return _decodeList(body, Project.fromJson);
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final body = await _send(
      'POST',
      _projects,
      token: token,
      json: project.toJson(),
    );
    return Project.fromJson(_decodeObject(body));
  }

  Future<String> obtainToken(String username, String password) async {
    final body = await _send(
      'POST',
      '/api/v1/auth/token/',
      json: {'username': username, 'password': password},
    );
    return _decodeObject(body)['token'] as String;
  }

  Future<void> logout({required String token}) async {
    await _send('POST', '/api/v1/auth/logout/', token: token);
  }

  Future<String> _send(
    String method,
    String path, {
    String? token,
    Map<String, dynamic>? json,
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'));
    request.headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Token $token';
    if (json != null) {
      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
      request.body = jsonEncode(json);
    }

    final response = await _client
        .send(request)
        .then(http.Response.fromStream)
        .timeout(timeout);
    // DRF omits the charset, so decode explicitly to keep non-ASCII intact.
    final body = utf8.decode(response.bodyBytes, allowMalformed: true);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, body);
    }
    return body;
  }

  List<T> _decodeList<T>(
    String body,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final decoded = jsonDecode(body) as List<dynamic>;
    return [for (final item in decoded) fromJson(item as Map<String, dynamic>)];
  }

  Map<String, dynamic> _decodeObject(String body) =>
      jsonDecode(body) as Map<String, dynamic>;
}
