import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/firestore_collections.dart';
import 'value_formatters.dart';

class ShippingCustomerProfile {
  const ShippingCustomerProfile({
    required this.signedIn,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.company = '',
    this.country = '',
  });

  const ShippingCustomerProfile.signedOut()
    : signedIn = false,
      name = '',
      email = '',
      phone = '',
      company = '',
      country = '';

  final bool signedIn;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String country;
}

String shippingCustomerDisplayName(String name, String emptyFallback) {
  return name.isEmpty ? emptyFallback : name;
}

ShippingCustomerProfile shippingCustomerProfileFromSources({
  required String authName,
  required String authEmail,
  required String authPhone,
  Map<String, dynamic>? data,
}) {
  final source = data ?? <String, dynamic>{};

  return ShippingCustomerProfile(
    signedIn: true,
    name: firstNonEmpty([
      source['name'],
      source['fullName'],
      source['displayName'],
      authName,
    ]),
    email: firstNonEmpty([source['email'], authEmail]),
    phone: firstNonEmpty([
      source['phone'],
      source['phoneNumber'],
      source['mobile'],
      authPhone,
    ]),
    company: firstNonEmpty([source['companyName'], source['company']]),
    country: firstNonEmpty([source['country'], source['countryName']]),
  );
}

Future<ShippingCustomerProfile> loadShippingCustomerProfile({
  required String? uid,
  required String authName,
  required String authEmail,
  required String authPhone,
  required Future<Map<String, dynamic>?> Function(String uid) readUserDocument,
}) async {
  if (uid == null) {
    return const ShippingCustomerProfile.signedOut();
  }

  var profile = shippingCustomerProfileFromSources(
    authName: authName,
    authEmail: authEmail,
    authPhone: authPhone,
  );

  try {
    final data = await readUserDocument(uid);
    profile = shippingCustomerProfileFromSources(
      authName: authName,
      authEmail: authEmail,
      authPhone: authPhone,
      data: data ?? <String, dynamic>{},
    );
  } catch (_) {
    // Keep Firebase Auth data as fallback.
  }

  return profile;
}

Future<ShippingCustomerProfile> loadShippingCustomerProfileFromAuth(
  User? user,
) {
  return loadShippingCustomerProfile(
    uid: user?.uid,
    authName: user?.displayName?.trim() ?? '',
    authEmail: user?.email?.trim() ?? '',
    authPhone: user?.phoneNumber?.trim() ?? '',
    readUserDocument: (uid) async {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(uid)
          .get();
      return snapshot.data();
    },
  );
}
