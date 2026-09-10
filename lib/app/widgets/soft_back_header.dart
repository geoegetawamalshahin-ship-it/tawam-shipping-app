import 'package:flutter/material.dart';

class SoftBackHeader extends StatelessWidget {
  const SoftBackHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.onBack,
    required this.height,
    required this.shadowColor,
    required this.shadowAlpha,
    required this.shadowBlur,
    required this.shadowOffset,
    required this.borderColor,
    required this.backIconColor,
    required this.titleColor,
    required this.titleFontWeight,
    required this.subtitleColor,
    required this.subtitleFontSize,
    required this.subtitleFontWeight,
    required this.trailingBackground,
    required this.trailingIconColor,
    this.backIconSize,
    this.leadingGap = 14,
    this.titleFontSize = 20,
    this.titleLetterSpacing,
    this.subtitleLetterSpacing = .8,
    this.trailingIconSize,
  });

  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final VoidCallback onBack;
  final double height;
  final Color shadowColor;
  final double shadowAlpha;
  final double shadowBlur;
  final Offset shadowOffset;
  final Color borderColor;
  final Color backIconColor;
  final double? backIconSize;
  final double leadingGap;
  final Color titleColor;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final double? titleLetterSpacing;
  final Color subtitleColor;
  final double subtitleFontSize;
  final FontWeight subtitleFontWeight;
  final double subtitleLetterSpacing;
  final Color trailingBackground;
  final Color trailingIconColor;
  final double? trailingIconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: shadowAlpha),
            blurRadius: shadowBlur,
            offset: shadowOffset,
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: backIconColor,
                size: backIconSize,
              ),
            ),
          ),
          SizedBox(width: leadingGap),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: titleFontSize,
                    fontWeight: titleFontWeight,
                    letterSpacing: titleLetterSpacing,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: subtitleFontSize,
                    fontWeight: subtitleFontWeight,
                    letterSpacing: subtitleLetterSpacing,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: trailingBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              trailingIcon,
              color: trailingIconColor,
              size: trailingIconSize,
            ),
          ),
        ],
      ),
    );
  }
}
