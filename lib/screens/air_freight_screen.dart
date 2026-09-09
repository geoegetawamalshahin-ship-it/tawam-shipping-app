import '../app/utils/value_formatters.dart';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app/widgets/shipping_form_widgets.dart';
import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
import 'my_quotes_screen.dart';

class AirFreightScreen extends StatefulWidget {
  const AirFreightScreen({super.key});

  @override
  State<AirFreightScreen> createState() => _AirFreightScreenState();
}

class _AirFreightScreenState extends State<AirFreightScreen> {
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

  // Standard air-freight volumetric divisor.
  // Can be changed later if your airline/forwarder uses another divisor.
  static const double _volumetricDivisor = 6000;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // =========================================================
  // CONTROLLERS
  // =========================================================

  final TextEditingController _originController = TextEditingController();

  final TextEditingController _destinationController = TextEditingController();

  final TextEditingController _cargoController = TextEditingController();

  final TextEditingController _weightController = TextEditingController();

  final TextEditingController _piecesController = TextEditingController(
    text: '1',
  );

  final TextEditingController _lengthController = TextEditingController();

  final TextEditingController _widthController = TextEditingController();

  final TextEditingController _heightController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  // =========================================================
  // AIR FREIGHT OPTIONS
  // =========================================================

  String _serviceMode = 'Door to Door';

  String _airServiceType = 'Standard';

  String _packageType = 'Boxes';

  DateTime? _readyDate;

  bool _dangerousGoods = false;

  bool _insuranceRequested = false;

  final Set<String> _additionalServices = <String>{};

  final List<String> _serviceModes = const [
    'Door to Door',
    'Airport to Airport',
    'Door to Airport',
    'Airport to Door',
  ];

  final List<String> _packageTypes = const [
    'Boxes',
    'Pallets',
    'Loose Cargo',
    'Crates',
  ];

  final List<String> _availableServices = const [
    'Customs Clearance',
    'Pickup',
    'Delivery',
    'Export Documentation',
    'Packing',
  ];

  // =========================================================
  // CUSTOMER
  // =========================================================

  bool _loadingProfile = true;

  bool _submitting = false;

  String _customerName = '';

  String _customerEmail = '';

  String _customerPhone = '';

  String _customerCompany = '';

  String _customerCountry = '';

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _weightController.addListener(_refreshCalculations);
    _piecesController.addListener(_refreshCalculations);
    _lengthController.addListener(_refreshCalculations);
    _widthController.addListener(_refreshCalculations);
    _heightController.addListener(_refreshCalculations);

