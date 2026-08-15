import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const Color _primaryBlue = Color(0xFF07569E);
  static const Color _darkNavy = Color(0xFF10233F);
  static const Color _pageBackground = Color(0xFFF4F7FB);
  static const Color _borderColor = Color(0xFFE3E9F0);
  static const Color _mutedText = Color(0xFF7F8997);

  @override
  Widget build(BuildContext context) {
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
                      const Expanded(
                        child: Text(
                          'Terms & Conditions',
                          textAlign: TextAlign.center,
                          style: TextStyle(
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

                  const Text(
                    'Terms of Service',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Please review the terms governing your use of the TAWAM AL-SHAHIN TRANSPORT mobile application and services.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: _primaryBlue,
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'By using the Tawam mobile application, you agree to use the application and its transportation services responsibly and in accordance with these Terms & Conditions.',
                            style: TextStyle(
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

                  const _TermsCard(
                    number: '01',
                    icon: Icons.apartment_rounded,
                    title: 'About Our Services',
                    text:
                        'TAWAM AL-SHAHIN TRANSPORT provides transportation, logistics and shipment-related services. The Tawam mobile application provides customers with digital access to selected account, shipment, quotation, tracking, document and support services.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '02',
                    icon: Icons.person_outline_rounded,
                    title: 'Customer Accounts',
                    text:
                        'Customers may be required to create an account to access certain application features. Information provided during registration should be accurate and kept reasonably up to date.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '03',
                    icon: Icons.lock_outline_rounded,
                    title: 'Account Security',
                    text:
                        'Customers are responsible for protecting their account credentials and for activity performed through their account. Passwords and password-reset links should not be shared with unauthorized persons.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '04',
                    icon: Icons.local_shipping_outlined,
                    title: 'Shipment Services',
                    text:
                        'Shipment availability, routes, schedules, transportation methods, documentation requirements and service conditions may vary according to shipment characteristics, origin, destination and applicable operational requirements.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '05',
                    icon: Icons.request_quote_outlined,
                    title: 'Quotations',
                    text:
                        'Quotation requests submitted through the application may require review by TAWAM AL-SHAHIN TRANSPORT. A displayed or requested quotation is not necessarily a confirmed booking until the required details and service arrangements have been accepted.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '06',
                    icon: Icons.route_outlined,
                    title: 'Shipment Tracking',
                    text:
                        'Tracking information is provided to assist customers in following shipment progress. Status information may depend on operational updates and may not always reflect events instantly.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '07',
                    icon: Icons.description_outlined,
                    title: 'Shipping Documents',
                    text:
                        'Invoices, shipment records and other transportation documents made available through the application are associated with the relevant customer or shipment account. Customers should not attempt to access documents belonging to another account.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '08',
                    icon: Icons.inventory_2_outlined,
                    title: 'Shipment Information',
                    text:
                        'Customers are responsible for providing accurate information about shipments, including descriptions, quantities, dimensions, weight, origin, destination and other information reasonably required to arrange transportation services.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '09',
                    icon: Icons.block_outlined,
                    title: 'Restricted or Prohibited Items',
                    text:
                        'Customers must not use the application or transportation services to request shipment of goods that are unlawful or prohibited under applicable requirements. Additional restrictions may apply depending on the shipment, route and destination.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '10',
                    icon: Icons.schedule_rounded,
                    title: 'Transit & Delivery',
                    text:
                        'Estimated transit and delivery times are provided for planning purposes. Actual timing may be affected by customs procedures, border processing, inspections, operational conditions, weather, traffic or other circumstances affecting transportation.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '11',
                    icon: Icons.payments_outlined,
                    title: 'Charges & Payments',
                    text:
                        'Transportation charges and applicable fees depend on the service provided and agreed quotation or arrangement. Additional charges may apply where services or requirements change after confirmation.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '12',
                    icon: Icons.support_agent_rounded,
                    title: 'Customer Support',
                    text:
                        'Customers may contact TAWAM AL-SHAHIN TRANSPORT through the Help Center for assistance relating to accounts, shipment services, quotations, documents or other application-related matters.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '13',
                    icon: Icons.security_rounded,
                    title: 'Acceptable Use',
                    text:
                        'The application must not be used to interfere with its operation, attempt unauthorized access to customer or company information, misuse another person’s account, or engage in activity that may compromise application security.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '14',
                    icon: Icons.cloud_outlined,
                    title: 'Application Availability',
                    text:
                        'We aim to provide reliable access to the application, but availability may occasionally be affected by maintenance, updates, network conditions, third-party services or technical issues.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '15',
                    icon: Icons.update_rounded,
                    title: 'Changes to These Terms',
                    text:
                        'TAWAM AL-SHAHIN TRANSPORT may update these Terms & Conditions when application features, services or applicable requirements change. The latest version may be made available through the application.',
                  ),

                  const SizedBox(height: 14),

                  const _TermsCard(
                    number: '16',
                    icon: Icons.handshake_outlined,
                    title: 'Contact Us',
                    text:
                        'If you have questions regarding these Terms & Conditions or a transportation service, please contact TAWAM AL-SHAHIN TRANSPORT through the Help Center in the application.',
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _darkNavy,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.handshake_outlined,
                          color: Colors.white,
                          size: 29,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'TAWAM AL-SHAHIN TRANSPORT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .3,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Transportation • Logistics • Shipment Services',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFB8C7D8),
                            fontSize: 11,
                          ),
                        ),
                        SizedBox(height: 15),
                        Divider(color: Color(0x25FFFFFF), height: 1),
                        SizedBox(height: 15),
                        Text(
                          'Last updated: August 2026',
                          style: TextStyle(
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
