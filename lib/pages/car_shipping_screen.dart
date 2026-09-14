import '../data/models/form_submit_outcome.dart';
import '../data/utils/value_formatters.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/shipping_form_widgets.dart';
import '../controllers/car_shipping_controller.dart';
import '../l10n/app_localizations.dart';
import '../controllers/locale_controller.dart';
import '../constant/app_routes.dart';

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
  late final CarShippingController _c;

  // =========================================================
  // CONTROLLERS
  // =========================================================

  TextEditingController get _originController => _c.originController;
  TextEditingController get _destinationController => _c.destinationController;
  TextEditingController get _vehicleCountController =>
      _c.vehicleCountController;
  TextEditingController get _makeController => _c.makeController;
  TextEditingController get _modelController => _c.modelController;
  TextEditingController get _yearController => _c.yearController;
  TextEditingController get _vinController => _c.vinController;
  TextEditingController get _vehicleValueController =>
      _c.vehicleValueController;
  TextEditingController get _notesController => _c.notesController;

  // =========================================================
  // CAR SHIPPING OPTIONS
  // =========================================================

  String get _serviceMode => _c.serviceMode.value;
  set _serviceMode(String value) => _c.serviceMode.value = value;
  String get _shippingMethod => _c.shippingMethod.value;
  set _shippingMethod(String value) => _c.shippingMethod.value = value;
  String get _vehicleType => _c.vehicleType.value;
  set _vehicleType(String value) => _c.vehicleType.value = value;
  String get _vehicleCondition => _c.vehicleCondition.value;
  set _vehicleCondition(String value) => _c.vehicleCondition.value = value;
  String get _valueCurrency => _c.valueCurrency.value;
  set _valueCurrency(String value) => _c.valueCurrency.value = value;
  DateTime? get _readyDate => _c.readyDate.value;
  set _readyDate(DateTime? value) => _c.readyDate.value = value;
  bool get _insuranceRequested => _c.insuranceRequested.value;
  set _insuranceRequested(bool value) => _c.insuranceRequested.value = value;
  bool get _priorityHandling => _c.priorityHandling.value;
  set _priorityHandling(bool value) => _c.priorityHandling.value = value;
  RxSet<String> get _additionalServices => _c.additionalServices;
  List<String> get _serviceModes => _c.serviceModes;
  List<String> get _vehicleTypes => _c.vehicleTypes;
  List<String> get _vehicleConditions => _c.vehicleConditions;
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
    _c = Get.find<CarShippingController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _c.loadProfile(AppLocalizations.of(context)!.tawamCustomer);
    });
  }

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
                        icon: Icons.directions_car_filled_outlined,
                        title: l10n.vehicleInformation,
                        subtitle: l10n.vehicleInfoSubtitle,
                      ),

                      const SizedBox(height: 13),

                      _buildVehicleSection(),

                      const SizedBox(height: 28),

                      _sectionTitle(
                        number: '03',
                        icon: Icons.local_shipping_outlined,
                        title: l10n.shippingMethod,
                        subtitle: l10n.chooseHowToMove,
                      ),

                      const SizedBox(height: 13),

                      _buildShippingMethodSection(),

                      const SizedBox(height: 28),

                      _sectionTitle(
                        number: '04',
                        icon: Icons.verified_user_outlined,
                        title: l10n.vehicleProtection,
                        subtitle: l10n.addInsuranceOrPriority,
                      ),

                      const SizedBox(height: 13),

                      _buildProtectionSection(),

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
      title: l10n.carShippingQuote,
      subtitle: l10n.officialRateRequest,
      trailingIcon: Icons.directions_car_filled_outlined,
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
      subtitleLetterSpacing: 1.05,
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
                  const Icon(
                    Icons.verified_user_outlined,
                    color: _primaryBlue,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.secureVehicleLogistics,
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
                  l10n.carHeroTitle,
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
                  l10n.carHeroSubtitle,
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
            icon: Icons.local_shipping_outlined,
            title: l10n.badgeRoad,
            subtitle: l10n.carrierTransport,
            primaryColor: _primaryBlue,
            titleColor: _textDark,
            subtitleColor: _textGrey,
          ),
        ),
        const ShippingTrustDivider(color: _border),
        Expanded(
          child: ShippingTrustItem(
            icon: Icons.directions_boat_outlined,
            title: 'RoRo',
            subtitle: l10n.portShipping,
            primaryColor: _primaryBlue,
            titleColor: _textDark,
            subtitleColor: _textGrey,
          ),
        ),
        const ShippingTrustDivider(color: _border),
        Expanded(
          child: ShippingTrustItem(
            icon: Icons.inventory_2_outlined,
            title: l10n.containerUpper,
            subtitle: l10n.protectedShipping,
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
            label: l10n.pickupLocation,
            hint: l10n.cityShowroomPort,
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
            hint: l10n.cityWarehousePort,
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

              _serviceMode = value;
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
  // VEHICLE
  // =========================================================

  Widget _buildVehicleSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(
      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        children: [
          _dropdown(
            label: l10n.vehicleType,
            icon: Icons.directions_car_filled_outlined,
            value: _vehicleType,
            items: _vehicleTypes,
            itemLabel: (item) => _optionLabel(l10n, item),
            onChanged: (value) {
              if (value == null) return;

              _vehicleType = value;
            },
          ),

          const SizedBox(height: 14),

          _textField(
            controller: _vehicleCountController,
            label: l10n.numberOfVehicles,
            hint: '1',
            icon: Icons.numbers_rounded,
            keyboardType: TextInputType.number,
            validator: (value) {
              final count = int.tryParse(value?.trim() ?? '');

              if (count == null || count <= 0) {
                return l10n.enterNumberOfVehicles;
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
                  label: l10n.vehicleMake,
                  hint: 'Toyota',
                  icon: Icons.badge_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.enterMake;
                    }

                    return null;
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _textField(
                  controller: _modelController,
                  label: l10n.vehicleModel,
                  hint: 'Land Cruiser',
                  icon: Icons.directions_car_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.enterModel;
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
            label: l10n.modelYear,
            hint: '2024',
            icon: Icons.calendar_today_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              final year = int.tryParse(value?.trim() ?? '');
              final maxYear = DateTime.now().year + 1;

              if (year == null || year < 1900 || year > maxYear) {
                return l10n.enterValidModelYear;
              }

              return null;
            },
          ),

          const SizedBox(height: 14),

          _dropdown(
            label: l10n.vehicleCondition,
            icon: Icons.car_repair_outlined,
            value: _vehicleCondition,
            items: _vehicleConditions,
            itemLabel: (item) => _optionLabel(l10n, item),
            onChanged: (value) {
              if (value == null) return;

              _vehicleCondition = value;
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
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFB26A00),
                    size: 18,
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      l10n.specialLoadingMayBeRequired,
                      style: const TextStyle(
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
            label: l10n.vinChassis,
            hint: l10n.optional,
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
                  label: l10n.vehicleValue,
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
                  initialValue: _valueCurrency,
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

                    _valueCurrency = value;
                  },
                ),
              ),
            ],
          ),

          FormSummaryListener(
            listenables: [_vehicleCountController],
            builder: (context) {
              if (_vehicleCount <= 1) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
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
                          Icons.info_outline_rounded,
                          color: _primaryBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.differentVehiclesHint,
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
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SHIPPING METHOD
  // =========================================================

  Widget _buildShippingMethodSection() {
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(
      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.transportMethod,
            style: const TextStyle(
              color: _textDark,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            l10n.chooseBestRouteVehicle,
            style: const TextStyle(color: _textGrey, fontSize: 9.5),
          ),

          const SizedBox(height: 14),

          _methodOption(
            value: 'Open Carrier',
            icon: Icons.local_shipping_outlined,
            title: l10n.openCarrier,
            subtitle: l10n.openCarrierDesc,
          ),

          const SizedBox(height: 10),

          _methodOption(
            value: 'Enclosed Carrier',
            icon: Icons.inventory_2_outlined,
            title: l10n.enclosedCarrier,
            subtitle: l10n.enclosedCarrierDesc,
          ),

          const SizedBox(height: 10),

          _methodOption(
            value: 'RoRo',
            icon: Icons.directions_boat_outlined,
            title: l10n.roroShipping,
            subtitle: l10n.roroDesc,
          ),

          const SizedBox(height: 10),

          _methodOption(
            value: 'Container',
            icon: Icons.view_in_ar_outlined,
            title: l10n.containerShipping,
            subtitle: l10n.containerShippingDesc,
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
        _shippingMethod = value;
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
    final l10n = AppLocalizations.of(context)!;

    return ShippingPremiumCard(
      borderColor: _border,

      shadowColor: _deepBlue,
      child: Column(
        children: [
          _optionSwitch(
            icon: Icons.shield_outlined,
            title: l10n.cargoInsurance,
            subtitle: l10n.requestInsuranceHint,
            value: _insuranceRequested,
            onChanged: (value) {
              _insuranceRequested = value;
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Divider(color: _border, height: 1),
          ),

          _optionSwitch(
            icon: Icons.workspace_premium_outlined,
            title: l10n.priority,
            subtitle: l10n.requestPriorityVehicle,
            value: _priorityHandling,
            onChanged: (value) {
              _priorityHandling = value;
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
        ? l10n.pickup
        : _originController.text.trim();

    final destination = _destinationController.text.trim().isEmpty
        ? l10n.destination
        : _destinationController.text.trim();

    final vehicleLabel = _vehicleLabel(l10n);

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
                    Icons.directions_car_filled_outlined,
                    LocaleController.serviceLabel(l10n, 'Car Shipping'),
                  ),

                  _summaryBadge(
                    Icons.local_shipping_outlined,
                    _optionLabel(l10n, _shippingMethod),
                  ),

                  _summaryBadge(
                    Icons.route_outlined,
                    _optionLabel(l10n, _serviceMode),
                  ),

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
                  child: Row(
                    children: [
                      const Icon(
                        Icons.construction_rounded,
                        color: Color(0xFF7EC0FF),
                        size: 18,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          l10n.specialLoadingFlagged,
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

  int get _vehicleCount => _c.vehicleCount;

  String _vehicleLabel(AppLocalizations l10n) {
    final make = _makeController.text.trim();
    final model = _modelController.text.trim();
    final year = _yearController.text.trim();

    final parts = <String>[
      if (year.isNotEmpty) year,
      if (make.isNotEmpty) make,
      if (model.isNotEmpty) model,
    ];

    if (parts.isEmpty) {
      return _optionLabel(l10n, _vehicleType);
    }

    return '${parts.join(' ')} • ${_optionLabel(l10n, _vehicleType)}';
  }

  Future<void> _selectReadyDate() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    final result = await showDatePicker(
      context: context,
      initialDate: _readyDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: l10n.selectVehicleReadyDate,
    );

    if (result == null || !mounted) return;

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

  void _showMessage(String message, {required bool error}) {
    showShippingMessage(
      context,
      message: message,
      error: error,
      successColor: _deepBlue,
    );
  }
}
