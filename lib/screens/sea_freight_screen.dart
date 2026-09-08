import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app/widgets/shipping_form_widgets.dart';
import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
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
                      icon: Icons.directions_boat_filled_outlined,
                      title: l10n.serviceSeaFreight,
                      subtitle: l10n.chooseHowToMove,
                    ),

                    const SizedBox(height: 13),

                    _buildShipmentTypeSection(),

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
                      icon: Icons.add_business_outlined,
                      title: l10n.additionalServices,
                      subtitle: l10n.addOptionalLogistics,
                    ),

                    const SizedBox(height: 13),

                    _buildServicesSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '05',
                      icon: Icons.person_outline_rounded,
                      title: l10n.contactDetails,
                      subtitle: l10n.contactFilledFromAccount,
                    ),

                    const SizedBox(height: 13),

                    _buildCustomerSection(),

                    const SizedBox(height: 28),

                    _sectionTitle(
                      number: '06',
                      icon: Icons.notes_rounded,
                      title: l10n.specialInstructions,
                      subtitle: l10n.anythingTeamShouldKnow,
                    ),

                    const SizedBox(height: 13),

                    _buildNotesSection(),

                    const SizedBox(height: 28),

                    _buildReviewCard(),

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

    return ShippingFormHeader(
      title: l10n.seaFreightQuote,
      subtitle: l10n.officialRateRequest,
      trailingIcon: Icons.directions_boat_filled_outlined,
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
      trailingIconSize: 22,
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
                    l10n.oceanFreight,
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

          PositionedDirectional(
            start: 19,
            end: 19,
            bottom: 19,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.seaHeroTitle,
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
                  l10n.seaHeroSubmitSubtitle,
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

  // =========================================================
  // TRUST BAR
  // =========================================================

  Widget _buildTrustBar() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingTrustBar(
      borderColor: _border,
      children: [
          Expanded(
            child: ShippingTrustItem(
              icon: Icons.inventory_2_outlined,
              title: 'FCL',
              subtitle: _optionLabel(l10n, 'Full Container'),
              primaryColor: _primaryBlue,
              titleColor: _textDark,
              subtitleColor: _textGrey,
              titleFontSize: 11,
              subtitleFontWeight: FontWeight.w500,
            ),
          ),
          const ShippingTrustDivider(color: _border),
          Expanded(
            child: ShippingTrustItem(
              icon: Icons.widgets_outlined,
              title: 'LCL',
              subtitle: _optionLabel(l10n, 'Shared Cargo'),
              primaryColor: _primaryBlue,
              titleColor: _textDark,
              subtitleColor: _textGrey,
              titleFontSize: 11,
              subtitleFontWeight: FontWeight.w500,
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
              titleFontSize: 11,
              subtitleFontWeight: FontWeight.w500,
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
            hint: l10n.portCityPickup,
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
            label: l10n.destination,
            hint: l10n.portCityDelivery,
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
  // SHIPMENT TYPE
  // =========================================================

  Widget _buildShipmentTypeSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(

      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.shipmentLoad,
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
                child: _shipmentTypeButton(
                  value: 'FCL',
                  title: 'FCL',
                  subtitle: _optionLabel(l10n, 'Full Container Load'),
                  icon: Icons.inventory_2_outlined,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _shipmentTypeButton(
                  value: 'LCL',
                  title: 'LCL',
                  subtitle: _optionLabel(l10n, 'Less Container Load'),
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
    final l10n = AppLocalizations.of(context)!;

    return Column(
      key: const ValueKey('FCL'),
      children: [
        _dropdown(
          label: l10n.containerType,
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
          label: l10n.numberOfContainers,
          hint: '1',
          icon: Icons.numbers_rounded,
          keyboardType: TextInputType.number,
          validator: _quantityValidator,
        ),
      ],
    );
  }

  Widget _buildLclFields() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      key: const ValueKey('LCL'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _textField(
          controller: _quantityController,
          label: l10n.numberOfPackagesPallets,
          hint: '1',
          icon: Icons.inventory_outlined,
          keyboardType: TextInputType.number,
          validator: _quantityValidator,
        ),

        const SizedBox(height: 16),

        Text(
          l10n.packageDimensions,
          style: const TextStyle(
            color: _textDark,
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          l10n.enterDimensionsCm,
          style: const TextStyle(color: _textGrey, fontSize: 9, height: 1.35),
        ),

        const SizedBox(height: 11),

        Row(
          children: [
            Expanded(
              child: _smallNumberField(
                controller: _lengthController,
                label: l10n.length,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _smallNumberField(
                controller: _widthController,
                label: l10n.width,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _smallNumberField(
                controller: _heightController,
                label: l10n.height,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          l10n.enterDimensionsCm,
          style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(

      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        children: [
          _textField(
            controller: _cargoController,
            label: l10n.cargoType,
            hint: l10n.hintCargoSea,
            icon: Icons.category_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterCargoType;
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          _textField(
            controller: _weightController,
            label: l10n.grossWeight,
            hint: '0',
            suffix: 'KG',
            icon: Icons.monitor_weight_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final number = double.tryParse(value?.trim() ?? '');

              if (number == null || number <= 0) {
                return l10n.pleaseEnterGrossWeight;
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          _textField(
            controller: _volumeController,
            label: l10n.cbm,
            hint: _shipmentType == 'LCL'
                ? l10n.calculatedAutomatically
                : l10n.optional,
            suffix: 'CBM',
            icon: Icons.view_in_ar_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (_shipmentType != 'LCL') {
                return null;
              }

              final volume = double.tryParse(value?.trim() ?? '');

              if (volume == null || volume <= 0) {
                return l10n.enterCargoVolume;
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
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: _primaryBlue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.weCalculateVolumetric,
                      style: const TextStyle(
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
  // SERVICES
  // =========================================================

  Widget _buildServicesSection() {
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
  // REVIEW
  // =========================================================

  Widget _buildReviewCard() {
    final l10n = AppLocalizations.of(context)!;

    final origin = _originController.text.trim().isEmpty
        ? l10n.origin
        : _originController.text.trim();

    final destination = _destinationController.text.trim().isEmpty
        ? l10n.destination
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
              Row(
                children: [
                  const Icon(
                    Icons.fact_check_outlined,
                    color: Colors.white,
                    size: 20,
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
                    Icons.directions_boat_filled_outlined,
                    LocaleController.serviceLabel(l10n, 'Sea Freight'),
                  ),

                  _summaryBadge(Icons.inventory_2_outlined, _shipmentType),

                  _summaryBadge(
                    Icons.route_outlined,
                    _optionLabel(l10n, _serviceMode),
                  ),

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
                child: Row(
                  children: [
                    const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF7EC0FF),
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        l10n.reviewedBeforeOfficialRate,
                        style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;

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

  Future<void> _showSuccessDialog({
    required String quoteNumber,
    required String documentId,
  }) {
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
    String Function(String item)? itemLabel,
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
