import 'package:flutter/material.dart';

class NumberedSectionHeading extends StatelessWidget {
  const NumberedSectionHeading({
    super.key,
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeColor,
    required this.iconColor,
    required this.titleColor,
    required this.subtitleColor,
  });

  final String number;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color badgeColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 19),
                  const SizedBox(width: 7),
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 10.5,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
