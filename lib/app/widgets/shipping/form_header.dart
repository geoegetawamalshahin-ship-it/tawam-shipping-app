import 'package:flutter/material.dart';

class ShippingFormHeader extends StatelessWidget {
  const ShippingFormHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.onBack,
    required this.borderColor,
    required this.shadowColor,
    required this.leadingBackgroundColor,
    required this.leadingIconColor,
    required this.trailingBackgroundColor,
    required this.trailingIconColor,
    required this.titleColor,
    this.titleFontSize = 20,
    this.subtitleFontSize = 8.5,
    this.subtitleLetterSpacing = 1.15,
    this.trailingIconSize = 23,
  });

  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final VoidCallback onBack;
  final Color borderColor;
  final Color shadowColor;
  final Color leadingBackgroundColor;
  final Color leadingIconColor;
  final Color trailingBackgroundColor;
  final Color trailingIconColor;
  final Color titleColor;
  final double titleFontSize;
  final double subtitleFontSize;
  final double subtitleLetterSpacing;
  final double trailingIconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: .035),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: leadingBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: leadingIconColor,
                  size: 23,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
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
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: trailingIconColor,
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w800,
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
              color: trailingBackgroundColor,
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
