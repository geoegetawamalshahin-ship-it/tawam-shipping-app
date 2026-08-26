import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
import 'my_quotes_screen.dart';

class LandFreightScreen extends StatefulWidget {
  const LandFreightScreen({super.key});

  @override
  State<LandFreightScreen> createState() => _LandFreightScreenState();
}

class _LandFreightScreenState extends State<LandFreightScreen> {
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

  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();

  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // =========================================================
  // LAND FREIGHT OPTIONS
  // =========================================================

  String _loadType = 'FTL';
  String _weightUnit = 'KG';

  final List<String> _weightUnits = const ['KG', 'TON'];
  String _serviceMode = 'Door to Door';
  String _truckType = 'Recommend for Me';
  String _packageType = 'Pallets';

  DateTime? _readyDate;

  bool _dangerousGoods = false;
  bool _insuranceRequested = false;
  bool _oversizedCargo = false;

  final Set<String> _additionalServices = <String>{};

  final List<String> _serviceModes = const [
    'Door to Door',
    'Depot to Depot',
    'Door to Depot',
    'Depot to Door',
  ];

  final List<String> _truckTypes = const [
    'Recommend for Me',
    'Curtain Side',
    'Box Truck',
    'Flatbed',
    'Reefer',
    'Lowbed',
  ];

  final List<String> _packageTypes = const [
    'Pallets',
    'Boxes',
    'Crates',
    'Bags',
    'Loose Cargo',
  ];

  final List<String> _availableServices = const [
    'Customs Clearance',
    'Pickup',
    'Delivery',
    'Border Documentation',
    'Loading / Unloading',
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
    _quantityController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _temperatureController.dispose();
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
      // Firebase Auth data is kept as fallback.
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
                      icon: Icons.local_shipping_rounded,
                      title: l10n.transportType,
                      subtitle: l10n.chooseFtlLtl,
                    ),

                    const SizedBox(height: 13),

                    _buildTransportSection(),

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

                    if (_loadType == 'LTL') ...[
                      _sectionTitle(
                        number: '04',
                        icon: Icons.straighten_rounded,
                        title: l10n.dimensionsWeight,
                        subtitle: l10n.weCalculateVolumetric,
                      ),

                      const SizedBox(height: 13),

                      _buildDimensionsSection(),

                      const SizedBox(height: 28),
                    ],

                    _sectionTitle(
                      number: _loadType == 'LTL' ? '05' : '04',
                      icon: Icons.health_and_safety_outlined,
                      title: l10n.cargoRequirements,
                      subtitle: l10n.anythingTeamShouldKnow,
                    ),

                    const SizedBox(height: 13),

