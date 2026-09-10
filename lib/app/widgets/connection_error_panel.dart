import 'package:flutter/material.dart';

class ConnectionErrorPanel extends StatelessWidget {
  const ConnectionErrorPanel({
    super.key,
    required this.title,
    required this.body,
    required this.retryLabel,
    required this.onRetry,
    required this.borderColor,
    required this.titleColor,
    required this.bodyColor,
    required this.accentColor,
    this.bodyFontWeight = FontWeight.w400,
  });

  final String title;
  final String body;
  final String retryLabel;
  final VoidCallback onRetry;
  final Color borderColor;
  final Color titleColor;
  final Color bodyColor;
  final Color accentColor;
  final FontWeight bodyFontWeight;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F6FC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: accentColor,
                size: 29,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: bodyColor,
                fontSize: 11.5,
                height: 1.5,
                fontWeight: bodyFontWeight,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(retryLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
