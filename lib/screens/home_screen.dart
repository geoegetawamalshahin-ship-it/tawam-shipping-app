import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
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
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../app/utils/value_formatters.dart';
import '../locale_controller.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final NotificationController _notificationController =
      Get.find<NotificationController>();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      NotificationRouter.consumePending(context);
    });
  }

  @override
  void dispose() {
    NotificationRouter.homeReady = false;
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

    LocaleController.setLanguage(selected);
    await Get.updateLocale(LocaleController.locale.value);
    await LocaleController.saveLanguage(selected);
  }

  String _languageLabel(AppLocalizations l10n, String language) {
    return languageLabel(l10n, language);
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
                              color: Color(0xFF52657A),
                              fontSize: 12,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
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
                stream: _notificationController.watchNotifications(
                    _notificationController.currentUser?.uid ?? '__no_user__',
                  ),
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
                        PositionedDirectional(
                          top: -9,
                          end: -10,
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
            l10n.shippingServices,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textDark,
              fontSize: 27,
              height: 1.2,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.rateRequestSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF52657A),
              fontSize: 15.5,
              height: 1.4,
              fontWeight: FontWeight.w600,
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
            crossAxisSpacing: compact ? 10 : 12,
            mainAxisSpacing: compact ? 12 : 14,
            childAspectRatio: compact ? 1.24 : 1.29,
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
                        Color(0x14000000),
                        Color(0x33000000),
                        Color(0xEE00142C),
                      ],
                      stops: [0, .36, 1],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 10 : 12,
                    12,
                    compact ? 10 : 12,
                    compact ? 12 : 14,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        service.icon,
                        color: Colors.white,
                        size: compact ? 30 : 34,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 15 : 16.5,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          shadows: const [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                            Shadow(color: Color(0xFF001B35), blurRadius: 14),
                          ],
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
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    final items = [
      {
        'title': l10n.getAQuote,
        'icon': _QuickActionIconType.quote,
        'onTap': () {
          _openPage(context, const GetQuoteScreen());
        },
      },
      {
        'title': l10n.createABooking,
        'icon': _QuickActionIconType.booking,
        'onTap': () {
          _openPage(context, const CreateBookingScreen());
        },
      },
      {
        'title': l10n.volumeCalculator,
        'icon': _QuickActionIconType.volume,
        'onTap': () {
          _openPage(context, const VolumeCalculatorScreen());
        },
      },
      {
        'title': l10n.shipmentTracking,
        'icon': _QuickActionIconType.tracking,
        'onTap': () {
          _openPage(context, const TrackShipmentScreen());
        },
      },
      {
        'title': l10n.myQuotes,
        'icon': _QuickActionIconType.quotes,
        'onTap': () {
          _openPage(context, const MyQuotesScreen());
        },
      },
      {
        'title': l10n.myBookings,
        'icon': _QuickActionIconType.bookings,
        'onTap': () {
          _openPage(context, const MyBookingsScreen());
        },
      },
    ];

    if (isTablet) {
      items.addAll([
        {
          'title': l10n.customerReviews,
          'icon': _QuickActionIconType.reviews,
          'onTap': () {
            _openExternalUrl(
              'https://share.google/tEGndxjEovXjiF15o',
            );
          },
        },
        {
          'title': l10n.ourWebsite,
          'icon': _QuickActionIconType.website,
          'onTap': () {
            _openExternalUrl('https://tawam-alshahin.ae/');
          },
        },
      ]);
    }

    final grid = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: isTablet ? 1.18 : .86,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item['onTap'] as VoidCallback,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFBFDFF)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD5E3F1), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: .08),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFEAF4FF), Color(0xFFF4F8FD)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD8EAFB),
                        width: .9,
                      ),
                    ),
                    child: _QuickActionLineIcon(
                      type: item['icon'] as _QuickActionIconType,
                      color: const Color(0xFF07569E),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['title'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 11.7,
                      height: 1.18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!isTablet) return grid;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: grid,
      ),
    );
  }

  Future<void> _openExternalUrl(String link) async {
    final opened = await launchUrl(
      Uri.parse(link),
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.couldNotOpenLink),
        ),
      );
    }
  }

  // ==========================================================
  // BOTTOM NAVIGATION
  // ==========================================================

  Widget _buildBottomNavigation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 68,
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
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
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 23,
              color: selected ? primaryBlue : const Color(0xFF8B98AA),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? primaryBlue : const Color(0xFF8B98AA),
                  fontSize: 11.5,
                  height: 1.1,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 22 : 0,
              height: 3,
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
                            SnackBar(content: Text(l10n.couldNotOpenReviews)),
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
                            SnackBar(content: Text(l10n.couldNotOpenWebsite)),
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

                            await _authController.signOut();

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
// PREMIUM QUICK ACTION LINE ICONS
// ==========================================================

