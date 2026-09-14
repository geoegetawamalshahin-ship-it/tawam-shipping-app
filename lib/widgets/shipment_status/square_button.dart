import 'package:flutter/material.dart';

class ShipmentSquareButton extends StatelessWidget {
  const ShipmentSquareButton({super.key, required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2EAF2)),
        ),
        child: Icon(icon, color: const Color(0xFF062B55), size: 22),
      ),
    );
  }
}
