import 'package:flutter/material.dart';

/// Shared section heading used by the shipping forms.
class ShippingSectionTitle extends StatelessWidget {
  const ShippingSectionTitle({
    super.key,
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.softColor,
    required this.titleColor,
    required this.subtitleColor,
    this.titleLetterSpacing = -.2,
    this.subtitleFontWeight = FontWeight.w500,
  });

  final String number;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color softColor;
  final Color titleColor;
  final Color subtitleColor;
  final double? titleLetterSpacing;
  final FontWeight? subtitleFontWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: softColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: primaryColor, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    number,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: titleLetterSpacing,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 10,
                  height: 1.35,
                  fontWeight: subtitleFontWeight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
