import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
            // HEADER
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
                          'Privacy Policy',
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
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 39,
                    ),
                  ),

                  const SizedBox(height: 17),

                  const Text(
                    'Your privacy matters',
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
                      'TAWAM AL-SHAHIN TRANSPORT is committed to handling customer information responsibly and securely.',
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

            // CONTENT
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
                            'This Privacy Policy explains how TAWAM AL-SHAHIN TRANSPORT handles information when customers use the Tawam mobile application and related transportation services.',
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

                  const _PrivacySectionCard(
                    number: '01',
                    icon: Icons.person_outline_rounded,
                    title: 'Information We Collect',
                    text:
                        'When you create or use a Tawam account, we may process information that you provide to us, including:',
                    bullets: [
                      'Full name',
                      'Email address',
                      'Phone number',
                      'Company information, when provided',
                      'Delivery or account address, when provided',
                      'Account and customer identification information',
                    ],
                  ),

                  const SizedBox(height: 14),

                  const _PrivacySectionCard(
                    number: '02',
                    icon: Icons.local_shipping_outlined,
                    title: 'Shipment Information',
                    text:
                        'When you use our transportation and logistics services, information related to your shipments may be processed to provide and manage the requested service.',
                    bullets: [
                      'Shipment and tracking numbers',
                      'Origin and destination information',
                      'Shipment status and delivery updates',
                      'Transportation service details',
                      'Shipment-related documents',
                      'Information submitted with quotation requests',
                    ],
                  ),

                  const SizedBox(height: 14),

                  const _PrivacySectionCard(
                    number: '03',
                    icon: Icons.manage_accounts_outlined,
                    title: 'How We Use Your Information',
                    text:
                        'TAWAM AL-SHAHIN TRANSPORT may use information collected through the application to:',
                    bullets: [
                      'Create and manage customer accounts',
                      'Authenticate users and protect account access',
                      'Process transportation and shipment requests',
                      'Provide shipment tracking and status updates',
                      'Manage quotation requests',
                      'Provide invoices and shipment documents',
                      'Respond to customer support requests',
                      'Maintain and improve application functionality',
                    ],
                  ),

                  const SizedBox(height: 14),

                  const _PrivacySectionCard(
                    number: '04',
                    icon: Icons.lock_outline_rounded,
                    title: 'Account & Authentication Security',
                    text:
                        'Account access is protected using authentication services. Customers should keep their login credentials confidential and should not share passwords or password-reset links with other persons.',
                  ),

                  const SizedBox(height: 14),

                  const _PrivacySectionCard(
                    number: '05',
                    icon: Icons.description_outlined,
                    title: 'Shipping Documents',
                    text:
                        'Invoices, transportation documents, proof-of-delivery files and other shipment-related documents may be made available through a customer account when those documents are associated with that customer or shipment.',
                  ),

                  const SizedBox(height: 14),

                  const _PrivacySectionCard(
                    number: '06',
                    icon: Icons.notifications_none_rounded,
                    title: 'Service Communications',
                    text:
                        'We may use your contact information to provide service-related communications such as shipment updates, quotation information, account notices, security messages and customer-support responses.',
                  ),

                  const SizedBox(height: 14),

                  const _PrivacySectionCard(
                    number: '07',
                    icon: Icons.share_outlined,
                    title: 'Information Sharing',
                    text:
                        'Information may be shared when reasonably necessary to provide transportation or logistics services, process a customer request, support application operations, comply with applicable legal requirements, or protect the security of our services. We do not intend customer accounts to provide public access to private shipment information.',
                  ),

                  const SizedBox(height: 14),

                  const _PrivacySectionCard(
                    number: '08',
                    icon: Icons.storage_outlined,
                    title: 'Data Storage',
                    text:
                        'Account and application data may be stored using cloud infrastructure and service providers used by TAWAM AL-SHAHIN TRANSPORT to operate the application. Access to customer information should be limited according to account permissions and operational requirements.',
                  ),

                  const SizedBox(height: 14),

                  const _PrivacySectionCard(
                    number: '09',
                    icon: Icons.security_rounded,
                    title: 'Data Security',
                    text:
                        'We use technical and organizational safeguards designed to reduce unauthorized access, disclosure, alteration or misuse of customer and shipment information. No electronic system can guarantee absolute security, so customers should also protect their account credentials and devices.',
                  ),

                  const SizedBox(height: 14),

                  const _PrivacySectionCard(
                    number: '10',
                    icon: Icons.history_rounded,
                    title: 'Data Retention',
                    text:
                        'Information may be retained for as long as reasonably necessary to provide transportation services, maintain customer and shipment records, support business operations, resolve disputes, meet contractual requirements and comply with applicable obligations.',
                  ),

                  const SizedBox(height: 14),

                  const _PrivacySectionCard(
                    number: '11',
                    icon: Icons.edit_note_rounded,
                    title: 'Your Account Information',
                    text:
                        'Customers may review and update certain account information through the Profile section of the Tawam application. Security-sensitive changes may require additional authentication or verification.',
                  ),

                  const SizedBox(height: 14),

                  const _PrivacySectionCard(
                    number: '12',
                    icon: Icons.key_rounded,
                    title: 'Password & Account Protection',
                    text:
                        'Customers can use the available account-security features to reset or change their password. Passwords should be strong, unique and kept confidential. If you believe your account has been accessed without authorization, contact us promptly.',
                  ),

                  const SizedBox(height: 14),

                  const _PrivacySectionCard(
                    number: '13',
                    icon: Icons.support_agent_rounded,
                    title: 'Contact & Privacy Requests',
                    text:
                        'If you have questions regarding your account, shipment information, privacy or this Privacy Policy, please contact TAWAM AL-SHAHIN TRANSPORT through the Help Center available in the application.',
                  ),

                  const SizedBox(height: 14),

                  const _PrivacySectionCard(
                    number: '14',
                    icon: Icons.update_rounded,
                    title: 'Changes to This Policy',
                    text:
                        'TAWAM AL-SHAHIN TRANSPORT may update this Privacy Policy when the application, our services or applicable requirements change. The latest version will be made available through the application.',
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
                          Icons.verified_user_outlined,
                          color: Colors.white,
                          size: 28,
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
                            fontWeight: FontWeight.w500,
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

                  const SizedBox(height: 18),

                  const Center(
                    child: Text(
                      'Privacy • Security • Trust',
                      style: TextStyle(
                        color: _mutedText,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .7,
                      ),
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

class _PrivacySectionCard extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String text;
  final List<String> bullets;

  const _PrivacySectionCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.text,
    this.bullets = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: PrivacyPolicyScreen._borderColor),
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  color: PrivacyPolicyScreen._primaryBlue,
                  size: 22,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: PrivacyPolicyScreen._darkNavy,
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
                    color: PrivacyPolicyScreen._mutedText,
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
              color: PrivacyPolicyScreen._mutedText,
              fontSize: 12.5,
              height: 1.6,
            ),
          ),

          if (bullets.isNotEmpty) ...[
            const SizedBox(height: 13),

            ...bullets.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6, right: 10),
                      decoration: const BoxDecoration(
                        color: PrivacyPolicyScreen._primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),

                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: PrivacyPolicyScreen._darkNavy,
                          fontSize: 11.5,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
