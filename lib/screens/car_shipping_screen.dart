import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'my_quotes_screen.dart';

class CarShippingScreen extends StatefulWidget {
  const CarShippingScreen({super.key});

  @override
  State<CarShippingScreen> createState() => _CarShippingScreenState();
}

class _CarShippingScreenState extends State<CarShippingScreen> {
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

  final TextEditingController _vehicleCountController = TextEditingController(
    text: '1',
  );

  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final TextEditingController _vinController = TextEditingController();

  final TextEditingController _vehicleValueController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  // =========================================================
  // CAR SHIPPING OPTIONS
  // =========================================================

  String _serviceMode = 'Door to Door';
  String _shippingMethod = 'Open Carrier';
  String _vehicleType = 'SUV';
  String _vehicleCondition = 'Running';
  String _valueCurrency = 'AED';

  DateTime? _readyDate;

  bool _insuranceRequested = false;
  bool _priorityHandling = false;

  final Set<String> _additionalServices = <String>{};

  final List<String> _serviceModes = const [
    'Door to Door',
    'Port to Port',
    'Door to Port',
    'Port to Door',
  ];

  final List<String> _vehicleTypes = const [
    'Sedan',
    'SUV',
    'Pickup',
    'Van',
    'Motorcycle',
    'Luxury / Classic',
    'Commercial Vehicle',
    'Other',
  ];

  final List<String> _vehicleConditions = const [
    'Running',
    'Non-Running',
    'Damaged / Accident',
  ];

  final List<String> _currencies = const ['AED', 'USD', 'EUR'];

  final List<String> _availableServices = const [
    'Pickup',
    'Delivery',
    'Customs Clearance',
    'Export Documentation',
    'Vehicle Inspection',
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

    _vehicleCountController.addListener(_refreshSummary);
    _makeController.addListener(_refreshSummary);
    _modelController.addListener(_refreshSummary);
    _yearController.addListener(_refreshSummary);

    _loadCustomerProfile();
  }

  @override
  void dispose() {
    _vehicleCountController.removeListener(_refreshSummary);
    _makeController.removeListener(_refreshSummary);
    _modelController.removeListener(_refreshSummary);
    _yearController.removeListener(_refreshSummary);

    _originController.dispose();
    _destinationController.dispose();
    _vehicleCountController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _vehicleValueController.dispose();
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
      // Keep Firebase Auth data as fallback.
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
                      title: 'Transport Route',
                      subtitle:
                          'Tell us where your vehicle needs to be collected and delivered.',
                    ),

                    const SizedBox(height: 13),

