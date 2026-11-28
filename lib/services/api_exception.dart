import 'dart:async';
import 'dart:convert';

/// Exception thrown when an API request returns a non-2xx status code.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;

  final String message;

  bool get isUnauthorized => statusCode == 401;

  bool get isForbidden => statusCode == 403;

  String? get detail {
    try {
      final decoded = jsonDecode(message);
      if (decoded is! Map<String, dynamic> || decoded.isEmpty) return null;
      return decoded.entries
          .map((entry) {
            final value = entry.value;
            final text = value is List ? value.join(' ') : '$value';
            const general = {'detail', 'non_field_errors'};
            return general.contains(entry.key) ? text : '${entry.key}: $text';
          })
          .join('\n');
    } on FormatException {
      return null;
    }
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

String describeError(Object error) {
  if (error is ApiException) {
    return error.detail ?? 'Server menolak (status ${error.statusCode}).';
  }
  if (error is TimeoutException) return 'Server terlalu lama merespons.';
  if (error is FormatException || error is TypeError) {
    return 'Respons server tidak dikenali.';
  }
  return 'Tidak dapat terhubung ke server.';
}
