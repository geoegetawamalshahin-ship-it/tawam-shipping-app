import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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

                      Expanded(
                        child: Text(
                          l10n.privacyPolicy,
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
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 39,
                    ),
                  ),

                  const SizedBox(height: 17),

                  Text(
                    l10n.privacyPolicy,
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
                      l10n.privacyHeroSubtitle,
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
                            l10n.privacyIntro,
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

                  _PrivacySectionCard(
                    number: '01',
                    icon: Icons.person_outline_rounded,
                    title: l10n.informationWeCollect,
                    text: l10n.privacyAccountIntro,
                    bullets: [
                      l10n.fullName,
                      l10n.emailAddress,
                      l10n.privacyPhoneNumber,
                      l10n.privacyCompanyWhenProvided,
                      l10n.privacyAddressWhenProvided,
                      l10n.privacyAccountIdInfo,
                    ],
                  ),

                  const SizedBox(height: 14),

                  _PrivacySectionCard(
                    number: '02',
                    icon: Icons.local_shipping_outlined,
                    title: l10n.shipmentInformation,
                    text: l10n.privacyShipmentIntro,
                    bullets: [
                      l10n.privacyTrackingNumbers,
                      l10n.privacyOriginDestination,
                      l10n.privacyStatusUpdates,
                      l10n.privacyServiceDetails,
                      l10n.privacyRelatedDocuments,
                      l10n.privacyQuoteInfo,
                    ],
                  ),

                  const SizedBox(height: 14),

                  _PrivacySectionCard(
                    number: '03',
                    icon: Icons.manage_accounts_outlined,
                    title: l10n.howWeUseInformation,
                    text: l10n.privacyUseIntro,
                    bullets: [
                      l10n.privacyUseAccounts,
                      l10n.privacyUseAuth,
                      l10n.privacyUseRequests,
                      l10n.privacyUseTracking,
                      l10n.privacyUseQuotes,
                      l10n.privacyUseInvoices,
                      l10n.privacyUseSupport,
                      l10n.privacyUseImprove,
                    ],
                  ),

                  const SizedBox(height: 14),

                  _PrivacySectionCard(
                    number: '04',
                    icon: Icons.lock_outline_rounded,
                    title: l10n.accountSecurity,
                    text:
                        l10n.privacyAccountSecurityBody,
                  ),

                  const SizedBox(height: 14),

                  _PrivacySectionCard(
                    number: '05',
                    icon: Icons.description_outlined,
                    title: l10n.shippingDocuments,
                    text:
                        l10n.privacyShippingDocumentsBody,
                  ),

                  const SizedBox(height: 14),

                  _PrivacySectionCard(
                    number: '06',
                    icon: Icons.notifications_none_rounded,
                    title: l10n.serviceCommunications,
                    text:
                        l10n.privacyServiceCommunicationsBody,
                  ),

                  const SizedBox(height: 14),

                  _PrivacySectionCard(
                    number: '07',
                    icon: Icons.share_outlined,
                    title: l10n.dataSharing,
                    text:
                        l10n.privacyDataSharingBody,
                  ),

                  const SizedBox(height: 14),

                  _PrivacySectionCard(
                    number: '08',
                    icon: Icons.storage_outlined,
                    title: l10n.dataStorage,
                    text:
                        l10n.privacyDataStorageBody,
                  ),

                  const SizedBox(height: 14),

                  _PrivacySectionCard(
                    number: '09',
                    icon: Icons.security_rounded,
                    title: l10n.securityMeasures,
                    text:
                        l10n.privacySecurityMeasuresBody,
                  ),

                  const SizedBox(height: 14),

                  _PrivacySectionCard(
                    number: '10',
                    icon: Icons.history_rounded,
                    title: l10n.dataRetention,
                    text:
                        l10n.privacyDataRetentionBody,
                  ),

                  const SizedBox(height: 14),

                  _PrivacySectionCard(
                    number: '11',
                    icon: Icons.edit_note_rounded,
                    title: l10n.yourAccountInformation,
                    text:
                        l10n.privacyYourAccountInfoBody,
                  ),

                  const SizedBox(height: 14),

                  _PrivacySectionCard(
                    number: '12',
                    icon: Icons.key_rounded,
                    title: l10n.passwordAccountProtection,
                    text:
                        l10n.privacyPasswordProtectionBody,
                  ),

                  const SizedBox(height: 14),

                  _PrivacySectionCard(
                    number: '13',
                    icon: Icons.support_agent_rounded,
                    title: l10n.contactUs,
                    text:
                        l10n.privacyContactBody,
                  ),

                  const SizedBox(height: 14),

                  _PrivacySectionCard(
                    number: '14',
                    icon: Icons.update_rounded,
                    title: l10n.changesToPolicy,
                    text:
                        l10n.privacyChangesBody,
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
                          Icons.verified_user_outlined,
                          color: Colors.white,
                          size: 28,
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
                            fontWeight: FontWeight.w500,
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

                  const SizedBox(height: 18),

                  Center(
                    child: Text(
                      l10n.privacySecurityTrust,
                      style: const TextStyle(
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
