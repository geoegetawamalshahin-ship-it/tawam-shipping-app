import 'package:flutter/material.dart';

import '../app/widgets/legal/document_chrome.dart';
import '../l10n/app_localizations.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const Color _darkNavy = Color(0xFF10233F);
  static const Color _pageBackground = Color(0xFFF4F7FB);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            LegalDocumentHeader(
              barTitle: l10n.termsConditions,
              heroTitle: l10n.termsOfService,
              subtitle: l10n.reviewTermsSubtitle,
              heroIcon: Icons.gavel_rounded,
              onBack: () => Navigator.pop(context),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 35),
                children: [
                  LegalIntroBanner(text: l10n.termsIntro),

                  const SizedBox(height: 18),

                  LegalSectionCard(
                    number: '01',
                    icon: Icons.apartment_rounded,
                    title: l10n.aboutOurServices,
                    text:
                        l10n.termsAboutServicesBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '02',
                    icon: Icons.person_outline_rounded,
                    title: l10n.customerAccounts,
                    text:
                        l10n.termsCustomerAccountsBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '03',
                    icon: Icons.lock_outline_rounded,
                    title: l10n.accountSecurity,
                    text:
                        l10n.termsAccountSecurityBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '04',
                    icon: Icons.local_shipping_outlined,
                    title: l10n.shipmentServices,
                    text:
                        l10n.termsShipmentServicesBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '05',
                    icon: Icons.request_quote_outlined,
                    title: l10n.quotations,
                    text:
                        l10n.termsQuotationsBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '06',
                    icon: Icons.route_outlined,
                    title: l10n.shipmentTracking,
                    text:
                        l10n.termsShipmentTrackingBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '07',
                    icon: Icons.description_outlined,
                    title: l10n.shippingDocuments,
                    text:
                        l10n.termsShippingDocumentsBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '08',
                    icon: Icons.inventory_2_outlined,
                    title: l10n.shipmentInformation,
                    text:
                        l10n.termsShipmentInformationBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '09',
                    icon: Icons.block_outlined,
                    title: l10n.restrictedItems,
                    text:
                        l10n.termsRestrictedItemsBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '10',
                    icon: Icons.schedule_rounded,
                    title: l10n.transitDelivery,
                    text:
                        l10n.termsTransitDeliveryBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '11',
                    icon: Icons.payments_outlined,
                    title: l10n.chargesPayments,
                    text:
                        l10n.termsChargesPaymentsBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '12',
                    icon: Icons.support_agent_rounded,
                    title: l10n.customerSupport,
                    text:
                        l10n.termsCustomerSupportBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '13',
                    icon: Icons.security_rounded,
                    title: l10n.acceptableUse,
                    text:
                        l10n.termsAcceptableUseBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '14',
                    icon: Icons.cloud_outlined,
                    title: l10n.applicationAvailability,
                    text:
                        l10n.termsApplicationAvailabilityBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '15',
                    icon: Icons.update_rounded,
                    title: l10n.changesToTerms,
                    text:
                        l10n.termsChangesBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '16',
                    icon: Icons.handshake_outlined,
                    title: l10n.contactUs,
                    text:
                        l10n.termsContactBody,
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _darkNavy,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.handshake_outlined,
                          color: Colors.white,
                          size: 29,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.tawamAlShahinTransport,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .3,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          l10n.transportLogisticsServices,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFB8C7D8),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Divider(color: Color(0x25FFFFFF), height: 1),
                        const SizedBox(height: 15),
                        Text(
                          l10n.lastUpdatedAugust2026,
                          style: const TextStyle(
                            color: Color(0xFFAEBBCC),
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

