import 'package:flutter/material.dart';
import 'get_quote_screen.dart';

class VolumeCalculatorScreen extends StatefulWidget {
  const VolumeCalculatorScreen({super.key});

  @override
  State<VolumeCalculatorScreen> createState() => _VolumeCalculatorScreenState();
}

class _VolumeCalculatorScreenState extends State<VolumeCalculatorScreen> {
  static const Color deepBlue = Color(0xFF062B55);
  static const Color primaryBlue = Color(0xFF0B4F9C);
  static const Color brightBlue = Color(0xFF1268BC);
  static const Color pageBg = Color(0xFFF4F7FB);
  static const Color textDark = Color(0xFF10233F);
  static const Color textGrey = Color(0xFF8793A4);
  static const Color borderColor = Color(0xFFE1E8F0);
  static const Color softBlue = Color(0xFFEAF3FF);

  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _actualWeightController = TextEditingController();

  double _cbm = 0;
  double _airVolWeight = 0;
  double _courierVolWeight = 0;
  double _chargeableAirWeight = 0;
  bool _hasCalculated = false;

  @override
  void initState() {
    super.initState();

    for (final controller in [
      _lengthController,
      _widthController,
      _heightController,
      _quantityController,
      _actualWeightController,
    ]) {
      controller.addListener(_calculateLive);
    }
  }

  @override
  void dispose() {
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _quantityController.dispose();
    _actualWeightController.dispose();
    super.dispose();
  }

  void _calculateLive() {
    final length = double.tryParse(_lengthController.text.trim()) ?? 0;
    final width = double.tryParse(_widthController.text.trim()) ?? 0;
    final height = double.tryParse(_heightController.text.trim()) ?? 0;
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    final actualWeight =
        double.tryParse(_actualWeightController.text.trim()) ?? 0;

    if (length <= 0 || width <= 0 || height <= 0 || quantity <= 0) {
      if (!mounted) return;
      setState(() {
        _cbm = 0;
        _airVolWeight = 0;
        _courierVolWeight = 0;
        _chargeableAirWeight = 0;
        _hasCalculated = false;
      });
      return;
    }

    final totalCubicCm = length * width * height * quantity;
    final cbm = totalCubicCm / 1000000;
    final airVolWeight = totalCubicCm / 6000;
    final courierVolWeight = totalCubicCm / 5000;
    final chargeable = actualWeight > airVolWeight
        ? actualWeight
        : airVolWeight;

    if (!mounted) return;
    setState(() {
      _cbm = cbm;
      _airVolWeight = airVolWeight;
      _courierVolWeight = courierVolWeight;
      _chargeableAirWeight = chargeable;
      _hasCalculated = true;
    });
  }

  void _reset() {
    _lengthController.clear();
    _widthController.clear();
    _heightController.clear();
    _quantityController.text = '1';
    _actualWeightController.clear();

    setState(() {
      _cbm = 0;
      _airVolWeight = 0;
      _courierVolWeight = 0;
      _chargeableAirWeight = 0;
      _hasCalculated = false;
    });
  }