    _loadCustomerProfile();
  }

  @override
  void dispose() {
    _weightController.removeListener(_refreshCalculations);
    _piecesController.removeListener(_refreshCalculations);
    _lengthController.removeListener(_refreshCalculations);
    _widthController.removeListener(_refreshCalculations);
    _heightController.removeListener(_refreshCalculations);

    _originController.dispose();
    _destinationController.dispose();
    _cargoController.dispose();
    _weightController.dispose();
    _piecesController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // =========================================================
  // AUTOMATIC CALCULATIONS
  // =========================================================

  double get _grossWeight {
    return double.tryParse(_weightController.text.trim()) ?? 0;
  }

  int get _pieces {
    return int.tryParse(_piecesController.text.trim()) ?? 0;
  }

  double get _length {
    return double.tryParse(_lengthController.text.trim()) ?? 0;
  }

  double get _width {
    return double.tryParse(_widthController.text.trim()) ?? 0;
  }

  double get _height {
    return double.tryParse(_heightController.text.trim()) ?? 0;
  }

  double get _volumeCbm {
    if (_length <= 0 || _width <= 0 || _height <= 0 || _pieces <= 0) {
      return 0;
    }

    return (_length * _width * _height * _pieces) / 1000000;
  }

  double get _volumetricWeight {
    if (_length <= 0 || _width <= 0 || _height <= 0 || _pieces <= 0) {
      return 0;
    }

    return (_length * _width * _height * _pieces) / _volumetricDivisor;
  }

  double get _chargeableWeight {
    return math.max(_grossWeight, _volumetricWeight);
  }

  void _refreshCalculations() {
    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // AUTO-FILL CUSTOMER PROFILE
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

      name = firstNonEmpty([
        data['name'],
        data['fullName'],
        data['displayName'],
        name,
      ]);

      email = firstNonEmpty([data['email'], email]);

      phone = firstNonEmpty([
        data['phone'],
        data['phoneNumber'],
        data['mobile'],
        phone,
      ]);

      company = firstNonEmpty([data['companyName'], data['company']]);

      country = firstNonEmpty([data['country'], data['countryName']]);
    } catch (_) {
      // Firebase Auth information is used as fallback.
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
            _buildHeader(),

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
                      icon: Icons.flight_takeoff_rounded,
                      title: l10n.shipmentRoute,
                      subtitle: l10n.tellUsWhereMoving,
                    ),

                    const SizedBox(height: 13),

                    _buildRouteSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '02',
                      icon: Icons.bolt_rounded,
                      title: l10n.airFreightService,
                      subtitle: l10n.chooseServiceLevel,
                    ),

                    const SizedBox(height: 13),

                    _buildAirServiceSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '03',
                      icon: Icons.inventory_2_outlined,
                      title: l10n.cargoInformation,
                      subtitle: l10n.provideCargoSpecs,
                    ),

                    const SizedBox(height: 13),

                    _buildCargoSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '04',
                      icon: Icons.straighten_rounded,
                      title: l10n.dimensionsWeight,
                      subtitle: l10n.weCalculateVolumetric,
                    ),

                    const SizedBox(height: 13),

                    _buildDimensionsSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '05',
                      icon: Icons.add_business_outlined,
                      title: l10n.additionalServices,
                      subtitle: l10n.addOptionalLogistics,
                    ),

                    const SizedBox(height: 13),

                    _buildServicesSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '06',
                      icon: Icons.person_outline_rounded,
                      title: l10n.contactDetails,
                      subtitle: l10n.contactFilledFromAccount,
                    ),

                    const SizedBox(height: 13),

                    _buildCustomerSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '07',
                      icon: Icons.notes_rounded,
                      title: l10n.specialInstructions,
                      subtitle: l10n.anythingAirTeam,
                    ),

                    const SizedBox(height: 13),

                    _buildNotesSection(),

                    const SizedBox(height: 28),

                    _buildSummary(),

                    const SizedBox(height: 22),

                    _buildSubmitButton(),

                    const SizedBox(height: 14),

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
                            style: const TextStyle(
                              color: _textGrey,
                              fontSize: 9.5,
                              height: 1.4,
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

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingFormHeader(
      title: l10n.airFreightQuote,
      subtitle: l10n.officialRateRequest,
      trailingIcon: Icons.flight_rounded,
      onBack: () => Navigator.pop(context),
      borderColor: _border,
      shadowColor: _deepBlue,
      leadingBackgroundColor: _softGrey,
      leadingIconColor: _deepBlue,
      trailingBackgroundColor: _softBlue,
      trailingIconColor: _primaryBlue,
      titleColor: _textDark,
      titleFontSize: 20,
      subtitleFontSize: 8.5,
      subtitleLetterSpacing: 1.15,
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
          Image.asset('assets/images/air_freight.png', fit: BoxFit.cover),

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
                    l10n.globalAirCargo,
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
                  l10n.fastCargoGlobalReach,
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
                  l10n.airHeroSubtitle,
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
              icon: Icons.bolt_rounded,
              title: l10n.express.toUpperCase(),
              subtitle: l10n.priorityCargo,
              primaryColor: _primaryBlue,
              titleColor: _textDark,
              subtitleColor: _textGrey,
            ),
          ),
          const ShippingTrustDivider(color: _border),
          Expanded(
            child: ShippingTrustItem(
              icon: Icons.flight_takeoff_rounded,
              title: 'A2A',
              subtitle: l10n.airportToAirport,
              primaryColor: _primaryBlue,
              titleColor: _textDark,
              subtitleColor: _textGrey,
            ),
          ),
          const ShippingTrustDivider(color: _border),
          Expanded(
            child: ShippingTrustItem(
              icon: Icons.home_work_outlined,
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
  // TITLES
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
      titleLetterSpacing: null,
      subtitleFontWeight: null,
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
            hint: l10n.airportCityPickup,
            icon: Icons.flight_takeoff_rounded,
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
            hint: l10n.airportCityDelivery,
            icon: Icons.flight_land_rounded,
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
    return ShippingDateSelector(
      onTap: _selectReadyDate,
      fillColor: _softGrey,
      iconBackgroundColor: _softBlue,
      borderColor: _border,
      primaryColor: _primaryBlue,
      labelColor: _textGrey,
      textColor: _textDark,
      label: l10n.cargoReadyDate,
      isEmpty: _readyDate == null,
      valueText: _readyDate == null ? l10n.selectReadyDate : _formatDate(_readyDate!),
      labelWeight: null,
    );
  }

  // =========================================================
  // AIR SERVICE
  // =========================================================

  Widget _buildAirServiceSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(

      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chooseServiceLevel,
            style: const TextStyle(
              color: _textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          _airServiceOption(
            value: 'Standard',
            icon: Icons.flight_rounded,
            title: l10n.standardAirFreight,
            subtitle: l10n.standardAirDesc,
          ),

          const SizedBox(height: 10),

          _airServiceOption(
            value: 'Express',
            icon: Icons.bolt_rounded,
            title: l10n.expressAirFreight,
            subtitle: l10n.expressAirDesc,
          ),

          const SizedBox(height: 10),

          _airServiceOption(
            value: 'Priority',
            icon: Icons.workspace_premium_outlined,
            title: l10n.priorityTimeCritical,
            subtitle: l10n.priorityAirDesc,
          ),
        ],
      ),
    );
  }

  Widget _airServiceOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _airServiceType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _airServiceType = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _deepBlue : _softGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _deepBlue : _border),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: .12)
                    : _softBlue,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : _primaryBlue,
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? Colors.white : _textDark,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: selected ? const Color(0xFFD6E5F4) : _textGrey,
                      fontSize: 8.8,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 19,
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // CARGO
  // =========================================================

  Widget _buildCargoSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(

      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        children: [
          _textField(
            controller: _cargoController,
            label: l10n.cargoType,
            hint: l10n.hintCargoAir,
            icon: Icons.category_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterCargoType;
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          _dropdown(
            label: l10n.packageType,
            icon: Icons.inventory_2_outlined,
            value: _packageType,
            items: _packageTypes,
            itemLabel: (item) => _optionLabel(l10n, item),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _packageType = value;
              });
            },
          ),

          const SizedBox(height: 14),

          _textField(
            controller: _piecesController,
            label: l10n.numberOfPieces,
            hint: '1',
            icon: Icons.numbers_rounded,
            keyboardType: TextInputType.number,
            validator: (value) {
              final number = int.tryParse(value?.trim() ?? '');

              if (number == null || number <= 0) {
                return l10n.enterNumberOfPieces;
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          _optionSwitch(
            icon: Icons.warning_amber_rounded,
            title: l10n.dangerousGoods,
            subtitle: l10n.dgHint,
            value: _dangerousGoods,
            onChanged: (value) {
              setState(() {
                _dangerousGoods = value;
              });
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Divider(color: _border, height: 1),
          ),

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

  // =========================================================
  // DIMENSIONS + AUTOMATIC WEIGHT
  // =========================================================

  Widget _buildDimensionsSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(

      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField(
            controller: _weightController,
            label: l10n.grossWeight,
            hint: '0',
            suffix: 'KG',
            icon: Icons.monitor_weight_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final weight = double.tryParse(value?.trim() ?? '');

              if (weight == null || weight <= 0) {
                return l10n.pleaseEnterGrossWeight;
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          Text(
            l10n.averagePieceDimensions,
            style: const TextStyle(
              color: _textDark,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            l10n.enterDimensionsCm,
            style: const TextStyle(color: _textGrey, fontSize: 9),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _dimensionField(
                  controller: _lengthController,
                  label: l10n.length,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _dimensionField(
                  controller: _widthController,
                  label: l10n.width,
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _dimensionField(
                  controller: _heightController,
                  label: l10n.height,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: _deepBlue,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF7FC2FF),
                      size: 18,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      l10n.automaticAirCalc,
                      style: const TextStyle(
                        color: Color(0xFFD6E8F8),
                        fontSize: 7.8,
                        letterSpacing: .7,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _calculationItem(
                        l10n.actual,
                        '${_formatNumber(_grossWeight)} KG',
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: .14),
                    ),

                    Expanded(
                      child: _calculationItem(
                        l10n.volumetric,
                        '${_formatNumber(_volumetricWeight)} KG',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 13),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.scale_outlined,
                        color: Color(0xFF87C8FF),
                        size: 19,
                      ),

                      const SizedBox(width: 9),

                      Expanded(
                        child: Text(
                          l10n.chargeableWeight,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      Text(
                        '${_formatNumber(_chargeableWeight)} KG',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  l10n.cargoVolumeCbm(_volumeCbm.toStringAsFixed(3)),
                  style: const TextStyle(
                    color: Color(0xFFBFD5E8),
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _calculationItem(String label, String value) {
    return ShippingCalculationItem(label: label, value: value);
  }

  // =========================================================
  // SERVICES
  // =========================================================

  Widget _buildServicesSection() {
    final l10n = AppLocalizations.of(context)!;
    return ShippingServicesSection(
      title: l10n.selectServices,
      subtitle: l10n.youCanChooseMoreThanOne,
      services: _availableServices,
      selectedServices: _additionalServices,
      serviceLabel: (service) => _optionLabel(l10n, service),
      borderColor: _border,
      shadowColor: _deepBlue,
      textColor: _textDark,
      labelColor: _textGrey,
      primaryColor: _primaryBlue,
      fillColor: _softGrey,
      onSelectionChanged: (service, value) {
        setState(() {
          if (value) {
            _additionalServices.add(service);
          } else {
            _additionalServices.remove(service);
          }
        });
      },
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
      child: _loadingProfile
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 25),
              child: Center(
                child: CircularProgressIndicator(
                  color: _primaryBlue,
                  strokeWidth: 2.5,
                ),
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        color: _success,
                        size: 18,
                      ),

                      const SizedBox(width: 9),

                      Expanded(
                        child: Text(
                          l10n.contactFilledFromAccount,
                          style: const TextStyle(
                            color: _success,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _contactRow(
                  Icons.person_outline_rounded,
                  l10n.fullName,
                  _customerName,
                ),

                const ShippingContactDivider(color: _border),

                _contactRow(
                  Icons.phone_outlined,
                  l10n.phoneNumber,
                  _customerPhone.isEmpty
                      ? l10n.notProvided
                      : _customerPhone,
                ),

                const ShippingContactDivider(color: _border),

                _contactRow(
                  Icons.email_outlined,
                  l10n.emailAddress,
                  _customerEmail.isEmpty
                      ? l10n.notProvided
                      : _customerEmail,
                ),

                if (_customerCompany.isNotEmpty) ...[
                  const ShippingContactDivider(color: _border),
                  _contactRow(
                    Icons.business_outlined,
                    l10n.company,
                    _customerCompany,
                  ),
                ],

                if (_customerCountry.isNotEmpty) ...[
                  const ShippingContactDivider(color: _border),
                  _contactRow(
                    Icons.public_outlined,
                    l10n.country,
                    _customerCountry,
                  ),
                ],
              ],
            ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: _softBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primaryBlue, size: 19),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: _textGrey, fontSize: 8.5),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
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
      child: TextFormField(
        controller: _notesController,
        minLines: 4,
        maxLines: 7,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(
          color: _textDark,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: l10n.specialHandlingHint,
          hintStyle: const TextStyle(color: Color(0xFFA1ACB9), fontSize: 10),
          filled: true,
          fillColor: _softGrey,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: _primaryBlue, width: 1.4),
          ),
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined, color: Colors.white, size: 19),

              const SizedBox(width: 8),

              Text(
                l10n.requestSummary,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const Icon(Icons.flight_rounded, color: Color(0xFF76B7FF)),

              Expanded(
                child: Text(
                  destination,
                  maxLines: 2,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _summaryBadge(l10n.serviceAirFreight),
              _summaryBadge(_optionLabel(l10n, _airServiceType)),
              _summaryBadge(_optionLabel(l10n, _serviceMode)),
              _summaryBadge('$_pieces ${l10n.numberOfPieces}'),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.scale_outlined,
                  color: Color(0xFF7EC0FF),
                  size: 19,
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Text(
                    l10n.chargeableWeight,
                    style: const TextStyle(color: Color(0xFFD9E8F6), fontSize: 9.5),
                  ),
                ),

                Text(
                  '${_formatNumber(_chargeableWeight)} KG',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBadge(String text) {
    return ShippingSummaryBadge(text: text);
  }

  // =========================================================
  // SUBMIT
  // =========================================================

  Widget _buildSubmitButton() {
    final l10n = AppLocalizations.of(context)!;
    return ShippingSubmitButton(
      submitting: _submitting,
      onSubmit: _submitQuote,
      primaryColor: _primaryBlue,
      label: l10n.submitQuoteRequest,
      icon: Icons.flight_takeoff_rounded,
    );
  }

  Future<void> _submitQuote() async {
    if (_submitting) return;

    final l10n = AppLocalizations.of(context)!;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _showMessage(
        l10n.pleaseCompleteShipmentInfo,
        error: true,
      );

      return;
    }

    if (_readyDate == null) {
      _showMessage(l10n.pleaseSelectPickupDate, error: true);

      return;
    }

    if (_length <= 0 || _width <= 0 || _height <= 0) {
      _showMessage(l10n.pleaseEnterDimensionsFirst, error: true);

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
          'QR-${now.year}${twoDigits(now.month)}${twoDigits(now.day)}-'
          '${twoDigits(now.hour)}${twoDigits(now.minute)}${twoDigits(now.second)}';

      final quoteData = <String, dynamic>{
        // Customer
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

        // Quote
        'quoteNumber': quoteNumber,
        'requestType': 'quote',
        'serviceType': 'Air Freight',

        // Route
        'from': _originController.text.trim(),
        'to': _destinationController.text.trim(),
        'origin': _originController.text.trim(),
        'destination': _destinationController.text.trim(),
        'serviceMode': _serviceMode,

        // Air freight
        'airServiceType': _airServiceType,
        'packageType': _packageType,

        // Cargo
        'cargoType': _cargoController.text.trim(),
        'cargo': _cargoController.text.trim(),
        'quantity': _pieces,
        'pieces': _pieces,

        'weightKg': _grossWeight,
        'grossWeightKg': _grossWeight,

        'lengthCm': _length,
        'widthCm': _width,
        'heightCm': _height,

        'volumeCbm': _volumeCbm,

        'volumetricWeightKg': _volumetricWeight,

        'chargeableWeightKg': _chargeableWeight,

        'dangerousGoods': _dangerousGoods,

        'insuranceRequested': _insuranceRequested,

        'additionalServices': _additionalServices.toList(),

        // Dates
        'readyDate': Timestamp.fromDate(_readyDate!),

        // Compatibility with existing admin/customer screens
        'pickupDate': Timestamp.fromDate(_readyDate!),

        // Notes
        'notes': _notesController.text.trim(),

        // Admin
        'status': 'new',
        'quotedPrice': null,
        'currency': 'AED',
        'adminNote': '',
        'adminUpdatedAt': null,

        // System
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

      _showMessage(
        error.message ?? l10n.couldNotSubmitQuote,
        error: true,
      );
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
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  dialogL10n.quoteSentToTawam,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                    child: Text(dialogL10n.doneUpper),
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
  // COMMON WIDGETS
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

  Widget _dimensionField({
    required TextEditingController controller,
    required String label,
  }) {
    return shippingDimensionField(
      controller: controller,
      label: label,
      textDark: _textDark,
      textGrey: _textGrey,
      primaryBlue: _primaryBlue,
      softGrey: _softGrey,
      border: _border,
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
    return shippingDropdown(
      value: value,
      items: items,
      onChanged: onChanged,
      itemLabel: itemLabel,
      primaryColor: _primaryBlue,
      decoration: _inputDecoration(label: label, hint: '', icon: icon),
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
      labelWeight: null,
      focusedErrorBorderEnabled: false,
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
                style: const TextStyle(color: _textGrey, fontSize: 8.8),
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

  Future<void> _selectReadyDate() async {
    final now = DateTime.now();

    final result = await showDatePicker(
      context: context,
      initialDate: _readyDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: AppLocalizations.of(context)!.selectPickupDate,
    );

    if (result == null || !mounted) return;

    setState(() {
      _readyDate = result;
    });
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;

    return formatLocalizedDate(l10n, date);
  }

  // Map stored English option values to localized display labels.
  String _optionLabel(AppLocalizations l10n, String value) {
    return LocaleController.optionLabel(l10n, value);
  }


  String _formatNumber(double value) {
    return formatDisplayNumber(value, nonPositiveAsZero: true);
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
