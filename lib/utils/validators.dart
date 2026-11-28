String? validateRequired(String? value, String label, {int? max}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return '$label tidak boleh kosong!';
  if (max != null && text.length > max) return '$label maksimal $max karakter!';
  return null;
}

String? validateUrl(String? value, {bool required = false, int? max}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return required ? 'URL tidak boleh kosong!' : null;
  final uri = Uri.tryParse(text);
  final valid =
      uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.contains('.');
  if (!valid) return 'URL harus valid (http:// atau https://)!';
  if (max != null && text.length > max) return 'URL maksimal $max karakter!';
  return null;
}
