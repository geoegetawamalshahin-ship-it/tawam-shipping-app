import 'package:flutter/material.dart';

class ShippingPremiumCard extends StatelessWidget {
  const ShippingPremiumCard({
    super.key,
    required this.child,
    required this.borderColor,
    required this.shadowColor,
    this.borderRadius = 21,
    this.shadowBlur = 18,
    this.shadowOffset = const Offset(0, 7),
  });

  final Widget child;
  final Color borderColor;
  final Color shadowColor;
  final double borderRadius;
  final double shadowBlur;
  final Offset shadowOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: .035),
            blurRadius: shadowBlur,
            offset: shadowOffset,
          ),
        ],
      ),
      child: child,
    );
  }
}
