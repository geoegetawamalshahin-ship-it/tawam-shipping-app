import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
import '../presentation/controllers/quote_controller.dart';

const Color _primaryBlue = Color(0xFF07569E);
const Color _darkNavy = Color(0xFF10233F);
const Color _accentRed = Color(0xFFD72638);
const Color _pageBackground = Color(0xFFF4F7FB);
const Color _borderColor = Color(0xFFE3E9F0);
const Color _mutedText = Color(0xFF8B95A3);

class RequestQuoteScreen extends StatefulWidget {
  const RequestQuoteScreen({super.key});

  @override
  State<RequestQuoteScreen> createState() => _RequestQuoteScreenState();
}

class _RequestQuoteScreenState extends State<RequestQuoteScreen> {
  final QuoteController _quoteController = Get.find<QuoteController>();
  final _formKey = GlobalKey<FormState>();

  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  final _cargoController = TextEditingController();
  final _weightController = TextEditingController();
  final _quantityController = TextEditingController();
  final _dateController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _cargoTypes = const [
    'General Cargo',
    'Vehicles',
    'Heavy Equipment',
    'Furniture',
    'Electronics',
    'Food Products',
    'Medical Supplies',
    'Other',
  ];

  final List<String> _shippingModes = const [
    'Road Freight',
    'Air Freight',
    'Sea Freight',
    'Express',
  ];

  String _selectedCargoType = 'General Cargo';
  String _selectedShippingMode = 'Road Freight';

  DateTime? _pickupDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _deliveryController.dispose();
    _cargoController.dispose();
    _weightController.dispose();
    _quantityController.dispose();
    _dateController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  IconData _shippingModeIcon(String mode) {
    switch (mode) {
      case 'Air Freight':
        return Icons.flight_takeoff_rounded;
      case 'Sea Freight':
        return Icons.directions_boat_filled_outlined;
      case 'Express':
        return Icons.bolt_rounded;
      default:
        return Icons.local_shipping_outlined;
    }
  }

  String _shippingModeLabel(AppLocalizations l10n, String mode) {
    return LocaleController.optionLabel(l10n, mode);
  }

  Future<void> _choosePickupDate() async {
    final l10n = AppLocalizations.of(context)!;
    final today = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? today.add(const Duration(days: 1)),
      firstDate: today,
      lastDate: DateTime(today.year + 2),
      helpText: l10n.selectPreferredPickupDate,
      cancelText: l10n.cancel,
      confirmText: l10n.select,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _darkNavy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    setState(() {
      _pickupDate = selectedDate;
      _dateController.text = _formatDate(selectedDate);
    });
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final day = date.day.toString().padLeft(2, '0');
    final month = LocaleController.monthAbbrev(l10n, date.month);

    return '$day $month ${date.year}';
  }

  Future<void> _submitQuote() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final user = _quoteController.currentUser;

