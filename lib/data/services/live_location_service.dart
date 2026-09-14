import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import '../models/live_location.dart';

class LiveLocationService {
  LiveLocationService(this._firebaseAuth);

  static const _endpoint =
      'https://ofbnwaivxxdrxhtsniny.supabase.co/functions/v1/live-shipment';

  final FirebaseAuth _firebaseAuth;

  Future<LiveLocationResult> fetchLiveLocation(String shipmentId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return const LiveLocationResult.failure('generic');
    }

    final client = HttpClient();

    try {
      final token = await user.getIdToken();
      if (token == null || token.trim().isEmpty) {
        throw Exception('Authentication token unavailable');
      }

      final request = await client.postUrl(Uri.parse(_endpoint));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.write(jsonEncode({'shipmentId': shipmentId}));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(responseBody);

      if (response.statusCode == 200 &&
          decoded is Map<String, dynamic> &&
          decoded['success'] == true) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          return LiveLocationResult.success(LiveLocation.fromMap(data));
        }
      }

      String message = 'generic';
      if (decoded is Map<String, dynamic>) {
        final serverMessage = decoded['message']?.toString().trim();
        if (serverMessage != null && serverMessage.isNotEmpty) {
          message = serverMessage;
        }
      }
      return LiveLocationResult.failure(message);
    } catch (_) {
      return const LiveLocationResult.failure('generic');
    } finally {
      client.close(force: true);
    }
  }
}
