import 'package:flutter/material.dart';

import 'premium_card.dart';

class ShippingServicesSection extends StatelessWidget {
  const ShippingServicesSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.services,
    required this.selectedServices,
    required this.serviceLabel,
    required this.onSelectionChanged,
    required this.borderColor,
    required this.shadowColor,
    required this.textColor,
    required this.labelColor,
    required this.primaryColor,
    required this.fillColor,
  });

  final String title;
  final String subtitle;
  final Iterable<String> services;
  final Iterable<String> selectedServices;
  final String Function(String) serviceLabel;
  final void Function(String, bool) onSelectionChanged;
  final Color borderColor;
  final Color shadowColor;
  final Color textColor;
  final Color labelColor;
  final Color primaryColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return ShippingPremiumCard(
      borderColor: borderColor,
      shadowColor: shadowColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            style: TextStyle(color: labelColor, fontSize: 9.5),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 9,
            children: services.map((service) {
              final selected = selectedServices.contains(service);

              return FilterChip(
                label: Text(serviceLabel(service)),
                selected: selected,
                showCheckmark: true,
                checkmarkColor: Colors.white,
                selectedColor: primaryColor,
                backgroundColor: fillColor,
                side: BorderSide(color: selected ? primaryColor : borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : textColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (value) => onSelectionChanged(service, value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
