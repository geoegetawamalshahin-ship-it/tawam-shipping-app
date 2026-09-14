import 'package:flutter/material.dart';

class ShipmentLiveDot extends StatelessWidget {
  const ShipmentLiveDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(color: Color(0xFF55D6A5), shape: BoxShape.circle),
    );
  }
}
