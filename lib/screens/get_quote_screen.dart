import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetQuoteScreen extends StatefulWidget {
  const GetQuoteScreen({
    super.key,
    this.initialServiceType,
    this.initialLengthCm,
    this.initialWidthCm,
    this.initialHeightCm,
    this.initialQuantity,
    this.initialWeightKg,
  });

  final String? initialServiceType;

  final String? initialLengthCm;
  final String? initialWidthCm;
  final String? initialHeightCm;
  final String? initialQuantity;
  final String? initialWeightKg;

  @override
  State<GetQuoteScreen> createState() => _GetQuoteScreenState();
}

class _GetQuoteScreenState extends State<GetQuoteScreen> {
  static const Color primaryBlue = Color(0xFF0B4F9C);
  static const Color deepBlue = Color(0xFF062B55);
  static const Color softBlue = Color(0xFFEAF3FF);
  static const Color pageBackground = Color(0xFFF5F7FB);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF7A8797);
  static const Color borderColor = Color(0xFFE3EAF2);

  final _formKey = GlobalKey<FormState>();

  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _cargoController = TextEditingController();
  final _weightController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _services = const [
    'Sea Freight',
    'Air Freight',
    'Land Freight',
    'Car Shipping',
    'International Moving',
    'Parcel Shipping',
  ];

  String _selectedService = 'Land Freight';
  DateTime? _pickupDate;
  bool _submitting = false;

  @override
  @override
  void initState() {
    super.initState();

    // Service Type
    final initialService = widget.initialServiceType?.trim();

    if (initialService != null && _services.contains(initialService)) {
      _selectedService = initialService;
    }

    // Dimensions coming from Volume Calculator
    _lengthController.text = widget.initialLengthCm?.trim() ?? '';

    _widthController.text = widget.initialWidthCm?.trim() ?? '';

    _heightController.text = widget.initialHeightCm?.trim() ?? '';

    _weightController.text = widget.initialWeightKg?.trim() ?? '';

    final initialQuantity = widget.initialQuantity?.trim();

    if (initialQuantity != null && initialQuantity.isNotEmpty) {
      _quantityController.text = initialQuantity;
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _cargoController.dispose();
    _weightController.dispose();
    _quantityController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(),
                      const SizedBox(height: 24),
                      _sectionTitle(
                        icon: Icons.local_shipping_outlined,
                        title: 'Shipping Service',
                        subtitle: 'Choose the service that fits your shipment',
                      ),
                      const SizedBox(height: 14),
                      _buildServiceSelector(),
                      const SizedBox(height: 24),
                      _sectionTitle(
                        icon: Icons.route_outlined,
                        title: 'Route',
                        subtitle: 'Where is your shipment moving from and to?',
                      ),
                      const SizedBox(height: 14),
                      _buildRouteCard(),
                      const SizedBox(height: 24),
                      _sectionTitle(
                        icon: Icons.inventory_2_outlined,
                        title: 'Shipment Details',
                        subtitle: 'Tell us about your cargo',
                      ),
                      const SizedBox(height: 14),
                      _buildShipmentDetailsCard(),
                      const SizedBox(height: 24),
                      _sectionTitle(
                        icon: Icons.calendar_month_outlined,
                        title: 'Pickup',
                        subtitle: 'Select your preferred pickup date',
                      ),
                      const SizedBox(height: 14),
                      _buildPickupCard(),
                      const SizedBox(height: 24),
                      _sectionTitle(
                        icon: Icons.notes_rounded,
                        title: 'Additional Notes',
                        subtitle: 'Add any special instructions for our team',
                      ),
                      const SizedBox(height: 14),
                      _buildNotesCard(),
                      const SizedBox(height: 24),
                      _buildTrustStrip(),
                      const SizedBox(height: 22),
                      _buildSubmitButton(),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'Our team will review your request and send you the best available rate.',
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
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: .07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: deepBlue,
                size: 23,
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
                  'Get a Quote',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'TAWAM AL-SHAHIN TRANSPORT',
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .8,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.verified_outlined,
              color: primaryBlue,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [deepBlue, Color(0xFF0A4789)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: .18),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -26,
            child: Icon(
              Icons.public_rounded,
              size: 145,
              color: Colors.white.withValues(alpha: .055),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.request_quote_outlined, color: Colors.white, size: 32),
              SizedBox(height: 14),
              Text(
                'Request Your Best Rate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tell us about your shipment and our logistics team will prepare a tailored quotation.',
                style: TextStyle(
                  color: Color(0xFFD5E3F3),
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: softBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryBlue, size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textGrey,
                  fontSize: 10.5,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: .035),
            blurRadius: 12,
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
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 3.05,
        ),
        itemBuilder: (context, index) {
          final service = _services[index];
          final selected = service == _selectedService;

          return InkWell(
            onTap: () {
              setState(() {
                _selectedService = service;
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: selected ? deepBlue : const Color(0xFFF8FAFD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: selected ? deepBlue : borderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    _serviceIcon(service),
                    color: selected ? Colors.white : primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : textDark,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
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

  Widget _buildRouteCard() {
    return _card(
      child: Column(
        children: [
          _textField(
            controller: _fromController,
            label: 'From',
            hint: 'City, Country',
            icon: Icons.trip_origin_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter pickup location';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(child: Divider(color: borderColor, height: 1)),
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
              const Expanded(child: Divider(color: borderColor, height: 1)),
            ],
          ),
          const SizedBox(height: 14),
          _textField(
            controller: _toController,
            label: 'To',
            hint: 'City, Country',
            icon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter delivery location';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentDetailsCard() {
    return _card(
      child: Column(
        children: [
          _textField(
            controller: _cargoController,
            label: 'Cargo Type',
            hint: 'e.g. General Cargo, Steel, Furniture',
            icon: Icons.category_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter cargo type';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _textField(
                  controller: _weightController,
                  label: 'Weight',
                  hint: '0',
                  suffix: 'KG',
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final weight = double.tryParse(value?.trim() ?? '');
                    if (weight == null || weight <= 0) {
                      return 'Enter weight';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(
                  controller: _quantityController,
                  label: 'Quantity',
                  hint: '1',
                  icon: Icons.numbers_rounded,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final quantity = int.tryParse(value?.trim() ?? '');
                    if (quantity == null || quantity <= 0) {
                      return 'Enter quantity';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Dimensions (optional)',
              style: TextStyle(
                color: textDark,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 9),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Dimensions are recorded in centimeters (CM).',
              style: TextStyle(
                color: textGrey,
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard() {
    return InkWell(
      onTap: _selectPickupDate,
      borderRadius: BorderRadius.circular(20),
      child: _card(
        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                color: softBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferred Pickup Date',
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _pickupDate == null
                        ? 'Select a date'
                        : _formatDate(_pickupDate!),
                    style: TextStyle(
                      color: _pickupDate == null ? textGrey : textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: textGrey,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return _card(
      child: TextFormField(
        controller: _notesController,
        minLines: 4,
        maxLines: 7,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText:
              'Special handling, customs information, vehicle details, packing notes, or anything else we should know...',
          hintStyle: const TextStyle(
            color: Color(0xFF9AA5B4),
            fontSize: 11,
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

  Widget _buildTrustStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _TrustItem(
              icon: Icons.verified_user_outlined,
              title: 'Secure Request',
            ),
          ),
          Expanded(
            child: _TrustItem(
              icon: Icons.price_check_outlined,
              title: 'Best Rate',
            ),
          ),
          Expanded(
            child: _TrustItem(
              icon: Icons.support_agent_rounded,
              title: 'Expert Support',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submitQuote,
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
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'SUBMIT QUOTE REQUEST',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .4,
                    ),
                  ),
                  SizedBox(width: 9),
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
        isError: true,
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please sign in before requesting a quote.', isError: true);
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userSnapshot.data() ?? <String, dynamic>{};

      final customerName = _firstNonEmpty([
        userData['name'],
        userData['fullName'],
        user.displayName,
      ]);

      final customerEmail = _firstNonEmpty([userData['email'], user.email]);

      final customerPhone = _firstNonEmpty([
        userData['phone'],
        userData['phoneNumber'],
        user.phoneNumber,
      ]);

      final now = DateTime.now();

      final quoteNumber =
          'QR-${now.year}${_two(now.month)}${_two(now.day)}-'
          '${_two(now.hour)}${_two(now.minute)}${_two(now.second)}';

      final quoteData = <String, dynamic>{
        'userId': user.uid,
        'customerName': customerName.isEmpty ? 'Tawam Customer' : customerName,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'quoteNumber': quoteNumber,
        'serviceType': _selectedService,
        'from': _fromController.text.trim(),
        'to': _toController.text.trim(),
        'cargoType': _cargoController.text.trim(),
        'weightKg': double.parse(_weightController.text.trim()),
        'quantity': int.parse(_quantityController.text.trim()),
        'lengthCm': _parseOptionalDouble(_lengthController.text),
        'widthCm': _parseOptionalDouble(_widthController.text),
        'heightCm': _parseOptionalDouble(_heightController.text),
        'volumeCbm': () {
          final length = _parseOptionalDouble(_lengthController.text);
          final width = _parseOptionalDouble(_widthController.text);
          final height = _parseOptionalDouble(_heightController.text);

          final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;

          if (length == null || width == null || height == null) {
            return null;
          }

          return (length * width * height * quantity) / 1000000;
        }(),
        'pickupDate': _pickupDate == null
            ? null
            : Timestamp.fromDate(_pickupDate!),
        'notes': _notesController.text.trim(),
        'status': 'new',
        'quotedPrice': null,
        'currency': 'AED',
        'adminNote': '',
        'adminUpdatedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'source': 'customer_app',
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
        requestId: reference.id,
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      _showMessage(
        error.message ?? 'Could not submit your quote request.',
        isError: true,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      _showMessage('Something went wrong. Please try again.', isError: true);
    }
  }

  Future<void> _showSuccessDialog({
    required String quoteNumber,
    required String requestId,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: deepBlue.withValues(alpha: .18),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: softBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: primaryBlue,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Quote Request Submitted',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Your request has been sent to TAWAM AL-SHAHIN TRANSPORT.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 12,
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
                      const Text(
                        'REFERENCE',
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 9,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        quoteNumber,
                        style: const TextStyle(
                          color: deepBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
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
                    child: const Text(
                      'DONE',
                      style: TextStyle(fontWeight: FontWeight.w800),
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

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: .035),
            blurRadius: 12,
            offset: const Offset(0, 5),
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
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: primaryBlue, size: 21),
        labelStyle: const TextStyle(
          color: textGrey,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9DA8B6), fontSize: 11.5),
        suffixStyle: const TextStyle(
          color: textGrey,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
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
          borderSide: const BorderSide(color: Color(0xFFD94747)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD94747), width: 1.4),
        ),
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
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'CM',
        labelStyle: const TextStyle(
          color: textGrey,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        suffixStyle: const TextStyle(
          color: textGrey,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
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
      helpText: 'SELECT PICKUP DATE',
    );

    if (selected == null || !mounted) return;

    setState(() {
      _pickupDate = selected;
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

  double? _parseOptionalDouble(String value) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFF9E2A2A) : deepBlue,
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _GetQuoteScreenState.primaryBlue, size: 22),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _GetQuoteScreenState.textDark,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