                    _buildRequirementsSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: _loadType == 'LTL' ? '06' : '05',
                      icon: Icons.add_business_outlined,
                      title: l10n.additionalServices,
                      subtitle: l10n.addOptionalLogistics,
                    ),

                    const SizedBox(height: 13),

                    _buildServicesSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: _loadType == 'LTL' ? '07' : '06',
                      icon: Icons.person_outline_rounded,
                      title: l10n.contactDetails,
                      subtitle: l10n.contactFilledFromAccount,
                    ),

                    const SizedBox(height: 13),

                    _buildCustomerSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: _loadType == 'LTL' ? '08' : '07',
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
                            style: const TextStyle(
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

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.landFreightQuote,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.officialRateRequest,
                  style: const TextStyle(
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
              Icons.local_shipping_rounded,
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
          Image.asset('assets/images/land_freight.png', fit: BoxFit.cover),

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
                  const Icon(Icons.route_rounded, color: _primaryBlue, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    l10n.regionalRoadFreight,
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
                  l10n.landHeroTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.55,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  l10n.landHeroSubtitle,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _LandTrustItem(
              icon: Icons.local_shipping_outlined,
              title: 'FTL',
              subtitle: _optionLabel(l10n, 'Full Truck Load'),
            ),
          ),
          const _LandDivider(),
          Expanded(
            child: _LandTrustItem(
              icon: Icons.inventory_2_outlined,
              title: 'LTL',
              subtitle: _optionLabel(l10n, 'Partial Load'),
            ),
          ),
          const _LandDivider(),
          Expanded(
            child: _LandTrustItem(
              icon: Icons.public_rounded,
              title: l10n.badgeXBorder,
              subtitle: l10n.regionalRoutes,
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
    final l10n = AppLocalizations.of(context)!;

    return _premiumCard(
      child: Column(
        children: [
          _textField(
            controller: _originController,
            label: l10n.pickupLocation,
            hint: l10n.enterPickupLocation,
            icon: Icons.trip_origin_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterPickupLocation;
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
            label: l10n.deliveryLocation,
            hint: l10n.enterDeliveryLocation,
            icon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterDeliveryLocation;
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
                    style: const TextStyle(
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
  // TRANSPORT TYPE
  // =========================================================

  Widget _buildTransportSection() {
    final l10n = AppLocalizations.of(context)!;

    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.loadType,
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
                child: _loadTypeButton(
                  value: 'FTL',
                  title: 'FTL',
                  subtitle: _optionLabel(l10n, 'Full Truck Load'),
                  icon: Icons.local_shipping_rounded,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _loadTypeButton(
                  value: 'LTL',
                  title: 'LTL',
                  subtitle: _optionLabel(l10n, 'Less Than Truck Load'),
                  icon: Icons.inventory_2_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _loadType == 'FTL' ? _buildFtlFields() : _buildLtlFields(),
          ),
        ],
      ),
    );
  }

  Widget _loadTypeButton({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _loadType == value;

    return InkWell(
      onTap: () {
        setState(() {
          _loadType = value;
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

  Widget _buildFtlFields() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      key: const ValueKey('FTL'),
      children: [
        _dropdown(
          label: l10n.truckTrailerType,
          icon: Icons.local_shipping_outlined,
          value: _truckType,
          items: _truckTypes,
          itemLabel: (item) => _optionLabel(l10n, item),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _truckType = value;

              if (_truckType != 'Reefer') {
                _temperatureController.clear();
              }
            });
          },
        ),

        const SizedBox(height: 14),

        _textField(
          controller: _quantityController,
          label: l10n.numberOfTrucks,
          hint: '1',
          icon: Icons.numbers_rounded,
          keyboardType: TextInputType.number,
          validator: _quantityValidator,
        ),

        if (_truckType == 'Reefer') ...[
          const SizedBox(height: 14),

          _textField(
            controller: _temperatureController,
            label: l10n.requiredTemperature,
            hint: l10n.hintTemperature,
            suffix: '°C',
            icon: Icons.thermostat_rounded,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            validator: (value) {
              if (_truckType != 'Reefer') return null;

              final temperature = double.tryParse(value?.trim() ?? '');

              if (temperature == null) {
                return l10n.enterRequiredTemperature;
              }

              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLtlFields() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      key: const ValueKey('LTL'),
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
          controller: _quantityController,
          label: l10n.numberOfPackagesPallets,
          hint: '1',
          icon: Icons.numbers_rounded,
          keyboardType: TextInputType.number,
          validator: _quantityValidator,
        ),

        const SizedBox(height: 14),

        _dropdown(
          label: l10n.preferredVehicle,
          icon: Icons.local_shipping_outlined,
          value: _truckType,
          items: _truckTypes,
          itemLabel: (item) => _optionLabel(l10n, item),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _truckType = value;

              if (_truckType != 'Reefer') {
                _temperatureController.clear();
              }
            });
          },
        ),

        if (_truckType == 'Reefer') ...[
          const SizedBox(height: 14),

          _textField(
            controller: _temperatureController,
            label: l10n.requiredTemperature,
            hint: l10n.hintTemperature,
            suffix: '°C',
            icon: Icons.thermostat_rounded,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            validator: (value) {
              if (_truckType != 'Reefer') return null;

              final temperature = double.tryParse(value?.trim() ?? '');

              if (temperature == null) {
                return l10n.enterRequiredTemperature;
              }

              return null;
            },
          ),
        ],
      ],
    );
  }

  // =========================================================
  // CARGO
  // =========================================================

  Widget _buildCargoSection() {
    final l10n = AppLocalizations.of(context)!;

    return _premiumCard(
      child: Column(
        children: [
          _textField(
            controller: _cargoController,
            label: l10n.cargoType,
            hint: l10n.hintCargoLand,
            icon: Icons.category_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterCargoType;
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
                  controller: _weightController,
                  label: l10n.grossWeight,
                  hint: '0',
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final weight = double.tryParse(value?.trim() ?? '');

                    if (weight == null || weight <= 0) {
                      return l10n.pleaseEnterGrossWeight;
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(width: 10),

              SizedBox(
                width: 90,
                child: DropdownButtonFormField<String>(
                  initialValue: _weightUnit,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.unit,
                    filled: true,
                    fillColor: _softGrey,
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
                  items: _weightUnits
                      .map(
                        (unit) => DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _weightUnit = value;
                    });
                  },
                ),
              ),
            ],
          ),

          if (_loadType == 'FTL') ...[
            const SizedBox(height: 14),

            _textField(
              controller: _volumeController,
              label: l10n.totalVolume,
              hint: l10n.optional,
              suffix: 'CBM',
              icon: Icons.view_in_ar_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // LTL DIMENSIONS / AUTO CBM
  // =========================================================

  Widget _buildDimensionsSection() {
    final l10n = AppLocalizations.of(context)!;

    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.averagePackageDimensions,
            style: const TextStyle(
              color: _textDark,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            l10n.enterDimensionsCm,
            style: TextStyle(color: _textGrey, fontSize: 9, height: 1.35),
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

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _deepBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF7EC0FF),
                  size: 19,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.automaticVolume,
                        style: const TextStyle(
                          color: Color(0xFFCFE1F3),
                          fontSize: 7.8,
                          letterSpacing: .8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        l10n.calculatedFromDimensionsQty,
                        style: const TextStyle(
                          color: Color(0xFFD9E8F6),
                          fontSize: 8.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  '${_formattedVolume()} CBM',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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

  // =========================================================
  // REQUIREMENTS
  // =========================================================

  Widget _buildRequirementsSection() {
    final l10n = AppLocalizations.of(context)!;

    return _premiumCard(
      child: Column(
        children: [
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
            icon: Icons.straighten_rounded,
            title: l10n.oversizedCargo,
            subtitle: l10n.oversizedMayNeedTrailer,
            value: _oversizedCargo,
            onChanged: (value) {
              setState(() {
                _oversizedCargo = value;
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

                      const SizedBox(width: 9),

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

                const _LandContactDivider(),

                _contactRow(
                  icon: Icons.phone_outlined,
                  label: l10n.phoneNumber,
                  value: _customerPhone.isEmpty
                      ? l10n.notProvided
                      : _customerPhone,
                ),

                const _LandContactDivider(),

                _contactRow(
                  icon: Icons.email_outlined,
                  label: l10n.emailAddress,
                  value: _customerEmail.isEmpty
                      ? l10n.notProvided
                      : _customerEmail,
                ),

                if (_customerCompany.isNotEmpty) ...[
                  const _LandContactDivider(),

                  _contactRow(
                    icon: Icons.business_outlined,
                    label: l10n.company,
                    value: _customerCompany,
                  ),
                ],

                if (_customerCountry.isNotEmpty) ...[
                  const _LandContactDivider(),

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
        ? l10n.pickup
        : _originController.text.trim();

    final destination = _destinationController.text.trim().isEmpty
        ? l10n.delivery
        : _destinationController.text.trim();

    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;

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
              Icons.local_shipping_rounded,
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
                    Icons.local_shipping_rounded,
                    LocaleController.serviceLabel(l10n, 'Land Freight'),
                  ),

                  _summaryBadge(Icons.inventory_2_outlined, _loadType),

                  _summaryBadge(
                    Icons.route_outlined,
                    _optionLabel(l10n, _serviceMode),
                  ),

                  if (_loadType == 'FTL')
                    _summaryBadge(
                      Icons.local_shipping_outlined,
                      '$quantity Truck${quantity == 1 ? '' : 's'}',
                    ),

                  if (_loadType == 'LTL')
                    _summaryBadge(
                      Icons.inventory_outlined,
                      '$quantity Package${quantity == 1 ? '' : 's'}',
                    ),

                  if (_truckType != 'Recommend for Me')
                    _summaryBadge(Icons.fire_truck_outlined, _truckType),
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
                      Icons.monitor_weight_outlined,
                      color: Color(0xFF7EC0FF),
                      size: 19,
                    ),

                    const SizedBox(width: 9),

                    Expanded(
                      child: Text(
                        'Gross Weight: ${_displayWeight()}',
                        style: const TextStyle(
                          color: Color(0xFFD9E8F6),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    if (_currentVolume() > 0)
                      Text(
                        '${_formattedVolume()} CBM',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ],
                ),
              ),

              if (_truckType == 'Reefer' &&
                  _temperatureController.text.trim().isNotEmpty) ...[
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
                        Icons.thermostat_rounded,
                        color: Color(0xFF7EC0FF),
                        size: 18,
                      ),

                      const SizedBox(width: 9),

                      Expanded(
                        child: Text(
                          'Temperature Controlled • ${_temperatureController.text.trim()} °C',
                          style: const TextStyle(
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
                  const Icon(Icons.request_quote_outlined, size: 21),

                  const SizedBox(width: 10),

                  Text(
                    l10n.submitQuoteRequest,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .35,
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Icon(Icons.arrow_forward_rounded, size: 20),
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

    if (_loadType == 'LTL') {
      final length = double.tryParse(_lengthController.text.trim()) ?? 0;
      final width = double.tryParse(_widthController.text.trim()) ?? 0;
      final height = double.tryParse(_heightController.text.trim()) ?? 0;

      if (length <= 0 || width <= 0 || height <= 0) {
        _showMessage(
          l10n.pleaseEnterDimensionsFirst,
          error: true,
        );
        return;
      }
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

      final quantity = int.parse(_quantityController.text.trim());

      final enteredWeight = double.parse(_weightController.text.trim());

      final weight = _weightUnit == 'TON'
          ? enteredWeight * 1000
          : enteredWeight;

      final temperature = _truckType == 'Reefer'
          ? double.tryParse(_temperatureController.text.trim())
          : null;

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
        'serviceType': 'Land Freight',

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
        // LAND FREIGHT
        // -------------------------------------------------
        'loadType': _loadType,
        'shipmentType': _loadType,

        'truckType': _truckType,
        'trailerType': _truckType,

        'packageType': _loadType == 'LTL' ? _packageType : null,

        'quantity': quantity,

        'numberOfTrucks': _loadType == 'FTL' ? quantity : null,

        'pieces': _loadType == 'LTL' ? quantity : null,

        'temperatureControlled': _truckType == 'Reefer',

        'targetTemperatureC': temperature,

        // -------------------------------------------------
        // CARGO
        // -------------------------------------------------
        'cargoType': _cargoController.text.trim(),
        'cargo': _cargoController.text.trim(),

        'enteredWeight': enteredWeight,
        'weightUnit': _weightUnit,
        'weightKg': weight,
        'grossWeightKg': weight,

        'volumeCbm': _currentVolume(),

        'lengthCm': _loadType == 'LTL'
            ? _parseOptionalDouble(_lengthController.text)
            : null,

        'widthCm': _loadType == 'LTL'
            ? _parseOptionalDouble(_widthController.text)
            : null,

        'heightCm': _loadType == 'LTL'
            ? _parseOptionalDouble(_heightController.text)
            : null,

        'dangerousGoods': _dangerousGoods,

        'oversizedCargo': _oversizedCargo,

        'insuranceRequested': _insuranceRequested,

        'additionalServices': _additionalServices.toList(),

        // -------------------------------------------------
        // DATE
        // -------------------------------------------------
        'readyDate': Timestamp.fromDate(_readyDate!),

        // Compatibility with existing admin/customer screens
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

  void _calculateVolume() {
    if (_loadType != 'LTL') {
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

    final value = cbm.toStringAsFixed(3);

    if (_volumeController.text != value) {
      _volumeController.text = value;

      if (mounted) {
        setState(() {});
      }
    }
  }

  double _currentVolume() {
    if (_loadType == 'LTL') {
      return double.tryParse(_volumeController.text.trim()) ?? 0;
    }

    return double.tryParse(_volumeController.text.trim()) ?? 0;
  }

  String _formattedVolume() {
    final value = _currentVolume();

    if (value <= 0) {
      return '0';
    }

    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(3);
  }

  String _displayWeight() {
    final value = double.tryParse(_weightController.text.trim()) ?? 0;

    if (value <= 0) {
      return '0 KG';
    }

    if (value == value.roundToDouble()) {
      return '${value.toStringAsFixed(0)} KG';
    }

    return '${value.toStringAsFixed(2)} KG';
  }

  String? _quantityValidator(String? value) {
    final number = int.tryParse(value?.trim() ?? '');

    if (number == null || number <= 0) {
      return AppLocalizations.of(context)!.enterQuantity;
    }

    return null;
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;

    return '${date.day} ${LocaleController.monthAbbrev(l10n, date.month)} ${date.year}';
  }

  // Map stored English option values to localized display labels.
  String _optionLabel(AppLocalizations l10n, String value) {
    return LocaleController.optionLabel(l10n, value);
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

class _LandTrustItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _LandTrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: _LandFreightScreenState._primaryBlue, size: 20),

        const SizedBox(height: 6),

        Text(
          title,
          style: const TextStyle(
            color: _LandFreightScreenState._textDark,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _LandFreightScreenState._textGrey,
            fontSize: 7.5,
          ),
        ),
      ],
    );
  }
}

class _LandDivider extends StatelessWidget {
  const _LandDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: _LandFreightScreenState._border,
    );
  }
}

class _LandContactDivider extends StatelessWidget {
  const _LandContactDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 13),
      child: Divider(color: _LandFreightScreenState._border, height: 1),
    );
  }
}
