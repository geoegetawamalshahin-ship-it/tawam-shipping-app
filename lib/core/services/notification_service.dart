import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../screens/notifications_screen.dart';

/// Owns Firebase Messaging setup and token persistence outside the UI layer.
abstract final class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _lastSavedToken;

  static Future<void> initialize() async {
    await _messaging.setAutoInitEnabled(true);

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    debugPrint('Notification Permission: ${settings.authorizationStatus}');
    await _saveCurrentToken();

    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) await _saveCurrentToken();
    });

    _messaging.onTokenRefresh.listen(_saveTokenToFirestore);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_openOrRemember);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      NotificationRouter.remember(
        _payloadFrom(initialMessage),
        autoOpen: true,
      );
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

  static Future<bool> _notificationsEnabled(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      return userDoc.data()?['notificationsEnabled'] != false;
    } catch (error) {
      debugPrint('Could not read notification preference: $error');
      return true;
    }
  }

  static Future<void> _saveCurrentToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('No logged-in user. Token not saved yet.');
      return;
    }
    if (!await _notificationsEnabled(user.uid)) return;

    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('FCM Token not available yet.');
        return;
      }
      await _saveTokenToFirestore(token);
    } catch (error) {
      debugPrint('FCM Token Error: $error');
    }
  }

  static Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('No logged-in user. Token not saved yet.');
      return;
    }
    if (!await _notificationsEnabled(user.uid) || _lastSavedToken == token) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'fcmTokens': FieldValue.arrayUnion([token]),
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _lastSavedToken = token;
      debugPrint('FCM Token saved successfully');
    } catch (error) {
      debugPrint('Error saving FCM Token: $error');
    }
  }
}
