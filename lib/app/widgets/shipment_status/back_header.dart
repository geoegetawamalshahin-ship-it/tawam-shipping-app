import 'package:flutter/material.dart';

import 'square_button.dart';

const Color _headerDeepBlue = Color(0xFF062B55);
const Color _headerPrimaryBlue = Color(0xFF0B4F9C);
const Color _headerSoftBlue = Color(0xFFEAF3FF);
const Color _headerTextDark = Color(0xFF101B2D);

class ShipmentBackHeader extends StatelessWidget {
  const ShipmentBackHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.onBack,
    this.trailingIconSize = 22,
  });

  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final VoidCallback onBack;
  final double trailingIconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: _headerDeepBlue.withValues(alpha: .06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ShipmentSquareButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _headerTextDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _headerPrimaryBlue,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .85,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _headerSoftBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              trailingIcon,
              color: _headerPrimaryBlue,
              size: trailingIconSize,
            ),
          ),
        ],
      ),
    );
  }
}
