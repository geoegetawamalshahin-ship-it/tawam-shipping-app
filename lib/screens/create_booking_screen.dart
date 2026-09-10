import '../app/utils/value_formatters.dart';
import '../app/widgets/soft_back_header.dart';
import '../app/widgets/numbered_section_heading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/booking_controller.dart';
import '../l10n/app_localizations.dart';
import '../locale_controller.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key, this.initialServiceType});

  final String? initialServiceType;

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final BookingController _bookingController = Get.find<BookingController>();

  static const Color deepBlue = Color(0xFF062B55);
  static const Color primaryBlue = Color(0xFF0B4F9C);
  static const Color brightBlue = Color(0xFF1268BC);
  static const Color softBlue = Color(0xFFEAF3FF);
  static const Color pageBg = Color(0xFFF4F7FB);
  static const Color textDark = Color(0xFF101B2D);
  static const Color textGrey = Color(0xFF7E8A9A);
  static const Color borderColor = Color(0xFFE1E8F0);

  final _formKey = GlobalKey<FormState>();

  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _cargoController = TextEditingController();
  final _weightController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _services = const [
    'Sea Freight',
    'Air Freight',
    'Land Freight',
    'Car Shipping',
    'International Moving',
    'Parcel Shipping',
  ];

  final List<String> _preferredTimes = const [
    'Morning',
    'Afternoon',
    'Evening',
    'Flexible',
  ];

  String _selectedService = 'Land Freight';
  String _preferredTime = 'Flexible';
  DateTime? _pickupDate;

  String _customerName = 'TAWAM Customer';
  String _customerEmail = '';
  bool _loadingProfile = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialServiceType?.trim();
    if (initial != null && _services.contains(initial)) {
      _selectedService = initial;
    }
    _loadCustomerProfile();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _deliveryController.dispose();
    _cargoController.dispose();
    _weightController.dispose();
    _quantityController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerProfile() async {
    final user = _bookingController.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loadingProfile = false);
      return;
    }

    String name = user.displayName?.trim() ?? '';
    String email = user.email?.trim() ?? '';
    String phone = user.phoneNumber?.trim() ?? '';

    try {
      final data = await _bookingController.loadUserProfile(user.uid);

      name = firstNonEmpty([
        data['name'],
        data['fullName'],
        data['customerName'],
        name,
      ]);
      email = firstNonEmpty([data['email'], data['customerEmail'], email]);
      phone = firstNonEmpty([
        data['phone'],
        data['phoneNumber'],
        data['customerPhone'],
        phone,
      ]);
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _customerName = name.isEmpty ? 'TAWAM Customer' : name;
      _customerEmail = email;
      _phoneController.text = phone;
      _loadingProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 34),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(),
                      const SizedBox(height: 24),
                      _sectionHeading(
                        number: '01',
                        icon: Icons.local_shipping_outlined,
                        title: l10n.selectService,
                        subtitle: l10n.chooseHowToMove,
                      ),
                      const SizedBox(height: 14),
                      _buildServiceSelector(),
                      const SizedBox(height: 26),
                      _sectionHeading(
                        number: '02',
                        icon: Icons.route_outlined,
                        title: l10n.routeAndSchedule,
                        subtitle: l10n.tellOperationsWhereWhen,
                      ),
                      const SizedBox(height: 14),
                      _buildRouteAndSchedule(),
                      const SizedBox(height: 26),
                      _sectionHeading(
                        number: '03',
                        icon: Icons.inventory_2_outlined,
                        title: l10n.shipmentDetails,
                        subtitle: l10n.provideCargoForBooking,
                      ),
                      const SizedBox(height: 14),
                      _buildCargoDetails(),
                      const SizedBox(height: 26),
                      _sectionHeading(
                        number: '04',
                        icon: Icons.verified_user_outlined,
                        title: l10n.contactAndInstructions,
                        subtitle: l10n.accountAttachedToBooking,
                      ),
                      const SizedBox(height: 14),
                      _buildCustomerCard(),
                      const SizedBox(height: 14),
                      _buildNotesCard(),
                      const SizedBox(height: 22),
                      _buildTrustPanel(),
                      const SizedBox(height: 20),
                      _buildSubmitButton(),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          l10n.bookingReviewedByOps,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textGrey,
                            fontSize: 10.5,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SoftBackHeader(
      title: l10n.createBookingTitle,
      subtitle: l10n.tawamAlShahinTransport,
      trailingIcon: Icons.calendar_month_outlined,
      onBack: () => Navigator.pop(context),
      height: 84,
      shadowColor: deepBlue,
      shadowAlpha: .065,
      shadowBlur: 22,
      shadowOffset: const Offset(0, 7),
      borderColor: borderColor,
      backIconColor: deepBlue,
      backIconSize: 23,
      titleColor: textDark,
      titleFontWeight: FontWeight.w800,
      titleLetterSpacing: -0.35,
      subtitleColor: primaryBlue,
      subtitleFontSize: 9.5,
      subtitleFontWeight: FontWeight.w700,
      trailingBackground: softBlue,
      trailingIconColor: primaryBlue,
      trailingIconSize: 23,
    );
  }

  Widget _buildHero() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [deepBlue, Color(0xFF0A4789), brightBlue],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: .18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -36,
            child: Icon(
              Icons.public_rounded,
              size: 164,
              color: Colors.white.withValues(alpha: .055),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.globalBookingDesk,
                    style: TextStyle(
                      color: Color(0xFFD5E5F4),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                l10n.scheduleYourShipment,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                l10n.bookingHeroSubtitle,
                style: TextStyle(
                  color: Color(0xFFD7E6F5),
                  fontSize: 12.3,
                  height: 1.48,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  _HeroFeature(
                    icon: Icons.verified_outlined,
                    label: l10n.secure,
                  ),
                  const SizedBox(width: 18),
                  _HeroFeature(icon: Icons.public_rounded, label: l10n.global),
                  const SizedBox(width: 18),
                  _HeroFeature(
                    icon: Icons.support_agent_rounded,
                    label: l10n.expertTeam,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading({
    required String number,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return NumberedSectionHeading(
      number: number,
      icon: icon,
      title: title,
      subtitle: subtitle,
      badgeColor: deepBlue,
      iconColor: primaryBlue,
      titleColor: textDark,
      subtitleColor: textGrey,
    );
  }

  Widget _buildServiceSelector() {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: .035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 7,
          mainAxisSpacing: 7,
          childAspectRatio: 2.65,
        ),
        itemBuilder: (context, index) {
          final l10n = AppLocalizations.of(context)!;
          final service = _services[index];
          final selected = service == _selectedService;
          return InkWell(
            onTap: () => setState(() => _selectedService = service),
            borderRadius: BorderRadius.circular(15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(colors: [deepBlue, primaryBlue])
                    : null,
                color: selected ? null : const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: selected ? deepBlue : borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: .14)
                          : softBlue,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      _serviceIcon(service),
                      color: selected ? Colors.white : primaryBlue,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      LocaleController.serviceLabel(l10n, service),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : textDark,
                        fontSize: 10.5,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRouteAndSchedule() {
    final l10n = AppLocalizations.of(context)!;
    return _premiumCard(
      child: Column(
        children: [
          _input(
            controller: _pickupController,
            label: l10n.pickupLocation,
            hint: l10n.cityCountry,
            icon: Icons.trip_origin_rounded,
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n.pleaseEnterPickupLocation
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: Divider(color: borderColor)),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: softBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: primaryBlue,
                  size: 18,
                ),
              ),
              const Expanded(child: Divider(color: borderColor)),
            ],
          ),
          const SizedBox(height: 12),
          _input(
            controller: _deliveryController,
            label: l10n.deliveryLocation,
            hint: l10n.cityCountry,
            icon: Icons.location_on_outlined,
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n.pleaseEnterDeliveryLocation
                : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _dateSelector()),
              const SizedBox(width: 10),
              Expanded(child: _timeSelector()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dateSelector() {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: _selectPickupDate,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: primaryBlue,
              size: 21,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.pickupDate,
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _pickupDate == null
                        ? l10n.selectDate
                        : _formatDate(l10n, _pickupDate!),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _pickupDate == null ? textGrey : textDark,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, color: primaryBlue, size: 21),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _preferredTime,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: textGrey,
                ),
                style: const TextStyle(
                  color: textDark,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
                items: _preferredTimes
                    .map(
                      (time) =>
                          DropdownMenuItem(
                            value: time,
                            child: Text(_preferredTimeLabel(l10n, time)),
                          ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _preferredTime = value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCargoDetails() {
    final l10n = AppLocalizations.of(context)!;
    return _premiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _input(
            controller: _cargoController,
            label: l10n.cargoType,
            hint: l10n.vehicleGeneralCargoHint,
            icon: Icons.category_outlined,
            validator: (value) => value == null || value.trim().isEmpty
                ? l10n.pleaseEnterCargoType
                : null,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _input(
                  controller: _weightController,
                  label: l10n.weight,
                  hint: '0',
                  suffix: 'KG',
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final weight = double.tryParse(value?.trim() ?? '');
                    return weight == null || weight <= 0
                        ? l10n.enterWeight
                        : null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _input(
                  controller: _quantityController,
                  label: l10n.quantity,
                  hint: '1',
                  icon: Icons.numbers_rounded,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final quantity = int.tryParse(value?.trim() ?? '');
                    return quantity == null || quantity <= 0
                        ? l10n.enterQuantity
                        : null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              const Icon(Icons.straighten_rounded, color: primaryBlue, size: 18),
              const SizedBox(width: 7),
              Text(
                l10n.dimensionsOptional,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _dimensionInput(
                  controller: _lengthController,
                  label: l10n.length,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dimensionInput(
                  controller: _widthController,
                  label: l10n.width,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dimensionInput(
                  controller: _heightController,
                  label: l10n.height,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    final l10n = AppLocalizations.of(context)!;
    return _premiumCard(
      child: _loadingProfile
          ? const SizedBox(
              height: 90,
              child: Center(
                child: CircularProgressIndicator(color: primaryBlue),
              ),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [deepBlue, primaryBlue],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _initials(_customerName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _customerName == 'TAWAM Customer'
                                ? l10n.tawamCustomer
                                : _customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _customerEmail.isEmpty
                                ? l10n.signedInCustomer
                                : _customerEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF8F0),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF16765C),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.verified,
                            style: const TextStyle(
                              color: Color(0xFF16765C),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _input(
                  controller: _phoneController,
                  label: l10n.contactPhone,
                  hint: '+971 ...',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l10n.pleaseEnterPhoneNumber
                      : null,
                ),
              ],
            ),
    );
  }

  Widget _buildNotesCard() {
    final l10n = AppLocalizations.of(context)!;
    return _premiumCard(
      child: TextFormField(
        controller: _notesController,
        minLines: 4,
        maxLines: 7,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: l10n.specialInstructions,
          hintText:
              l10n.pickupAccessHint,
          labelStyle: const TextStyle(
            color: textGrey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF9DA8B6),
            fontSize: 10.8,
            height: 1.4,
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFD),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: primaryBlue, width: 1.4),
          ),
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _buildTrustPanel() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TrustFeature(
              icon: Icons.verified_user_outlined,
              title: l10n.secureBooking,
            ),
          ),
          const _MiniDivider(),
          Expanded(
            child: _TrustFeature(
              icon: Icons.handshake_outlined,
              title: l10n.professionalCare,
            ),
          ),
          const _MiniDivider(),
          Expanded(
            child: _TrustFeature(
              icon: Icons.support_agent_rounded,
              title: l10n.expertSupport,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submitBooking,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: deepBlue,
          disabledBackgroundColor: deepBlue.withValues(alpha: .55),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _submitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    l10n.confirmBooking,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Future<void> _submitBooking() async {
    if (_submitting) return;
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _showMessage(
        l10n.pleaseCompleteBooking,
        isError: true,
      );
      return;
    }

    if (_pickupDate == null) {
      _showMessage(l10n.pleaseSelectPickupDate, isError: true);
      return;
    }

    final user = _bookingController.currentUser;
    if (user == null) {
      _showMessage(l10n.pleaseSignInBeforeBooking, isError: true);
      return;
    }

    setState(() => _submitting = true);

    try {
      final now = DateTime.now();
      final bookingReference =
          'BK-${now.year}${twoDigits(now.month)}${twoDigits(now.day)}-${twoDigits(now.hour)}${twoDigits(now.minute)}${twoDigits(now.second)}';
      final phone = _phoneController.text.trim();

      final bookingData = <String, dynamic>{
        'userId': user.uid,
        'bookingReference': bookingReference,
        'requestType': 'booking',
        'customerName': _customerName,
        'customerEmail': _customerEmail,
        'customerPhone': phone,
        'fullName': _customerName,
        'email': _customerEmail,
        'phone': phone,
        'serviceType': _selectedService,
        'pickupLocation': _pickupController.text.trim(),
        'deliveryLocation': _deliveryController.text.trim(),
        'from': _pickupController.text.trim(),
        'to': _deliveryController.text.trim(),
        'pickupDate': Timestamp.fromDate(_pickupDate!),
        'shipmentDate': Timestamp.fromDate(_pickupDate!),
        'preferredTime': _preferredTime,
        'cargoType': _cargoController.text.trim(),
        'cargo': _cargoController.text.trim(),
        'weightKg': double.parse(_weightController.text.trim()),
        'quantity': int.parse(_quantityController.text.trim()),
        'lengthCm': parseOptionalDouble(_lengthController.text),
        'widthCm': parseOptionalDouble(_widthController.text),
        'heightCm': parseOptionalDouble(_heightController.text),
        'notes': _notesController.text.trim(),
        'status': 'pending',
        'adminNote': '',
        'adminUpdatedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'source': 'customer_app',
      };

      await _bookingController.createBookingRequest(bookingData);

      if (!mounted) return;
      setState(() => _submitting = false);
      await _showSuccessDialog(bookingReference);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showMessage(
        error.message ?? l10n.unableToSubmitBooking,
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showMessage(l10n.somethingWentWrong, isError: true);
    }
  }

  Future<void> _showSuccessDialog(String bookingReference) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(27),
              boxShadow: [
                BoxShadow(
                  color: deepBlue.withValues(alpha: .18),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: const BoxDecoration(
                    color: softBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: primaryBlue,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.bookingRequestSubmitted,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  l10n.bookingSentToTawam,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 11.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.bookingReference,
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 8.8,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        bookingReference,
                        style: const TextStyle(
                          color: deepBlue,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF6E5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          l10n.pendingConfirmation,
                          style: const TextStyle(
                            color: Color(0xFFB26A00),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: deepBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      l10n.doneUpper,
                      style: TextStyle(fontWeight: FontWeight.w900),
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

  Widget _premiumCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: .035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: keyboardType == TextInputType.text
          ? TextCapitalization.words
          : TextCapitalization.none,
      style: const TextStyle(
        color: textDark,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: primaryBlue, size: 20),
        labelStyle: const TextStyle(
          color: textGrey,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9DA8B6), fontSize: 11),
        suffixStyle: const TextStyle(
          color: textGrey,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: primaryBlue, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD53B4A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD53B4A), width: 1.4),
        ),
      ),
    );
  }

  Widget _dimensionInput({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        color: textDark,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'CM',
        labelStyle: const TextStyle(
          color: textGrey,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
        suffixStyle: const TextStyle(
          color: textGrey,
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        contentPadding: const EdgeInsets.symmetric(horizontal: 7, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: primaryBlue, width: 1.3),
        ),
      ),
    );
  }

  Future<void> _selectPickupDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: AppLocalizations.of(context)!.selectPickupDate,
    );
    if (selected == null || !mounted) return;
    setState(() => _pickupDate = selected);
  }

  IconData _serviceIcon(String service) {
    switch (service) {
      case 'Sea Freight':
        return Icons.directions_boat_filled_outlined;
      case 'Air Freight':
        return Icons.flight_rounded;
      case 'Land Freight':
        return Icons.local_shipping_outlined;
      case 'Car Shipping':
        return Icons.directions_car_filled_outlined;
      case 'International Moving':
        return Icons.home_work_outlined;
      case 'Parcel Shipping':
        return Icons.inventory_2_outlined;
      default:
        return Icons.local_shipping_outlined;
    }
  }

  String _preferredTimeLabel(AppLocalizations l10n, String time) {
    switch (time) {
      case 'Morning':
        return l10n.morning;
      case 'Afternoon':
        return l10n.afternoon;
      case 'Evening':
        return l10n.evening;
      default:
        return l10n.flexible;
    }
  }

  String _formatDate(AppLocalizations l10n, DateTime date) {
    return formatLocalizedDate(l10n, date);
  }




  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'TA';
    if (parts.length == 1) {
      final first = parts.first;
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFF9D2732) : deepBlue,
        content: Text(message),
      ),
    );
  }
}

class _HeroFeature extends StatelessWidget {
  const _HeroFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TrustFeature extends StatelessWidget {
  const _TrustFeature({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _CreateBookingScreenState.primaryBlue, size: 22),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _CreateBookingScreenState.textDark,
            fontSize: 8.8,
            height: 1.15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MiniDivider extends StatelessWidget {
  const _MiniDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: _CreateBookingScreenState.borderColor,
    );
  }
}
