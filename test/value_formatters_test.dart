import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/utils/value_formatters.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_ar.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

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
    expect(
      formatLocalizedDate(en, DateTime(2024, 2, 29)),
      '29 ${en.monthFeb} 2024',
    );
    expect(
      formatLocalizedDate(ar, DateTime(2026, 9, 1)),
      '1 ${ar.monthSep} 2026',
    );
  });

  test('keyed values skip missing null and blank strings', () {
    final data = {
      'missing': null,
      'blank': '  ',
      'zero': 0,
      'flag': false,
      'name': '  Muscat  ',
    };

    expect(firstKeyedValue(data, ['absent', 'missing', 'blank']), isNull);
    expect(firstKeyedValue(data, ['blank', 'zero']), 0);
    expect(firstKeyedValue(data, ['flag']), false);
    expect(stringFromKeys(data, ['absent', 'blank']), '-');
    expect(stringFromKeys(data, ['absent'], fallback: ''), '');
    expect(stringFromKeys(data, ['name']), 'Muscat');
    expect(stringFromKeys({'count': 4}, ['count']), '4');
  });

  test(
    'local date conversion supports timestamp datetime and parseable strings',
    () {
      final local = DateTime(2024, 6, 15, 18, 5);
      final utc = DateTime.utc(2024, 6, 15, 15, 30);
      final timestamp = Timestamp.fromDate(local);

      expect(toLocalDateTime(null), isNull);
      expect(toLocalDateTime(''), isNull);
      expect(toLocalDateTime('   '), isNull);
      expect(toLocalDateTime(42), isNull);
      expect(toLocalDateTime('not-a-date'), isNull);
      expect(toLocalDateTime(timestamp), local.toLocal());
      expect(toLocalDateTime(utc), utc.toLocal());
      expect(toLocalDateTime(local), local.toLocal());
      expect(
        toLocalDateTime('  2024-06-15T18:05:00  '),
        DateTime.parse('2024-06-15T18:05:00').toLocal(),
      );
    },
  );

  test('optional dates keep empty fallbacks and raw unparsed text', () {
    final en = AppLocalizationsEn();

    expect(
      formatOptionalLocalizedDate(en, null, emptyFallback: en.notSpecified),
      en.notSpecified,
    );
    expect(
      formatOptionalLocalizedDate(en, '  ', emptyFallback: en.notSpecified),
      en.notSpecified,
    );
    expect(
      formatOptionalLocalizedDate(
        en,
        'Warehouse hold',
        emptyFallback: en.notSpecified,
      ),
      'Warehouse hold',
    );
    expect(
      formatOptionalLocalizedDateTime(
        en,
        null,
        emptyFallback: en.awaitingUpdate,
      ),
      en.awaitingUpdate,
    );
    expect(
      formatOptionalLocalizedDateTime(en, '', emptyFallback: en.awaitingUpdate),
      en.awaitingUpdate,
    );
    expect(
      formatOptionalLocalizedDateTime(
        en,
        'Customs review',
        emptyFallback: en.awaitingUpdate,
      ),
      'Customs review',
    );

    final morning = DateTime(2026, 9, 1, 0, 7);
    expect(
      formatOptionalLocalizedDate(en, morning, emptyFallback: en.notSpecified),
      '1 ${en.monthSep} 2026',
    );
    expect(
      formatOptionalLocalizedDateTime(
        en,
        morning,
        emptyFallback: en.awaitingUpdate,
      ),
      '1 ${en.monthSep} 2026 • 12:07 ${en.periodAm}',
    );

    final afternoon = DateTime(2026, 9, 1, 13, 5);
    expect(
      formatOptionalLocalizedDateTime(
        en,
        Timestamp.fromDate(afternoon),
        emptyFallback: en.awaitingUpdate,
      ),
      '1 ${en.monthSep} 2026 • 1:05 ${en.periodPm}',
    );

    final noon = DateTime(2026, 9, 1, 12, 0);
    expect(
      formatOptionalLocalizedDateTime(
        en,
        noon,
        emptyFallback: en.awaitingUpdate,
      ),
      '1 ${en.monthSep} 2026 • 12:00 ${en.periodPm}',
    );
  });

  test('language labels keep stored names and default to English', () {
    final en = AppLocalizationsEn();
    final ar = AppLocalizationsAr();

    expect(languageLabel(en, 'Arabic'), en.languageArabic);
    expect(languageLabel(en, 'French'), en.languageFrench);
    expect(languageLabel(en, 'English'), en.languageEnglish);
    expect(languageLabel(en, ''), en.languageEnglish);
    expect(languageLabel(en, 'Spanish'), en.languageEnglish);
    expect(languageLabel(ar, 'Arabic'), ar.languageArabic);
    expect(languageLabel(ar, 'French'), ar.languageFrench);
    expect(languageLabel(ar, 'English'), ar.languageEnglish);
  });
}
