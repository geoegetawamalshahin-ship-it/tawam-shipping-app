import 'package:flutter/material.dart';

class ShipmentHeroFeature extends StatelessWidget {
  const ShipmentHeroFeature({
    super.key,
    required this.icon,
    required this.label,
    this.iconSize = 13,
    this.fontSize = 9,
  });

  final IconData icon;
  final String label;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: iconSize),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
