import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/utils/shipping_customer_profile.dart';
import 'package:tawam_shipping_app/core/firestore_collections.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

void main() {
  test('complete firestore values win over auth in field order', () {
    final profile = shippingCustomerProfileFromSources(
      authName: 'Auth Name',
      authEmail: 'auth@example.com',
      authPhone: '0500000000',
      data: {
        'name': 'Stored Name',
        'fullName': 'Ignored Full',
        'email': 'stored@example.com',
        'phone': '0501111111',
        'phoneNumber': '0502222222',
        'companyName': 'Tawam Co',
        'company': 'Other Co',
        'country': 'UAE',
        'countryName': 'Ignored',
      },
    );

    expect(profile.signedIn, isTrue);
    expect(profile.name, 'Stored Name');
    expect(profile.email, 'stored@example.com');
    expect(profile.phone, '0501111111');
    expect(profile.company, 'Tawam Co');
    expect(profile.country, 'UAE');
  });

  test(
    'blank and missing firestore fields fall back to later keys and auth',
    () {
      final profile = shippingCustomerProfileFromSources(
        authName: 'Auth Name',
        authEmail: 'auth@example.com',
        authPhone: '0500000000',
        data: {
          'name': '  ',
          'fullName': 'Full Name',
          'email': '',
          'phone': null,
          'mobile': '0503333333',
          'company': 'Fallback Co',
          'countryName': 'Oman',
        },
      );

      expect(profile.name, 'Full Name');
      expect(profile.email, 'auth@example.com');
      expect(profile.phone, '0503333333');
      expect(profile.company, 'Fallback Co');
      expect(profile.country, 'Oman');
    },
  );

  test('empty name stays empty until the page applies tawamCustomer', () {
    final en = AppLocalizationsEn();
    final profile = shippingCustomerProfileFromSources(
      authName: '',
      authEmail: '',
      authPhone: '',
      data: {},
    );

    expect(profile.name, '');
    expect(
      shippingCustomerDisplayName(profile.name, en.tawamCustomer),
      en.tawamCustomer,
    );
    expect(shippingCustomerDisplayName('Sara', en.tawamCustomer), 'Sara');
  });

  test('signed-out users skip firestore reads', () async {
    var reads = 0;
    final profile = await loadShippingCustomerProfile(
      uid: null,
      authName: 'Auth Name',
      authEmail: 'auth@example.com',
      authPhone: '0500000000',
      readUserDocument: (_) async {
        reads += 1;
        return {'name': 'Should not load'};
      },
    );

    expect(reads, 0);
    expect(profile.signedIn, isFalse);
    expect(profile.name, '');
  });

  test('missing documents keep auth values', () async {
    final profile = await loadShippingCustomerProfile(
      uid: 'user-1',
      authName: 'Auth Name',
      authEmail: 'auth@example.com',
      authPhone: '0500000000',
      readUserDocument: (_) async => null,
    );

    expect(profile.signedIn, isTrue);
    expect(profile.name, 'Auth Name');
    expect(profile.email, 'auth@example.com');
    expect(profile.phone, '0500000000');
  });

  test('read failures keep auth values', () async {
    final profile = await loadShippingCustomerProfile(
      uid: 'user-1',
      authName: 'Auth Name',
      authEmail: 'auth@example.com',
      authPhone: '0500000000',
      readUserDocument: (_) async => throw StateError('unavailable'),
    );

    expect(profile.name, 'Auth Name');
    expect(profile.email, 'auth@example.com');
    expect(profile.phone, '0500000000');
    expect(profile.company, '');
    expect(profile.country, '');
  });

  test('shipping profile reads stay on the users collection', () {
    expect(FirestoreCollections.users, 'users');
  });
}
