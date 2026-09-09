import 'package:cloud_firestore/cloud_firestore.dart';

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

Object? firstKeyedValue(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    if (!data.containsKey(key)) {
      continue;
    }

    final value = data[key];

    if (value == null) {
      continue;
    }

    if (value is String && value.trim().isEmpty) {
      continue;
    }

    return value;
  }

  return null;
}

String stringFromKeys(
  Map<String, dynamic> data,
  List<String> keys, {
  String fallback = '-',
}) {
  final value = firstKeyedValue(data, keys);

  if (value == null) {
    return fallback;
  }

  return value.toString().trim();
}

DateTime? toLocalDateTime(Object? value) {
  if (value is Timestamp) {
    return value.toDate().toLocal();
  }

  if (value is DateTime) {
    return value.toLocal();
  }

  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim())?.toLocal();
  }

  return null;
}

String formatLocalizedDate(AppLocalizations l10n, DateTime date) {
  return '${date.day} ${LocaleController.monthAbbrev(l10n, date.month)} ${date.year}';
}

String formatOptionalLocalizedDate(
  AppLocalizations l10n,
  Object? value, {
  required String emptyFallback,
}) {
  final date = toLocalDateTime(value);

  if (date == null) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? emptyFallback : text;
  }

  return formatLocalizedDate(l10n, date);
}

String formatOptionalLocalizedDateTime(
  AppLocalizations l10n,
  Object? value, {
  required String emptyFallback,
}) {
  final date = toLocalDateTime(value);

  if (date == null) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? emptyFallback : text;
  }

  final hour12 = date.hour == 0
      ? 12
      : date.hour > 12
      ? date.hour - 12
      : date.hour;

  final minute = date.minute.toString().padLeft(2, '0');

  final amPm = LocaleController.timePeriod(l10n, date.hour);

  return '${formatLocalizedDate(l10n, date)} • $hour12:$minute $amPm';
}

String formatDisplayNumber(double value, {bool nonPositiveAsZero = false}) {
  if (nonPositiveAsZero && value <= 0) {
    return '0';
  }

  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }

  return value.toStringAsFixed(2);
}

String? positiveIntegerQuantityError(String? value, String errorMessage) {
  final number = int.tryParse(value?.trim() ?? '');

  if (number == null || number <= 0) {
    return errorMessage;
  }

  return null;
}

String languageLabel(AppLocalizations l10n, String language) {
  switch (language) {
    case 'Arabic':
      return l10n.languageArabic;
    case 'French':
      return l10n.languageFrench;
    default:
      return l10n.languageEnglish;
  }
}
