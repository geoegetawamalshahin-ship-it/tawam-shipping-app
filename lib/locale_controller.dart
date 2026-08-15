import 'package:flutter/material.dart';

class LocaleController {
  static final ValueNotifier<Locale> locale = ValueNotifier<Locale>(
    const Locale('en'),
  );

  static void setLanguage(String language) {
    switch (language) {
      case 'Arabic':
        locale.value = const Locale('ar');
        break;

      case 'French':
        locale.value = const Locale('fr');
        break;

      default:
        locale.value = const Locale('en');
    }
  }
}
