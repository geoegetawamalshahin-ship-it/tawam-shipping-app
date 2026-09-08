import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app/widgets/shipping_form_widgets.dart';
import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
import 'my_quotes_screen.dart';

class InternationalMovingScreen extends StatefulWidget {
  const InternationalMovingScreen({super.key});

  @override
  State<InternationalMovingScreen> createState() =>
      _InternationalMovingScreenState();
}

class _InternationalMovingScreenState extends State<InternationalMovingScreen> {
  // =========================================================
  // BRAND
  // =========================================================

  static const Color _deepBlue = Color(0xFF062B55);
  static const Color _primaryBlue = Color(0xFF0B4F9C);

  static const Color _pageBg = Colors.white;
  static const Color _softBlue = Color(0xFFEAF3FF);
  static const Color _softGrey = Color(0xFFF7F9FC);
  static const Color _border = Color(0xFFE2EAF2);

  static const Color _textDark = Color(0xFF101B2D);
  static const Color _textGrey = Color(0xFF7E8A9A);
  static const Color _success = Color(0xFF16765C);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // =========================================================
  // CONTROLLERS
  // =========================================================

  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final TextEditingController _roomsController = TextEditingController(
    text: '2',
  );

  final TextEditingController _originFloorController = TextEditingController(
    text: '0',
  );

  final TextEditingController _destinationFloorController =
      TextEditingController(text: '0');

  final TextEditingController _boxesController = TextEditingController(
    text: '10',
  );

  final TextEditingController _largeItemsController = TextEditingController(
    text: '5',
  );

  final TextEditingController _volumeController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  // =========================================================
  // MOVING OPTIONS
  // =========================================================

  String _moveType = 'Home Move';
  String _propertyType = 'Apartment';
  String _serviceMode = 'Door to Door';

  DateTime? _movingDate;

  bool _originElevator = true;
  bool _destinationElevator = true;

  bool _packingRequired = true;
  bool _unpackingRequired = false;
  bool _furnitureDisassembly = true;
  bool _storageRequired = false;
  bool _insuranceRequested = false;

  final Set<String> _specialItems = <String>{};
  final Set<String> _additionalServices = <String>{};

  final List<String> _propertyTypes = const [
    'Apartment',
    'Villa',
    'Townhouse',
    'Studio',
    'Office',
    'Warehouse',
    'Other',
  ];

  final List<String> _serviceModes = const [
    'Door to Door',
    'Door to Port',
    'Port to Door',
  ];

  final List<String> _specialItemOptions = const [
    'Piano',
    'Safe',
    'Artwork',
    'Large Appliances',
    'Fragile Items',
    'High-Value Items',
  ];

  final List<String> _additionalServiceOptions = const [
    'Customs Clearance',
    'Packing Materials',
    'Furniture Reassembly',
    'Debris Removal',
  ];

  // =========================================================
  // CUSTOMER PROFILE
  // =========================================================

  bool _loadingProfile = true;
  bool _submitting = false;

  String _customerName = '';
  String _customerEmail = '';
  String _customerPhone = '';
  String _customerCompany = '';
  String _customerCountry = '';

  // =========================================================
  // INIT / DISPOSE
  // =========================================================

  @override
  void initState() {
    super.initState();

    _roomsController.addListener(_refreshSummary);
    _boxesController.addListener(_refreshSummary);
    _largeItemsController.addListener(_refreshSummary);
    _volumeController.addListener(_refreshSummary);

    _loadCustomerProfile();
  }

