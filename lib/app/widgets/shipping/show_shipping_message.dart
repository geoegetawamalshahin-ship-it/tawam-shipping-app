import 'package:flutter/material.dart';

const Color shippingMessageErrorColor = Color(0xFF9E2A2A);

void showShippingMessage(
  BuildContext context, {
  required String message,
  required bool error,
  required Color successColor,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? shippingMessageErrorColor : successColor,
    ),
  );
}
