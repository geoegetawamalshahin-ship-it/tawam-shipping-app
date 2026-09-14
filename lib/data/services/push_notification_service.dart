import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../constant/firestore_collections.dart';
import 'notification_router.dart';

class PushNotificationService {
  PushNotificationService({
    FirebaseMessaging? messaging,
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseMessaging _messaging;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  String? _lastSavedToken;

  Future<void> initialize() async {
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

    debugPrint(
      'Notification Permission: '
      '${settings.authorizationStatus}',
    );

    await saveCurrentToken();

    _firebaseAuth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await saveCurrentToken();
      } else {
        _lastSavedToken = null;
      }
    });

    _messaging.onTokenRefresh.listen((String newToken) async {
      debugPrint('NEW FCM TOKEN: $newToken');
      await _saveTokenToFirestore(newToken);
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_openOrRemember);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      NotificationRouter.remember(_payloadFrom(initialMessage), autoOpen: true);
    }
  }

  Map<String, String> _payloadFrom(RemoteMessage message) {
    return NotificationRouter.payloadFromMessage(
      data: message.data,
      title: message.notification?.title,
      body: message.notification?.body,
    );
  }

  void _openOrRemember(RemoteMessage message) {
    final payload = _payloadFrom(message);
    final context = NotificationRouter.navigatorKey.currentContext;

    if (NotificationRouter.homeReady && context != null && context.mounted) {
      NotificationRouter.openFromPayload(context, payload);
      return;
    }

    NotificationRouter.remember(payload, autoOpen: true);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final payload = _payloadFrom(message);
    final context = NotificationRouter.navigatorKey.currentContext;

    if (!NotificationRouter.homeReady || context == null || !context.mounted) {
      NotificationRouter.remember(payload);
      return;
    }

    NotificationRouter.showForegroundBanner(context, payload);
  }

  Future<void> saveCurrentToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      debugPrint('No logged-in user. Token not saved yet.');
      return;
    }

    try {
      final userDoc = await _firestore
          .collection(FirestoreCollections.users)
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

  Future<void> _saveTokenToFirestore(String token) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      debugPrint('No logged-in user. Token not saved yet.');
      return;
    }

    try {
      final userDoc = await _firestore
          .collection(FirestoreCollections.users)
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
      await _firestore.collection(FirestoreCollections.users).doc(user.uid).set(
        {
          'fcmToken': token,
          'fcmTokens': FieldValue.arrayUnion([token]),
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      _lastSavedToken = token;
      debugPrint('FCM Token saved successfully ✅');
    } catch (e) {
      debugPrint('Error saving FCM Token: $e');
    }
  }
}
