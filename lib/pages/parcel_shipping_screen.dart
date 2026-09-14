import '../data/models/form_submit_outcome.dart';
import '../data/utils/value_formatters.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/shipping_form_widgets.dart';
import '../controllers/parcel_shipping_controller.dart';
import '../l10n/app_localizations.dart';
import '../controllers/locale_controller.dart';
import '../constant/app_routes.dart';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final ParcelShippingController _c;

  // =========================================================
  // CONTROLLERS
  // =========================================================

  TextEditingController get _originController => _c.originController;
  TextEditingController get _destinationController => _c.destinationController;
  TextEditingController get _parcelCountController => _c.parcelCountController;
  TextEditingController get _contentsController => _c.contentsController;
  TextEditingController get _weightController => _c.weightController;
  TextEditingController get _lengthController => _c.lengthController;
  TextEditingController get _widthController => _c.widthController;
  TextEditingController get _heightController => _c.heightController;
  TextEditingController get _declaredValueController =>
      _c.declaredValueController;
  TextEditingController get _notesController => _c.notesController;

  // =========================================================
  // PARCEL OPTIONS
  // =========================================================

  String get _serviceLevel => _c.serviceLevel.value;
  set _serviceLevel(String value) => _c.serviceLevel.value = value;
  String get _pickupMethod => _c.pickupMethod.value;
  set _pickupMethod(String value) => _c.pickupMethod.value = value;
  String get _packageType => _c.packageType.value;
  set _packageType(String value) => _c.packageType.value = value;
  String get _declaredValueCurrency => _c.declaredValueCurrency.value;
  set _declaredValueCurrency(String value) =>
      _c.declaredValueCurrency.value = value;
  DateTime? get _readyDate => _c.readyDate.value;
  set _readyDate(DateTime? value) => _c.readyDate.value = value;
  bool get _fragile => _c.fragile.value;
  set _fragile(bool value) => _c.fragile.value = value;
  bool get _insuranceRequested => _c.insuranceRequested.value;
  set _insuranceRequested(bool value) => _c.insuranceRequested.value = value;
  bool get _signatureRequired => _c.signatureRequired.value;
  set _signatureRequired(bool value) => _c.signatureRequired.value = value;
  RxSet<String> get _additionalServices => _c.additionalServices;
  List<String> get _pickupMethods => _c.pickupMethods;
  List<String> get _packageTypes => _c.packageTypes;
  List<String> get _currencies => _c.currencies;
  List<String> get _availableServices => _c.availableServices;

  // =========================================================
  // CUSTOMER PROFILE
  // =========================================================

  bool get _loadingProfile => _c.loadingProfile.value;
  String get _customerName => _c.customerName.value;
  String get _customerEmail => _c.customerEmail.value;
  String get _customerPhone => _c.customerPhone.value;
  String get _customerCompany => _c.customerCompany.value;
  String get _customerCountry => _c.customerCountry.value;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();
    _c = Get.find<ParcelShippingController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _c.loadProfile(AppLocalizations.of(context)!.tawamCustomer);
    });
  }

  // =========================================================
  // AUTOMATIC CALCULATIONS
  // =========================================================

  int get _parcelCount => _c.parcelCount;
  double get _totalActualWeight => _c.totalActualWeight;
  double get _totalVolumeCbm => _c.totalVolumeCbm;
  double get _totalVolumetricWeight => _c.totalVolumetricWeight;
  double get _chargeableWeight => _c.chargeableWeight;

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      _c.observeForm();
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
    });
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

    return ShippingPremiumCard(
      borderColor: _border,

      shadowColor: _deepBlue,
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

              _pickupMethod = value;
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
      valueText: _readyDate == null
          ? l10n.selectReadyDate
          : _formatDate(_readyDate!),
    );
  }

  // =========================================================
  // SERVICE LEVEL
  // =========================================================

  Widget _buildServiceLevelSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(
      borderColor: _border,

      shadowColor: _deepBlue,
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
        _serviceLevel = value;
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

    return ShippingPremiumCard(
      borderColor: _border,

      shadowColor: _deepBlue,
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

              _packageType = value;
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

                    _declaredValueCurrency = value;
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

    return ShippingPremiumCard(
      borderColor: _border,

      shadowColor: _deepBlue,
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
                  l10n.totalVolumeCarrierNote(
                    _totalVolumeCbm.toStringAsFixed(3),
                  ),
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
    return ShippingCalculationItem(label: label, value: value);
  }

  // =========================================================
  // PROTECTION
  // =========================================================

  Widget _buildProtectionSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(
      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        children: [
          _optionSwitch(
            icon: Icons.broken_image_outlined,
            title: l10n.fragile,
            subtitle: l10n.parcelExtraCare,
            value: _fragile,
            onChanged: (value) {
              _fragile = value;
            },
          ),

          const ShippingContactDivider(color: _border),

          _optionSwitch(
            icon: Icons.shield_outlined,
            title: l10n.cargoInsurance,
            subtitle: l10n.requestInsuranceHint,
            value: _insuranceRequested,
            onChanged: (value) {
              _insuranceRequested = value;
            },
          ),

          const ShippingContactDivider(color: _border),

          _optionSwitch(
            icon: Icons.draw_outlined,
            title: l10n.signatureOnDelivery,
            subtitle: l10n.requireRecipientConfirmation,
            value: _signatureRequired,
            onChanged: (value) {
              _signatureRequired = value;
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
        if (value) {
          _additionalServices.add(service);
        } else {
          _additionalServices.remove(service);
        }
      },
    );
  }

  // =========================================================
  // CUSTOMER
  // =========================================================

  Widget _buildCustomerSection() {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      _c.loadingProfile.value;
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
    });
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
    return FormSummaryListener(
      listenables: _c.summaryListenables,
      builder: (context) => _buildSummaryBody(AppLocalizations.of(context)!),
    );
  }

  Widget _buildSummaryBody(AppLocalizations l10n) {
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
    return ShippingSummaryBadge(text: text, icon: icon);
  }

  // =========================================================
  // SUBMIT
  // =========================================================

  Widget _buildSubmitButton() {
    final l10n = AppLocalizations.of(context)!;
    return Obx(
      () => ShippingSubmitButton(
        submitting: _c.quotes.isSubmitting.value,
        onSubmit: _submitQuote,
        primaryColor: _primaryBlue,
        label: l10n.submitQuoteRequest,
        icon: Icons.request_quote_outlined,
      ),
    );
  }

  Future<void> _submitQuote() async {
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    final outcome = await _c.submit(
      formValid: _formKey.currentState?.validate() ?? false,
    );

    if (!mounted) return;

    if (outcome.isSuccess) {
      await _showSuccessDialog(outcome.reference ?? '');
      return;
    }

    switch (outcome.error) {
      case FormSubmitError.submitting:
      case null:
        return;
      case FormSubmitError.invalidForm:
        _showMessage(l10n.pleaseCompleteShipmentInfo, error: true);
        return;
      case FormSubmitError.missingDate:
        _showMessage(l10n.pleaseSelectPickupDate, error: true);
        return;
      case FormSubmitError.missingDimensions:
        _showMessage(l10n.pleaseEnterDimensionsFirst, error: true);
        return;
      case FormSubmitError.unsigned:
        _showMessage(l10n.pleaseSignInBeforeQuote, error: true);
        return;
      case FormSubmitError.firebase:
        _showMessage(
          outcome.firebaseMessage ?? l10n.couldNotSubmitQuote,
          error: true,
        );
        return;
      default:
        _showMessage(l10n.somethingWentWrong, error: true);
        return;
    }
  }

  // =========================================================
  // SUCCESS
  // =========================================================

  Future<void> _showSuccessDialog(String quoteNumber) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ShippingQuoteSuccessDialog(
        quoteNumber: quoteNumber,
        deepBlue: _deepBlue,
        success: _success,
        textDark: _textDark,
        textGrey: _textGrey,
        softGrey: _softGrey,
        border: _border,
        primaryBlue: _primaryBlue,
        onViewQuotes: () {
          Navigator.pop(dialogContext);
          Get.toNamed(AppRoutes.myQuotes);
        },
        onDone: () {
          Navigator.pop(dialogContext);
          Navigator.pop(context);
        },
      ),
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
      onChanged: (_) {},
      textColor: _textDark,
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
      style: const TextStyle(
        color: _textDark,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
      ),
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
    return shippingOptionSwitch(
      icon: icon,
      title: title,
      subtitle: subtitle,
      value: value,
      onChanged: onChanged,
      softBlue: _softBlue,
      primaryBlue: _primaryBlue,
      textDark: _textDark,
      textGrey: _textGrey,
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

    _readyDate = result;
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
    showShippingMessage(
      context,
      message: message,
      error: error,
      successColor: _deepBlue,
    );
  }
}
