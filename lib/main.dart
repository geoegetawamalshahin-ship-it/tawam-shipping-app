import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'screens/splash_screen.dart';
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
      debugPrint('FOREGROUND NOTIFICATION');

      debugPrint('Title: ${message.notification?.title}');

      debugPrint('Body: ${message.notification?.body}');
    });

    // --------------------------------------------------------
    // 7. المستخدم ضغط على إشعار
    // --------------------------------------------------------

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('NOTIFICATION OPENED: ${message.messageId}');
    });

    // --------------------------------------------------------
    // 8. التطبيق كان مسكر وفتح من إشعار
    // --------------------------------------------------------

    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint(
        'APP OPENED FROM TERMINATED NOTIFICATION: '
        '${initialMessage.messageId}',
      );
    }
  }

  // ==========================================================
  // GET CURRENT TOKEN
  // ==========================================================

  static Future<void> _saveCurrentToken() async {
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
        return MaterialApp(
          debugShowCheckedModeBanner: false,

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
