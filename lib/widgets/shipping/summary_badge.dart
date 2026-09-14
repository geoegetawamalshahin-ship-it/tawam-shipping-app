import 'package:flutter/material.dart';

class ShippingSummaryBadge extends StatelessWidget {
  const ShippingSummaryBadge({super.key, required this.text, this.icon, this.showBorder = false});
  final String text;
  final IconData? icon;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(30),
        border: showBorder ? Border.all(color: Colors.white.withValues(alpha: .10)) : null,
      ),
      child: icon == null
          ? Text(text, style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w700))
          : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF79BFFF), size: 13),

          const SizedBox(width: 6),

          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
