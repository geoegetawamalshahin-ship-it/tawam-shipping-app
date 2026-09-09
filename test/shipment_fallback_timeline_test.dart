import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/shipment_status/timeline_row.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

Future<List<ShipmentTimelineRow>> _pumpFallback(
  WidgetTester tester, {
  required String status,
  required double lastRowBottomPadding,
  String lastUpdate = '2 hours ago',
}) async {
  final l10n = AppLocalizationsEn();
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Column(
          children: shipmentFallbackTimeline(
            l10n: l10n,
            status: status,
            lastUpdate: lastUpdate,
            lastRowBottomPadding: lastRowBottomPadding,
          ),
        ),
      ),
    ),
  );
  return tester
      .widgetList<ShipmentTimelineRow>(find.byType(ShipmentTimelineRow))
      .toList();
}

void main() {
  testWidgets('known statuses keep stage order and current index', (
    tester,
  ) async {
    final l10n = AppLocalizationsEn();
    final rows = await _pumpFallback(
      tester,
      status: 'in_transit',
      lastRowBottomPadding: 0,
    );

    expect(rows, hasLength(7));
    expect(rows.map((row) => row.title).toList(), [
      l10n.timelineCreatedTitle,
      l10n.timelineConfirmedTitle,
      l10n.timelinePreparedTitle,
      l10n.timelineInTransitTitle,
      l10n.timelineCustomsTitle,
      l10n.timelineOutForDeliveryTitle,
      l10n.timelineDeliveredTitle,
    ]);
    expect(rows.map((row) => row.icon).toList(), [
      Icons.inventory_2_outlined,
      Icons.verified_outlined,
      Icons.fact_check_outlined,
      Icons.local_shipping_outlined,
      Icons.gavel_outlined,
      Icons.route_outlined,
      Icons.check_circle_outline_rounded,
    ]);

    for (var i = 0; i < rows.length; i++) {
      expect(rows[i].completed, i <= 3);
      expect(rows[i].active, i == 3);
      expect(rows[i].showLine, i != 6);
      expect(rows[i].contentBottomPadding, i == 6 ? 0 : 18);
    }

    expect(rows[3].time, '2 hours ago');
    expect(rows[2].time, l10n.completed);
    expect(rows[4].time, l10n.waiting);
    expect(find.text(l10n.currentBadge), findsOneWidget);
  });

  testWidgets('unknown status uses the first stage as current', (tester) async {
    final rows = await _pumpFallback(
      tester,
      status: 'not-a-status',
      lastRowBottomPadding: 18,
    );

    expect(rows, hasLength(7));
    expect(rows.first.active, isTrue);
    expect(rows.first.completed, isTrue);
    expect(rows.skip(1).every((row) => !row.active && !row.completed), isTrue);
  });

  testWidgets('customs maps to customs_clearance stage', (tester) async {
    final customs = await _pumpFallback(
      tester,
      status: 'customs',
      lastRowBottomPadding: 18,
    );
    final clearance = await _pumpFallback(
      tester,
      status: 'customs_clearance',
      lastRowBottomPadding: 18,
    );

    expect(customs[4].active, isTrue);
    expect(clearance[4].active, isTrue);
    expect(customs[4].completed, isTrue);
    expect(customs[5].completed, isFalse);
  });

  testWidgets('cancelled is a single current row without a connector', (
    tester,
  ) async {
    final l10n = AppLocalizationsEn();
    final rows = await _pumpFallback(
      tester,
      status: 'cancelled',
      lastRowBottomPadding: 0,
    );

    expect(rows, hasLength(1));
    expect(rows.single.title, l10n.timelineCancelledTitle);
    expect(rows.single.description, l10n.timelineCancelledDesc);
    expect(rows.single.time, l10n.latestUpdate);
    expect(rows.single.completed, isFalse);
    expect(rows.single.active, isTrue);
    expect(rows.single.showLine, isFalse);
    expect(rows.single.contentBottomPadding, 0);
    expect(rows.single.icon, Icons.cancel_outlined);
    expect(rows.single.activeColor, const Color(0xFFD72638));
    expect(find.text(l10n.currentBadge), findsOneWidget);
  });

  testWidgets('details last row keeps 18 padding including cancelled', (
    tester,
  ) async {
    final delivered = await _pumpFallback(
      tester,
      status: 'delivered',
      lastRowBottomPadding: 18,
    );
    expect(delivered.last.active, isTrue);
    expect(delivered.last.completed, isTrue);
    expect(delivered.last.showLine, isFalse);
    expect(delivered.last.contentBottomPadding, 18);
    expect(delivered.first.contentBottomPadding, 18);
    expect(delivered.first.showLine, isTrue);

    final cancelled = await _pumpFallback(
      tester,
      status: 'cancelled',
      lastRowBottomPadding: 18,
    );
    expect(cancelled.single.contentBottomPadding, 18);
    expect(cancelled.single.showLine, isFalse);
  });
}
