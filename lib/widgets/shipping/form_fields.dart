import 'package:flutter/material.dart';

Widget shippingTextField({
  required TextEditingController controller,
  required InputDecoration decoration,
  required Color textColor,
  required ValueChanged<String> onChanged,
  TextInputType? keyboardType,
  FormFieldValidator<String>? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    onChanged: onChanged,
    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w700),
    decoration: decoration,
  );
}

InputDecoration shippingInputDecoration({
  required String label,
  required String hint,
  required IconData icon,
  String? suffix,
  required Color primaryColor,
  required Color labelColor,
  required Color fillColor,
  required Color borderColor,
  FontWeight? labelWeight = FontWeight.w600,
  bool focusedErrorBorderEnabled = true,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixText: suffix,
    prefixIcon: Icon(icon, color: primaryColor, size: 19),
    labelStyle: TextStyle(
      color: labelColor,
      fontSize: 10,
      fontWeight: labelWeight,
    ),
    hintStyle: const TextStyle(color: Color(0xFFA4AFBB), fontSize: 10.5),
    suffixStyle: TextStyle(
      color: primaryColor,
      fontSize: 9,
      fontWeight: FontWeight.w900,
    ),
    filled: true,
    fillColor: fillColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide:  BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: primaryColor, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0xFFC23B3B)),
    ),
    focusedErrorBorder: focusedErrorBorderEnabled ? OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Color(0xFFC23B3B), width: 1.4),
    ) : null,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
  );
}
