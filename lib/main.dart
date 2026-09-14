import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'constant/app_routes.dart';
import 'controllers/locale_controller.dart';
import 'data/services/notification_router.dart';
import 'data/services/push_notification_service.dart';
import 'initial_binding.dart';
import 'l10n/app_localizations.dart';
import 'res/app_theme.dart';
import 'routes.dart';
import 'widgets/responsive_app_frame.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('BACKGROUND NOTIFICATION: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Supabase.initialize(
    url: 'https://ofbnwaivxxdrxhtsniny.supabase.co',
    publishableKey: 'sb_publishable_u3T4BrB43DG4-JTbx4b4qQ_LQa_YqvT',
    accessToken: () async {
      return FirebaseAuth.instance.currentUser?.getIdToken();
    },
  );

  final pushNotifications = PushNotificationService();
  await pushNotifications.initialize();

  await LocaleController.restoreFromFirestore();

  runApp(const TawamShippingApp());
}

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
          builder: (context, child) {
            return ResponsiveAppFrame(child: child ?? const SizedBox.shrink());
          },
          initialBinding: InitialBinding(),
          theme: AppTheme.lightTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: AppRoutes.splash,
          getPages: appPages,
        );
      },
    );
  }
}
