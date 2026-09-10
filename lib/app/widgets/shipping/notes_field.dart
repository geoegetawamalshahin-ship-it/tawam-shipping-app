import 'package:flutter/material.dart';

class ShippingNotesField extends StatelessWidget {
  const ShippingNotesField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.textColor,
    required this.hintColor,
    required this.primaryColor,
    required this.fillColor,
    required this.borderColor,
    this.showPrefixIcon = true,
    this.hintHeight = 1.45,
    this.includeIdleBorderSide = true,
  });

  final TextEditingController controller;
  final String hintText;
  final Color textColor;
  final Color hintColor;
  final Color primaryColor;
  final Color fillColor;
  final Color borderColor;
  final bool showPrefixIcon;
  final double? hintHeight;
  final bool includeIdleBorderSide;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(15);

    return TextFormField(
      controller: controller,
      minLines: 4,
      maxLines: 7,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: 10,
          height: hintHeight,
        ),
        prefixIcon: showPrefixIcon
            ? Padding(
                padding: const EdgeInsets.only(bottom: 70),
                child: Icon(Icons.edit_note_rounded, color: primaryColor),
              )
            : null,
        filled: true,
        fillColor: fillColor,
        border: includeIdleBorderSide
            ? OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: borderColor),
              )
            : OutlineInputBorder(borderRadius: radius),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: primaryColor, width: 1.4),
        ),
      ),
    );
  }
}
