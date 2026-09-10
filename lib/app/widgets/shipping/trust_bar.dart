import 'package:flutter/material.dart';

/// Shared visual shell for the trust strip displayed by shipping forms.
class ShippingTrustBar extends StatelessWidget {
  const ShippingTrustBar({
    super.key,
    required this.borderColor,
    required this.children,
  });

  final Color borderColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Row(children: children),
    );
  }
}
