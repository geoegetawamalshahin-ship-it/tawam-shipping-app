import 'package:flutter/material.dart';

import 'dividers.dart';

class ShippingCustomerDetails extends StatelessWidget {
  const ShippingCustomerDetails({super.key, required this.loading, required this.verifiedMessage, required this.fullNameLabel, required this.phoneLabel, required this.emailLabel, required this.companyLabel, required this.countryLabel, required this.notProvidedLabel, required this.customerName, required this.customerPhone, required this.customerEmail, required this.customerCompany, required this.customerCountry, required this.primaryColor, required this.softColor, required this.borderColor, required this.successColor, required this.textColor, required this.labelColor});
  final bool loading;
  final String verifiedMessage, fullNameLabel, phoneLabel, emailLabel, companyLabel, countryLabel, notProvidedLabel;
  final String customerName, customerPhone, customerEmail, customerCompany, customerCountry;
  final Color primaryColor, softColor, borderColor, successColor, textColor, labelColor;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Padding(padding: const EdgeInsets.symmetric(vertical: 25), child: Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2.5)));
    }
    return Column(children: [
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFEAF8F0), borderRadius: BorderRadius.circular(14)), child: Row(children: [
        Icon(Icons.verified_user_outlined, color: successColor, size: 18),
        const SizedBox(width: 9),
        Expanded(child: Text(verifiedMessage, style: TextStyle(color: successColor, fontSize: 9.5, height: 1.35, fontWeight: FontWeight.w700))),
      ])),
      const SizedBox(height: 16),
      _contactRow(icon: Icons.person_outline_rounded, label: fullNameLabel, value: customerName),
      ShippingContactDivider(color: borderColor),
      _contactRow(icon: Icons.phone_outlined, label: phoneLabel, value: customerPhone.isEmpty ? notProvidedLabel : customerPhone),
      ShippingContactDivider(color: borderColor),
      _contactRow(icon: Icons.email_outlined, label: emailLabel, value: customerEmail.isEmpty ? notProvidedLabel : customerEmail),
      if (customerCompany.isNotEmpty) ...[ShippingContactDivider(color: borderColor), _contactRow(icon: Icons.business_outlined, label: companyLabel, value: customerCompany)],
      if (customerCountry.isNotEmpty) ...[ShippingContactDivider(color: borderColor), _contactRow(icon: Icons.public_outlined, label: countryLabel, value: customerCountry)],
    ]);
  }

  Widget _contactRow({required IconData icon, required String label, required String value}) {
    return Row(children: [
      Container(width: 39, height: 39, decoration: BoxDecoration(color: softColor, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: primaryColor, size: 19)),
      const SizedBox(width: 11),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 8.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: textColor, fontSize: 11.5, fontWeight: FontWeight.w800)),
      ])),
    ]);
  }
}
