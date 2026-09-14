import 'package:flutter/material.dart';

class ActionSuccessDialog extends StatelessWidget {
  const ActionSuccessDialog({
    super.key,
    required this.padding,
    required this.borderRadius,
    required this.shadowColor,
    required this.shadowBlur,
    required this.shadowOffset,
    required this.iconCircleSize,
    required this.iconCircleColor,
    required this.icon,
    required this.iconColor,
    required this.iconSize,
    required this.afterIconGap,
    required this.title,
    required this.titleColor,
    required this.titleFontSize,
    required this.titleFontWeight,
    required this.afterTitleGap,
    required this.body,
    required this.bodyColor,
    required this.bodyFontSize,
    required this.bodyHeight,
    required this.afterBodyGap,
    required this.middle,
    required this.afterMiddleGap,
    required this.buttonHeight,
    required this.buttonColor,
    required this.buttonRadius,
    required this.buttonLabel,
    required this.buttonFontWeight,
    required this.onDone,
    this.bodyFontWeight,
    this.buttonFontSize,
    this.buttonLetterSpacing,
  });

  final EdgeInsets padding;
  final double borderRadius;
  final Color shadowColor;
  final double shadowBlur;
  final Offset shadowOffset;
  final double iconCircleSize;
  final Color iconCircleColor;
  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final double afterIconGap;
  final String title;
  final Color titleColor;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final double afterTitleGap;
  final String body;
  final Color bodyColor;
  final double bodyFontSize;
  final double bodyHeight;
  final FontWeight? bodyFontWeight;
  final double afterBodyGap;
  final Widget middle;
  final double afterMiddleGap;
  final double buttonHeight;
  final Color buttonColor;
  final double buttonRadius;
  final String buttonLabel;
  final FontWeight buttonFontWeight;
  final double? buttonFontSize;
  final double? buttonLetterSpacing;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: shadowBlur,
              offset: shadowOffset,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconCircleSize,
              height: iconCircleSize,
              decoration: BoxDecoration(
                color: iconCircleColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: iconSize),
            ),
            SizedBox(height: afterIconGap),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: titleFontSize,
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
                fontWeight: bodyFontWeight,
              ),
            ),
            SizedBox(height: afterBodyGap),
            middle,
            SizedBox(height: afterMiddleGap),
            SizedBox(
              width: double.infinity,
              height: buttonHeight,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonRadius),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    fontWeight: buttonFontWeight,
                    letterSpacing: buttonLetterSpacing,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
