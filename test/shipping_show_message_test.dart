import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipping/show_shipping_message.dart';

void main() {
  // Matches get-quote `deepBlue` and the six shipping forms.
  const success = Color(0xFF062B55);

  Future<void> pumpHost(
    WidgetTester tester,
    void Function(BuildContext context) onPressed,
  ) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () => onPressed(context),
                child: const Text('show'),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('normal message uses success color and floating behavior', (
    tester,
  ) async {
    await pumpHost(tester, (context) {
      showShippingMessage(
        context,
        message: 'Quote sent',
        error: false,
        successColor: success,
      );
    });
    await tester.tap(find.text('show'));
    await tester.pump();

    expect(find.text('Quote sent'), findsOneWidget);
    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.behavior, SnackBarBehavior.floating);
    expect(bar.backgroundColor, success);
    expect(bar.duration, const Duration(milliseconds: 4000));
  });

  testWidgets('error message uses the shipping error color', (tester) async {
    await pumpHost(tester, (context) {
      showShippingMessage(
        context,
        message: 'Please complete the form',
        error: true,
        successColor: success,
      );
    });
    await tester.tap(find.text('show'));
    await tester.pump();

    expect(find.text('Please complete the form'), findsOneWidget);
    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.backgroundColor, shippingMessageErrorColor);
    expect(bar.behavior, SnackBarBehavior.floating);
  });

  testWidgets('a new message replaces the previous snackbar', (tester) async {
    await pumpHost(tester, (context) {
      showShippingMessage(
        context,
        message: 'First',
        error: false,
        successColor: success,
      );
      showShippingMessage(
        context,
        message: 'Second',
        error: true,
        successColor: success,
      );
    });
    await tester.tap(find.text('show'));
    await tester.pump();

    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor,
      shippingMessageErrorColor,
    );
  });

  testWidgets('track and support keep unfilled floating radius 14', (
    tester,
  ) async {
    await pumpHost(tester, (context) {
      showFloatingRadiusMessage(context, message: 'Could not track');
    });
    await tester.tap(find.text('show'));
    await tester.pump();

    expect(find.text('Could not track'), findsOneWidget);
    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.behavior, SnackBarBehavior.floating);
    expect(bar.backgroundColor, isNull);
    expect(
      bar.shape,
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  });
}
