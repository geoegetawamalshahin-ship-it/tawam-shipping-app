import 'package:flutter/material.dart';

class ShipmentHeroFeature extends StatelessWidget {
  const ShipmentHeroFeature({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.white, size: 13),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
    ]);
  }
}
