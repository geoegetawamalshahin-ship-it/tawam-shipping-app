import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShipmentService {
  ShipmentService(this._auth, this._firestore, this._supabase);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final SupabaseClient _supabase;

  User? get currentUser => _auth.currentUser;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMine() {
    final user = currentUser;
    if (user == null) return const Stream.empty();
    return _firestore
        .collection('shipments')
        .where('userId', isEqualTo: user.uid)
        .snapshots();
  }

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> findByTrackingNumber(
    String trackingNumber,
  ) async {
    final user = currentUser;
    if (user == null) return null;
    final snapshot = await _firestore
        .collection('shipments')
        .where('userId', isEqualTo: user.uid)
        .where('trackingNumber', isEqualTo: trackingNumber)
        .limit(1)
        .get();
    return snapshot.docs.isEmpty ? null : snapshot.docs.first;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchById(String id) =>
      _firestore.collection('shipments').doc(id).snapshots();

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> loadMine() async {
    final user = currentUser;
    if (user == null) return const [];
    final snapshot = await _firestore
        .collection('shipments')
        .where('userId', isEqualTo: user.uid)
        .get();
    return snapshot.docs;
  }

  Future<String> createDocumentUrl(String path) => _supabase.storage
      .from('shipping-documents')
      .createSignedUrl(path, 600);

  Future<Map<String, dynamic>> loadLiveLocation(String shipmentId) async {
    final user = currentUser;
    if (user == null) throw StateError('Authentication required');
    final token = await user.getIdToken();
    if (token == null || token.trim().isEmpty) {
      throw StateError('Authentication token unavailable');
    }

    final client = HttpClient();
    try {
      final request = await client.postUrl(
        Uri.parse(
          'https://ofbnwaivxxdrxhtsniny.supabase.co/functions/v1/live-shipment',
        ),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.write(jsonEncode({'shipmentId': shipmentId}));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(body);
      if (response.statusCode == 200 &&
          decoded is Map<String, dynamic> &&
          decoded['success'] == true &&
          decoded['data'] is Map<String, dynamic>) {
        return decoded['data'] as Map<String, dynamic>;
      }
      if (decoded is Map<String, dynamic>) {
        throw StateError(decoded['message']?.toString() ?? 'generic');
      }
      throw StateError('generic');
    } finally {
      client.close(force: true);
    }
  }
}
