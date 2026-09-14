import 'package:flutter/material.dart';

InputDecoration authInputDecoration({
  required String hintText,
  required IconData icon,
  Widget? suffixIcon,
  double contentPaddingVertical = 20,
  bool errorBorderEnabled = false,
  bool focusedErrorBorderEnabled = false,
}) {
  final radius = BorderRadius.circular(17);
  const idleBorder = BorderSide(color: Color(0xFFE0E4E9));

  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFFA5ABB5)),
    prefixIcon: Icon(icon, color: const Color(0xFF87909D)),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: const Color(0xFFF7F8FA),
    contentPadding: EdgeInsets.symmetric(
      vertical: contentPaddingVertical,
      horizontal: 18,
    ),
    border: OutlineInputBorder(borderRadius: radius, borderSide: idleBorder),
    enabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: idleBorder,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: Color(0xFF07569E), width: 1.7),
    ),
    errorBorder: errorBorderEnabled
        ? OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: Color(0xFFD72638)),
          )
        : null,
    focusedErrorBorder: focusedErrorBorderEnabled
        ? OutlineInputBorder(
            borderRadius: radius,
            borderSide: const BorderSide(color: Color(0xFFD72638), width: 1.7),
          )
        : null,
  );
}
