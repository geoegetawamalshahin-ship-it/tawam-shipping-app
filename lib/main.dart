import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'screens/splash_screen.dart';
import 'screens/notifications_screen.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';

// ============================================================
// FCM - BACKGROUND HANDLER
// ============================================================

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint('BACKGROUND NOTIFICATION: ${message.messageId}');
}

// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // مهم جداً
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Supabase.initialize(
    url: 'https://ofbnwaivxxdrxhtsniny.supabase.co',
    publishableKey: 'sb_publishable_u3T4BrB43DG4-JTbx4b4qQ_LQa_YqvT',
    accessToken: () async {
      return FirebaseAuth.instance.currentUser?.getIdToken();
    },
  );

  // تجهيز الإشعارات
  await NotificationSetup.initialize();

  await LocaleController.restoreFromFirestore();

  runApp(const TawamShippingApp());
}

// ============================================================
// FIREBASE MESSAGING SETUP
// ============================================================

class NotificationSetup {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static String? _lastSavedToken;

  static Future<void> initialize() async {
    // --------------------------------------------------------
    // 1. تشغيل FCM
    // --------------------------------------------------------

    await _messaging.setAutoInitEnabled(true);

    // --------------------------------------------------------
    // 2. طلب صلاحية الإشعارات
    // --------------------------------------------------------

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    debugPrint(
      'Notification Permission: '
      '${settings.authorizationStatus}',
    );

    // --------------------------------------------------------
    // 3. حفظ Token إذا المستخدم مسجل دخول
    // --------------------------------------------------------

    await _saveCurrentToken();

    // --------------------------------------------------------
    // 4. إذا المستخدم عمل Login بعد تشغيل التطبيق
    // --------------------------------------------------------

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _saveCurrentToken();
      }
    });

    // --------------------------------------------------------
    // 5. إذا Firebase غيّر Token
    // --------------------------------------------------------

    _messaging.onTokenRefresh.listen((String newToken) async {
      debugPrint('NEW FCM TOKEN: $newToken');

      await _saveTokenToFirestore(newToken);
    });

    // --------------------------------------------------------
    // 6. إشعار وصل والتطبيق مفتوح
    // --------------------------------------------------------

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // --------------------------------------------------------
    // 7. المستخدم ضغط على إشعار
    // --------------------------------------------------------

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _openOrRemember(message);
    });

    // --------------------------------------------------------
    // 8. التطبيق كان مسكر وفتح من إشعار
    // --------------------------------------------------------

    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      NotificationRouter.remember(_payloadFrom(initialMessage), autoOpen: true);
    }
  }

  static Map<String, String> _payloadFrom(RemoteMessage message) {
    return NotificationRouter.payloadFromMessage(
      data: message.data,
      title: message.notification?.title,
      body: message.notification?.body,
    );
  }

  static void _openOrRemember(RemoteMessage message) {
    final payload = _payloadFrom(message);
    final context = NotificationRouter.navigatorKey.currentContext;

    if (NotificationRouter.homeReady && context != null && context.mounted) {
      NotificationRouter.openFromPayload(context, payload);
      return;
    }

    NotificationRouter.remember(payload, autoOpen: true);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    final payload = _payloadFrom(message);
    final context = NotificationRouter.navigatorKey.currentContext;

    if (!NotificationRouter.homeReady || context == null || !context.mounted) {
      NotificationRouter.remember(payload);
      return;
    }

    NotificationRouter.showForegroundBanner(context, payload);
  }

  // ==========================================================
  // GET CURRENT TOKEN
  // ==========================================================

  static Future<void> _saveCurrentToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('No logged-in user. Token not saved yet.');
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.data()?['notificationsEnabled'] == false) {
        debugPrint('Notifications disabled. Token not saved.');
        return;
      }
    } catch (e) {
      debugPrint('Could not read notification preference: $e');
    }

    try {
      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('FCM Token not available yet.');

        return;
      }

      debugPrint('FCM TOKEN: $token');

      await _saveTokenToFirestore(token);
    } catch (e) {
      debugPrint('FCM Token Error: $e');
    }
  }

  // ==========================================================
  // SAVE TOKEN TO FIRESTORE
  // ==========================================================

  static Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('No logged-in user. Token not saved yet.');

      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.data()?['notificationsEnabled'] == false) {
        debugPrint('Notifications disabled. Token not saved.');
        return;
      }
    } catch (e) {
      debugPrint('Could not read notification preference: $e');
    }

    if (_lastSavedToken == token) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        // آخر جهاز مسجل
        'fcmToken': token,

        // يدعم أكثر من جهاز لنفس الحساب
        'fcmTokens': FieldValue.arrayUnion([token]),

        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _lastSavedToken = token;

      debugPrint('FCM Token saved successfully ✅');
    } catch (e) {
      debugPrint('Error saving FCM Token: $e');
    }
  }
}

// ============================================================
// APP
// ============================================================

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
