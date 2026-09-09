import '../../l10n/app_localizations.dart';
import '../../locale_controller.dart';

String twoDigits(int value) => value.toString().padLeft(2, '0');

double? parseOptionalDouble(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  return double.tryParse(text);
}

String firstNonEmpty(List<dynamic> values) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

String formatLocalizedDate(AppLocalizations l10n, DateTime date) {
  return '${date.day} ${LocaleController.monthAbbrev(l10n, date.month)} ${date.year}';
}
