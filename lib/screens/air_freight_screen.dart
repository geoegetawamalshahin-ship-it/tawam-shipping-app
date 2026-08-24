import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      // Firebase Auth information is used as fallback.
    }

    if (!mounted) return;

    setState(() {
      _customerName = name.isEmpty ? 'TAWAM Customer' : name;

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
                      title: 'Shipment Route',
                      subtitle: 'Tell us where your air cargo is moving.',
                    ),

                    const SizedBox(height: 13),

                    _buildRouteSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '02',
                      icon: Icons.bolt_rounded,
                      title: 'Air Freight Service',
                      subtitle: 'Choose the service level for your shipment.',
                    ),

                    const SizedBox(height: 13),

                    _buildAirServiceSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '03',
                      icon: Icons.inventory_2_outlined,
                      title: 'Cargo Information',
                      subtitle: 'Provide your cargo specifications.',
                    ),

                    const SizedBox(height: 13),

                    _buildCargoSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '04',
                      icon: Icons.straighten_rounded,
                      title: 'Dimensions & Weight',
                      subtitle:
                          'We calculate volumetric and chargeable weight automatically.',
                    ),

                    const SizedBox(height: 13),

                    _buildDimensionsSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '05',
                      icon: Icons.add_business_outlined,
                      title: 'Additional Services',
                      subtitle: 'Add optional logistics services if required.',
                    ),

                    const SizedBox(height: 13),

                    _buildServicesSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '06',
                      icon: Icons.person_outline_rounded,
                      title: 'Contact Details',
                      subtitle: 'Automatically filled from your account.',
                    ),

                    const SizedBox(height: 13),

                    _buildCustomerSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '07',
                      icon: Icons.notes_rounded,
                      title: 'Special Instructions',
                      subtitle: 'Anything our air freight team should know?',
                    ),

                    const SizedBox(height: 13),

                    _buildNotesSection(),

                    const SizedBox(height: 28),

                    _buildSummary(),

                    const SizedBox(height: 22),

                    _buildSubmitButton(),

                    const SizedBox(height: 14),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: _textGrey,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Your shipment information is securely submitted to our logistics team.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
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
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: _border)),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .035),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _softGrey,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: _deepBlue,
                  size: 23,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Air Freight Quote',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.35,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'OFFICIAL RATE REQUEST',
                  style: TextStyle(
                    color: _primaryBlue,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.15,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.flight_rounded,
              color: _primaryBlue,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HERO
  // =========================================================

  Widget _buildHero() {
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

          Positioned(
            left: 18,
            top: 17,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .94),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.public_rounded, color: _primaryBlue, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'GLOBAL AIR CARGO',
                    style: TextStyle(
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

          const Positioned(
            left: 19,
            right: 19,
            bottom: 19,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fast Cargo.\nGlobal Reach.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.55,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Professional air freight solutions for urgent, commercial and international cargo.',
                  style: TextStyle(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _border),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _AirTrustItem(
              icon: Icons.bolt_rounded,
              title: 'EXPRESS',
              subtitle: 'Priority Cargo',
            ),
          ),
          _AirDivider(),
          Expanded(
            child: _AirTrustItem(
              icon: Icons.flight_takeoff_rounded,
              title: 'A2A',
              subtitle: 'Airport to Airport',
            ),
          ),
          _AirDivider(),
          Expanded(
            child: _AirTrustItem(
              icon: Icons.home_work_outlined,
              title: 'D2D',
              subtitle: 'Door to Door',
            ),
          ),
        ],
      ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: _softBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _primaryBlue, size: 21),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    number,
                    style: const TextStyle(
                      color: _primaryBlue,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),

                  const SizedBox(width: 7),

                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,
                style: const TextStyle(
                  color: _textGrey,
                  fontSize: 10,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ROUTE
  // =========================================================

  Widget _buildRouteSection() {
    return _premiumCard(
      child: Column(
        children: [
          _textField(
            controller: _originController,
            label: 'Origin',
            hint: 'Airport, city or pickup location',
            icon: Icons.flight_takeoff_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter origin';
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
            label: 'Destination',
            hint: 'Airport, city or delivery location',
            icon: Icons.flight_land_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter destination';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          _dropdown(
            label: 'Service Mode',
            icon: Icons.route_outlined,
            value: _serviceMode,
            items: _serviceModes,
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
                  const Text(
                    'Cargo Ready Date',
                    style: TextStyle(color: _textGrey, fontSize: 9.5),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _readyDate == null
                        ? 'Select ready date'
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
  // AIR SERVICE
  // =========================================================

  Widget _buildAirServiceSection() {
    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Level',
            style: TextStyle(
              color: _textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          _airServiceOption(
            value: 'Standard',
            icon: Icons.flight_rounded,
            title: 'Standard Air Freight',
            subtitle: 'Reliable international air cargo for regular shipments.',
          ),

          const SizedBox(height: 10),

          _airServiceOption(
            value: 'Express',
            icon: Icons.bolt_rounded,
            title: 'Express Air Freight',
            subtitle: 'Faster handling for urgent and time-sensitive cargo.',
          ),

          const SizedBox(height: 10),

          _airServiceOption(
            value: 'Priority',
            icon: Icons.workspace_premium_outlined,
            title: 'Priority / Time Critical',
            subtitle: 'Priority handling for highly urgent shipments.',
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
    return _premiumCard(
      child: Column(
        children: [
          _textField(
            controller: _cargoController,
            label: 'Cargo Type',
            hint: 'e.g. Electronics, Machinery, General Cargo',
            icon: Icons.category_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter cargo type';
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          _dropdown(
            label: 'Package Type',
            icon: Icons.inventory_2_outlined,
            value: _packageType,
            items: _packageTypes,
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
            label: 'Number of Pieces',
            hint: '1',
            icon: Icons.numbers_rounded,
            keyboardType: TextInputType.number,
            validator: (value) {
              final number = int.tryParse(value?.trim() ?? '');

              if (number == null || number <= 0) {
                return 'Enter number of pieces';
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          _optionSwitch(
            icon: Icons.warning_amber_rounded,
            title: 'Dangerous Goods',
            subtitle: 'Cargo classified as hazardous / DG.',
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
            title: 'Cargo Insurance',
            subtitle: 'Request cargo insurance with the quotation.',
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
    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _textField(
            controller: _weightController,
            label: 'Gross Weight',
            hint: '0',
            suffix: 'KG',
            icon: Icons.monitor_weight_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final weight = double.tryParse(value?.trim() ?? '');

              if (weight == null || weight <= 0) {
                return 'Please enter gross weight';
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          const Text(
            'Average Piece Dimensions',
            style: TextStyle(
              color: _textDark,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Enter dimensions in centimeters.',
            style: TextStyle(color: _textGrey, fontSize: 9),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _dimensionField(
                  controller: _lengthController,
                  label: 'Length',
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _dimensionField(
                  controller: _widthController,
                  label: 'Width',
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _dimensionField(
                  controller: _heightController,
                  label: 'Height',
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
                const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF7FC2FF),
                      size: 18,
                    ),

                    SizedBox(width: 8),

                    Text(
                      'AUTOMATIC AIR FREIGHT CALCULATION',
                      style: TextStyle(
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
                        'Actual',
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
                        'Volumetric',
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

                      const Expanded(
                        child: Text(
                          'Chargeable Weight',
                          style: TextStyle(
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
                  'Cargo volume: ${_volumeCbm.toStringAsFixed(3)} CBM',
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
  // SERVICES
  // =========================================================

  Widget _buildServicesSection() {
    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select services',
            style: TextStyle(
              color: _textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'You can choose more than one.',
            style: TextStyle(color: _textGrey, fontSize: 9.5),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 9,
            children: _availableServices.map((service) {
              final selected = _additionalServices.contains(service);

              return FilterChip(
                label: Text(service),
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
                  child: const Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: _success,
                        size: 18,
                      ),

                      SizedBox(width: 9),

                      Expanded(
                        child: Text(
                          'Contact details automatically filled from your account.',
                          style: TextStyle(
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
                  'Full Name',
                  _customerName,
                ),

                const _AirContactDivider(),

                _contactRow(
                  Icons.phone_outlined,
                  'Phone Number',
                  _customerPhone.isEmpty
                      ? 'Not added to profile'
                      : _customerPhone,
                ),

                const _AirContactDivider(),

                _contactRow(
                  Icons.email_outlined,
                  'Email Address',
                  _customerEmail.isEmpty
                      ? 'Not added to profile'
                      : _customerEmail,
                ),

                if (_customerCompany.isNotEmpty) ...[
                  const _AirContactDivider(),
                  _contactRow(
                    Icons.business_outlined,
                    'Company',
                    _customerCompany,
                  ),
                ],

                if (_customerCountry.isNotEmpty) ...[
                  const _AirContactDivider(),
                  _contactRow(
                    Icons.public_outlined,
                    'Country',
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
          hintText:
              'Special handling, airline requirements, temperature requirements, delivery deadline...',
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
    final origin = _originController.text.trim().isEmpty
        ? 'Origin'
        : _originController.text.trim();

    final destination = _destinationController.text.trim().isEmpty
        ? 'Destination'
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
          const Row(
            children: [
              Icon(Icons.fact_check_outlined, color: Colors.white, size: 19),

              SizedBox(width: 8),

              Text(
                'REQUEST SUMMARY',
                style: TextStyle(
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
              _summaryBadge('Air Freight'),
              _summaryBadge(_airServiceType),
              _summaryBadge(_serviceMode),
              _summaryBadge('$_pieces Pieces'),
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

                const Expanded(
                  child: Text(
                    'Chargeable Weight',
                    style: TextStyle(color: Color(0xFFD9E8F6), fontSize: 9.5),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // =========================================================
  // SUBMIT
  // =========================================================

  Widget _buildSubmitButton() {
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
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flight_takeoff_rounded, size: 21),

                  SizedBox(width: 10),

                  Text(
                    'REQUEST OFFICIAL QUOTE',
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

    if (!_formKey.currentState!.validate()) {
      _showMessage(
        'Please complete the required shipment information.',
        error: true,
      );

      return;
    }

    if (_readyDate == null) {
      _showMessage('Please select the cargo ready date.', error: true);

      return;
    }

    if (_length <= 0 || _width <= 0 || _height <= 0) {
      _showMessage('Please enter the cargo dimensions.', error: true);

      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please sign in before requesting a quote.', error: true);

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
        error.message ?? 'Could not submit quote request.',
        error: true,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      _showMessage('Something went wrong. Please try again.', error: true);
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

                const Text(
                  'Air Freight Request Received',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Your air freight request has been sent securely to our logistics team.',
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
                      const Text(
                        'REQUEST NUMBER',
                        style: TextStyle(
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
                    child: const Text(
                      'VIEW MY QUOTES',
                      style: TextStyle(
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
                    child: const Text('DONE'),
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
      onChanged: (_) => setState(() {}),
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
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primaryBlue),
      decoration: _inputDecoration(label: label, hint: '', icon: icon),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
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
      labelStyle: const TextStyle(color: _textGrey, fontSize: 10),
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
      helpText: 'SELECT CARGO READY DATE',
    );

    if (result == null || !mounted) return;

    setState(() {
      _readyDate = result;
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatNumber(double value) {
    if (value <= 0) return '0';

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

// ===========================================================
// TRUST ITEM
// ===========================================================

class _AirTrustItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AirTrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: _AirFreightScreenState._primaryBlue, size: 20),

        const SizedBox(height: 6),

        Text(
          title,
          style: const TextStyle(
            color: _AirFreightScreenState._textDark,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _AirFreightScreenState._textGrey,
            fontSize: 7.5,
          ),
        ),
      ],
    );
  }
}

class _AirDivider extends StatelessWidget {
  const _AirDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: _AirFreightScreenState._border,
    );
  }
}

class _AirContactDivider extends StatelessWidget {
  const _AirContactDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Divider(color: _AirFreightScreenState._border, height: 1),
    );
  }
}
