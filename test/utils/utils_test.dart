import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/utils/date_format.dart';
import 'package:myportofolio_mobile/utils/validators.dart';

void main() {
  test('validateRequired menolak spasi dan teks terlalu panjang', () {
    expect(validateRequired('   ', 'Title'), 'Title tidak boleh kosong!');
    expect(
      validateRequired('abcd', 'Title', max: 3),
      'Title maksimal 3 karakter!',
    );
    expect(validateRequired('abc', 'Title', max: 3), isNull);
  });

  test('validateUrl hanya menerima http(s) absolut', () {
    expect(validateUrl(''), isNull);
    expect(validateUrl('', required: true), isNotNull);
    expect(validateUrl('abc'), isNotNull);
    expect(validateUrl('ftp://example.com'), isNotNull);
    expect(validateUrl('https://example.com/a.png'), isNull);
    expect(validateUrl('https://example.com', max: 5), isNotNull);
  });

  test('format tanggal dan periode', () {
    final date = dateOnlyUtc(DateTime(2026, 2, 3, 23, 59));

    expect(date, DateTime.utc(2026, 2, 3));
    expect(formatDate(date), '03/02/2026');
    expect(formatPeriod(date, null), '03/02/2026 - Sekarang');
    expect(formatPeriod(null, date), '- - 03/02/2026');
  });
}
