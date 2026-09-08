import 'package:flutter/material.dart';

class ShippingPremiumCard extends StatelessWidget {
  const ShippingPremiumCard({
    super.key,
    required this.child,
    required this.borderColor,
    required this.shadowColor,
  });

  final Widget child;
  final Color borderColor;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: .035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}
