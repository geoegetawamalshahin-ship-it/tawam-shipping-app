import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipping/customer_details.dart';

const _primary = Color(0xFF0B4F9C);
const _soft = Color(0xFFEAF3FF);
const _border = Color(0xFFE2EAF2);
const _success = Color(0xFF16765C);
const _text = Color(0xFF101B2D);
const _label = Color(0xFF7E8A9A);

ShippingCustomerDetails _details({
  double? verifiedMessageHeight = 1.35,
  FontWeight? labelFontWeight = FontWeight.w600,
  String company = '',
  String country = '',
  bool loading = false,
}) {
  return ShippingCustomerDetails(
    loading: loading,
    verifiedMessage: 'Filled from account',
    fullNameLabel: 'Full name',
    phoneLabel: 'Phone',
    emailLabel: 'Email',
    companyLabel: 'Company',
    countryLabel: 'Country',
    notProvidedLabel: 'Not provided',
    customerName: 'Ada',
    customerPhone: '',
    customerEmail: 'a@b.com',
    customerCompany: company,
    customerCountry: country,
    primaryColor: _primary,
    softColor: _soft,
    borderColor: _border,
    successColor: _success,
    textColor: _text,
    labelColor: _label,
    verifiedMessageHeight: verifiedMessageHeight,
    labelFontWeight: labelFontWeight,
  );
}

void main() {
  testWidgets('five-form defaults keep verified height and label weight', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: _details())));

    expect(find.text('Filled from account'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Not provided'), findsOneWidget);
    expect(find.text('a@b.com'), findsOneWidget);
    expect(find.text('Company'), findsNothing);

    expect(
      tester.widget<Text>(find.text('Filled from account')).style?.height,
      1.35,
    );
    expect(
      tester.widget<Text>(find.text('Full name')).style?.fontWeight,
      FontWeight.w600,
    );
  });

  testWidgets('air keeps no verified height and no label weight', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _details(verifiedMessageHeight: null, labelFontWeight: null),
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text('Filled from account')).style?.height,
      isNull,
    );
    expect(
      tester.widget<Text>(find.text('Full name')).style?.fontWeight,
      isNull,
    );
  });

  testWidgets('company and country rows appear only when filled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _details(company: 'Tawam', country: 'UAE'),
        ),
      ),
    );

    expect(find.text('Tawam'), findsOneWidget);
    expect(find.text('UAE'), findsOneWidget);
  });
}
