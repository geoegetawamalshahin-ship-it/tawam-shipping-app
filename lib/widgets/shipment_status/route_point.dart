import 'package:flutter/material.dart';

const Color _routePrimaryBlue = Color(0xFF0B4F9C);
const Color _routeTextGrey = Color(0xFF7E8A9A);
const Color _routeTextDark = Color(0xFF101B2D);

class ShipmentRoutePoint extends StatelessWidget {
  const ShipmentRoutePoint({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.alignRight,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _routePrimaryBlue, size: 17),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(
            color: _routeTextGrey,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: .55,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignRight ? TextAlign.end : TextAlign.start,
          style: const TextStyle(
            color: _routeTextDark,
            fontSize: 10.8,
            height: 1.25,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
