import 'package:flutter/material.dart';

const Color _textDark = Color(0xFF101B2D);
const Color _textGrey = Color(0xFF7E8A9A);
const Color _border = Color(0xFFE2EAF2);

class SupportQuickContactCard extends StatelessWidget {
  const SupportQuickContactCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.background,
    required this.onTap,
    this.borderColor = _border,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color background;
  final VoidCallback onTap;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Container(
                width: 41,
                height: 41,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(height: 9),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _textGrey, fontSize: 7.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
