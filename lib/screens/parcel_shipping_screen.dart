import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app/widgets/shipping_form_widgets.dart';
import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
import 'my_quotes_screen.dart';

class ParcelShippingScreen extends StatefulWidget {
  const ParcelShippingScreen({super.key});

  @override
  State<ParcelShippingScreen> createState() => _ParcelShippingScreenState();
}

class _ParcelShippingScreenState extends State<ParcelShippingScreen> {
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

  // Common courier volumetric divisor.
  // Final carrier calculation may vary by route/carrier.
  static const double _volumetricDivisor = 5000;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // =========================================================
  // CONTROLLERS
  // =========================================================

  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final TextEditingController _parcelCountController = TextEditingController(
    text: '1',
  );

  final TextEditingController _contentsController = TextEditingController();

  final TextEditingController _weightController = TextEditingController();

  final TextEditingController _lengthController = TextEditingController();

  final TextEditingController _widthController = TextEditingController();

  final TextEditingController _heightController = TextEditingController();

  final TextEditingController _declaredValueController =
      TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  // =========================================================
  // PARCEL OPTIONS
  // =========================================================

  String _serviceLevel = 'Express';
  String _pickupMethod = 'Door Pickup';
  String _packageType = 'Box';
  String _declaredValueCurrency = 'AED';

  DateTime? _readyDate;

  bool _fragile = false;
  bool _insuranceRequested = false;
  bool _signatureRequired = false;

  final Set<String> _additionalServices = <String>{};

  final List<String> _pickupMethods = const ['Door Pickup', 'Drop-off'];

  final List<String> _packageTypes = const [
    'Box',
    'Envelope / Document',
    'Padded Bag',
    'Tube',
    'Other',
  ];

  final List<String> _currencies = const ['AED', 'USD', 'EUR'];

  final List<String> _availableServices = const [
    'Customs Clearance',
    'Pickup',
    'Delivery',
    'Export Documentation',
    'Proof of Delivery',
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

    _parcelCountController.addListener(_refreshCalculations);
    _weightController.addListener(_refreshCalculations);
    _lengthController.addListener(_refreshCalculations);
    _widthController.addListener(_refreshCalculations);
    _heightController.addListener(_refreshCalculations);

    _loadCustomerProfile();
  }

  @override
  void dispose() {
    _parcelCountController.removeListener(_refreshCalculations);
    _weightController.removeListener(_refreshCalculations);
    _lengthController.removeListener(_refreshCalculations);
    _widthController.removeListener(_refreshCalculations);
    _heightController.removeListener(_refreshCalculations);

    _originController.dispose();
    _destinationController.dispose();
    _parcelCountController.dispose();
    _contentsController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _declaredValueController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  void _refreshCalculations() {
    if (mounted) {
      setState(() {});
    }
  }

  // =========================================================
  // AUTOMATIC CALCULATIONS
  // =========================================================

  int get _parcelCount {
    final value = int.tryParse(_parcelCountController.text.trim());

    if (value == null || value <= 0) {
      return 1;
    }

    return value;
  }

  double get _weightPerParcel {
    return double.tryParse(_weightController.text.trim()) ?? 0;
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

  double get _totalActualWeight {
    return _weightPerParcel * _parcelCount;
  }

  double get _totalVolumeCbm {
    if (_length <= 0 || _width <= 0 || _height <= 0 || _parcelCount <= 0) {
      return 0;
    }

    return (_length * _width * _height * _parcelCount) / 1000000;
  }

  double get _totalVolumetricWeight {
    if (_length <= 0 || _width <= 0 || _height <= 0 || _parcelCount <= 0) {
      return 0;
    }

    return (_length * _width * _height * _parcelCount) / _volumetricDivisor;
  }

  double get _chargeableWeight {
    return math.max(_totalActualWeight, _totalVolumetricWeight);
  }

  double? get _declaredValue {
    final text = _declaredValueController.text.trim();

    if (text.isEmpty) {
      return null;
    }

    return double.tryParse(text);
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
      // Keep Firebase Auth data as fallback.
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
                      icon: Icons.bolt_rounded,
                      title: l10n.deliveryService,
                      subtitle: l10n.chooseServiceLevel,
                    ),

                    const SizedBox(height: 13),

                    _buildServiceLevelSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '03',
                      icon: Icons.inventory_2_outlined,
                      title: l10n.cargoInformation,
                      subtitle: l10n.provideCargoSpecs,
                    ),

                    const SizedBox(height: 13),

                    _buildParcelInfoSection(),

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
                      icon: Icons.shield_outlined,
                      title: l10n.protectionAndDelivery,
                      subtitle: l10n.addInsuranceFragileSignature,
                    ),

