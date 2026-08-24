import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                      title: 'Moving Route',
                      subtitle:
                          'Tell us where your move starts and where your new destination is.',
                    ),

                    const SizedBox(height: 13),

                    _buildRouteSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '02',
                      icon: Icons.home_work_outlined,
                      title: 'Move Profile',
                      subtitle:
                          'Help us understand the size and type of your relocation.',
                    ),

                    const SizedBox(height: 13),

                    _buildMoveProfileSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '03',
                      icon: Icons.inventory_2_outlined,
                      title: 'Inventory Estimate',
                      subtitle:
                          'Provide a simple estimate. Final volume can be confirmed by our team.',
                    ),

                    const SizedBox(height: 13),

                    _buildInventorySection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '04',
                      icon: Icons.chair_outlined,
                      title: 'Special Items',
                      subtitle:
                          'Select items that may require special packing or handling.',
                    ),

                    const SizedBox(height: 13),

                    _buildSpecialItemsSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '05',
                      icon: Icons.design_services_outlined,
                      title: 'Moving Services',
                      subtitle:
                          'Build the moving package that fits your relocation.',
                    ),

                    const SizedBox(height: 13),

                    _buildMovingServicesSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '06',
                      icon: Icons.add_business_outlined,
                      title: 'Additional Services',
                      subtitle:
                          'Add customs and destination support if required.',
                    ),

                    const SizedBox(height: 13),

                    _buildAdditionalServicesSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '07',
                      icon: Icons.person_outline_rounded,
                      title: 'Contact Details',
                      subtitle: 'Automatically filled from your account.',
                    ),

                    const SizedBox(height: 13),

                    _buildCustomerSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '08',
                      icon: Icons.notes_rounded,
                      title: 'Special Instructions',
                      subtitle:
                          'Tell our relocation team anything else that may help planning.',
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
                            'Your moving information is securely submitted to our relocation team.',
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
                  'International Moving Quote',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.35,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'OFFICIAL RELOCATION RATE REQUEST',
                  style: TextStyle(
                    color: _primaryBlue,
                    fontSize: 8.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .95,
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
              Icons.home_work_outlined,
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
                    'GLOBAL RELOCATION',
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
                  'Move Worldwide.\nFeel At Home.',
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
                  'Premium relocation planning for homes, offices and personal effects — from collection to final delivery.',
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
            child: _MovingTrustItem(
              icon: Icons.inventory_2_outlined,
              title: 'PACK',
              subtitle: 'Professional Packing',
            ),
          ),
          _MovingDivider(),
          Expanded(
            child: _MovingTrustItem(
              icon: Icons.public_rounded,
              title: 'GLOBAL',
              subtitle: 'International Move',
            ),
          ),
          _MovingDivider(),
          Expanded(
            child: _MovingTrustItem(
              icon: Icons.home_rounded,
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
            label: 'Moving From',
            hint: 'City, building or current address',
            icon: Icons.home_outlined,
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
            label: 'Moving To',
            hint: 'City, building or destination address',
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
                  const Text(
                    'Preferred Moving Date',
                    style: TextStyle(
                      color: _textGrey,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _movingDate == null
                        ? 'Select moving date'
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
    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Move Type',
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
                child: _moveTypeButton(
                  value: 'Home Move',
                  icon: Icons.home_rounded,
                  title: 'Home',
                  subtitle: 'Household move',
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _moveTypeButton(
                  value: 'Office Move',
                  icon: Icons.business_rounded,
                  title: 'Office',
                  subtitle: 'Business move',
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _moveTypeButton(
                  value: 'Personal Effects',
                  icon: Icons.inventory_2_rounded,
                  title: 'Personal',
                  subtitle: 'Personal effects',
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _dropdown(
            label: 'Property Type',
            icon: Icons.apartment_rounded,
            value: _propertyType,
            items: _propertyTypes,
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
                ? 'Rooms / Work Areas'
                : 'Bedrooms / Rooms',
            hint: '2',
            icon: Icons.bed_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              final count = int.tryParse(value?.trim() ?? '');

              if (count == null || count <= 0) {
                return 'Enter number of rooms';
              }

              return null;
            },
          ),

          const SizedBox(height: 18),

          const Text(
            'Origin Access',
            style: TextStyle(
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
                  label: 'Floor',
                  hint: '0',
                  icon: Icons.layers_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _compactToggle(
                  title: 'Elevator',
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

          const Text(
            'Destination Access',
            style: TextStyle(
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
                  label: 'Floor',
                  hint: '0',
                  icon: Icons.layers_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _compactToggle(
                  title: 'Elevator',
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
    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _textField(
                  controller: _boxesController,
                  label: 'Estimated Boxes',
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
                  label: 'Large Items',
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
            label: 'Estimated Volume',
            hint: 'Optional — our team can confirm it',
            suffix: 'CBM',
            icon: Icons.view_in_ar_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return null;
              }

              final volume = double.tryParse(value.trim());

              if (volume == null || volume <= 0) {
                return 'Enter a valid volume';
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
                    _planningNote,
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
    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items requiring extra care',
            style: TextStyle(
              color: _textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Select all that apply.',
            style: TextStyle(color: _textGrey, fontSize: 9.5),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 9,
            children: _specialItemOptions.map((item) {
              final selected = _specialItems.contains(item);

              return FilterChip(
                label: Text(item),
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
    return _premiumCard(
      child: Column(
        children: [
          _optionSwitch(
            icon: Icons.inventory_2_outlined,
            title: 'Professional Packing',
            subtitle: 'Our moving team packs household or office items.',
            value: _packingRequired,
            onChanged: (value) {
              setState(() {
                _packingRequired = value;
              });
            },
          ),

          const _MovingCardDivider(),

          _optionSwitch(
            icon: Icons.unarchive_outlined,
            title: 'Unpacking Service',
            subtitle: 'Request unpacking support at destination.',
            value: _unpackingRequired,
            onChanged: (value) {
              setState(() {
                _unpackingRequired = value;
              });
            },
          ),

          const _MovingCardDivider(),

          _optionSwitch(
            icon: Icons.handyman_outlined,
            title: 'Furniture Disassembly',
            subtitle:
                'Dismantling support for large furniture before transport.',
            value: _furnitureDisassembly,
            onChanged: (value) {
              setState(() {
                _furnitureDisassembly = value;
              });
            },
          ),

          const _MovingCardDivider(),

          _optionSwitch(
            icon: Icons.warehouse_outlined,
            title: 'Temporary Storage',
            subtitle: 'Request storage options before final delivery.',
            value: _storageRequired,
            onChanged: (value) {
              setState(() {
                _storageRequired = value;
              });
            },
          ),

          const _MovingCardDivider(),

          _optionSwitch(
            icon: Icons.shield_outlined,
            title: 'Moving Insurance',
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

  Widget _buildAdditionalServicesSection() {
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
            children: _additionalServiceOptions.map((service) {
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

                const _MovingContactDivider(),

                _contactRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: _customerPhone.isEmpty
                      ? 'Not added to profile'
                      : _customerPhone,
                ),

                const _MovingContactDivider(),

                _contactRow(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  value: _customerEmail.isEmpty
                      ? 'Not added to profile'
                      : _customerEmail,
                ),

                if (_customerCompany.isNotEmpty) ...[
                  const _MovingContactDivider(),

                  _contactRow(
                    icon: Icons.business_outlined,
                    label: 'Company',
                    value: _customerCompany,
                  ),
                ],

                if (_customerCountry.isNotEmpty) ...[
                  const _MovingContactDivider(),

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
              'Building access, parking restrictions, fragile items, destination timing, storage details, customs notes...',
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
        ? 'Moving From'
        : _originController.text.trim();

    final destination = _destinationController.text.trim().isEmpty
        ? 'Moving To'
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
              const Row(
                children: [
                  Icon(
                    Icons.fact_check_outlined,
                    color: Colors.white,
                    size: 19,
                  ),

                  SizedBox(width: 8),

                  Text(
                    'MOVE SUMMARY',
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
                  _summaryBadge(Icons.public_rounded, 'International Moving'),

                  _summaryBadge(Icons.home_work_outlined, _moveType),

                  _summaryBadge(Icons.apartment_rounded, _propertyType),

                  _summaryBadge(
                    Icons.bed_outlined,
                    '$_roomsCount Room${_roomsCount == 1 ? '' : 's'}',
                  ),

                  _summaryBadge(Icons.inventory_2_outlined, '$_boxCount Boxes'),
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
                        _serviceSummaryText,
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
                            ? 'Final survey can confirm volume, access and packing requirements.'
                            : 'Our relocation team can confirm final volume and access requirements before issuing the rate.',
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
        'Please complete the required moving information.',
        error: true,
      );
      return;
    }

    if (_movingDate == null) {
      _showMessage('Please select your preferred moving date.', error: true);
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

      _showMessage(
        error.message ?? 'Could not submit moving quote request.',
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
                  'Moving Request Received',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Your international relocation request has been sent securely to our moving team.',
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

  String get _planningNote {
    if (_estimatedVolume > 0) {
      return 'Estimated volume entered: ${_formatNumber(_estimatedVolume)} CBM. Our team can confirm the final volume before the rate is issued.';
    }

    if (_roomsCount >= 4 || _boxCount >= 40 || _largeItemsCount >= 15) {
      return 'Large move profile detected. A pre-move survey may help confirm volume, access and packing requirements.';
    }

    if (_roomsCount >= 2 || _boxCount >= 15 || _largeItemsCount >= 7) {
      return 'Medium move profile. Final CBM can be confirmed by our relocation team before quotation.';
    }

    return 'Compact move profile. You can leave CBM blank if you do not know it — our team can confirm it.';
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

  String get _serviceSummaryText {
    final services = _combinedServices;

    if (services.isEmpty) {
      return 'Standard relocation coordination';
    }

    if (services.length <= 2) {
      return services.join(' • ');
    }

    return '${services.take(2).join(' • ')} +${services.length - 2} more';
  }

  String? _nonNegativeIntegerValidator(String? value) {
    final number = int.tryParse(value?.trim() ?? '');

    if (number == null || number < 0) {
      return 'Enter 0 or more';
    }

    return null;
  }

  Future<void> _selectMovingDate() async {
    final now = DateTime.now();

    final result = await showDatePicker(
      context: context,
      initialDate: _movingDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: 'SELECT MOVING DATE',
    );

    if (result == null || !mounted) return;

    setState(() {
      _movingDate = result;
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
// SMALL WIDGETS
// ===========================================================

class _MovingTrustItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MovingTrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: _InternationalMovingScreenState._primaryBlue,
          size: 20,
        ),

        const SizedBox(height: 6),

        Text(
          title,
          style: const TextStyle(
            color: _InternationalMovingScreenState._textDark,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _InternationalMovingScreenState._textGrey,
            fontSize: 7.5,
          ),
        ),
      ],
    );
  }
}

class _MovingDivider extends StatelessWidget {
  const _MovingDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: _InternationalMovingScreenState._border,
    );
  }
}

class _MovingContactDivider extends StatelessWidget {
  const _MovingContactDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Divider(color: _InternationalMovingScreenState._border, height: 1),
    );
  }
}

class _MovingCardDivider extends StatelessWidget {
  const _MovingCardDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Divider(color: _InternationalMovingScreenState._border, height: 1),
    );
  }
}
