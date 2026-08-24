import 'dart:async';

import 'package:flutter/material.dart';

import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'shipments_screen.dart';
import 'shipping_documents_screen.dart';
import 'support_screen.dart';
import 'track_shipment_screen.dart';
import 'get_quote_screen.dart';
import 'my_quotes_screen.dart';
import 'create_booking_screen.dart';
import 'my_bookings_screen.dart';
import 'volume_calculator_screen.dart';
import 'sea_freight_screen.dart';
import 'air_freight_screen.dart';
import 'land_freight_screen.dart';
import 'car_shipping_screen.dart';
import 'international_moving_screen.dart';
import 'parcel_shipping_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../locale_controller.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ==========================================================
  // TAWAM BRAND
  // ==========================================================

  static const Color primaryBlue = Color(0xFF0B4F9C);
  static const Color deepBlue = Color(0xFF062B55);
  static const Color pageBackground = Color(0xFFF5F7FB);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF7A8797);
  static const Color borderColor = Color(0xFFE4EAF1);

  // ==========================================================
  // BANNERS
  // ==========================================================

  List<String> get _bannerImages => [
    LocaleController.bannerAsset('banner_1.png'),
    LocaleController.bannerAsset('banner_2.png'),
    LocaleController.bannerAsset('banner_3.png'),
    LocaleController.bannerAsset('banner_4.png'),
  ];

  late final PageController _bannerController;
  Timer? _bannerTimer;
  int _currentBanner = 0;

  @override
  void initState() {
    super.initState();

    _bannerController = PageController();
    LocaleController.restoreFromFirestore();

    _bannerTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _nextBanner(),
    );
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _nextBanner() {
    if (!_bannerController.hasClients || _bannerImages.isEmpty) return;

    final next = (_currentBanner + 1) % _bannerImages.length;

    _bannerController.animateToPage(
      next,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _selectLanguage(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final selectedLanguage = LocaleController.languageName;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9DEE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 21),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l10n.applicationLanguage,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...LocaleController.languageNames.map((language) {
                  final isSelected = language == selectedLanguage;
                  final label = _languageLabel(l10n, language);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: isSelected
                          ? const Color(0xFFEAF4FF)
                          : const Color(0xFFF7F9FC),
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: () => Navigator.pop(sheetContext, language),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFB9D8F3)
                                  : borderColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: const Icon(
                                  Icons.language_rounded,
                                  color: primaryBlue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: textDark,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: primaryBlue,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !context.mounted) return;
    await LocaleController.saveLanguage(selected);
  }

  String _languageLabel(AppLocalizations l10n, String language) {
    switch (language) {
      case 'Arabic':
        return l10n.languageArabic;
      case 'French':
        return l10n.languageFrench;
      default:
        return l10n.languageEnglish;
    }
  }

  // ==========================================================
  // PAGE
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: pageBackground,
      drawer: _buildDrawer(context),

      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildBottomNavigation(context),
      ),

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBannerSlider(),

                    const SizedBox(height: 24),

                    _buildSectionHeader(),

                    const SizedBox(height: 18),

                    _buildServiceGrid(context),

                    const SizedBox(height: 24),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.quickActions,
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            l10n.quickActionsSubtitle,
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    _buildQuickActions(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: .08),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Builder(
            builder: (drawerContext) {
              return InkWell(
                onTap: () => Scaffold.of(drawerContext).openDrawer(),
                borderRadius: BorderRadius.circular(14),
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(Icons.menu_rounded, color: deepBlue, size: 33),
                ),
              );
            },
          ),

          Expanded(
            child: Center(
              child: SizedBox(
                width: 170,
                height: 68,
                child: ClipRect(
                  child: Transform.scale(
                    scale: 2.35,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/tawam_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          InkWell(
            onTap: () {
              _openPage(context, const NotificationsScreen());
            },
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: deepBlue.withValues(alpha: .04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where(
                      'userId',
                      isEqualTo:
                          FirebaseAuth.instance.currentUser?.uid ??
                          '__no_user__',
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  int unreadCount = 0;

                  if (snapshot.hasData) {
                    unreadCount = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      return data['isRead'] != true;
                    }).length;
                  }

                  return Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_none_rounded,
                        color: deepBlue,
                        size: 27,
                      ),

                      if (unreadCount > 0)
                        Positioned(
                          top: -9,
                          right: -10,
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 19,
                              minHeight: 19,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE53935),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PREMIUM BANNER SLIDER
  // ==========================================================

  Widget _buildBannerSlider() {
    return AspectRatio(
      aspectRatio: 2.08,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _bannerImages.length,
            onPageChanged: (index) {
              if (!mounted) return;

              setState(() {
                _currentBanner = index;
              });
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  _bannerImages[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: deepBlue,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.white54,
                        size: 44,
                      ),
                    );
                  },
                ),
              );
            },
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_bannerImages.length, (index) {
                final selected = index == _currentBanner;

                return GestureDetector(
                  onTap: () {
                    _bannerController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: .55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // RATE REQUEST HEADER
  // ==========================================================

  Widget _buildSectionHeader() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        children: [
          Text(
            l10n.rateRequest,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textDark,
              fontSize: 27,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.rateRequestSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textGrey,
              fontSize: 13,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PREMIUM 3-COLUMN SERVICE GRID
  // ==========================================================

  Widget _buildServiceGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final services = <_ServiceItem>[
      _ServiceItem(
        storedName: 'Sea Freight',
        title: l10n.serviceSeaFreight,
        subtitle: l10n.serviceSeaFreightSubtitle,
        image: 'assets/images/sea_freight.png',
        icon: Icons.directions_boat_filled_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SeaFreightScreen()),
          );
        },
      ),
      _ServiceItem(
        storedName: 'Air Freight',
        title: l10n.serviceAirFreight,
        subtitle: l10n.serviceAirFreightSubtitle,
        image: 'assets/images/air_freight.png',
        icon: Icons.flight_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AirFreightScreen()),
          );
        },
      ),
      _ServiceItem(
        storedName: 'Land Freight',
        title: l10n.serviceLandFreight,
        subtitle: l10n.serviceLandFreightSubtitle,
        image: 'assets/images/land_freight.png',
        icon: Icons.local_shipping_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LandFreightScreen()),
          );
        },
      ),
      _ServiceItem(
        storedName: 'Car Shipping',
        title: l10n.serviceCarShipping,
        subtitle: l10n.serviceCarShippingSubtitle,
        image: 'assets/images/car_shipping.png',
        icon: Icons.directions_car_filled_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CarShippingScreen()),
          );
        },
      ),
      _ServiceItem(
        storedName: 'International Moving',
        title: l10n.serviceInternationalMoving,
        subtitle: l10n.serviceMovingSubtitle,
        image: 'assets/images/moving.png',
        icon: Icons.home_work_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const InternationalMovingScreen(),
            ),
          );
        },
      ),
      _ServiceItem(
        storedName: 'Parcel Shipping',
        title: l10n.serviceParcelShipping,
        subtitle: l10n.serviceParcelSubtitle,
        image: 'assets/images/parcel.png',
        icon: Icons.inventory_2_outlined,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ParcelShippingScreen()),
          );
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth >= 600 ? 3 : 2,
            crossAxisSpacing: compact ? 8 : 10,
            mainAxisSpacing: compact ? 10 : 12,
            childAspectRatio: compact ? 1.35 : 1.42,
          ),
          itemBuilder: (context, index) {
            final service = services[index];

            return _buildServiceCard(context, service, compact: compact);
          },
        );
      },
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    _ServiceItem service, {
    required bool compact,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            service.onTap ??
            () => _showRateRequestSheet(context, service.storedName),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: deepBlue.withValues(alpha: .10),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  service.image,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: const Color(0xFFDDE7F2));
                  },
                ),

                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x12000000),
                        Color(0x24000000),
                        Color(0xD600142C),
                      ],
                      stops: [0, .42, 1],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 6 : 8,
                    10,
                    compact ? 6 : 8,
                    10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        service.icon,
                        color: Colors.white,
                        size: compact ? 30 : 34,
                      ),

                      const SizedBox(height: 7),

                      Text(
                        service.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 11 : 12.2,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          shadows: const [
                            Shadow(color: Colors.black54, blurRadius: 6),
                          ],
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        service.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .82),
                          fontSize: compact ? 8 : 8.8,
                          height: 1,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = [
      {
        'title': l10n.getAQuote,
        'icon': Icons.request_quote_outlined,
        'onTap': () {
          _openPage(context, const GetQuoteScreen());
        },
      },
      {
        'title': l10n.createABooking,
        'icon': Icons.calendar_month_outlined,
        'onTap': () {
          _openPage(context, const CreateBookingScreen());
        },
      },
      {
        'title': l10n.volumeCalculator,
        'icon': Icons.calculate_outlined,
        'onTap': () {
          _openPage(context, const VolumeCalculatorScreen());
        },
      },
      {
        'title': l10n.shipmentTracking,
        'icon': Icons.local_shipping_outlined,
        'onTap': () {
          _openPage(context, const TrackShipmentScreen());
        },
      },
      {
        'title': l10n.myQuotes,
        'icon': Icons.request_quote_outlined,
        'onTap': () {
          _openPage(context, const MyQuotesScreen());
        },
      },
      {
        'title': l10n.myBookings,
        'icon': Icons.calendar_month_outlined,
        'onTap': () {
          _openPage(context, const MyBookingsScreen());
        },
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.00,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item['onTap'] as VoidCallback,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: deepBlue.withValues(alpha: .045),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: primaryBlue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    item['title'] as String,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 10.5,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  Widget _buildBottomNavigation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(7, 7, 7, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: .08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _navItem(
              icon: Icons.home_rounded,
              label: l10n.home,
              selected: true,
              onTap: () {},
            ),
          ),
          Expanded(
            child: _navItem(
              icon: Icons.search_rounded,
              label: l10n.track,
              onTap: () {
                _openPage(context, const TrackShipmentScreen());
              },
            ),
          ),
          Expanded(
            child: _navItem(
              icon: Icons.inventory_2_outlined,
              label: l10n.shipments,
              onTap: () {
                _openPage(context, const ShipmentsScreen());
              },
            ),
          ),
          Expanded(
            child: _navItem(
              icon: Icons.support_agent_rounded,
              label: l10n.support,
              onTap: () {
                _openPage(context, const SupportScreen());
              },
            ),
          ),
          Expanded(
            child: _navItem(
              icon: Icons.person_outline_rounded,
              label: l10n.profile,
              onTap: () {
                _openPage(context, const ProfileScreen());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected ? primaryBlue : const Color(0xFF8B98AA),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                color: selected ? primaryBlue : const Color(0xFF8B98AA),
                fontSize: 9.4,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),

            const SizedBox(height: 4),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 22 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // DRAWER
  // ==========================================================

  Widget _buildDrawer(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget sectionTitle(String text) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF7E8A9A),
            fontSize: 9,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    Widget premiumItem({
      required IconData icon,
      required String title,
      String? subtitle,
      required VoidCallback onTap,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(17),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FF),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: primaryBlue, size: 21),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Color(0xFF8B97A8),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Color(0xFF9AA6B5),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Drawer(
      width: MediaQuery.of(context).size.width * .86,
      backgroundColor: const Color(0xFFF7F9FC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ======================================================
            // PREMIUM HEADER
            // ======================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // TAWAM LOGO
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Transform.scale(
                        scale: 1.65,
                        alignment: AlignmentDirectional.centerStart,
                        child: Image.asset(
                          'assets/images/tawam_logo.png',
                          width: 175,
                          height: 72,
                          fit: BoxFit.contain,
                          alignment: AlignmentDirectional.centerStart,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // LANGUAGE
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectLanguage(context),
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0xFFD7E3F1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.language_rounded,
                              size: 18,
                              color: Color(0xFF0B4F9C),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              LocaleController.languageBadge,
                              style: const TextStyle(
                                color: Color(0xFF062B55),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: Color(0xFF062B55),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFE8EDF4)),
            ),

            const SizedBox(height: 5),

            // ======================================================
            // MENU
            // ======================================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionTitle(l10n.shippingServices),

                    premiumItem(
                      icon: Icons.request_quote_outlined,
                      title: l10n.getAQuote,
                      subtitle: l10n.requestNewQuotation,
                      onTap: () {
                        Navigator.pop(context);
                        _openPage(context, const GetQuoteScreen());
                      },
                    ),

                    premiumItem(
                      icon: Icons.receipt_long_outlined,
                      title: l10n.myQuotes,
                      subtitle: l10n.viewQuotationHistory,
                      onTap: () {
                        Navigator.pop(context);
                        _openPage(context, const MyQuotesScreen());
                      },
                    ),

                    premiumItem(
                      icon: Icons.calendar_month_outlined,
                      title: l10n.createABooking,
                      subtitle: l10n.createNewBooking,
                      onTap: () {
                        Navigator.pop(context);
                        _openPage(context, const CreateBookingScreen());
                      },
                    ),

                    premiumItem(
                      icon: Icons.event_note_outlined,
                      title: l10n.myBookings,
                      subtitle: l10n.managePreviousBookings,
                      onTap: () {
                        Navigator.pop(context);
                        _openPage(context, const MyBookingsScreen());
                      },
                    ),

                    sectionTitle(l10n.shipmentManagement),

                    premiumItem(
                      icon: Icons.calculate_outlined,
                      title: l10n.volumeCalculator,
                      subtitle: l10n.calculateCargoVolume,
                      onTap: () {
                        Navigator.pop(context);
                        _openPage(context, const VolumeCalculatorScreen());
                      },
                    ),

                    premiumItem(
                      icon: Icons.location_searching_rounded,
                      title: l10n.shipmentTracking,
                      subtitle: l10n.trackShipmentStatus,
                      onTap: () {
                        Navigator.pop(context);
                        _openPage(context, const TrackShipmentScreen());
                      },
                    ),

                    premiumItem(
                      icon: Icons.local_shipping_outlined,
                      title: l10n.myShipments,
                      subtitle: l10n.viewAllActiveShipments,
                      onTap: () {
                        Navigator.pop(context);
                        _openPage(context, const ShipmentsScreen());
                      },
                    ),

                    premiumItem(
                      icon: Icons.description_outlined,
                      title: l10n.documents,
                      subtitle: l10n.shippingAndAccountDocuments,
                      onTap: () {
                        Navigator.pop(context);
                        _openPage(context, const ShippingDocumentsScreen());
                      },
                    ),
                    premiumItem(
                      icon: Icons.reviews_outlined,
                      title: l10n.customerReviews,
                      subtitle: l10n.seeWhatCustomersSay,
                      onTap: () async {
                        Navigator.pop(context);

                        final url = Uri.parse(
                          'https://share.google/tEGndxjEovXjiF15o',
                        );

                        final opened = await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );

                        if (!opened && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.couldNotOpenReviews),
                            ),
                          );
                        }
                      },
                    ),

                    premiumItem(
                      icon: Icons.language_rounded,
                      title: l10n.ourWebsite,
                      subtitle: l10n.visitTawamOnline,
                      onTap: () async {
                        Navigator.pop(context);

                        final url = Uri.parse('https://tawam-alshahin.ae/');

                        final opened = await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );

                        if (!opened && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.couldNotOpenWebsite),
                            ),
                          );
                        }
                      },
                    ),
                    sectionTitle(l10n.accountAndSupport),

                    premiumItem(
                      icon: Icons.support_agent_rounded,
                      title: l10n.support,
                      subtitle: l10n.contactLogisticsSupport,
                      onTap: () {
                        Navigator.pop(context);
                        _openPage(context, const SupportScreen());
                      },
                    ),

                    premiumItem(
                      icon: Icons.person_outline_rounded,
                      title: l10n.myAccount,
                      subtitle: l10n.profileAndSettings,
                      onTap: () {
                        Navigator.pop(context);
                        _openPage(context, const ProfileScreen());
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  title: Text(
                                    l10n.logOut,
                                    style: const TextStyle(
                                      color: Color(0xFF101B2D),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  content: Text(
                                    l10n.logOutConfirm,
                                    style: const TextStyle(
                                      color: Color(0xFF7E8A9A),
                                      fontSize: 13,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext, false);
                                      },
                                      child: Text(l10n.cancelUpper),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext, true);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF0B4F9C,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(l10n.logOutUpper),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (shouldLogout != true) return;

                            await FirebaseAuth.instance.signOut();

                            if (!context.mounted) return;

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          borderRadius: BorderRadius.circular(17),
                          child: Container(
                            width: double.infinity,
                            height: 54,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(17),
                              border: Border.all(
                                color: const Color(0xFFDCE5F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.logout_rounded,
                                  color: Color(0xFF0B4F9C),
                                  size: 21,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.logOut,
                                    style: const TextStyle(
                                      color: Color(0xFF101B2D),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF9AA6B5),
                                  size: 13,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          l10n.socialMedia,
                          style: const TextStyle(
                            color: Color(0xFF7E8A9A),
                            fontSize: 9,
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _socialButton(
                            FontAwesomeIcons.instagram,
                            'https://www.instagram.com/tawam.alshahin.transport/',
                          ),
                          _socialButton(
                            FontAwesomeIcons.facebookF,
                            'https://www.facebook.com/tawam.alshahin.transport/',
                          ),
                          _socialButton(
                            FontAwesomeIcons.xTwitter,
                            'https://x.com/tawam_alshahin',
                          ),
                          _socialButton(
                            FontAwesomeIcons.whatsapp,
                            'https://wa.me/971509106107',
                          ),
                          _socialButton(
                            FontAwesomeIcons.linkedinIn,
                            'https://www.linkedin.com/company/tawam-al-shahin-transport/about/',
                          ),
                          _socialButton(
                            FontAwesomeIcons.youtube,
                            'https://www.youtube.com/@tawam_alshahin',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(FaIconData icon, String link) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () async {
          final url = Uri.parse(link);

          final opened = await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );

          if (!opened) {
            if (!mounted) return;

            final l10n = AppLocalizations.of(context)!;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(l10n.couldNotOpenLink),
              ),
            );
          }
        },
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD8E4F2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D062B55),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: FaIcon(icon, color: const Color(0xFF0B4F9C), size: 17),
          ),
        ),
      ),
    );
  }
  // ==========================================================
  // RATE REQUEST SHEET
  // ==========================================================

  void _showRateRequestSheet(BuildContext context, String service) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        final serviceDisplayName = LocaleController.serviceLabel(l10n, service);

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  serviceDisplayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  l10n.requestRateForService,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            l10n.rateRequestWillConnect(serviceDisplayName),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.requestRate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================================
// MODELS
// ==========================================================

class _ServiceItem {
  const _ServiceItem({
    required this.storedName,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.icon,
    this.onTap,
  });

  final String storedName;
  final String title;
  final String subtitle;
  final String image;
  final IconData icon;
  final VoidCallback? onTap;
}

// ==========================================================
// TRUST ITEM
// ==========================================================
