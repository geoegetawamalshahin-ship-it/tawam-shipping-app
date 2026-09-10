import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tawam_shipping_app/app/widgets/list_filter_bar.dart';
import 'package:tawam_shipping_app/l10n/app_localizations.dart';
import 'package:tawam_shipping_app/l10n/app_localizations_en.dart';

void main() {
  final en = AppLocalizationsEn();

  const items = [
    ListFilterItem(value: 'all', label: 'All'),
    ListFilterItem(value: 'pending', label: 'Pending'),
  ];

  testWidgets('bookings row keeps right padding and 160ms chips', (
    tester,
  ) async {
    var selected = 'all';

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ListFilterBar(
                items: items,
                selectedValue: selected,
                onSelected: (value) => setState(() => selected = value),
                animationDuration: const Duration(milliseconds: 160),
                chipPadding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 10,
                ),
                selectedColor: const Color(0xFF0B4F9C),
                unselectedBorderColor: const Color(0xFFE3EAF2),
                unselectedTextColor: const Color(0xFF8793A4),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              );
            },
          ),
        ),
      ),
    );

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(ListView), findsNothing);

    final trail = tester.widget<Padding>(find.byType(Padding).first);
    expect(trail.padding, const EdgeInsets.only(right: 8));

    final chip = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    expect(chip.duration, const Duration(milliseconds: 160));
    expect(
      chip.padding,
      const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
    );
    expect(chip.alignment, isNull);
    expect(
      tester.widget<Text>(find.text('All')).style?.fontWeight,
      FontWeight.w700,
    );

    await tester.tap(find.text('Pending'));
    await tester.pump();
    expect(
      tester.widget<Text>(find.text('Pending')).style?.color,
      Colors.white,
    );
  });

  testWidgets('quotes list keeps height 39 and centered chips', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListFilterBar(
            items: [
              ListFilterItem(value: 'all', label: en.all),
              ListFilterItem(value: 'waiting', label: en.waiting),
            ],
            selectedValue: 'all',
            onSelected: (_) {},
            height: 39,
            useSeparatedList: true,
            animationDuration: const Duration(milliseconds: 180),
            chipPadding: const EdgeInsets.symmetric(horizontal: 15),
            chipAlignment: Alignment.center,
            selectedColor: const Color(0xFF0B4F9C),
            unselectedBorderColor: const Color(0xFFE2E8F0),
            unselectedTextColor: const Color(0xFF7E8A9A),
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    expect(find.byType(ListView), findsOneWidget);
    expect(tester.getSize(find.byType(ListFilterBar)).height, 39);

    final chip = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    expect(chip.duration, const Duration(milliseconds: 180));
    expect(chip.alignment, Alignment.center);
    expect(chip.padding, const EdgeInsets.symmetric(horizontal: 15));
    expect(chip.decoration is BoxDecoration, isTrue);
    expect((chip.decoration! as BoxDecoration).boxShadow, isNull);
  });

  testWidgets('support chips keep 10.3 and weight 800', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListFilterBar(
            items: [
              ListFilterItem(value: 'all', label: en.all),
              ListFilterItem(value: 'new', label: en.statusNew),
            ],
            selectedValue: 'all',
            onSelected: (_) {},
            height: 40,
            useSeparatedList: true,
            animationDuration: const Duration(milliseconds: 180),
            chipPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
            selectedColor: const Color(0xFF0B4F9C),
            unselectedBorderColor: const Color(0xFFE2EAF2),
            unselectedTextColor: const Color(0xFF7E8A9A),
            fontSize: 10.3,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(ListFilterBar)).height, 40);
    final label = tester.widget<Text>(find.text(en.statusNew));
    expect(label.style?.fontSize, 10.3);
    expect(label.style?.fontWeight, FontWeight.w800);
    expect(label.style?.color, const Color(0xFF7E8A9A));
  });

  testWidgets('shipments selected chip keeps the blue shadow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListFilterBar(
            items: const [
              ListFilterItem(value: 'all', label: 'All'),
              ListFilterItem(value: 'in_transit', label: 'In Transit'),
            ],
            selectedValue: 'all',
            onSelected: (_) {},
            height: 40,
            useSeparatedList: true,
            animationDuration: const Duration(milliseconds: 200),
            chipPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
            selectedColor: const Color(0xFF0B4F9C),
            unselectedBorderColor: const Color(0xFFE2EAF2),
            unselectedTextColor: const Color(0xFF748090),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            selectedBoxShadow: [
              BoxShadow(
                color: const Color(0xFF0B4F9C).withValues(alpha: .14),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
      ),
    );

    final selected = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    final unselected = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).last,
    );
    expect(selected.duration, const Duration(milliseconds: 200));
    expect((selected.decoration! as BoxDecoration).boxShadow, isNotNull);
    expect((unselected.decoration! as BoxDecoration).boxShadow, isNull);
    expect(
      tester.widget<Text>(find.text('In Transit')).style?.color,
      const Color(0xFF748090),
    );
  });
}
