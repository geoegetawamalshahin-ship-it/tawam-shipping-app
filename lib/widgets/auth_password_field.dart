import 'package:flutter/material.dart';

import 'auth_field_decoration.dart';

class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.icon = Icons.lock_outline_rounded,
    this.contentPaddingVertical = 20,
    this.errorBorderEnabled = false,
    this.focusedErrorBorderEnabled = false,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final IconData icon;
  final double contentPaddingVertical;
  final bool errorBorderEnabled;
  final bool focusedErrorBorderEnabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      decoration: authInputDecoration(
        hintText: hintText,
        icon: icon,
        contentPaddingVertical: contentPaddingVertical,
        errorBorderEnabled: errorBorderEnabled,
        focusedErrorBorderEnabled: focusedErrorBorderEnabled,
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFF07569E),
          ),
        ),
      ),
    );
  }
}
