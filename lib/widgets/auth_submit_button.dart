import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.submitting,
    required this.onPressed,
  });

  final String label;
  final RxBool submitting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final busy = submitting.value;
      return SizedBox(
        width: double.infinity,
        height: 59,
        child: ElevatedButton(
          onPressed: busy ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF07569E),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF07569E),
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: busy
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
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward_rounded, size: 23),
                  ],
                ),
        ),
      );
    });
  }
}
