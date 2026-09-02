import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/tawam_shipping_app.dart';
import 'core/services/notification_service.dart';
import 'locale_controller.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('BACKGROUND NOTIFICATION: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Supabase.initialize(
    url: 'https://ofbnwaivxxdrxhtsniny.supabase.co',
    publishableKey: 'sb_publishable_u3T4BrB43DG4-JTbx4b4qQ_LQa_YqvT',
    accessToken: () async => FirebaseAuth.instance.currentUser?.getIdToken(),
  );

  await NotificationService.initialize();
  await LocaleController.restoreFromFirestore();
  runApp(const TawamShippingApp());
}
