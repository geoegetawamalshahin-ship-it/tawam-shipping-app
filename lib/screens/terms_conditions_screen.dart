import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const Color _primaryBlue = Color(0xFF07569E);
  static const Color _darkNavy = Color(0xFF10233F);
  static const Color _pageBackground = Color(0xFFF4F7FB);
  static const Color _borderColor = Color(0xFFE3E9F0);
  static const Color _mutedText = Color(0xFF7F8997);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF092542),
                    Color(0xFF07569E),
                    Color(0xFF0874C9),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Material(
                        color: const Color(0x24FFFFFF),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14),
                          child: const SizedBox(
                            width: 46,
                            height: 46,
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          l10n.termsConditions,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 46),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: const Color(0x20FFFFFF),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0x2FFFFFFF)),
                    ),
                    child: const Icon(
                      Icons.gavel_rounded,
                      color: Colors.white,
                      size: 39,
                    ),
                  ),

                  const SizedBox(height: 17),

                  Text(
                    l10n.termsOfService,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.reviewTermsSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFD7E8F8),
                        fontSize: 12.5,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 35),
                children: [
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4FD),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFD5E8F8)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: _primaryBlue,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.termsIntro,
                            style: const TextStyle(
                              color: _darkNavy,
                              fontSize: 12.5,
                              height: 1.55,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  _TermsCard(
                    number: '01',
                    icon: Icons.apartment_rounded,
                    title: l10n.aboutOurServices,
                    text:
                        l10n.termsAboutServicesBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '02',
                    icon: Icons.person_outline_rounded,
                    title: l10n.customerAccounts,
                    text:
                        l10n.termsCustomerAccountsBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '03',
                    icon: Icons.lock_outline_rounded,
                    title: l10n.accountSecurity,
                    text:
                        l10n.termsAccountSecurityBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '04',
                    icon: Icons.local_shipping_outlined,
                    title: l10n.shipmentServices,
                    text:
                        l10n.termsShipmentServicesBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '05',
                    icon: Icons.request_quote_outlined,
                    title: l10n.quotations,
                    text:
                        l10n.termsQuotationsBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '06',
                    icon: Icons.route_outlined,
                    title: l10n.shipmentTracking,
                    text:
                        l10n.termsShipmentTrackingBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '07',
                    icon: Icons.description_outlined,
                    title: l10n.shippingDocuments,
                    text:
                        l10n.termsShippingDocumentsBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '08',
                    icon: Icons.inventory_2_outlined,
                    title: l10n.shipmentInformation,
                    text:
                        l10n.termsShipmentInformationBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '09',
                    icon: Icons.block_outlined,
                    title: l10n.restrictedItems,
                    text:
                        l10n.termsRestrictedItemsBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '10',
                    icon: Icons.schedule_rounded,
                    title: l10n.transitDelivery,
                    text:
                        l10n.termsTransitDeliveryBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '11',
                    icon: Icons.payments_outlined,
                    title: l10n.chargesPayments,
                    text:
                        l10n.termsChargesPaymentsBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '12',
                    icon: Icons.support_agent_rounded,
                    title: l10n.customerSupport,
                    text:
                        l10n.termsCustomerSupportBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '13',
                    icon: Icons.security_rounded,
                    title: l10n.acceptableUse,
                    text:
                        l10n.termsAcceptableUseBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '14',
                    icon: Icons.cloud_outlined,
                    title: l10n.applicationAvailability,
                    text:
                        l10n.termsApplicationAvailabilityBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
                    number: '15',
                    icon: Icons.update_rounded,
                    title: l10n.changesToTerms,
                    text:
                        l10n.termsChangesBody,
                  ),

                  const SizedBox(height: 14),

                  _TermsCard(
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

class _TermsCard extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String text;

  const _TermsCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TermsConditionsScreen._borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C10233F),
            blurRadius: 22,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FD),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: TermsConditionsScreen._primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: TermsConditionsScreen._darkNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    color: TermsConditionsScreen._mutedText,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            text,
            style: const TextStyle(
              color: TermsConditionsScreen._mutedText,
              fontSize: 12.5,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