  @override
  void dispose() {
    _roomsController.removeListener(_refreshSummary);
    _boxesController.removeListener(_refreshSummary);
    _largeItemsController.removeListener(_refreshSummary);
    _volumeController.removeListener(_refreshSummary);

    _originController.dispose();
    _destinationController.dispose();
    _roomsController.dispose();
    _originFloorController.dispose();
    _destinationFloorController.dispose();
    _boxesController.dispose();
    _largeItemsController.dispose();
    _volumeController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  void _refreshSummary() {
    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // CUSTOMER AUTO-FILL
  // =========================================================

  Future<void> _loadCustomerProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _loadingProfile = false;
        });
      }
      return;
    }

    String name = user.displayName?.trim() ?? '';
    String email = user.email?.trim() ?? '';
    String phone = user.phoneNumber?.trim() ?? '';
    String company = '';
    String country = '';

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = snapshot.data() ?? <String, dynamic>{};

      name = _firstNonEmpty([
        data['name'],
        data['fullName'],
        data['displayName'],
        name,
      ]);

      email = _firstNonEmpty([data['email'], email]);

      phone = _firstNonEmpty([
        data['phone'],
        data['phoneNumber'],
        data['mobile'],
        phone,
      ]);

      company = _firstNonEmpty([data['companyName'], data['company']]);

      country = _firstNonEmpty([data['country'], data['countryName']]);
    } catch (_) {
      // Firebase Auth data remains as fallback.
    }

    if (!mounted) return;

    setState(() {
      _customerName = name.isEmpty
          ? AppLocalizations.of(context)!.tawamCustomer
          : name;
      _customerEmail = email;
      _customerPhone = phone;
      _customerCompany = company;
      _customerCountry = country;
      _loadingProfile = false;
    });
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 38),
                  children: [
                    _buildHero(),

                    const SizedBox(height: 20),

                    _buildTrustBar(),

                    const SizedBox(height: 30),

                    _sectionTitle(
                      number: '01',
                      icon: Icons.route_rounded,
                      title: l10n.shipmentRoute,
                      subtitle: l10n.tellUsWhereMoving,
                    ),

                    const SizedBox(height: 13),

                    _buildRouteSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '02',
                      icon: Icons.home_work_outlined,
                      title: l10n.moveProfile,
                      subtitle: l10n.moveProfileHelp,
                    ),

                    const SizedBox(height: 13),

                    _buildMoveProfileSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '03',
                      icon: Icons.inventory_2_outlined,
                      title: l10n.inventoryEstimate,
                      subtitle: l10n.inventoryEstimateHelp,
                    ),

                    const SizedBox(height: 13),

                    _buildInventorySection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '04',
                      icon: Icons.chair_outlined,
                      title: l10n.specialItems,
                      subtitle: l10n.selectSpecialPackingItems,
                    ),

                    const SizedBox(height: 13),

                    _buildSpecialItemsSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '05',
                      icon: Icons.design_services_outlined,
                      title: l10n.movingServices,
                      subtitle: l10n.buildMovingPackage,
                    ),

                    const SizedBox(height: 13),

                    _buildMovingServicesSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '06',
                      icon: Icons.add_business_outlined,
                      title: l10n.additionalServices,
                      subtitle: l10n.addOptionalLogistics,
                    ),

                    const SizedBox(height: 13),

                    _buildAdditionalServicesSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '07',
                      icon: Icons.person_outline_rounded,
                      title: l10n.contactDetails,
                      subtitle: l10n.contactFilledFromAccount,
                    ),

                    const SizedBox(height: 13),

                    _buildCustomerSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '08',
                      icon: Icons.notes_rounded,
                      title: l10n.specialInstructions,
                      subtitle: l10n.anythingTeamShouldKnow,
                    ),

                    const SizedBox(height: 13),

                    _buildNotesSection(),

                    const SizedBox(height: 28),

                    _buildSummary(),

                    const SizedBox(height: 22),

                    _buildSubmitButton(),

                    const SizedBox(height: 13),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: _textGrey,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            l10n.infoSubmittedSecurely,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _textGrey,
                              fontSize: 9.5,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ShippingFormHeader(
      title: l10n.movingQuote,
      subtitle: l10n.officialRateRequest,
      trailingIcon: Icons.home_work_outlined,
      onBack: () => Navigator.pop(context),
      borderColor: _border,
      shadowColor: _deepBlue,
      leadingBackgroundColor: _softGrey,
      leadingIconColor: _deepBlue,
      trailingBackgroundColor: _softBlue,
      trailingIconColor: _primaryBlue,
      titleColor: _textDark,
      titleFontSize: 19,
      subtitleFontSize: 8.2,
      subtitleLetterSpacing: .95,
      trailingIconSize: 23,
    );
  }

  // =========================================================
  // HERO
  // =========================================================

  Widget _buildHero() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 235,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .13),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/moving.png', fit: BoxFit.cover),

          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x08000000),
                  Color(0x55062B55),
                  Color(0xEB062B55),
                ],
                stops: [0, .45, 1],
              ),
            ),
          ),

          PositionedDirectional(
            start: 18,
            top: 17,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .94),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.public_rounded, color: _primaryBlue, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    l10n.globalRelocation,
                    style: const TextStyle(
                      color: _deepBlue,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          PositionedDirectional(
            start: 19,
            end: 19,
            bottom: 19,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.movingHeroTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.55,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.movingHeroSubtitle,
                  style: const TextStyle(
                    color: Color(0xFFE2EDF8),
                    fontSize: 10.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBar() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingTrustBar(
      borderColor: _border,
      children: [
          Expanded(
            child: ShippingTrustItem(
              icon: Icons.inventory_2_outlined,
              title: l10n.badgePack,
              subtitle: l10n.professionalPacking,
              primaryColor: _primaryBlue,
              titleColor: _textDark,
              subtitleColor: _textGrey,
            ),
          ),
          const ShippingTrustDivider(color: _border),
          Expanded(
            child: ShippingTrustItem(
              icon: Icons.public_rounded,
              title: l10n.badgeGlobal,
              subtitle: l10n.serviceInternationalMoving,
              primaryColor: _primaryBlue,
              titleColor: _textDark,
              subtitleColor: _textGrey,
            ),
          ),
          const ShippingTrustDivider(color: _border),
          Expanded(
            child: ShippingTrustItem(
              icon: Icons.home_rounded,
              title: 'D2D',
              subtitle: l10n.doorToDoor,
              primaryColor: _primaryBlue,
              titleColor: _textDark,
              subtitleColor: _textGrey,
            ),
          ),
      ],
    );
  }

  // =========================================================
  // SECTION TITLE
  // =========================================================

  Widget _sectionTitle({
    required String number,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ShippingSectionTitle(
      number: number,
      icon: icon,
      title: title,
      subtitle: subtitle,
      primaryColor: _primaryBlue,
      softColor: _softBlue,
      titleColor: _textDark,
      subtitleColor: _textGrey,
    );
  }

  // =========================================================
  // ROUTE
  // =========================================================

  Widget _buildRouteSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(

      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        children: [
          _textField(
            controller: _originController,
            label: l10n.origin,
            hint: l10n.cityBuildingCurrent,
            icon: Icons.home_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterOrigin;
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          Container(
            height: 36,
            alignment: Alignment.center,
            child: Row(
              children: [
                const Expanded(child: Divider(color: _border)),

                Container(
                  width: 34,
                  height: 34,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _softBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: _border),
                  ),
                  child: const Icon(
                    Icons.south_rounded,
                    color: _primaryBlue,
                    size: 17,
                  ),
                ),

                const Expanded(child: Divider(color: _border)),
              ],
            ),
          ),

          const SizedBox(height: 14),

          _textField(
            controller: _destinationController,
            label: l10n.destination,
            hint: l10n.cityBuildingDestination,
            icon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterDestination;
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          _dropdown(
            label: l10n.serviceMode,
            icon: Icons.route_outlined,
            value: _serviceMode,
            items: _serviceModes,
            itemLabel: (item) => _optionLabel(l10n, item),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _serviceMode = value;
              });
            },
          ),

          const SizedBox(height: 16),

          _dateSelector(),
        ],
      ),
    );
  }

  Widget _dateSelector() {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: _selectMovingDate,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        decoration: BoxDecoration(
          color: _softGrey,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: _softBlue,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: _primaryBlue,
                size: 19,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.preferredPickupDate,
                    style: TextStyle(
                      color: _textGrey,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _movingDate == null
                        ? l10n.selectADate
                        : _formatDate(_movingDate!),
                    style: TextStyle(
                      color: _movingDate == null ? _textGrey : _textDark,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _textGrey,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // MOVE PROFILE
  // =========================================================

  Widget _buildMoveProfileSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(

      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.moveType,
            style: const TextStyle(
              color: _textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              Expanded(
                child: _moveTypeButton(
                  value: 'Home Move',
                  icon: Icons.home_rounded,
                  title: l10n.homeMoveShort,
                  subtitle: l10n.householdMove,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _moveTypeButton(
                  value: 'Office Move',
                  icon: Icons.business_rounded,
                  title: l10n.office,
                  subtitle: l10n.businessMove,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _moveTypeButton(
                  value: 'Personal Effects',
                  icon: Icons.inventory_2_rounded,
                  title: l10n.personalShort,
                  subtitle: l10n.personalEffectsLower,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _dropdown(
            label: l10n.propertyType,
            icon: Icons.apartment_rounded,
            value: _propertyType,
            items: _propertyTypes,
            itemLabel: (item) => _optionLabel(l10n, item),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _propertyType = value;
              });
            },
          ),

          const SizedBox(height: 14),

          _textField(
            controller: _roomsController,
            label: _moveType == 'Office Move'
                ? l10n.roomsWorkAreas
                : l10n.bedroomsRooms,
            hint: '2',
            icon: Icons.bed_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              final count = int.tryParse(value?.trim() ?? '');

              if (count == null || count <= 0) {
                return l10n.enterNumberOfRooms;
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          Text(
            l10n.originAccess,
            style: const TextStyle(
              color: _textDark,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 11),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _textField(
                  controller: _originFloorController,
                  label: l10n.floor,
                  hint: '0',
                  icon: Icons.layers_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _compactToggle(
                  title: l10n.elevator,
                  value: _originElevator,
                  onChanged: (value) {
                    setState(() {
                      _originElevator = value;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            l10n.destinationAccess,
            style: const TextStyle(
              color: _textDark,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 11),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _textField(
                  controller: _destinationFloorController,
                  label: l10n.floor,
                  hint: '0',
                  icon: Icons.layers_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _compactToggle(
                  title: l10n.elevator,
                  value: _destinationElevator,
                  onChanged: (value) {
                    setState(() {
                      _destinationElevator = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moveTypeButton({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _moveType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _moveType = value;

          if (_moveType == 'Office Move' &&
              !['Office', 'Warehouse', 'Other'].contains(_propertyType)) {
            _propertyType = 'Office';
          }

          if (_moveType != 'Office Move' &&
              ['Office', 'Warehouse'].contains(_propertyType)) {
            _propertyType = 'Apartment';
          }
        });
      },
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? _deepBlue : _softGrey,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selected ? _deepBlue : _border),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : _primaryBlue, size: 20),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : _textDark,
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? const Color(0xFFD9E7F5) : _textGrey,
                fontSize: 7.2,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: _softGrey,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.elevator_outlined,
              color: _primaryBlue,
              size: 17,
            ),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _textDark,
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Switch(
            value: value,
            activeThumbColor: _primaryBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // =========================================================
  // INVENTORY
  // =========================================================

  Widget _buildInventorySection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(

      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _textField(
                  controller: _boxesController,
                  label: l10n.estimatedBoxes,
                  hint: '10',
                  icon: Icons.inventory_outlined,
                  keyboardType: TextInputType.number,
                  validator: _nonNegativeIntegerValidator,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _textField(
                  controller: _largeItemsController,
                  label: l10n.largeItems,
                  hint: '5',
                  icon: Icons.chair_outlined,
                  keyboardType: TextInputType.number,
                  validator: _nonNegativeIntegerValidator,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _textField(
            controller: _volumeController,
            label: l10n.estimatedVolume,
            hint: l10n.optionalTeamCanConfirm,
            suffix: 'CBM',
            icon: Icons.view_in_ar_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return null;
              }

              final volume = double.tryParse(value.trim());

              if (volume == null || volume <= 0) {
                return l10n.enterValidVolume;
              }

              return null;
            },
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: _primaryBlue,
                  size: 17,
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    _planningNote(l10n),
                    style: const TextStyle(
                      color: _primaryBlue,
                      fontSize: 9.2,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SPECIAL ITEMS
  // =========================================================

  Widget _buildSpecialItemsSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(

      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.itemsRequiringExtraCare,
            style: const TextStyle(
              color: _textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            l10n.selectAllThatApply,
            style: const TextStyle(color: _textGrey, fontSize: 9.5),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 9,
            children: _specialItemOptions.map((item) {
              final selected = _specialItems.contains(item);

              return FilterChip(
                label: Text(_optionLabel(l10n, item)),
                selected: selected,
                showCheckmark: true,
                checkmarkColor: Colors.white,
                selectedColor: _deepBlue,
                backgroundColor: _softGrey,
                side: BorderSide(color: selected ? _deepBlue : _border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : _textDark,
                  fontSize: 9.3,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _specialItems.add(item);
                    } else {
                      _specialItems.remove(item);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // MOVING SERVICES
  // =========================================================

  Widget _buildMovingServicesSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(

      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        children: [
          _optionSwitch(
            icon: Icons.inventory_2_outlined,
            title: l10n.packing,
            subtitle: l10n.movingTeamPacksItems,
            value: _packingRequired,
            onChanged: (value) {
              setState(() {
                _packingRequired = value;
              });
            },
          ),

          const ShippingContactDivider(color: _border),

          _optionSwitch(
            icon: Icons.unarchive_outlined,
            title: l10n.unpackingService,
            subtitle: l10n.requestUnpacking,
            value: _unpackingRequired,
            onChanged: (value) {
              setState(() {
                _unpackingRequired = value;
              });
            },
          ),

          const ShippingContactDivider(color: _border),

          _optionSwitch(
            icon: Icons.handyman_outlined,
            title: l10n.furnitureDisassembly,
            subtitle: l10n.dismantlingSupport,
            value: _furnitureDisassembly,
            onChanged: (value) {
              setState(() {
                _furnitureDisassembly = value;
              });
            },
          ),

          const ShippingContactDivider(color: _border),

          _optionSwitch(
            icon: Icons.warehouse_outlined,
            title: l10n.temporaryStorage,
            subtitle: l10n.requestStorageBeforeDelivery,
            value: _storageRequired,
            onChanged: (value) {
              setState(() {
                _storageRequired = value;
              });
            },
          ),

          const ShippingContactDivider(color: _border),

          _optionSwitch(
            icon: Icons.shield_outlined,
            title: l10n.cargoInsurance,
            subtitle: l10n.requestInsuranceHint,
            value: _insuranceRequested,
            onChanged: (value) {
              setState(() {
                _insuranceRequested = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalServicesSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(

      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectServices,
            style: const TextStyle(
              color: _textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            l10n.youCanChooseMoreThanOne,
            style: const TextStyle(color: _textGrey, fontSize: 9.5),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 9,
            children: _additionalServiceOptions.map((service) {
              final selected = _additionalServices.contains(service);

              return FilterChip(
                label: Text(_optionLabel(l10n, service)),
                selected: selected,
                showCheckmark: true,
                checkmarkColor: Colors.white,
                selectedColor: _primaryBlue,
                backgroundColor: _softGrey,
                side: BorderSide(color: selected ? _primaryBlue : _border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : _textDark,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _additionalServices.add(service);
                    } else {
                      _additionalServices.remove(service);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CUSTOMER
  // =========================================================

  Widget _buildCustomerSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(

      borderColor: _border,

      shadowColor: _deepBlue,
      child: ShippingCustomerDetails(
        loading: _loadingProfile,
        verifiedMessage: l10n.contactFilledFromAccount,
        fullNameLabel: l10n.fullName,
        phoneLabel: l10n.phoneNumber,
        emailLabel: l10n.emailAddress,
        companyLabel: l10n.company,
        countryLabel: l10n.country,
        notProvidedLabel: l10n.notProvided,
        customerName: _customerName,
        customerPhone: _customerPhone,
        customerEmail: _customerEmail,
        customerCompany: _customerCompany,
        customerCountry: _customerCountry,
        primaryColor: _primaryBlue,
        softColor: _softBlue,
        borderColor: _border,
        successColor: _success,
        textColor: _textDark,
        labelColor: _textGrey,
      ),
    );
  }

  // =========================================================
  // NOTES
  // =========================================================

  Widget _buildNotesSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(

      borderColor: _border,

      shadowColor: _deepBlue,
      child: ShippingNotesField(
        controller: _notesController,
        hintText: l10n.specialHandlingHint,
        textColor: _textDark,
        hintColor: const Color(0xFFA1ACB9),
        primaryColor: _primaryBlue,
        fillColor: _softGrey,
        borderColor: _border,
      ),
    );
  }

  // =========================================================
  // SUMMARY
  // =========================================================

  Widget _buildSummary() {
    final l10n = AppLocalizations.of(context)!;

    final origin = _originController.text.trim().isEmpty
        ? l10n.origin
        : _originController.text.trim();

    final destination = _destinationController.text.trim().isEmpty
        ? l10n.destination
        : _destinationController.text.trim();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _deepBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .15),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -30,
            child: Icon(
              Icons.home_work_rounded,
              size: 125,
              color: Colors.white.withValues(alpha: .04),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.fact_check_outlined,
                    color: Colors.white,
                    size: 19,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    l10n.moveSummary,
                    style: const TextStyle(
                      color: Color(0xFFCFE1F3),
                      fontSize: 8.5,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      origin,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 9),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF76B7FF),
                      size: 20,
                    ),
                  ),

                  Expanded(
                    child: Text(
                      destination,
                      maxLines: 2,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _summaryBadge(
                    Icons.public_rounded,
                    LocaleController.serviceLabel(l10n, 'International Moving'),
                  ),

                  _summaryBadge(
                    Icons.home_work_outlined,
                    _optionLabel(l10n, _moveType),
                  ),

                  _summaryBadge(
                    Icons.apartment_rounded,
                    _optionLabel(l10n, _propertyType),
                  ),

                  _summaryBadge(
                    Icons.bed_outlined,
                    _roomsCount == 1
                        ? l10n.roomSingular(_roomsCount)
                        : l10n.roomPlural(_roomsCount),
                  ),

                  _summaryBadge(
                    Icons.inventory_2_outlined,
                    '$_boxCount ${l10n.boxes}',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.design_services_outlined,
                      color: Color(0xFF7EC0FF),
                      size: 19,
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        _serviceSummaryText(l10n),
                        style: const TextStyle(
                          color: Color(0xFFD9E8F6),
                          fontSize: 9.4,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    if (_estimatedVolume > 0)
                      Text(
                        '${_formatNumber(_estimatedVolume)} CBM',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 9),

              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF7EC0FF),
                      size: 18,
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        _estimatedVolume > 0
                            ? l10n.finalSurveyCanConfirm
                            : l10n.relocationTeamConfirmVolume,
                        style: const TextStyle(
                          color: Color(0xFFD9E8F6),
                          fontSize: 9.2,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF79BFFF), size: 13),

          const SizedBox(width: 6),

          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SUBMIT
  // =========================================================

  Widget _buildSubmitButton() {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submitQuote,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryBlue.withValues(alpha: .55),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: _submitting
            ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.request_quote_outlined, size: 21),

                  SizedBox(width: 10),

                  Text(
                    l10n.submitQuoteRequest,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .35,
                    ),
                  ),

                  SizedBox(width: 10),

                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Future<void> _submitQuote() async {
    if (_submitting) return;

    FocusScope.of(context).unfocus();

    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      _showMessage(l10n.pleaseCompleteShipmentInfo, error: true);
      return;
    }

    if (_movingDate == null) {
      _showMessage(l10n.pleaseSelectPickupDate, error: true);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(l10n.pleaseSignInBeforeQuote, error: true);
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final now = DateTime.now();

      final quoteNumber =
          'QR-${now.year}${_two(now.month)}${_two(now.day)}-'
          '${_two(now.hour)}${_two(now.minute)}${_two(now.second)}';

      final propertyDisplay = '$_moveType • $_propertyType';

      final quoteData = <String, dynamic>{
        // -------------------------------------------------
        // CUSTOMER
        // -------------------------------------------------
        'userId': user.uid,
        'customerName': _customerName,
        'customerEmail': _customerEmail,
        'customerPhone': _customerPhone,
        'customerCompany': _customerCompany,
        'customerCountry': _customerCountry,

        // Compatibility
        'fullName': _customerName,
        'email': _customerEmail,
        'phone': _customerPhone,

        // -------------------------------------------------
        // QUOTE
        // -------------------------------------------------
        'quoteNumber': quoteNumber,
        'requestType': 'quote',
        'serviceType': 'International Moving',

        // -------------------------------------------------
        // ROUTE
        // -------------------------------------------------
        'from': _originController.text.trim(),
        'to': _destinationController.text.trim(),
        'origin': _originController.text.trim(),
        'destination': _destinationController.text.trim(),
        'pickupLocation': _originController.text.trim(),
        'deliveryLocation': _destinationController.text.trim(),
        'serviceMode': _serviceMode,

        // -------------------------------------------------
        // MOVING PROFILE
        // -------------------------------------------------
        'moveType': _moveType,

        // Admin currently displays propertyType first, so keep
        // a human-friendly combined value plus rawResidenceType.
        'propertyType': propertyDisplay,
        'rawPropertyType': _propertyType,
        'residenceType': _propertyType,

        'rooms': _roomsCount,
        'bedrooms': _roomsCount,
        'roomCount': _roomsCount,

        'floor': _originFloorController.text.trim(),
        'floorNumber': _originFloorController.text.trim(),
        'originFloor': _originFloorController.text.trim(),
        'destinationFloor': _destinationFloorController.text.trim(),

        'hasElevator': _originElevator,
        'elevator': _originElevator,
        'originElevator': _originElevator,
        'destinationElevator': _destinationElevator,

        // -------------------------------------------------
        // INVENTORY
        // -------------------------------------------------
        'estimatedBoxes': _boxCount,
        'boxCount': _boxCount,

        'largeItemsCount': _largeItemsCount,

        'estimatedVolumeCbm': _estimatedVolume > 0 ? _estimatedVolume : null,

        'volumeCbm': _estimatedVolume > 0 ? _estimatedVolume : null,

        'specialItems': _specialItems.toList(),

        // Generic cargo compatibility
        'cargoType': _moveType == 'Office Move'
            ? 'Office Relocation'
            : 'Household Goods & Personal Effects',

        'cargo': _moveType == 'Office Move'
            ? 'Office Relocation'
            : 'Household Goods & Personal Effects',

        // -------------------------------------------------
        // SERVICES
        // -------------------------------------------------
        'packingRequired': _packingRequired,
        'packing': _packingRequired,

        'unpackingRequired': _unpackingRequired,
        'unpacking': _unpackingRequired,

        'furnitureDisassembly': _furnitureDisassembly,
        'disassemblyRequired': _furnitureDisassembly,

        'storageRequired': _storageRequired,
        'storage': _storageRequired,

        'insuranceRequested': _insuranceRequested,
        'insurance': _insuranceRequested,

        'additionalServices': _combinedServices,

        // -------------------------------------------------
        // DATE
        // -------------------------------------------------
        'movingDate': Timestamp.fromDate(_movingDate!),

        'readyDate': Timestamp.fromDate(_movingDate!),

        // Compatibility with existing quote screens
        'pickupDate': Timestamp.fromDate(_movingDate!),

        // -------------------------------------------------
        // NOTES
        // -------------------------------------------------
        'notes': _notesController.text.trim(),

        // -------------------------------------------------
        // ADMIN
        // -------------------------------------------------
        'status': 'new',
        'quotedPrice': null,
        'currency': 'AED',
        'adminNote': '',
        'adminUpdatedAt': null,

        // -------------------------------------------------
        // SYSTEM
        // -------------------------------------------------
        'source': 'customer_app',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('quote_requests')
          .add(quoteData);

      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      await _showSuccessDialog(quoteNumber);
    } on FirebaseException catch (error) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      _showMessage(error.message ?? l10n.couldNotSubmitQuote, error: true);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      _showMessage(l10n.somethingWentWrong, error: true);
    }
  }

  // =========================================================
  // SUCCESS
  // =========================================================

  Future<void> _showSuccessDialog(String quoteNumber) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext)!;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 23),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 27, 22, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _deepBlue.withValues(alpha: .16),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF8F0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: _success,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 17),

                Text(
                  dialogL10n.quoteRequestSubmitted,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  dialogL10n.quoteSentToTawam,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textGrey,
                    fontSize: 10.5,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _softGrey,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dialogL10n.reference,
                        style: const TextStyle(
                          color: _textGrey,
                          fontSize: 8,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        quoteNumber,
                        style: const TextStyle(
                          color: _deepBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyQuotesScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      dialogL10n.myQuotes,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _deepBlue,
                      side: const BorderSide(color: _border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      dialogL10n.doneUpper,
                      style: const TextStyle(
                        fontSize: 10.5,
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

  // =========================================================
  // COMMON UI
  // =========================================================


  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return shippingTextField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (_) => setState(() {}),
      textColor: _textDark,
      decoration: _inputDecoration(label: label, hint: hint, icon: icon, suffix: suffix),
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String item)? itemLabel,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primaryBlue),
      style: const TextStyle(
        color: _textDark,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(label: label, hint: '', icon: icon),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(itemLabel?.call(item) ?? item),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
  }) {
    return shippingInputDecoration(
      label: label,
      hint: hint,
      icon: icon,
      suffix: suffix,
      primaryColor: _primaryBlue,
      labelColor: _textGrey,
      fillColor: _softGrey,
      borderColor: _border,
    );
  }

  Widget _optionSwitch({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _softBlue,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: _primaryBlue, size: 20),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: const TextStyle(
                  color: _textGrey,
                  fontSize: 8.8,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        Switch(
          value: value,
          activeThumbColor: _primaryBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // =========================================================
  // HELPERS
  // =========================================================

  int get _roomsCount {
    final value = int.tryParse(_roomsController.text.trim());

    if (value == null || value <= 0) {
      return 1;
    }

    return value;
  }

  int get _boxCount {
    final value = int.tryParse(_boxesController.text.trim());

    if (value == null || value < 0) {
      return 0;
    }

    return value;
  }

  int get _largeItemsCount {
    final value = int.tryParse(_largeItemsController.text.trim());

    if (value == null || value < 0) {
      return 0;
    }

    return value;
  }

  double get _estimatedVolume {
    return double.tryParse(_volumeController.text.trim()) ?? 0;
  }

  String _planningNote(AppLocalizations l10n) {
    if (_estimatedVolume > 0) {
      return l10n.estimatedVolumeEntered(_formatNumber(_estimatedVolume));
    }

    if (_roomsCount >= 4 || _boxCount >= 40 || _largeItemsCount >= 15) {
      return l10n.largeMoveProfile;
    }

    if (_roomsCount >= 2 || _boxCount >= 15 || _largeItemsCount >= 7) {
      return l10n.mediumMoveProfile;
    }

    return l10n.compactMoveProfile;
  }

  List<String> get _combinedServices {
    final services = <String>[
      if (_packingRequired) 'Professional Packing',
      if (_unpackingRequired) 'Unpacking',
      if (_furnitureDisassembly) 'Furniture Disassembly',
      if (_storageRequired) 'Temporary Storage',
      if (_insuranceRequested) 'Moving Insurance',
      ..._additionalServices,
    ];

    return services;
  }

  String _serviceSummaryText(AppLocalizations l10n) {
    final services = _combinedServices;

    if (services.isEmpty) {
      return l10n.standardRelocationCoordination;
    }

    final labels = services.map((service) => _optionLabel(l10n, service)).toList();

    if (labels.length <= 2) {
      return labels.join(' • ');
    }

    return '${labels.take(2).join(' • ')} ${l10n.plusNMore(labels.length - 2)}';
  }

  String? _nonNegativeIntegerValidator(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final number = int.tryParse(value?.trim() ?? '');

    if (number == null || number < 0) {
      return l10n.enterZeroOrMore;
    }

    return null;
  }

  Future<void> _selectMovingDate() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    final result = await showDatePicker(
      context: context,
      initialDate: _movingDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: l10n.selectMovingDate,
    );

    if (result == null || !mounted) return;

    setState(() {
      _movingDate = result;
    });
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;

    return '${date.day} ${LocaleController.monthAbbrev(l10n, date.month)} ${date.year}';
  }

  // Map stored English option values to localized display labels.
  String _optionLabel(AppLocalizations l10n, String value) {
    return LocaleController.optionLabel(l10n, value);
  }


  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(2);
  }

  String _two(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;

      final text = value.toString().trim();

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  void _showMessage(String message, {required bool error}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? const Color(0xFF9E2A2A) : _deepBlue,
      ),
    );
  }
}