                    _buildRouteSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '02',
                      icon: Icons.directions_car_filled_outlined,
                      title: 'Vehicle Information',
                      subtitle:
                          'Provide the vehicle details required for accurate transport planning.',
                    ),

                    const SizedBox(height: 13),

                    _buildVehicleSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '03',
                      icon: Icons.local_shipping_outlined,
                      title: 'Shipping Method',
                      subtitle:
                          'Choose how you would like the vehicle to be transported.',
                    ),

                    const SizedBox(height: 13),

                    _buildShippingMethodSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '04',
                      icon: Icons.verified_user_outlined,
                      title: 'Vehicle Protection',
                      subtitle:
                          'Add insurance or priority handling to your quotation request.',
                    ),

                    const SizedBox(height: 13),

                    _buildProtectionSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '05',
                      icon: Icons.add_business_outlined,
                      title: 'Additional Services',
                      subtitle:
                          'Add customs, pickup, delivery and documentation support.',
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
                      subtitle:
                          'Add any vehicle, pickup, port or delivery instructions.',
                    ),

                    const SizedBox(height: 13),

                    _buildNotesSection(),

                    const SizedBox(height: 28),

                    _buildSummary(),

                    const SizedBox(height: 22),

                    _buildSubmitButton(),

                    const SizedBox(height: 13),

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
                            'Your vehicle information is securely submitted to our logistics team.',
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
                  'Car Shipping Quote',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.35,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'OFFICIAL VEHICLE RATE REQUEST',
                  style: TextStyle(
                    color: _primaryBlue,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.05,
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
              Icons.directions_car_filled_outlined,
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
          Image.asset('assets/images/car_shipping.png', fit: BoxFit.cover),

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
                  Icon(
                    Icons.verified_user_outlined,
                    color: _primaryBlue,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'SECURE VEHICLE LOGISTICS',
                    style: TextStyle(
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

          const Positioned(
            left: 19,
            right: 19,
            bottom: 19,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Vehicle.\nHandled Professionally.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.55,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Premium regional and international vehicle transport with flexible shipping options.',
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
            child: _CarTrustItem(
              icon: Icons.local_shipping_outlined,
              title: 'ROAD',
              subtitle: 'Carrier Transport',
            ),
          ),
          _CarDivider(),
          Expanded(
            child: _CarTrustItem(
              icon: Icons.directions_boat_outlined,
              title: 'RoRo',
              subtitle: 'Port Shipping',
            ),
          ),
          _CarDivider(),
          Expanded(
            child: _CarTrustItem(
              icon: Icons.inventory_2_outlined,
              title: 'CONTAINER',
              subtitle: 'Protected Shipping',
            ),
          ),
        ],
      ),
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
                        letterSpacing: -.2,
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
                  fontWeight: FontWeight.w500,
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
            label: 'Pickup / Origin',
            hint: 'City, address, showroom or port',
            icon: Icons.trip_origin_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter pickup / origin';
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
            label: 'Delivery / Destination',
            hint: 'City, address, warehouse or port',
            icon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter delivery / destination';
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
                    'Vehicle Ready Date',
                    style: TextStyle(
                      color: _textGrey,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
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
  // VEHICLE
  // =========================================================

  Widget _buildVehicleSection() {
    return _premiumCard(
      child: Column(
        children: [
          _dropdown(
            label: 'Vehicle Type',
            icon: Icons.directions_car_filled_outlined,
            value: _vehicleType,
            items: _vehicleTypes,
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _vehicleType = value;
              });
            },
          ),

          const SizedBox(height: 14),

          _textField(
            controller: _vehicleCountController,
            label: 'Number of Vehicles',
            hint: '1',
            icon: Icons.numbers_rounded,
            keyboardType: TextInputType.number,
            validator: (value) {
              final count = int.tryParse(value?.trim() ?? '');

              if (count == null || count <= 0) {
                return 'Enter number of vehicles';
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _textField(
                  controller: _makeController,
                  label: 'Make',
                  hint: 'Toyota',
                  icon: Icons.badge_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter make';
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _textField(
                  controller: _modelController,
                  label: 'Model',
                  hint: 'Land Cruiser',
                  icon: Icons.directions_car_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter model';
                    }

                    return null;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _textField(
            controller: _yearController,
            label: 'Model Year',
            hint: '2024',
            icon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              final year = int.tryParse(value?.trim() ?? '');
              final maxYear = DateTime.now().year + 1;

              if (year == null || year < 1900 || year > maxYear) {
                return 'Enter a valid model year';
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          _dropdown(
            label: 'Vehicle Condition',
            icon: Icons.car_repair_outlined,
            value: _vehicleCondition,
            items: _vehicleConditions,
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _vehicleCondition = value;
              });
            },
          ),

          if (_vehicleCondition != 'Running') ...[
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5E6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF2D9AC)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFB26A00),
                    size: 18,
                  ),

                  SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      'Special loading equipment may be required for non-running or damaged vehicles.',
                      style: TextStyle(
                        color: Color(0xFF8A5800),
                        fontSize: 9.2,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          _textField(
            controller: _vinController,
            label: 'VIN / Chassis Number',
            hint: 'Optional',
            icon: Icons.pin_outlined,
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _textField(
                  controller: _vehicleValueController,
                  label: 'Vehicle Value',
                  hint: 'Optional',
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
                      return 'Invalid value';
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(width: 10),

              SizedBox(
                width: 92,
                child: DropdownButtonFormField<String>(
                  initialValue: _valueCurrency,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Currency',
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
                      _valueCurrency = value;
                    });
                  },
                ),
              ),
            ],
          ),

          if (_vehicleCount > 1) ...[
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: _softBlue,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: _primaryBlue,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'If the vehicles are different models or conditions, add the remaining vehicle details under Special Instructions.',
                      style: TextStyle(
                        color: _primaryBlue,
                        fontSize: 9,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // SHIPPING METHOD
  // =========================================================

  Widget _buildShippingMethodSection() {
    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transport Method',
            style: TextStyle(
              color: _textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Choose the option that best fits your route and vehicle.',
            style: TextStyle(color: _textGrey, fontSize: 9.5),
          ),

          const SizedBox(height: 14),

          _methodOption(
            value: 'Open Carrier',
            icon: Icons.local_shipping_outlined,
            title: 'Open Carrier',
            subtitle: 'Cost-effective road transport for standard vehicles.',
          ),

          const SizedBox(height: 10),

          _methodOption(
            value: 'Enclosed Carrier',
            icon: Icons.inventory_2_outlined,
            title: 'Enclosed Carrier',
            subtitle:
                'Enhanced protection for luxury, classic or high-value vehicles.',
          ),

          const SizedBox(height: 10),

          _methodOption(
            value: 'RoRo',
            icon: Icons.directions_boat_outlined,
            title: 'RoRo Shipping',
            subtitle: 'Roll-on / roll-off international port shipping.',
          ),

          const SizedBox(height: 10),

          _methodOption(
            value: 'Container',
            icon: Icons.view_in_ar_outlined,
            title: 'Container Shipping',
            subtitle: 'Containerized international vehicle transportation.',
          ),
        ],
      ),
    );
  }

  Widget _methodOption({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _shippingMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _shippingMethod = value;
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
  // PROTECTION
  // =========================================================

  Widget _buildProtectionSection() {
    return _premiumCard(
      child: Column(
        children: [
          _optionSwitch(
            icon: Icons.shield_outlined,
            title: 'Cargo / Vehicle Insurance',
            subtitle: 'Request insurance options together with your quotation.',
            value: _insuranceRequested,
            onChanged: (value) {
              setState(() {
                _insuranceRequested = value;
              });
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Divider(color: _border, height: 1),
          ),

          _optionSwitch(
            icon: Icons.workspace_premium_outlined,
            title: 'Priority Handling',
            subtitle:
                'Request priority coordination for a time-sensitive vehicle movement.',
            value: _priorityHandling,
            onChanged: (value) {
              setState(() {
                _priorityHandling = value;
              });
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // ADDITIONAL SERVICES
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
                  label: 'Full Name',
                  value: _customerName,
                ),

                const _CarContactDivider(),

                _contactRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: _customerPhone.isEmpty
                      ? 'Not added to profile'
                      : _customerPhone,
                ),

                const _CarContactDivider(),

                _contactRow(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  value: _customerEmail.isEmpty
                      ? 'Not added to profile'
                      : _customerEmail,
                ),

                if (_customerCompany.isNotEmpty) ...[
                  const _CarContactDivider(),

                  _contactRow(
                    icon: Icons.business_outlined,
                    label: 'Company',
                    value: _customerCompany,
                  ),
                ],

                if (_customerCountry.isNotEmpty) ...[
                  const _CarContactDivider(),

                  _contactRow(
                    icon: Icons.public_outlined,
                    label: 'Country',
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
              'Extra vehicle details, access restrictions, multiple vehicle models, port instructions, preferred pickup time...',
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
    final origin = _originController.text.trim().isEmpty
        ? 'Pickup'
        : _originController.text.trim();

    final destination = _destinationController.text.trim().isEmpty
        ? 'Destination'
        : _destinationController.text.trim();

    final vehicleLabel = _vehicleLabel;

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
              Icons.directions_car_filled_rounded,
              size: 125,
              color: Colors.white.withValues(alpha: .04),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.fact_check_outlined,
                    color: Colors.white,
                    size: 19,
                  ),

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
                    Icons.directions_car_filled_outlined,
                    'Car Shipping',
                  ),

                  _summaryBadge(Icons.local_shipping_outlined, _shippingMethod),

                  _summaryBadge(Icons.route_outlined, _serviceMode),

                  _summaryBadge(
                    Icons.numbers_rounded,
                    '$_vehicleCount Vehicle${_vehicleCount == 1 ? '' : 's'}',
                  ),

                  _summaryBadge(Icons.car_repair_outlined, _vehicleCondition),
                ],
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_car_rounded,
                      color: Color(0xFF7EC0FF),
                      size: 19,
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        vehicleLabel,
                        style: const TextStyle(
                          color: Color(0xFFD9E8F6),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    if (_priorityHandling)
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFF86CAFF),
                        size: 18,
                      ),
                  ],
                ),
              ),

              if (_vehicleCondition != 'Running') ...[
                const SizedBox(height: 9),

                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.construction_rounded,
                        color: Color(0xFF7EC0FF),
                        size: 18,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Special loading requirement flagged automatically.',
                          style: TextStyle(
                            color: Color(0xFFD9E8F6),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                  Icon(Icons.request_quote_outlined, size: 21),

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
        'Please complete the required vehicle and route information.',
        error: true,
      );
      return;
    }

    if (_readyDate == null) {
      _showMessage('Please select the vehicle ready date.', error: true);
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

      final vehicleValue = _vehicleValueController.text.trim().isEmpty
          ? null
          : double.tryParse(_vehicleValueController.text.trim());

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
        'serviceType': 'Car Shipping',

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
        // VEHICLE / CAR SHIPPING
        // -------------------------------------------------
        'shippingMethod': _shippingMethod,

        'vehicleType': _vehicleType,
        'vehicleCount': _vehicleCount,

        // Compatibility with generic quantity fields
        'quantity': _vehicleCount,

        'vehicleMake': _makeController.text.trim(),
        'make': _makeController.text.trim(),

        'vehicleModel': _modelController.text.trim(),
        'model': _modelController.text.trim(),

        'vehicleYear': int.parse(_yearController.text.trim()),
        'year': int.parse(_yearController.text.trim()),

        'vehicleCondition': _vehicleCondition,

        'isRunning': _vehicleCondition == 'Running',

        'specialLoadingRequired': _vehicleCondition != 'Running',

        'vin': _vinController.text.trim(),
        'chassisNumber': _vinController.text.trim(),

        'vehicleValue': vehicleValue,

        'vehicleValueCurrency': _valueCurrency,

        'insuranceRequested': _insuranceRequested,

        'priorityHandling': _priorityHandling,

        'additionalServices': _additionalServices.toList(),

        // Helpful generic cargo text for old admin/search screens
        'cargoType':
            '$_vehicleType • ${_makeController.text.trim()} ${_modelController.text.trim()}',

        'cargo':
            '$_vehicleType • ${_makeController.text.trim()} ${_modelController.text.trim()}',

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

      _showMessage(
        error.message ?? 'Could not submit vehicle quote request.',
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
                  'Car Shipping Request Received',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Your vehicle transport request has been sent securely to our logistics team.',
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _deepBlue,
                      side: const BorderSide(color: _border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'DONE',
                      style: TextStyle(
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
      style: const TextStyle(
        color: _textDark,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
      ),
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

  int get _vehicleCount {
    final value = int.tryParse(_vehicleCountController.text.trim());

    if (value == null || value <= 0) {
      return 1;
    }

    return value;
  }

  String get _vehicleLabel {
    final make = _makeController.text.trim();
    final model = _modelController.text.trim();
    final year = _yearController.text.trim();

    final parts = <String>[
      if (year.isNotEmpty) year,
      if (make.isNotEmpty) make,
      if (model.isNotEmpty) model,
    ];

    if (parts.isEmpty) {
      return _vehicleType;
    }

    return '${parts.join(' ')} • $_vehicleType';
  }

  Future<void> _selectReadyDate() async {
    final now = DateTime.now();

    final result = await showDatePicker(
      context: context,
      initialDate: _readyDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: 'SELECT VEHICLE READY DATE',
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
// SMALL WIDGETS
// ===========================================================

class _CarTrustItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _CarTrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: _CarShippingScreenState._primaryBlue, size: 20),

        const SizedBox(height: 6),

        Text(
          title,
          style: const TextStyle(
            color: _CarShippingScreenState._textDark,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _CarShippingScreenState._textGrey,
            fontSize: 7.5,
          ),
        ),
      ],
    );
  }
}

class _CarDivider extends StatelessWidget {
  const _CarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: _CarShippingScreenState._border,
    );
  }
}

class _CarContactDivider extends StatelessWidget {
  const _CarContactDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Divider(color: _CarShippingScreenState._border, height: 1),
    );
  }
}
