import 'package:flutter/material.dart';

class ShippingDateSelector extends StatelessWidget {
  const ShippingDateSelector({
    super.key,
    required this.onTap,
    required this.fillColor,
    required this.iconBackgroundColor,
    required this.borderColor,
    required this.primaryColor,
    required this.labelColor,
    required this.textColor,
    required this.label,
    required this.valueText,
    required this.isEmpty,
    this.labelWeight = FontWeight.w600,
  });

  final VoidCallback onTap;
  final Color fillColor;
  final Color iconBackgroundColor;
  final Color borderColor;
  final Color primaryColor;
  final Color labelColor;
  final Color textColor;
  final String label;
  final String valueText;
  final bool isEmpty;
  final FontWeight? labelWeight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: primaryColor,
                size: 19,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 9.5,
                      fontWeight: labelWeight,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    valueText,
                    style: TextStyle(
                      color: isEmpty ? labelColor : textColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              color: labelColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
