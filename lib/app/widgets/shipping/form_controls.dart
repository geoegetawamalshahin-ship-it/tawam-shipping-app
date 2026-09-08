import 'package:flutter/material.dart';

Widget shippingDropdown({
  required String value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  required Color primaryColor,
  required InputDecoration decoration,
  TextStyle? style,
  String Function(String item)? itemLabel,
}) {
  return DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    dropdownColor: Colors.white,
    icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor),
    style: style,
    decoration: decoration,
    items: items.map((item) => DropdownMenuItem<String>(
      value: item,
      child: Text(itemLabel?.call(item) ?? item),
    )).toList(),
    onChanged: onChanged,
  );
}

Widget shippingDimensionField({
  required TextEditingController controller,
  required String label,
  required Color textDark,
  required Color textGrey,
  required Color primaryBlue,
  required Color softGrey,
  required Color border,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    textAlign: TextAlign.center,
    style: TextStyle(
      color: textDark,
      fontSize: 11,
      fontWeight: FontWeight.w800,
    ),
    decoration: InputDecoration(
      labelText: label,
      suffixText: 'CM',
      labelStyle: TextStyle(color: textGrey, fontSize: 8.5),
      suffixStyle: TextStyle(
        color: primaryBlue,
        fontSize: 7.5,
        fontWeight: FontWeight.w800,
      ),
      filled: true,
      fillColor: softGrey,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: primaryBlue),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
    ),
  );
}

Widget shippingOptionSwitch({
  required IconData icon,
  required String title,
  required String subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
  required Color softBlue,
  required Color primaryBlue,
  required Color textDark,
  required Color textGrey,
}) {
  return Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: softBlue,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: primaryBlue, size: 20),
      ),

      const SizedBox(width: 11),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textDark,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,
              style: TextStyle(
                color: textGrey,
                fontSize: 8.8,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),

      Switch(
        value: value,
        activeThumbColor: primaryBlue,
        onChanged: onChanged,
      ),
    ],
  );
}
