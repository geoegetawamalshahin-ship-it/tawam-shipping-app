import 'package:flutter/material.dart';

const Color _headerTextDark = Color(0xFF101B2D);
const Color _headerTextGrey = Color(0xFF7E8A9A);
const Color _headerSoftBlue = Color(0xFFEAF3FF);
const Color _headerPrimaryBlue = Color(0xFF0B4F9C);

class CountedSectionHeader extends StatelessWidget {
  const CountedSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
  });

  final String title;
  final String subtitle;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _headerTextDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: _headerTextGrey, fontSize: 9.5),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _headerSoftBlue,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: _headerPrimaryBlue,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
