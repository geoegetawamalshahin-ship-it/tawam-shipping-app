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
  });

  final TextEditingController controller;
  final String hintText;
  final Color textColor;
  final Color hintColor;
  final Color primaryColor;
  final Color fillColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
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
          height: 1.45,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: Icon(Icons.edit_note_rounded, color: primaryColor),
        ),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor, width: 1.4),
        ),
      ),
    );
  }
}
