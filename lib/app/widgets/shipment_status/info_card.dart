import 'package:flutter/material.dart';

class ShipmentInfoCard extends StatelessWidget {
  const ShipmentInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.minHeight,
    required this.borderColor,
    required this.iconBackground,
    required this.iconColor,
    required this.labelColor,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final double minHeight;
  final Color borderColor;
  final Color iconBackground;
  final Color iconColor;
  final Color labelColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 7.8,
              fontWeight: FontWeight.w800,
              letterSpacing: .55,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontSize: 10.8,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