    if (user == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSignInBeforeQuoteShort),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _quoteController.submitLegacy({
        'userId': user.uid,
        'pickupLocation': _pickupController.text.trim(),
        'deliveryLocation': _deliveryController.text.trim(),
        'cargo': _cargoController.text.trim(),
        'weight': _weightController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'shipmentDate': _dateController.text.trim(),
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'notes': _notesController.text.trim(),
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _pickupController.clear();
      _deliveryController.clear();
      _cargoController.clear();
      _weightController.clear();
      _quantityController.clear();
      _dateController.clear();
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _notesController.clear();

      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.couldNotSubmitQuoteRetry),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 35,
                  offset: Offset(0, 16),
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
                    color: Color(0xFFE8F7F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF16765C),
                    size: 38,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  l10n.quoteRequestSubmitted,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _darkNavy,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  l10n.quotePreparedSuccess,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _mutedText,
                    fontSize: 13.5,
                    height: 1.55,
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8FC),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_shipping_outlined,
                        color: _primaryBlue,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          '${_pickupController.text} → ${_deliveryController.text}',
                          style: const TextStyle(
                            color: _darkNavy,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: Text(
                      l10n.done,
                      style: const TextStyle(
                        fontSize: 15,
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

  InputDecoration _fieldDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFA2AAB5), fontSize: 13.5),
      prefixIcon: Icon(icon, color: _primaryBlue, size: 21),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: _primaryBlue, width: 1.7),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: _accentRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: _accentRed, width: 1.5),
      ),
    );
  }

  String? _requiredValidator(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }

    return null;
  }

  String? _emailValidator(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return l10n.pleaseEnterEmail;
    }

    final validEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!validEmail) {
      return l10n.pleaseEnterValidEmail;
    }

    return null;
  }

  String? _weightValidator(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final weight = value?.trim() ?? '';

    if (weight.isEmpty) {
      return l10n.pleaseEnterCargoWeight;
    }

    final parsedWeight = double.tryParse(weight);

    if (parsedWeight == null || parsedWeight <= 0) {
      return l10n.pleaseEnterValidWeight;
    }

    return null;
  }

  String? _quantityValidator(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final quantity = value?.trim() ?? '';

    if (quantity.isEmpty) {
      return l10n.pleaseEnterNumberOfItems;
    }

    final parsedQuantity = int.tryParse(quantity);

    if (parsedQuantity == null || parsedQuantity <= 0) {
      return l10n.pleaseEnterValidQuantity;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 38),
            children: [
              _buildPremiumHeader(),

              const SizedBox(height: 22),

              _SectionCard(
                icon: Icons.route_rounded,
                title: l10n.routeDetails,
                subtitle: l10n.tellUsCollectedDelivered,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _pickupController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        return _requiredValidator(
                          value,
                          l10n.pleaseEnterPickupLocation,
                        );
                      },
                      decoration: _fieldDecoration(
                        hintText: l10n.pickupLocation,
                        icon: Icons.radio_button_checked_rounded,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F2FC),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: _primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _deliveryController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        return _requiredValidator(
                          value,
                          l10n.pleaseEnterDeliveryLocation,
                        );
                      },
                      decoration: _fieldDecoration(
                        hintText: l10n.deliveryLocation,
                        icon: Icons.location_on_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _SectionCard(
                icon: Icons.local_shipping_outlined,
                title: l10n.shippingService,
                subtitle: l10n.chooseTransportService,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 12) / 2;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _shippingModes.map((mode) {
                        return SizedBox(
                          width: itemWidth,
                          child: _ShippingModeCard(
                            title: _shippingModeLabel(l10n, mode),
                            icon: _shippingModeIcon(mode),
                            selected: _selectedShippingMode == mode,
                            onTap: () {
                              setState(() {
                                _selectedShippingMode = mode;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              _SectionCard(
                icon: Icons.inventory_2_outlined,
                title: l10n.cargoInformation,
                subtitle: l10n.provideCargoForQuote,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCargoType,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _darkNavy,
                      ),
                      isExpanded: true,
                      decoration: _fieldDecoration(
                        hintText: l10n.cargoType,
                        icon: Icons.category_outlined,
                      ),
                      items: _cargoTypes.map((cargoType) {
                        return DropdownMenuItem<String>(
                          value: cargoType,
                          child: Text(
                            LocaleController.optionLabel(l10n, cargoType),
                            style: const TextStyle(
                              color: _darkNavy,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedCargoType = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _cargoController,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        return _requiredValidator(
                          value,
                          l10n.pleaseDescribeCargo,
                        );
                      },
                      decoration: _fieldDecoration(
                        hintText: l10n.cargoDescription,
                        icon: Icons.description_outlined,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: _weightValidator,
                            decoration: _fieldDecoration(
                              hintText: l10n.weightKg,
                              icon: Icons.scale_outlined,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: _quantityValidator,
                            decoration: _fieldDecoration(
                              hintText: l10n.quantity,
                              icon: Icons.numbers_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _SectionCard(
                icon: Icons.calendar_month_outlined,
                title: l10n.pickupSchedule,
                subtitle: l10n.choosePreferredCollectionDate,
                child: TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: _choosePickupDate,
                  validator: (value) {
                    if (_pickupDate == null) {
                      return l10n.pleaseSelectPickupDate;
                    }

                    return null;
                  },
                  decoration: _fieldDecoration(
                    hintText: l10n.preferredPickupDate,
                    icon: Icons.calendar_today_outlined,
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _darkNavy,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _SectionCard(
                icon: Icons.person_outline_rounded,
                title: l10n.contactInformation,
                subtitle: l10n.enterContactForLogistics,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        return _requiredValidator(
                          value,
                          l10n.pleaseEnterFullName,
                        );
                      },
                      decoration: _fieldDecoration(
                        hintText: l10n.fullName,
                        icon: Icons.person_outline_rounded,
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        return _requiredValidator(
                          value,
                          l10n.pleaseEnterPhone,
                        );
                      },
                      decoration: _fieldDecoration(
                        hintText: l10n.phoneNumber,
                        icon: Icons.phone_outlined,
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _emailValidator,
                      decoration: _fieldDecoration(
                        hintText: l10n.emailAddressHint,
                        icon: Icons.email_outlined,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _SectionCard(
                icon: Icons.edit_note_rounded,
                title: l10n.additionalNotes,
                subtitle: l10n.addInstructionsOrRequirements,
                child: TextFormField(
                  controller: _notesController,
                  minLines: 4,
                  maxLines: 7,
                  textInputAction: TextInputAction.newline,
                  decoration: _fieldDecoration(
                    hintText: l10n.specialHandlingHintShort,
                    icon: Icons.notes_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FD),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD5E8F8)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: _primaryBlue,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.reviewedBeforeFinalQuote,
                        style: const TextStyle(
                          color: Color(0xFF587089),
                          fontSize: 12.5,
                          height: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 61,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitQuote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF7DA9D0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.submitQuoteRequest,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 11),
                            const Icon(Icons.arrow_forward_rounded, size: 22),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF092542), Color(0xFF07569E), Color(0xFF0874C9)],
        ),
        borderRadius: BorderRadius.circular(29),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3507569E),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                ),
              ),

              const Spacer(),

              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.request_quote_outlined,
                  color: _primaryBlue,
                  size: 26,
                ),
              ),
            ],
          ),

          const SizedBox(height: 27),

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0x24FFFFFF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x28FFFFFF)),
            ),
            child: const Icon(
              Icons.calculate_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            l10n.catRequestQuote,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            l10n.shareDetailsTailoredQuote,
            style: const TextStyle(
              color: Color(0xFFD9E9F8),
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _HeaderBenefit(
                  icon: Icons.lock_outline_rounded,
                  label: l10n.secure,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderBenefit(
                  icon: Icons.tune_rounded,
                  label: l10n.tailored,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderBenefit(
                  icon: Icons.support_agent_rounded,
                  label: l10n.supported,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderBenefit extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderBenefit({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x20FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x24FFFFFF)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFDCEAF8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0B294D),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2FC),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: _primaryBlue, size: 23),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _darkNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _mutedText,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }
}

class _ShippingModeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ShippingModeCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _primaryBlue : const Color(0xFFF7F9FC),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
          decoration: BoxDecoration(
            color: selected ? _primaryBlue : const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? _primaryBlue : _borderColor),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x2807569E),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0x22FFFFFF)
                      : const Color(0xFFE8F2FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : _primaryBlue,
                  size: 21,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: selected ? Colors.white : _darkNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
