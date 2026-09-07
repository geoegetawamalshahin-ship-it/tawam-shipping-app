import 'package:flutter/material.dart';

/// Shared presentation-only widgets used by the shipping forms.
///
/// Every visual value is supplied by the caller so extracting these widgets
/// cannot silently change an existing screen's design.
class ShippingTrustItem extends StatelessWidget {
  const ShippingTrustItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.titleColor,
    required this.subtitleColor,
    this.titleFontSize = 10.5,
    this.subtitleFontSize = 7.5,
    this.subtitleFontWeight,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color titleColor;
  final Color subtitleColor;
  final double titleFontSize;
  final double subtitleFontSize;
  final FontWeight? subtitleFontWeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: titleFontSize,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: subtitleColor,
            fontSize: subtitleFontSize,
            fontWeight: subtitleFontWeight,
          ),
        ),
      ],
    );
  }
}

class ShippingTrustDivider extends StatelessWidget {
  const ShippingTrustDivider({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 38, color: color);
  }
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
