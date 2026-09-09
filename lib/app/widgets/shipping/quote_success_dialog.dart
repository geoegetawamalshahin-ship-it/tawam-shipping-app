import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class ShippingQuoteSuccessDialog extends StatelessWidget {
  const ShippingQuoteSuccessDialog({
    super.key,
    required this.quoteNumber,
    required this.onViewQuotes,
    required this.onDone,
    required this.deepBlue,
    required this.success,
    required this.textDark,
    required this.textGrey,
    required this.softGrey,
    required this.border,
    required this.primaryBlue,
  });

  final String quoteNumber;
  final VoidCallback onViewQuotes;
  final VoidCallback onDone;
  final Color deepBlue;
  final Color success;
  final Color textDark;
  final Color textGrey;
  final Color softGrey;
  final Color border;
  final Color primaryBlue;

  @override
  Widget build(BuildContext context) {
    final dialogL10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 23),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 27, 22, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: deepBlue.withValues(alpha: .16),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: success,
                size: 42,
              ),
            ),

            const SizedBox(height: 17),

            Text(
              dialogL10n.quoteRequestSubmitted,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              dialogL10n.quoteSentToTawam,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textGrey,
                fontSize: 10.5,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: softGrey,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  Text(
                    dialogL10n.reference,
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 8,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    quoteNumber,
                    style: TextStyle(
                      color: deepBlue,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onViewQuotes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  dialogL10n.myQuotes,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 9),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: onDone,
                style: OutlinedButton.styleFrom(
                  foregroundColor: deepBlue,
                  side: BorderSide(color: border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  dialogL10n.doneUpper,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
