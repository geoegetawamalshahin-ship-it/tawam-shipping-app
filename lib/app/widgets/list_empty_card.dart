import 'package:flutter/material.dart';

class ListEmptyCard extends StatelessWidget {
  const ListEmptyCard({
    super.key,
    required this.padding,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    required this.afterIconGap,
    required this.title,
    required this.titleColor,
    required this.titleFontWeight,
    required this.afterTitleGap,
    required this.body,
    required this.bodyColor,
    required this.bodyFontSize,
    this.width,
    this.margin,
    this.bodyHeight,
  });

  final double? width;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final double afterIconGap;
  final String title;
  final Color titleColor;
  final FontWeight titleFontWeight;
  final double afterTitleGap;
  final String body;
  final Color bodyColor;
  final double bodyFontSize;
  final double? bodyHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          SizedBox(height: afterIconGap),
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 16,
              fontWeight: titleFontWeight,
            ),
          ),
          SizedBox(height: afterTitleGap),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: bodyColor,
              fontSize: bodyFontSize,
              height: bodyHeight,
            ),
          ),
        ],
      ),
    );
  }
}
