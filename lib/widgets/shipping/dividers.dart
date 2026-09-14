import 'package:flutter/material.dart';

class ShippingTrustDivider extends StatelessWidget {
  const ShippingTrustDivider({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(width: 1, height: 38, color: color);
}

class ShippingContactDivider extends StatelessWidget {
  const ShippingContactDivider({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Divider(color: color, height: 1),
    );
  }
}