enum _QuickActionIconType {
  quote,
  booking,
  volume,
  tracking,
  quotes,
  bookings,
  reviews,
  website,
}

class _QuickActionLineIcon extends StatelessWidget {
  const _QuickActionLineIcon({
    required this.type,
    required this.color,
    this.size = 40,
  });

  final _QuickActionIconType type;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _QuickActionIconPainter(type: type, color: color),
      ),
    );
  }
}

class _QuickActionIconPainter extends CustomPainter {
  const _QuickActionIconPainter({required this.type, required this.color});

  final _QuickActionIconType type;
  final Color color;

  Paint get _line => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.45
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _whiteMask => Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 48, size.height / 48);

    switch (type) {
      case _QuickActionIconType.quote:
        _drawQuote(canvas);
        break;
      case _QuickActionIconType.booking:
        _drawBooking(canvas);
        break;
      case _QuickActionIconType.volume:
        _drawVolume(canvas);
        break;
      case _QuickActionIconType.tracking:
        _drawTracking(canvas);
        break;
      case _QuickActionIconType.quotes:
        _drawMyQuotes(canvas);
        break;
      case _QuickActionIconType.bookings:
        _drawMyBookings(canvas);
        break;
      case _QuickActionIconType.reviews:
        _drawReviews(canvas);
        break;
      case _QuickActionIconType.website:
        _drawWebsite(canvas);
        break;
    }

    canvas.restore();
  }

  void _drawQuote(Canvas canvas) {
    final line = _line;
    final document = RRect.fromRectAndRadius(
      const Rect.fromLTWH(7, 5, 29, 37),
      const Radius.circular(3),
    );
    canvas.drawRRect(document, line);

    final fold = Path()
      ..moveTo(27, 5)
      ..lineTo(36, 14)
      ..lineTo(27, 14)
      ..close();
    canvas.drawPath(fold, line);
    canvas.drawLine(const Offset(12, 19), const Offset(29, 19), line);
    canvas.drawLine(const Offset(12, 24), const Offset(27, 24), line);
    canvas.drawLine(const Offset(12, 29), const Offset(23, 29), line);

    canvas.drawCircle(const Offset(35, 34), 8.5, _whiteMask);
    canvas.drawCircle(const Offset(35, 34), 8.5, line);
    _drawDollar(canvas, const Offset(35, 34), line);
  }

  void _drawBooking(Canvas canvas) {
    final line = _line;
    _drawCalendarBase(canvas, const Rect.fromLTWH(5, 8, 38, 34), line);

    for (final x in <double>[12, 20, 28, 36]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, 23), width: 3.6, height: 3.6),
          const Radius.circular(.7),
        ),
        line,
      );
    }
    for (final x in <double>[12, 20, 28]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, 31), width: 3.6, height: 3.6),
          const Radius.circular(.7),
        ),
        line,
      );
    }

    _drawRoundBadge(canvas, const Offset(38, 36), line);
    canvas.drawLine(const Offset(34.5, 36), const Offset(41.5, 36), line);
    canvas.drawLine(const Offset(38, 32.5), const Offset(38, 39.5), line);
  }

  void _drawVolume(Canvas canvas) {
    final line = _line;
    final calculator = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5, 5, 28, 38),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(calculator, line);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 10, 18, 7),
        const Radius.circular(1.2),
      ),
      line,
    );

    for (final y in <double>[23, 30, 37]) {
      for (final x in <double>[11, 18, 25]) {
        canvas.drawCircle(Offset(x, y), 1.15, line);
      }
    }

    canvas.drawCircle(const Offset(37, 28), 7.5, _whiteMask);
    final box = Path()
      ..moveTo(30, 25)
      ..lineTo(37, 21)
      ..lineTo(44, 25)
      ..lineTo(37, 29)
      ..close();
    canvas.drawPath(box, line);
    canvas.drawLine(const Offset(30, 25), const Offset(30, 34), line);
    canvas.drawLine(const Offset(44, 25), const Offset(44, 34), line);
    canvas.drawLine(const Offset(30, 34), const Offset(37, 39), line);
    canvas.drawLine(const Offset(44, 34), const Offset(37, 39), line);
    canvas.drawLine(const Offset(37, 29), const Offset(37, 39), line);
  }

  void _drawTracking(Canvas canvas) {
    final line = _line;
    final route = Path()
      ..moveTo(10, 15)
      ..cubicTo(16, 19, 23, 8, 31, 13)
      ..cubicTo(34, 15, 36, 14, 39, 11);
    canvas.drawPath(route, line);
    _drawPin(canvas, const Offset(8, 10), line);
    _drawPin(canvas, const Offset(40, 8), line);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(5, 25, 25, 11),
        const Radius.circular(2),
      ),
      line,
    );
    final cab = Path()
      ..moveTo(30, 27)
      ..lineTo(37, 27)
      ..lineTo(43, 33)
      ..lineTo(43, 36)
      ..lineTo(30, 36)
      ..close();
    canvas.drawPath(cab, line);
    canvas.drawLine(const Offset(35, 28), const Offset(35, 33), line);
    canvas.drawLine(const Offset(35, 33), const Offset(41, 33), line);
    canvas.drawCircle(const Offset(13, 38), 3, _whiteMask);
    canvas.drawCircle(const Offset(13, 38), 3, line);
    canvas.drawCircle(const Offset(36, 38), 3, _whiteMask);
    canvas.drawCircle(const Offset(36, 38), 3, line);
  }

  void _drawMyQuotes(Canvas canvas) {
    final line = _line;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(15, 5, 27, 31),
        const Radius.circular(3),
      ),
      line,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, 12, 29, 31),
        const Radius.circular(3),
      ),
      _whiteMask,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6, 12, 29, 31),
        const Radius.circular(3),
      ),
      line,
    );
    canvas.drawLine(const Offset(12, 20), const Offset(29, 20), line);
    canvas.drawLine(const Offset(12, 25), const Offset(26, 25), line);
    canvas.drawLine(const Offset(12, 30), const Offset(23, 30), line);

    _drawRoundBadge(canvas, const Offset(36.5, 36), line);
    canvas.drawLine(const Offset(33, 36), const Offset(35.5, 38.5), line);
    canvas.drawLine(const Offset(35.5, 38.5), const Offset(40.5, 33.5), line);
  }

  void _drawMyBookings(Canvas canvas) {
    final line = _line;
    _drawCalendarBase(canvas, const Rect.fromLTWH(5, 7, 38, 35), line);
    canvas.drawLine(const Offset(11, 24), const Offset(37, 24), line);
    canvas.drawLine(const Offset(11, 30), const Offset(25, 30), line);
    canvas.drawLine(const Offset(11, 36), const Offset(22, 36), line);

    _drawRoundBadge(canvas, const Offset(37, 35), line);
    canvas.drawLine(const Offset(33.5, 35), const Offset(36, 37.5), line);
    canvas.drawLine(const Offset(36, 37.5), const Offset(41, 32.5), line);
  }

  void _drawReviews(Canvas canvas) {
    final line = _line;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(5, 7, 38, 29),
        const Radius.circular(5),
      ),
      line,
    );
    final tail = Path()
      ..moveTo(14, 36)
      ..lineTo(11, 43)
      ..lineTo(22, 36);
    canvas.drawPath(tail, line);
    for (final x in <double>[13, 20, 27, 34]) {
      canvas.drawCircle(Offset(x, 21), 2.2, line);
    }
  }

  void _drawWebsite(Canvas canvas) {
    final line = _line;
    canvas.drawCircle(const Offset(24, 24), 19, line);
    canvas.drawOval(const Rect.fromLTWH(15, 5, 18, 38), line);
    canvas.drawLine(const Offset(5, 24), const Offset(43, 24), line);
    canvas.drawArc(
      const Rect.fromLTWH(7, 13, 34, 22),
      0,
      3.14159,
      false,
      line,
    );
    canvas.drawArc(
      const Rect.fromLTWH(7, 13, 34, 22),
      3.14159,
      3.14159,
      false,
      line,
    );
  }

  void _drawCalendarBase(Canvas canvas, Rect rect, Paint line) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      line,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top + 10),
      Offset(rect.right, rect.top + 10),
      line,
    );
    canvas.drawLine(
      Offset(rect.left + 10, rect.top - 3),
      Offset(rect.left + 10, rect.top + 5),
      line,
    );
    canvas.drawLine(
      Offset(rect.right - 10, rect.top - 3),
      Offset(rect.right - 10, rect.top + 5),
      line,
    );
  }

  void _drawRoundBadge(Canvas canvas, Offset center, Paint line) {
    canvas.drawCircle(center, 7.5, _whiteMask);
    canvas.drawCircle(center, 7.5, line);
  }

  void _drawDollar(Canvas canvas, Offset center, Paint line) {
    canvas.drawLine(
      Offset(center.dx, center.dy - 5),
      Offset(center.dx, center.dy + 5),
      line,
    );
    final dollar = Path()
      ..moveTo(center.dx + 3, center.dy - 3)
      ..cubicTo(
        center.dx + 1,
        center.dy - 5,
        center.dx - 3,
        center.dy - 4,
        center.dx - 3,
        center.dy - 1.5,
      )
      ..cubicTo(
        center.dx - 3,
        center.dy + 1,
        center.dx + 3,
        center.dy,
        center.dx + 3,
        center.dy + 3,
      )
      ..cubicTo(
        center.dx + 3,
        center.dy + 5,
        center.dx - 1,
        center.dy + 5,
        center.dx - 3,
        center.dy + 3,
      );
    canvas.drawPath(dollar, line);
  }

  void _drawPin(Canvas canvas, Offset center, Paint line) {
    final pin = Path()
      ..moveTo(center.dx, center.dy + 8)
      ..cubicTo(
        center.dx - 1.5,
        center.dy + 5,
        center.dx - 5,
        center.dy + 2,
        center.dx - 5,
        center.dy - 1,
      )
      ..cubicTo(
        center.dx - 5,
        center.dy - 4,
        center.dx - 3,
        center.dy - 6,
        center.dx,
        center.dy - 6,
      )
      ..cubicTo(
        center.dx + 3,
        center.dy - 6,
        center.dx + 5,
        center.dy - 4,
        center.dx + 5,
        center.dy - 1,
      )
      ..cubicTo(
        center.dx + 5,
        center.dy + 2,
        center.dx + 1.5,
        center.dy + 5,
        center.dx,
        center.dy + 8,
      )
      ..close();
    canvas.drawPath(pin, _whiteMask);
    canvas.drawPath(pin, line);
    canvas.drawCircle(Offset(center.dx, center.dy - 1), 1.7, line);
  }

  @override
  bool shouldRepaint(covariant _QuickActionIconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}

// ==========================================================
// TRUST ITEM
// ==========================================================
