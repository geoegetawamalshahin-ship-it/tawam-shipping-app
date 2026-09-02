import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
import '../screens/notifications_screen.dart';
import '../screens/splash_screen.dart';
import '../theme/app_theme.dart';
import 'bindings/initial_binding.dart';

class TawamShippingApp extends StatelessWidget {
  const TawamShippingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.locale,
      builder: (context, locale, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: NotificationRouter.navigatorKey,
          initialBinding: InitialBinding(),
          theme: AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SplashScreen(),
        );
      },
    );
  }
}
