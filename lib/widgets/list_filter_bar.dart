import 'package:flutter/material.dart';

class ListFilterItem {
  const ListFilterItem({required this.value, required this.label});

  final String value;
  final String label;
}

class ListFilterBar extends StatelessWidget {
  const ListFilterBar({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    required this.animationDuration,
    required this.chipPadding,
    required this.selectedColor,
    required this.unselectedBorderColor,
    required this.unselectedTextColor,
    required this.fontSize,
    required this.fontWeight,
    this.height,
    this.useSeparatedList = false,
    this.chipTrailPadding = 8,
    this.chipAlignment,
    this.selectedBoxShadow,
  });

  final List<ListFilterItem> items;
  final String selectedValue;
  final ValueChanged<String> onSelected;
  final Duration animationDuration;
  final EdgeInsetsGeometry chipPadding;
  final Color selectedColor;
  final Color unselectedBorderColor;
  final Color unselectedTextColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double? height;
  final bool useSeparatedList;
  final double chipTrailPadding;
  final AlignmentGeometry? chipAlignment;
  final List<BoxShadow>? selectedBoxShadow;

  @override
  Widget build(BuildContext context) {
    if (useSeparatedList) {
      return SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) => _chip(items[index]),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in items)
            Padding(
              padding: EdgeInsets.only(right: chipTrailPadding),
              child: _chip(item),
            ),
        ],
      ),
    );
  }

  Widget _chip(ListFilterItem item) {
    final selected = item.value == selectedValue;

    return InkWell(
      onTap: () => onSelected(item.value),
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: animationDuration,
        padding: chipPadding,
        alignment: chipAlignment,
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? selectedColor : unselectedBorderColor,
          ),
          boxShadow: selected ? selectedBoxShadow : null,
        ),
        child: Text(
          item.label,
          style: TextStyle(
            color: selected ? Colors.white : unselectedTextColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
