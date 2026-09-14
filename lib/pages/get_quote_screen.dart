import '../data/utils/value_formatters.dart';
import '../widgets/action_success_dialog.dart';
import '../widgets/shipping/premium_card.dart';
import '../widgets/soft_back_header.dart';
import '../widgets/shipping/show_shipping_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/models/form_submit_outcome.dart';
import '../controllers/get_quote_form_controller.dart';
import '../l10n/app_localizations.dart';
import '../controllers/locale_controller.dart';

class GetQuoteScreen extends StatefulWidget {
  const GetQuoteScreen({super.key});

  @override
  State<GetQuoteScreen> createState() => _GetQuoteScreenState();
}

class _GetQuoteScreenState extends State<GetQuoteScreen> {
  late final GetQuoteFormController _c;

  static const Color primaryBlue = Color(0xFF0B4F9C);
  static const Color deepBlue = Color(0xFF062B55);
  static const Color softBlue = Color(0xFFEAF3FF);
  static const Color pageBackground = Color(0xFFF5F7FB);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF7A8797);
  static const Color borderColor = Color(0xFFE3EAF2);

  final _formKey = GlobalKey<FormState>();

  TextEditingController get _fromController => _c.fromController;
  TextEditingController get _toController => _c.toController;
  TextEditingController get _cargoController => _c.cargoController;
  TextEditingController get _weightController => _c.weightController;
  TextEditingController get _quantityController => _c.quantityController;
  TextEditingController get _lengthController => _c.lengthController;
  TextEditingController get _widthController => _c.widthController;
  TextEditingController get _heightController => _c.heightController;
  TextEditingController get _notesController => _c.notesController;

  List<String> get _services => _c.services;

  String get _selectedService => _c.selectedService.value;
  set _selectedService(String value) => _c.selectedService.value = value;
  DateTime? get _pickupDate => _c.pickupDate.value;
  set _pickupDate(DateTime? value) => _c.pickupDate.value = value;

  @override
  void initState() {
    super.initState();
    _c = Get.find<GetQuoteFormController>();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                        title: l10n.shippingService,
                        subtitle: l10n.chooseServiceFits,
                      ),
                      const SizedBox(height: 14),
                      _buildServiceSelector(),
                      const SizedBox(height: 24),
                      _sectionTitle(
                        icon: Icons.route_outlined,
                        title: l10n.route,
                        subtitle: l10n.whereShipmentMoving,
                      ),
                      const SizedBox(height: 14),
                      _buildRouteCard(),
                      const SizedBox(height: 24),
                      _sectionTitle(
                        icon: Icons.inventory_2_outlined,
                        title: l10n.shipmentDetailsSection,
                        subtitle: l10n.tellUsAboutCargo,
                      ),
                      const SizedBox(height: 14),
                      _buildShipmentDetailsCard(),
                      const SizedBox(height: 24),
                      _sectionTitle(
                        icon: Icons.calendar_month_outlined,
                        title: l10n.pickup,
                        subtitle: l10n.selectPreferredPickup,
                      ),
                      const SizedBox(height: 14),
                      _buildPickupCard(),
                      const SizedBox(height: 24),
                      _sectionTitle(
                        icon: Icons.notes_rounded,
                        title: l10n.additionalNotes,
                        subtitle: l10n.addSpecialInstructions,
                      ),
                      const SizedBox(height: 14),
                      _buildNotesCard(),
                      const SizedBox(height: 24),
                      _buildTrustStrip(),
                      const SizedBox(height: 22),
                      _buildSubmitButton(),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          l10n.teamWillReviewRate,
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
      title: l10n.getAQuoteTitle,
      subtitle: l10n.tawamAlShahinTransport,
      trailingIcon: Icons.verified_outlined,
      onBack: () => Navigator.pop(context),
      height: 82,
      shadowColor: deepBlue,
      shadowAlpha: .07,
      shadowBlur: 20,
      shadowOffset: const Offset(0, 6),
      borderColor: borderColor,
      backIconColor: deepBlue,
      backIconSize: 23,
      titleColor: textDark,
      titleFontWeight: FontWeight.w800,
      titleLetterSpacing: -0.3,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.request_quote_outlined,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 14),
              Text(
                l10n.requestYourBestRate,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.quoteHeroSubtitle,
                style: const TextStyle(
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
      child: Obx(() {
        // Read here: the grid builds its items during layout, which is
        // outside the reactive scope of this Obx.
        final selectedService = _selectedService;

        return GridView.builder(
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
            final l10n = AppLocalizations.of(context)!;
            final service = _services[index];
            final selected = service == selectedService;

            return InkWell(
              onTap: () => _selectedService = service,
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
                        LocaleController.serviceLabel(l10n, service),
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
        );
      }),
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
    final l10n = AppLocalizations.of(context)!;
    return _card(
      child: Column(
        children: [
          _textField(
            controller: _fromController,
            label: l10n.from,
            hint: l10n.cityCountry,
            icon: Icons.trip_origin_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterPickupLocation;
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
            label: l10n.to,
            hint: l10n.cityCountry,
            icon: Icons.location_on_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterDeliveryLocation;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentDetailsCard() {
    final l10n = AppLocalizations.of(context)!;
    return _card(
      child: Column(
        children: [
          _textField(
            controller: _cargoController,
            label: l10n.cargoType,
            hint: l10n.hintCargoQuote,
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
            children: [
              Expanded(
                child: _textField(
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
                    if (weight == null || weight <= 0) {
                      return l10n.enterWeight;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(
                  controller: _quantityController,
                  label: l10n.quantity,
                  hint: '1',
                  icon: Icons.numbers_rounded,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final quantity = int.tryParse(value?.trim() ?? '');
                    if (quantity == null || quantity <= 0) {
                      return l10n.enterQuantity;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.dimensionsOptional,
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
          const SizedBox(height: 9),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.dimensionsInCm,
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
    final l10n = AppLocalizations.of(context)!;
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
                  Text(
                    l10n.preferredPickupDate,
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    final date = _pickupDate;
                    return Text(
                      date == null ? l10n.selectADate : _formatDate(l10n, date),
                      style: TextStyle(
                        color: date == null ? textGrey : textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }),
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
    final l10n = AppLocalizations.of(context)!;
    return _card(
      child: TextFormField(
        controller: _notesController,
        minLines: 4,
        maxLines: 7,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: l10n.specialHandlingHint,
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TrustItem(
              icon: Icons.verified_user_outlined,
              title: l10n.secureRequest,
            ),
          ),
          Expanded(
            child: _TrustItem(
              icon: Icons.price_check_outlined,
              title: l10n.bestRate,
            ),
          ),
          Expanded(
            child: _TrustItem(
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
    return Obx(() {
      final submitting = _c.quotes.isSubmitting.value;
      return SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: submitting ? null : _submitQuote,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: deepBlue,
            disabledBackgroundColor: deepBlue.withValues(alpha: .55),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: submitting
              ? const SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, size: 20),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        l10n.submitQuoteRequest,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
        ),
      );
    });
  }

  Future<void> _submitQuote() async {
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    final outcome = await _c.submit(
      formValid: _formKey.currentState?.validate() ?? false,
    );

    if (!mounted) return;

    if (outcome.isSuccess) {
      await _showSuccessDialog(
        quoteNumber: outcome.reference ?? '',
        requestId: outcome.documentId ?? '',
      );
      return;
    }

    switch (outcome.error) {
      case FormSubmitError.submitting:
      case null:
        return;
      case FormSubmitError.invalidForm:
        _showMessage(l10n.pleaseCompleteShipmentInfo, isError: true);
        return;
      case FormSubmitError.unsigned:
        _showMessage(l10n.pleaseSignInBeforeQuote, isError: true);
        return;
      case FormSubmitError.firebase:
        _showMessage(
          outcome.firebaseMessage ?? l10n.couldNotSubmitQuote,
          isError: true,
        );
        return;
      default:
        _showMessage(l10n.somethingWentWrong, isError: true);
        return;
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
        final l10n = AppLocalizations.of(dialogContext)!;
        return ActionSuccessDialog(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          borderRadius: 26,
          shadowColor: deepBlue.withValues(alpha: .18),
          shadowBlur: 28,
          shadowOffset: const Offset(0, 12),
          iconCircleSize: 72,
          iconCircleColor: softBlue,
          icon: Icons.check_circle_rounded,
          iconColor: primaryBlue,
          iconSize: 42,
          afterIconGap: 18,
          title: l10n.quoteRequestSubmitted,
          titleColor: textDark,
          titleFontSize: 20,
          titleFontWeight: FontWeight.w800,
          afterTitleGap: 9,
          body: l10n.quoteSentToTawam,
          bodyColor: textGrey,
          bodyFontSize: 12,
          bodyHeight: 1.45,
          bodyFontWeight: FontWeight.w500,
          afterBodyGap: 18,
          middle: Container(
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
                  l10n.reference,
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
          afterMiddleGap: 18,
          buttonHeight: 52,
          buttonColor: deepBlue,
          buttonRadius: 16,
          buttonLabel: l10n.doneUpper,
          buttonFontWeight: FontWeight.w800,
          onDone: () {
            Navigator.pop(dialogContext);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _card({required Widget child}) {
    return ShippingPremiumCard(
      borderColor: borderColor,
      shadowColor: deepBlue,
      borderRadius: 20,
      shadowBlur: 12,
      shadowOffset: const Offset(0, 5),
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
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      helpText: l10n.selectPickupDate,
    );

    if (selected == null || !mounted) return;

    _pickupDate = selected;
  }

  String _formatDate(AppLocalizations l10n, DateTime date) {
    return formatLocalizedDate(l10n, date);
  }

  void _showMessage(String message, {required bool isError}) {
    showShippingMessage(
      context,
      message: message,
      error: isError,
      successColor: deepBlue,
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
