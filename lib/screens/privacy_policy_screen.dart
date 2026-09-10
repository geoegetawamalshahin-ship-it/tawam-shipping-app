import 'package:flutter/material.dart';

import '../app/widgets/legal/document_chrome.dart';
import '../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color _darkNavy = Color(0xFF10233F);
  static const Color _pageBackground = Color(0xFFF4F7FB);
  static const Color _mutedText = Color(0xFF7F8997);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            LegalDocumentHeader(
              barTitle: l10n.privacyPolicy,
              heroTitle: l10n.privacyPolicy,
              subtitle: l10n.privacyHeroSubtitle,
              heroIcon: Icons.shield_outlined,
              onBack: () => Navigator.pop(context),
            ),

            // CONTENT
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 35),
                children: [
                  LegalIntroBanner(text: l10n.privacyIntro),

                  const SizedBox(height: 18),

                  LegalSectionCard(
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

                  LegalSectionCard(
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

                  LegalSectionCard(
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

                  LegalSectionCard(
                    number: '04',
                    icon: Icons.lock_outline_rounded,
                    title: l10n.accountSecurity,
                    text:
                        l10n.privacyAccountSecurityBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '05',
                    icon: Icons.description_outlined,
                    title: l10n.shippingDocuments,
                    text:
                        l10n.privacyShippingDocumentsBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '06',
                    icon: Icons.notifications_none_rounded,
                    title: l10n.serviceCommunications,
                    text:
                        l10n.privacyServiceCommunicationsBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '07',
                    icon: Icons.share_outlined,
                    title: l10n.dataSharing,
                    text:
                        l10n.privacyDataSharingBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '08',
                    icon: Icons.storage_outlined,
                    title: l10n.dataStorage,
                    text:
                        l10n.privacyDataStorageBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '09',
                    icon: Icons.security_rounded,
                    title: l10n.securityMeasures,
                    text:
                        l10n.privacySecurityMeasuresBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '10',
                    icon: Icons.history_rounded,
                    title: l10n.dataRetention,
                    text:
                        l10n.privacyDataRetentionBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '11',
                    icon: Icons.edit_note_rounded,
                    title: l10n.yourAccountInformation,
                    text:
                        l10n.privacyYourAccountInfoBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '12',
                    icon: Icons.key_rounded,
                    title: l10n.passwordAccountProtection,
                    text:
                        l10n.privacyPasswordProtectionBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
                    number: '13',
                    icon: Icons.support_agent_rounded,
                    title: l10n.contactUs,
                    text:
                        l10n.privacyContactBody,
                  ),

                  const SizedBox(height: 14),

                  LegalSectionCard(
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