  void _requestQuote() {
    if (!_hasCalculated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Please enter the cargo dimensions first.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GetQuoteScreen(
          initialLengthCm: _lengthController.text.trim(),
          initialWidthCm: _widthController.text.trim(),
          initialHeightCm: _heightController.text.trim(),
          initialQuantity: _quantityController.text.trim(),
          initialWeightKg: _actualWeightController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(),
                    const SizedBox(height: 24),
                    _sectionHeading(
                      number: '01',
                      icon: Icons.straighten_rounded,
                      title: 'Cargo Dimensions',
                      subtitle:
                          'Enter one package size in centimeters and the total quantity.',
                    ),
                    const SizedBox(height: 14),
                    _buildDimensionsCard(),
                    const SizedBox(height: 24),
                    _sectionHeading(
                      number: '02',
                      icon: Icons.analytics_outlined,
                      title: 'Calculation Results',
                      subtitle:
                          'Instant logistics measurements for planning your shipment.',
                    ),
                    const SizedBox(height: 14),
                    _buildResults(),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _hasCalculated ? _requestQuote : null,
                        icon: const Icon(
                          Icons.request_quote_outlined,
                          size: 20,
                        ),
                        label: const Text(
                          'REQUEST A QUOTE',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: .4,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFD9E2EC),
                          disabledForegroundColor: const Color(0xFF8D99A8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildProfessionalNote(),

                    const SizedBox(height: 18),

                    _buildResetButton(),
                  ],
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
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: .06),
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
                  'Volume Calculator',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.35,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'TAWAM AL-SHAHIN TRANSPORT',
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 9.3,
                    fontWeight: FontWeight.w800,
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
              Icons.calculate_outlined,
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
          colors: [deepBlue, Color(0xFF0A4789), brightBlue],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: .17),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -28,
            child: Icon(
              Icons.inventory_2_outlined,
              size: 145,
              color: Colors.white.withValues(alpha: .055),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calculate_outlined, color: Colors.white, size: 19),
                  SizedBox(width: 8),
                  Text(
                    'LOGISTICS CALCULATION TOOL',
                    style: TextStyle(
                      color: Color(0xFFD5E5F4),
                      fontSize: 9.4,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Plan Your Cargo Smarter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Calculate CBM and volumetric weight instantly before requesting your shipping quotation.',
                style: TextStyle(
                  color: Color(0xFFD7E6F5),
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 17),
              Row(
                children: [
                  _HeroFeature(icon: Icons.speed_rounded, label: 'Instant'),
                  SizedBox(width: 18),
                  _HeroFeature(
                    icon: Icons.straighten_rounded,
                    label: 'Accurate',
                  ),
                  SizedBox(width: 18),
                  _HeroFeature(
                    icon: Icons.public_rounded,
                    label: 'Logistics Ready',
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: deepBlue,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: primaryBlue, size: 19),
                  const SizedBox(width: 7),
                  Text(
                    title,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textGrey,
                  fontSize: 10.5,
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

  Widget _buildDimensionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _input(
                  controller: _lengthController,
                  label: 'Length',
                  hint: '0',
                  suffix: 'CM',
                  icon: Icons.swap_horiz_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _input(
                  controller: _widthController,
                  label: 'Width',
                  hint: '0',
                  suffix: 'CM',
                  icon: Icons.straighten_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _input(
                  controller: _heightController,
                  label: 'Height',
                  hint: '0',
                  suffix: 'CM',
                  icon: Icons.height_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _input(
                  controller: _quantityController,
                  label: 'Quantity',
                  hint: '1',
                  icon: Icons.numbers_rounded,
                  integerOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          _input(
            controller: _actualWeightController,
            label: 'Actual Total Weight',
            hint: 'Optional',
            suffix: 'KG',
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: primaryBlue, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Enter the dimensions of one package. Quantity is applied automatically to the total calculation.',
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 9.8,
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
    );
  }

  Widget _buildResults() {
    if (!_hasCalculated) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
        ),
        child: const Column(
          children: [
            Icon(Icons.analytics_outlined, color: primaryBlue, size: 42),
            SizedBox(height: 12),
            Text(
              'Enter your cargo dimensions',
              style: TextStyle(
                color: textDark,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Your shipping calculation will appear here instantly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textGrey, fontSize: 10.5, height: 1.4),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [deepBlue, primaryBlue]),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: deepBlue.withValues(alpha: .14),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL SHIPMENT VOLUME',
                style: TextStyle(
                  color: Color(0xFFD6E6F6),
                  fontSize: 9.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .9,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _cbm.toStringAsFixed(3),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.7,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 3),
                    child: Text(
                      'CBM',
                      style: TextStyle(
                        color: Color(0xFFD6E6F6),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Cubic volume based on the entered dimensions and quantity.',
                style: TextStyle(
                  color: Color(0xFFD6E6F6),
                  fontSize: 10,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _resultCard(
                icon: Icons.flight_rounded,
                title: 'Air Vol. Weight',
                value: '${_airVolWeight.toStringAsFixed(1)} KG',
                subtitle: 'Divisor 6000',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _resultCard(
                icon: Icons.inventory_2_outlined,
                title: 'Courier Vol. Weight',
                value: '${_courierVolWeight.toStringAsFixed(1)} KG',
                subtitle: 'Divisor 5000',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _resultCard(
          icon: Icons.scale_outlined,
          title: 'Estimated Air Chargeable Weight',
          value: '${_chargeableAirWeight.toStringAsFixed(1)} KG',
          subtitle: 'Higher of actual total weight and air volumetric weight',
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _resultCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    bool fullWidth = false,
  }) {
    final card = Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
      child: Column(
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
          const SizedBox(height: 11),
          Text(
            title,
            style: const TextStyle(
              color: textGrey,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: deepBlue,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: textGrey, fontSize: 8.7, height: 1.3),
          ),
        ],
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: card) : card;
  }

  Widget _buildProfessionalNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFF0DDAA)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFFA66C00), size: 19),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Volumetric-weight rules can vary by carrier, service and route. Final chargeable weight is confirmed by TAWAM AL-SHAHIN TRANSPORT.',
              style: TextStyle(
                color: Color(0xFF795718),
                fontSize: 9.7,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _reset,
        icon: const Icon(Icons.restart_alt_rounded),
        label: const Text(
          'RESET CALCULATOR',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: .3),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: deepBlue,
          side: const BorderSide(color: Color(0xFFB8C7D8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
    bool integerOnly = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: integerOnly
          ? TextInputType.number
          : const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        color: textDark,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: primaryBlue, size: 20),
        labelStyle: const TextStyle(
          color: textGrey,
          fontSize: 10.2,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: Color(0xFF9DA8B6), fontSize: 11),
        suffixStyle: const TextStyle(
          color: textGrey,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
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
            fontSize: 9.3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