                    const SizedBox(height: 13),

                    _buildProtectionSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '06',
                      icon: Icons.add_business_outlined,
                      title: l10n.additionalServices,
                      subtitle: l10n.addOptionalLogistics,
                    ),

                    const SizedBox(height: 13),

                    _buildServicesSection(),

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
      title: l10n.parcelQuote,
      subtitle: l10n.officialRateRequest,
      trailingIcon: Icons.inventory_2_outlined,
      onBack: () => Navigator.pop(context),
      borderColor: _border,
      shadowColor: _deepBlue,
      leadingBackgroundColor: _softGrey,
      leadingIconColor: _deepBlue,
      trailingBackgroundColor: _softBlue,
      trailingIconColor: _primaryBlue,
      titleColor: _textDark,
      titleFontSize: 20,
      subtitleFontSize: 8.3,
      subtitleLetterSpacing: 1.0,
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
          Image.asset('assets/images/parcel.png', fit: BoxFit.cover),

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
                  const Icon(Icons.bolt_rounded, color: _primaryBlue, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    l10n.expressParcelLogistics,
                    style: const TextStyle(
                      color: _deepBlue,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .75,
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
                  l10n.parcelHeroTitle,
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
                  l10n.parcelHeroSubtitle,
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
              title: l10n.badgeExpress,
              subtitle: l10n.priority,
              primaryColor: _primaryBlue,
              titleColor: _textDark,
              subtitleColor: _textGrey,
            ),
          ),
          const ShippingTrustDivider(color: _border),
          Expanded(
            child: ShippingTrustItem(
              icon: Icons.public_rounded,
              title: l10n.badgeIntl,
              subtitle: l10n.globalParcels,
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

    return _premiumCard(
      child: Column(
        children: [
          _textField(
            controller: _originController,
            label: l10n.from,
            hint: l10n.cityPickupDropoff,
            icon: Icons.trip_origin_rounded,
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
            label: l10n.to,
            hint: l10n.cityOrDeliveryAddress,
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
            label: l10n.pickupMethod,
            icon: Icons.local_shipping_outlined,
            value: _pickupMethod,
            items: _pickupMethods,
            itemLabel: (item) => _optionLabel(l10n, item),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _pickupMethod = value;
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
      onTap: _selectReadyDate,
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
                    l10n.cargoReadyDate,
                    style: TextStyle(
                      color: _textGrey,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _readyDate == null
                        ? l10n.selectReadyDate
                        : _formatDate(_readyDate!),
                    style: TextStyle(
                      color: _readyDate == null ? _textGrey : _textDark,
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
  // SERVICE LEVEL
  // =========================================================

  Widget _buildServiceLevelSection() {
    final l10n = AppLocalizations.of(context)!;

    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.serviceLevel,
            style: const TextStyle(
              color: _textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          _serviceOption(
            value: 'Economy',
            icon: Icons.savings_outlined,
            title: l10n.economy,
            subtitle: l10n.economyParcelDesc,
          ),

          const SizedBox(height: 10),

          _serviceOption(
            value: 'Express',
            icon: Icons.bolt_rounded,
            title: l10n.express,
            subtitle: l10n.expressParcelDesc,
          ),

          const SizedBox(height: 10),

          _serviceOption(
            value: 'Priority',
            icon: Icons.workspace_premium_outlined,
            title: l10n.priority,
            subtitle: l10n.priorityParcelDesc,
          ),
        ],
      ),
    );
  }

  Widget _serviceOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _serviceLevel == value;

    return InkWell(
      onTap: () {
        setState(() {
          _serviceLevel = value;
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
  // PARCEL INFO
  // =========================================================

  Widget _buildParcelInfoSection() {
    final l10n = AppLocalizations.of(context)!;

    return _premiumCard(
      child: Column(
        children: [
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
            controller: _parcelCountController,
            label: l10n.numberOfParcels,
            hint: '1',
            icon: Icons.numbers_rounded,
            keyboardType: TextInputType.number,
            validator: (value) {
              final count = int.tryParse(value?.trim() ?? '');

              if (count == null || count <= 0) {
                return l10n.enterNumberOfParcels;
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          _textField(
            controller: _contentsController,
            label: l10n.parcelContents,
            hint: l10n.hintParcelContents,
            icon: Icons.category_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseDescribeParcel;
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _textField(
                  controller: _declaredValueController,
                  label: l10n.declaredValue,
                  hint: l10n.optional,
                  icon: Icons.payments_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }

                    final amount = double.tryParse(value.trim());

                    if (amount == null || amount <= 0) {
                      return l10n.invalidValue;
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(width: 10),

              SizedBox(
                width: 92,
                child: DropdownButtonFormField<String>(
                  initialValue: _declaredValueCurrency,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.currency,
                    filled: true,
                    fillColor: _softGrey,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: _border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: _primaryBlue,
                        width: 1.4,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: _currencies
                      .map(
                        (currency) => DropdownMenuItem<String>(
                          value: currency,
                          child: Text(currency),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _declaredValueCurrency = value;
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

  // =========================================================
  // DIMENSIONS / WEIGHT
  // =========================================================

  Widget _buildDimensionsSection() {
    final l10n = AppLocalizations.of(context)!;

    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField(
            controller: _weightController,
            label: l10n.weightPerParcel,
            hint: '0',
            suffix: 'KG',
            icon: Icons.monitor_weight_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final weight = double.tryParse(value?.trim() ?? '');

              if (weight == null || weight <= 0) {
                return l10n.enterParcelWeight;
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          Text(
            l10n.averageParcelDimensions,
            style: const TextStyle(
              color: _textDark,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            l10n.enterDimensionsCm,
            style: TextStyle(color: _textGrey, fontSize: 9),
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
                      l10n.automaticParcelCalculation,
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
                        '${_formatNumber(_totalActualWeight)} KG',
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
                        '${_formatNumber(_totalVolumetricWeight)} KG',
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
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
                  l10n.totalVolumeCarrierNote(_totalVolumeCbm.toStringAsFixed(3)),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFBFD5E8),
                    fontSize: 8.2,
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
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFBCD3E7), fontSize: 8.5),
        ),

        const SizedBox(height: 5),

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // PROTECTION
  // =========================================================

  Widget _buildProtectionSection() {
    final l10n = AppLocalizations.of(context)!;

    return _premiumCard(
      child: Column(
        children: [
          _optionSwitch(
            icon: Icons.broken_image_outlined,
            title: l10n.fragile,
            subtitle: l10n.parcelExtraCare,
            value: _fragile,
            onChanged: (value) {
              setState(() {
                _fragile = value;
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

          const ShippingContactDivider(color: _border),

          _optionSwitch(
            icon: Icons.draw_outlined,
            title: l10n.signatureOnDelivery,
            subtitle: l10n.requireRecipientConfirmation,
            value: _signatureRequired,
            onChanged: (value) {
              setState(() {
                _signatureRequired = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SERVICES
  // =========================================================

  Widget _buildServicesSection() {
    final l10n = AppLocalizations.of(context)!;

    return _premiumCard(
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
            children: _availableServices.map((service) {
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

    return _premiumCard(
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

                      SizedBox(width: 9),

                      Expanded(
                        child: Text(
                          l10n.contactFilledFromAccount,
                          style: TextStyle(
                            color: _success,
                            fontSize: 9.5,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _contactRow(
                  icon: Icons.person_outline_rounded,
                  label: l10n.fullName,
                  value: _customerName,
                ),

                const ShippingContactDivider(color: _border),

                _contactRow(
                  icon: Icons.phone_outlined,
                  label: l10n.phoneNumber,
                  value: _customerPhone.isEmpty
                      ? l10n.notProvided
                      : _customerPhone,
                ),

                const ShippingContactDivider(color: _border),

                _contactRow(
                  icon: Icons.email_outlined,
                  label: l10n.emailAddress,
                  value: _customerEmail.isEmpty
                      ? l10n.notProvided
                      : _customerEmail,
                ),

                if (_customerCompany.isNotEmpty) ...[
                  const ShippingContactDivider(color: _border),

                  _contactRow(
                    icon: Icons.business_outlined,
                    label: l10n.company,
                    value: _customerCompany,
                  ),
                ],

                if (_customerCountry.isNotEmpty) ...[
                  const ShippingContactDivider(color: _border),

                  _contactRow(
                    icon: Icons.public_outlined,
                    label: l10n.country,
                    value: _customerCountry,
                  ),
                ],
              ],
            ),
    );
  }

  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
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
                style: const TextStyle(
                  color: _textGrey,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                ),
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

    return _premiumCard(
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
          hintStyle: const TextStyle(
            color: Color(0xFFA1ACB9),
            fontSize: 10,
            height: 1.45,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(bottom: 70),
            child: Icon(Icons.edit_note_rounded, color: _primaryBlue),
          ),
          filled: true,
          fillColor: _softGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: _border),
          ),
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
        ? l10n.from
        : _originController.text.trim();

    final destination = _destinationController.text.trim().isEmpty
        ? l10n.to
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
              Icons.inventory_2_rounded,
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
                    Icons.inventory_2_outlined,
                    LocaleController.serviceLabel(l10n, 'Parcel Shipping'),
                  ),

                  _summaryBadge(
                    Icons.bolt_rounded,
                    _optionLabel(l10n, _serviceLevel),
                  ),

                  _summaryBadge(Icons.local_shipping_outlined, _pickupMethod),

                  _summaryBadge(
                    Icons.numbers_rounded,
                    '$_parcelCount Parcel${_parcelCount == 1 ? '' : 's'}',
                  ),

                  if (_fragile)
                    _summaryBadge(
                      Icons.broken_image_outlined,
                      _optionLabel(l10n, 'Fragile'),
                    ),
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
                        style: TextStyle(
                          color: Color(0xFFD9E8F6),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Text(
                      '${_formatNumber(_chargeableWeight)} KG',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
                        l10n.parcelRateConfirmHint,
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
          'QR-${now.year}${_two(now.month)}${_two(now.day)}-'
          '${_two(now.hour)}${_two(now.minute)}${_two(now.second)}';

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
        'serviceType': 'Parcel Shipping',

        // -------------------------------------------------
        // ROUTE
        // -------------------------------------------------
        'from': _originController.text.trim(),
        'to': _destinationController.text.trim(),
        'origin': _originController.text.trim(),
        'destination': _destinationController.text.trim(),
        'pickupLocation': _originController.text.trim(),
        'deliveryLocation': _destinationController.text.trim(),

        // -------------------------------------------------
        // PARCEL SERVICE
        // -------------------------------------------------
        'parcelServiceType': _serviceLevel,
        'serviceLevel': _serviceLevel,
        'pickupMethod': _pickupMethod,

        // -------------------------------------------------
        // PARCEL INFORMATION
        // -------------------------------------------------
        'packageType': _packageType,

        'quantity': _parcelCount,
        'pieces': _parcelCount,
        'parcelCount': _parcelCount,

        'contents': _contentsController.text.trim(),
        'parcelContents': _contentsController.text.trim(),

        // Generic compatibility
        'cargoType': _contentsController.text.trim(),
        'cargo': _contentsController.text.trim(),

        // -------------------------------------------------
        // WEIGHT / DIMENSIONS
        // -------------------------------------------------
        'weightPerParcelKg': _weightPerParcel,
        'totalActualWeightKg': _totalActualWeight,

        // Generic admin compatibility
        'weightKg': _totalActualWeight,
        'grossWeightKg': _totalActualWeight,

        'lengthCm': _length,
        'widthCm': _width,
        'heightCm': _height,

        'volumeCbm': _totalVolumeCbm,

        'volumetricDivisor': _volumetricDivisor,

        'volumetricWeightKg': _totalVolumetricWeight,

        'chargeableWeightKg': _chargeableWeight,

        // -------------------------------------------------
        // VALUE / PROTECTION
        // -------------------------------------------------
        'declaredValue': _declaredValue,

        'declaredValueCurrency': _declaredValueCurrency,

        'fragile': _fragile,

        'insuranceRequested': _insuranceRequested,

        'signatureRequired': _signatureRequired,

        'additionalServices': _additionalServices.toList(),

        // -------------------------------------------------
        // DATE
        // -------------------------------------------------
        'readyDate': Timestamp.fromDate(_readyDate!),

        // Compatibility
        'pickupDate': Timestamp.fromDate(_readyDate!),

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

  Widget _premiumCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: (_) {
        setState(() {});
      },
      style: const TextStyle(
        color: _textDark,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
        suffix: suffix,
      ),
    );
  }

  Widget _dimensionField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: _textDark,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'CM',
        labelStyle: const TextStyle(color: _textGrey, fontSize: 8.5),
        suffixStyle: const TextStyle(
          color: _primaryBlue,
          fontSize: 7.5,
          fontWeight: FontWeight.w800,
        ),
        filled: true,
        fillColor: _softGrey,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _primaryBlue),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
      ),
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
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixText: suffix,
      prefixIcon: Icon(icon, color: _primaryBlue, size: 19),
      labelStyle: const TextStyle(
        color: _textGrey,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(color: Color(0xFFA4AFBB), fontSize: 10.5),
      suffixStyle: const TextStyle(
        color: _primaryBlue,
        fontSize: 9,
        fontWeight: FontWeight.w900,
      ),
      filled: true,
      fillColor: _softGrey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _primaryBlue, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFC23B3B)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFC23B3B), width: 1.4),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
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

  Future<void> _selectReadyDate() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    final result = await showDatePicker(
      context: context,
      initialDate: _readyDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: l10n.selectParcelReadyDate,
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _readyDate = result;
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
    if (value <= 0) {
      return '0';
    }

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
