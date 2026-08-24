import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'my_quotes_screen.dart';

class SeaFreightScreen extends StatefulWidget {
  const SeaFreightScreen({super.key});

  @override
  State<SeaFreightScreen> createState() => _SeaFreightScreenState();
}

class _SeaFreightScreenState extends State<SeaFreightScreen> {
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

  // =========================================================
  // FORM
  // =========================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _originController = TextEditingController();

  final TextEditingController _destinationController = TextEditingController();

  final TextEditingController _cargoController = TextEditingController();

  final TextEditingController _weightController = TextEditingController();

  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );

  final TextEditingController _volumeController = TextEditingController();

  final TextEditingController _lengthController = TextEditingController();

  final TextEditingController _widthController = TextEditingController();

  final TextEditingController _heightController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  // =========================================================
  // SEA FREIGHT OPTIONS
  // =========================================================

  String _shipmentType = 'FCL';

  String _serviceMode = 'Door to Door';

  String _containerType = '40FT HC';

  DateTime? _readyDate;

  bool _dangerousGoods = false;
  bool _insuranceRequested = false;

  final Set<String> _additionalServices = <String>{};

  final List<String> _serviceModes = const [
    'Door to Door',
    'Port to Port',
    'Door to Port',
    'Port to Door',
  ];

  final List<String> _containerTypes = const [
    '20FT Standard',
    '40FT Standard',
    '40FT HC',
    '20FT Reefer',
    '40FT Reefer',
    'Open Top',
    'Flat Rack',
  ];

  final List<String> _availableServices = const [
    'Customs Clearance',
    'Pickup',
    'Delivery',
    'Packing List Review',
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

    _lengthController.addListener(_calculateVolume);
    _widthController.addListener(_calculateVolume);
    _heightController.addListener(_calculateVolume);
    _quantityController.addListener(_calculateVolume);

    _loadCustomerProfile();
  }

  @override
  void dispose() {
    _lengthController.removeListener(_calculateVolume);
    _widthController.removeListener(_calculateVolume);
    _heightController.removeListener(_calculateVolume);
    _quantityController.removeListener(_calculateVolume);

    _originController.dispose();
    _destinationController.dispose();
    _cargoController.dispose();
    _weightController.dispose();
    _quantityController.dispose();
    _volumeController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _notesController.dispose();

    super.dispose();
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
      // Firebase Auth fallback will still be shown.
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
                      title: 'Shipment Route',
                      subtitle: 'Tell us where your cargo is moving.',
                    ),

                    const SizedBox(height: 13),

                    _buildRouteSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '02',
                      icon: Icons.directions_boat_filled_outlined,
                      title: 'Sea Freight Type',
                      subtitle: 'Choose how your cargo will be shipped.',
                    ),

                    const SizedBox(height: 13),

                    _buildShipmentTypeSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '03',
                      icon: Icons.inventory_2_outlined,
                      title: 'Cargo Information',
                      subtitle: 'Provide the main cargo specifications.',
                    ),

                    const SizedBox(height: 13),

                    _buildCargoSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '04',
                      icon: Icons.add_business_outlined,
                      title: 'Additional Services',
                      subtitle: 'Add optional logistics services if required.',
                    ),

                    const SizedBox(height: 13),

                    _buildServicesSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '05',
                      icon: Icons.person_outline_rounded,
                      title: 'Contact Details',
                      subtitle: 'Automatically filled from your account.',
                    ),

                    const SizedBox(height: 13),

                    _buildCustomerSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '06',
                      icon: Icons.notes_rounded,
                      title: 'Special Instructions',
                      subtitle: 'Anything our logistics team should know?',
                    ),

                    const SizedBox(height: 13),

                    _buildNotesSection(),

                    const SizedBox(height: 28),

                    _buildReviewCard(),

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
                            'Your shipment information is securely submitted to our logistics team.',
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
          _headerButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sea Freight Quote',
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
              Icons.directions_boat_filled_outlined,
              color: _primaryBlue,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _softGrey,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Icon(icon, color: _deepBlue, size: 23),
        ),
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
          Image.asset('assets/images/sea_freight.png', fit: BoxFit.cover),

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
                    'OCEAN FREIGHT',
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
                  'Move Your Cargo\nAcross The World',
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
                  'Submit your sea freight requirements and receive a tailored quotation from our logistics team.',
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

  // =========================================================
  // TRUST BAR
  // =========================================================

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
            child: _TrustItem(
              icon: Icons.inventory_2_outlined,
              title: 'FCL',
              subtitle: 'Full Container',
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _TrustItem(
              icon: Icons.widgets_outlined,
              title: 'LCL',
              subtitle: 'Shared Cargo',
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _TrustItem(
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
            label: 'Origin',
            hint: 'Port, city or pickup location',
            icon: Icons.trip_origin_rounded,
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
            hint: 'Port, city or delivery location',
            icon: Icons.location_on_outlined,
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
  // SHIPMENT TYPE
  // =========================================================

  Widget _buildShipmentTypeSection() {
    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipment Load',
            style: TextStyle(
              color: _textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              Expanded(
                child: _shipmentTypeButton(
                  value: 'FCL',
                  title: 'FCL',
                  subtitle: 'Full Container Load',
                  icon: Icons.inventory_2_outlined,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _shipmentTypeButton(
                  value: 'LCL',
                  title: 'LCL',
                  subtitle: 'Less Container Load',
                  icon: Icons.widgets_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _shipmentType == 'FCL'
                ? _buildFclFields()
                : _buildLclFields(),
          ),
        ],
      ),
    );
  }

  Widget _shipmentTypeButton({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _shipmentType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _shipmentType = value;
        });

        _calculateVolume();
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? _deepBlue : _softGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _deepBlue : _border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: selected ? Colors.white : _primaryBlue,
                  size: 20,
                ),

                const Spacer(),

                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
              ],
            ),

            const SizedBox(height: 13),

            Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : _textDark,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,
              style: TextStyle(
                color: selected ? const Color(0xFFD9E7F5) : _textGrey,
                fontSize: 8.5,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFclFields() {
    return Column(
      key: const ValueKey('FCL'),
      children: [
        _dropdown(
          label: 'Container Type',
          icon: Icons.view_in_ar_outlined,
          value: _containerType,
          items: _containerTypes,
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _containerType = value;
            });
          },
        ),

        const SizedBox(height: 14),

        _textField(
          controller: _quantityController,
          label: 'Number of Containers',
          hint: '1',
          icon: Icons.numbers_rounded,
          keyboardType: TextInputType.number,
          validator: _quantityValidator,
        ),
      ],
    );
  }

  Widget _buildLclFields() {
    return Column(
      key: const ValueKey('LCL'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textField(
          controller: _quantityController,
          label: 'Number of Packages / Pallets',
          hint: '1',
          icon: Icons.inventory_outlined,
          keyboardType: TextInputType.number,
          validator: _quantityValidator,
        ),

        const SizedBox(height: 16),

        const Text(
          'Package Dimensions',
          style: TextStyle(
            color: _textDark,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Enter average dimensions to calculate volume automatically.',
          style: TextStyle(color: _textGrey, fontSize: 9, height: 1.35),
        ),

        const SizedBox(height: 11),

        Row(
          children: [
            Expanded(
              child: _smallNumberField(
                controller: _lengthController,
                label: 'Length',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _smallNumberField(
                controller: _widthController,
                label: 'Width',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _smallNumberField(
                controller: _heightController,
                label: 'Height',
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        const Text(
          'Dimensions in CM',
          style: TextStyle(
            color: _textGrey,
            fontSize: 8.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
            hint: 'e.g. Machinery, Furniture, General Cargo',
            icon: Icons.category_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter cargo type';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          _textField(
            controller: _weightController,
            label: 'Gross Weight',
            hint: '0',
            suffix: 'KG',
            icon: Icons.monitor_weight_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final number = double.tryParse(value?.trim() ?? '');

              if (number == null || number <= 0) {
                return 'Please enter gross weight';
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          _textField(
            controller: _volumeController,
            label: 'Total Volume',
            hint: _shipmentType == 'LCL'
                ? 'Calculated automatically'
                : 'Optional',
            suffix: 'CBM',
            icon: Icons.view_in_ar_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (_shipmentType != 'LCL') {
                return null;
              }

              final volume = double.tryParse(value?.trim() ?? '');

              if (volume == null || volume <= 0) {
                return 'Enter cargo volume';
              }

              return null;
            },
          ),

          if (_shipmentType == 'LCL') ...[
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
                    Icons.auto_awesome_rounded,
                    color: _primaryBlue,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'CBM is calculated automatically when dimensions and quantity are entered.',
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
            subtitle: 'Request insurance options with the quotation.',
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

                const _ContactDivider(),

                _contactRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: _customerPhone.isEmpty
                      ? 'Not added to profile'
                      : _customerPhone,
                ),

                const _ContactDivider(),

                _contactRow(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  value: _customerEmail.isEmpty
                      ? 'Not added to profile'
                      : _customerEmail,
                ),

                if (_customerCompany.isNotEmpty) ...[
                  const _ContactDivider(),

                  _contactRow(
                    icon: Icons.business_outlined,
                    label: 'Company',
                    value: _customerCompany,
                  ),
                ],

                if (_customerCountry.isNotEmpty) ...[
                  const _ContactDivider(),

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
              'Special cargo requirements, preferred port, customs information, temperature requirements...',
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
  // REVIEW
  // =========================================================

  Widget _buildReviewCard() {
    final origin = _originController.text.trim().isEmpty
        ? 'Origin'
        : _originController.text.trim();

    final destination = _destinationController.text.trim().isEmpty
        ? 'Destination'
        : _destinationController.text.trim();

    final quantity = int.tryParse(_quantityController.text) ?? 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 19, 18, 18),
      decoration: BoxDecoration(
        color: _deepBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .16),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -35,
            child: Icon(
              Icons.public_rounded,
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
                    size: 20,
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
                    Icons.directions_boat_filled_outlined,
                    'Sea Freight',
                  ),

                  _summaryBadge(Icons.inventory_2_outlined, _shipmentType),

                  _summaryBadge(Icons.route_outlined, _serviceMode),

                  if (_shipmentType == 'FCL')
                    _summaryBadge(
                      Icons.view_in_ar_outlined,
                      '$quantity × $_containerType',
                    ),

                  if (_shipmentType == 'LCL' &&
                      _volumeController.text.trim().isNotEmpty)
                    _summaryBadge(
                      Icons.view_in_ar_rounded,
                      '${_volumeController.text.trim()} CBM',
                    ),
                ],
              ),

              const SizedBox(height: 17),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .10),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF7EC0FF),
                      size: 19,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Your request will be reviewed by our logistics team before an official rate is issued.',
                        style: TextStyle(
                          color: Color(0xFFD9E8F6),
                          fontSize: 9.5,
                          height: 1.4,
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
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
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
          disabledBackgroundColor: _primaryBlue.withValues(alpha: .55),
          foregroundColor: Colors.white,
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
        'Please complete the required shipment information.',
        error: true,
      );
      return;
    }

    if (_readyDate == null) {
      _showMessage('Please select the cargo ready date.', error: true);
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

      final quantity = int.parse(_quantityController.text.trim());

      final weight = double.parse(_weightController.text.trim());

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

        // Compatibility fields
        'fullName': _customerName,
        'email': _customerEmail,
        'phone': _customerPhone,

        // -------------------------------------------------
        // QUOTE
        // -------------------------------------------------
        'quoteNumber': quoteNumber,
        'requestType': 'quote',
        'serviceType': 'Sea Freight',

        // -------------------------------------------------
        // ROUTE
        // -------------------------------------------------
        'from': _originController.text.trim(),
        'to': _destinationController.text.trim(),
        'origin': _originController.text.trim(),
        'destination': _destinationController.text.trim(),
        'serviceMode': _serviceMode,

        // -------------------------------------------------
        // SEA FREIGHT
        // -------------------------------------------------
        'shipmentType': _shipmentType,
        'containerType': _shipmentType == 'FCL' ? _containerType : null,

        'quantity': quantity,

        // -------------------------------------------------
        // CARGO
        // -------------------------------------------------
        'cargoType': _cargoController.text.trim(),
        'cargo': _cargoController.text.trim(),
        'weightKg': weight,

        'volumeCbm': _parseOptionalDouble(_volumeController.text),

        'lengthCm': _shipmentType == 'LCL'
            ? _parseOptionalDouble(_lengthController.text)
            : null,

        'widthCm': _shipmentType == 'LCL'
            ? _parseOptionalDouble(_widthController.text)
            : null,

        'heightCm': _shipmentType == 'LCL'
            ? _parseOptionalDouble(_heightController.text)
            : null,

        'dangerousGoods': _dangerousGoods,

        'insuranceRequested': _insuranceRequested,

        'additionalServices': _additionalServices.toList(),

        // -------------------------------------------------
        // DATE
        // -------------------------------------------------
        'readyDate': Timestamp.fromDate(_readyDate!),

        // Keep pickupDate for current admin compatibility
        'pickupDate': Timestamp.fromDate(_readyDate!),

        // -------------------------------------------------
        // NOTES
        // -------------------------------------------------
        'notes': _notesController.text.trim(),

        // -------------------------------------------------
        // ADMIN / STATUS
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

      final reference = await FirebaseFirestore.instance
          .collection('quote_requests')
          .add(quoteData);

      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      await _showSuccessDialog(
        quoteNumber: quoteNumber,
        documentId: reference.id,
      );
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

  Future<void> _showSuccessDialog({
    required String quoteNumber,
    required String documentId,
  }) {
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
                  'Quote Request Received',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Your sea freight request has been sent securely to our logistics team.',
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
                        letterSpacing: .35,
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

  Widget _smallNumberField({
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
        labelStyle: const TextStyle(color: _textGrey, fontSize: 9),
        filled: true,
        fillColor: _softGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 7, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.3),
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
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primaryBlue),
      dropdownColor: Colors.white,
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

  Future<void> _selectReadyDate() async {
    final now = DateTime.now();

    final result = await showDatePicker(
      context: context,
      initialDate: _readyDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: 'SELECT CARGO READY DATE',
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _readyDate = result;
    });
  }

  void _calculateVolume() {
    if (_shipmentType != 'LCL') {
      return;
    }

    final length = double.tryParse(_lengthController.text.trim()) ?? 0;

    final width = double.tryParse(_widthController.text.trim()) ?? 0;

    final height = double.tryParse(_heightController.text.trim()) ?? 0;

    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    if (length <= 0 || width <= 0 || height <= 0 || quantity <= 0) {
      return;
    }

    final cbm = (length * width * height * quantity) / 1000000;

    final newValue = cbm.toStringAsFixed(3);

    if (_volumeController.text != newValue) {
      _volumeController.text = newValue;

      if (mounted) {
        setState(() {});
      }
    }
  }

  String? _quantityValidator(String? value) {
    final number = int.tryParse(value?.trim() ?? '');

    if (number == null || number <= 0) {
      return 'Enter quantity';
    }

    return null;
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

  double? _parseOptionalDouble(String value) {
    final text = value.trim();

    if (text.isEmpty) return null;

    return double.tryParse(text);
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

class _TrustItem extends StatelessWidget {
  const _TrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: _SeaFreightScreenState._primaryBlue, size: 20),

        const SizedBox(height: 6),

        Text(
          title,
          style: const TextStyle(
            color: _SeaFreightScreenState._textDark,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _SeaFreightScreenState._textGrey,
            fontSize: 7.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: _SeaFreightScreenState._border,
    );
  }
}

class _ContactDivider extends StatelessWidget {
  const _ContactDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Divider(color: _SeaFreightScreenState._border, height: 1),
    );
  }
}
