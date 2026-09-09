import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/utils/value_formatters.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_ar.dart';

void main() {
  test('optional numbers preserve parsing and empty behavior', () {
    expect(parseOptionalDouble('  '), isNull);
    expect(parseOptionalDouble('invalid'), isNull);
    expect(parseOptionalDouble('1,5'), isNull);
    expect(parseOptionalDouble(' 0 '), 0);
    expect(parseOptionalDouble(' -12.5 '), -12.5);
  });
  test('first nonempty preserves order and zero values', () {
    expect(firstNonEmpty([null, ' ', ' x ', 'y']), 'x');
    expect(firstNonEmpty([null, 0, 'later']), '0');
    expect(firstNonEmpty([false, 'later']), 'false');
    expect(firstNonEmpty([null, ' ']), '');
    expect(firstNonEmpty([]), '');
  });
  test('padding preserves values above two digits', () {
    expect(twoDigits(0), '00');
    expect(twoDigits(9), '09');
    expect(twoDigits(123), '123');
  });
  test('date formatting preserves locale month and unpadded day', () {
    final en = AppLocalizationsEn();
    final ar = AppLocalizationsAr();
    expect(formatLocalizedDate(en, DateTime(2024, 2, 29)), '29 ${en.monthFeb} 2024');
    expect(formatLocalizedDate(ar, DateTime(2026, 9, 1)), '1 ${ar.monthSep} 2026');
  });
}
