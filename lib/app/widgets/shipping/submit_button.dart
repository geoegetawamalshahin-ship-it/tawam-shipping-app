import 'package:flutter/material.dart';

class ShippingSubmitButton extends StatelessWidget {
  const ShippingSubmitButton({
    super.key,
    required this.submitting,
    required this.onSubmit,
    required this.primaryColor,
    required this.label,
    required this.icon,
  });

  final bool submitting;
  final VoidCallback onSubmit;
  final Color primaryColor;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: submitting ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryColor.withValues(alpha: .55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: submitting
            ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 21),

                  const SizedBox(width: 10),

                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .35,
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }
}
