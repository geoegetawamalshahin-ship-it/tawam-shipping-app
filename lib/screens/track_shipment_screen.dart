import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'shipment_details_screen.dart';

const Color _primaryBlue = Color(0xFF07569E);
const Color _darkNavy = Color(0xFF10233F);
const Color _pageBackground = Color(0xFFF4F7FB);
const Color _borderColor = Color(0xFFE3E9F0);
const Color _accentRed = Color(0xFFD72638);

class TrackShipmentScreen extends StatefulWidget {
  final String? initialTrackingNumber;

  const TrackShipmentScreen({super.key, this.initialTrackingNumber});

  @override
  State<TrackShipmentScreen> createState() => _TrackShipmentScreenState();
}

class _TrackShipmentScreenState extends State<TrackShipmentScreen> {
  final TextEditingController _trackingController = TextEditingController();

  bool _isSearching = false;
  bool _showResult = false;

  Map<String, dynamic>? _shipment;

  @override
  void initState() {
    super.initState();

    final initialNumber = widget.initialTrackingNumber?.trim();

    if (initialNumber != null && initialNumber.isNotEmpty) {
      _trackingController.text = initialNumber;
    }
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _trackShipment() async {
    final trackingNumber = _trackingController.text.trim().toUpperCase();

    FocusScope.of(context).unfocus();

    if (trackingNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your tracking number'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to track your shipment'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _showResult = false;
      _shipment = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('shipments')
          .where('userId', isEqualTo: user.uid)
          .where('trackingNumber', isEqualTo: trackingNumber)
          .limit(1)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isSearching = false;
          _showResult = false;
          _shipment = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Shipment not found in your account'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );

        return;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();

      setState(() {
        _isSearching = false;
        _showResult = true;

        _shipment = {
          ...data,
          'id': doc.id,
          'number': data['trackingNumber'] ?? '',
          'origin': data['pickupLocation'] ?? '',
          'destination': data['deliveryLocation'] ?? '',
          'type': data['cargo'] ?? 'Shipment',
          'date': data['expectedDelivery'] ?? '',
        };
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _showResult = false;
        _shipment = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not track shipment: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openShipmentDetails() {
    final shipment = _shipment;

    if (shipment == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShipmentDetailsScreen(shipment: shipment),
      ),
    );
  }

  void _scanCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('QR code scanning will be connected later'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            _buildPremiumHeader(),

            const SizedBox(height: 22),

            _buildTrackingCard(),

            const SizedBox(height: 22),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _showResult
                  ? _buildShipmentResult()
                  : _buildTrackingGuide(),
            ),

            if (_showResult) ...[
              const SizedBox(height: 22),
              _buildTrackingTimeline(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
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
                  Icons.location_searching_rounded,
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
              Icons.local_shipping_outlined,
              color: Colors.white,
              size: 29,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Track Shipment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Follow your shipment journey and receive the latest delivery updates.',
            style: TextStyle(
              color: Color(0xFFD9E9F8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100B294D),
            blurRadius: 24,
            offset: Offset(0, 11),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter tracking number',
            style: TextStyle(
              color: _darkNavy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Use the number provided in your shipping confirmation.',
            style: TextStyle(
              color: Color(0xFF8993A1),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _trackingController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              _trackShipment();
            },
            decoration: InputDecoration(
              hintText: 'Example: TW-2026-00124',
              hintStyle: const TextStyle(color: Color(0xFFA1A9B5)),
              prefixIcon: const Icon(Icons.search_rounded, color: _primaryBlue),
              suffixIcon: IconButton(
                onPressed: _scanCode,
                icon: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: _darkNavy,
                ),
              ),
              filled: true,
              fillColor: const Color(0xFFF7F9FC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 19,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: _borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: _primaryBlue, width: 1.7),
              ),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 57,
            child: ElevatedButton(
              onPressed: _isSearching ? null : _trackShipment,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF7BA7CF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _isSearching
                  ? const SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Track Shipment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, size: 22),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingGuide() {
    return Container(
      key: const ValueKey('tracking-guide'),
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: _primaryBlue, size: 22),
              SizedBox(width: 10),
              Text(
                'How tracking works',
                style: TextStyle(
                  color: _darkNavy,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 19),

          const _GuideItem(
            number: '1',
            title: 'Enter your tracking number',
            description: 'Find it in your shipment confirmation.',
          ),

          const SizedBox(height: 15),

          const _GuideItem(
            number: '2',
            title: 'View live shipment status',
            description: 'See the route, progress and latest update.',
          ),

          const SizedBox(height: 15),

          const _GuideItem(
            number: '3',
            title: 'Open full shipment details',
            description: 'Review the full journey and delivery information.',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildShipmentResult() {
    final shipment = _shipment;

    if (shipment == null) {
      return const SizedBox.shrink();
    }

    final trackingNumber =
        (shipment['trackingNumber'] ?? shipment['number'] ?? '').toString();

    final pickup = (shipment['pickupLocation'] ?? shipment['origin'] ?? '')
        .toString();

    final delivery =
        (shipment['deliveryLocation'] ?? shipment['destination'] ?? '')
            .toString();

    final cargo = (shipment['cargo'] ?? shipment['type'] ?? 'Shipment')
        .toString();

    final status = (shipment['status'] ?? 'pending').toString().toLowerCase();

    final expectedDelivery = shipment['expectedDelivery'];

    String formattedDelivery = 'Not specified';

    if (expectedDelivery is Timestamp) {
      final date = expectedDelivery.toDate();

      formattedDelivery =
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } else if (expectedDelivery != null) {
      formattedDelivery = expectedDelivery.toString();
    }

    double progress;

    String readableStatus;

    switch (status) {
      case 'confirmed':
        progress = 0.25;
        readableStatus = 'Confirmed';
        break;

      case 'in_transit':
        progress = 0.55;
        readableStatus = 'In Transit';
        break;

      case 'out_for_delivery':
        progress = 0.85;
        readableStatus = 'Out for Delivery';
        break;

      case 'delivered':
        progress = 1.0;
        readableStatus = 'Delivered';
        break;

      case 'cancelled':
        progress = 0.0;
        readableStatus = 'Cancelled';
        break;

      default:
        progress = 0.10;
        readableStatus = 'Pending';
    }

    final progressPercent = (progress * 100).round();

    return Container(
      key: const ValueKey('shipment-result'),
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100B294D),
            blurRadius: 24,
            offset: Offset(0, 11),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFEAF4FD), Color(0xFFDCEEFF)],
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: _primaryBlue,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trackingNumber,
                      style: const TextStyle(
                        color: _darkNavy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Live shipment data',
                      style: TextStyle(
                        color: Color(0xFF929BA8),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2FC),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  readableStatus,
                  style: const TextStyle(
                    color: _primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _RouteLocation(
                    icon: Icons.radio_button_checked_rounded,
                    iconColor: _primaryBlue,
                    title: 'Origin',
                    location: pickup,
                    alignRight: false,
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFA2ABB7),
                  ),
                ),

                Expanded(
                  child: _RouteLocation(
                    icon: Icons.location_on_rounded,
                    iconColor: _accentRed,
                    title: 'Destination',
                    location: delivery,
                    alignRight: true,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Text(
                'Shipment progress',
                style: TextStyle(
                  color: Color(0xFF788391),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  color: _primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE6EBF1),
              color: _primaryBlue,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _ResultInfo(
                  icon: Icons.calendar_today_outlined,
                  title: 'Estimated delivery',
                  value: formattedDelivery,
                ),
              ),
              Expanded(
                child: _ResultInfo(
                  icon: Icons.route_outlined,
                  title: 'Shipment type',
                  value: cargo,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _openShipmentDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkNavy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Full Details',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    final shipment = _shipment;

    if (shipment == null) {
      return const SizedBox.shrink();
    }

    final status = (shipment['status'] ?? 'pending').toString().toLowerCase();

    bool reached(String step) {
      const order = [
        'pending',
        'confirmed',
        'prepared',
        'in_transit',
        'out_for_delivery',
        'delivered',
      ];

      final currentIndex = order.indexOf(status);
      final stepIndex = order.indexOf(step);

      if (currentIndex == -1 || stepIndex == -1) return false;

      return currentIndex >= stepIndex;
    }

    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Latest Tracking Updates',
            style: TextStyle(
              color: _darkNavy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 21),

          _TrackingUpdate(
            icon: Icons.inventory_2_outlined,
            title: 'Shipment received',
            description: 'Shipment information has been created.',
            time: 'Shipment created',
            completed: reached('pending'),
            active: status == 'pending',
          ),

          _TrackingUpdate(
            icon: Icons.verified_outlined,
            title: 'Confirmed',
            description: 'Shipment has been confirmed by Tawam logistics.',
            time: reached('confirmed') ? 'Confirmed' : 'Waiting',
            completed: reached('confirmed'),
            active: status == 'confirmed',
          ),
          _TrackingUpdate(
            icon: Icons.inventory_2_outlined,
            title: 'Prepared',
            description: 'Shipment has been prepared and is ready for transit.',
            time: reached('prepared') ? 'Prepared' : 'Waiting',
            completed: reached('prepared'),
            active: status == 'prepared',
          ),

          _TrackingUpdate(
            icon: Icons.local_shipping_rounded,
            title: 'In transit',
            description: 'Shipment is moving to destination.',
            time: reached('in_transit') ? 'In progress' : 'Waiting',
            completed: reached('in_transit'),
            active: status == 'in_transit',
          ),

          _TrackingUpdate(
            icon: Icons.route_rounded,
            title: 'Out for delivery',
            description: 'Shipment is on the way to final delivery.',
            time: reached('out_for_delivery') ? 'In progress' : 'Waiting',
            completed: reached('out_for_delivery'),
            active: status == 'out_for_delivery',
          ),

          _TrackingUpdate(
            icon: Icons.check_circle_outline_rounded,
            title: 'Delivered',
            description: 'Shipment has been delivered successfully.',
            time: status == 'delivered' ? 'Delivered' : 'Waiting',
            completed: status == 'delivered',
            active: status == 'delivered',
          ),

          if (status == 'cancelled')
            const _TrackingUpdate(
              icon: Icons.cancel_outlined,
              title: 'Cancelled',
              description: 'This shipment has been cancelled.',
              time: 'Cancelled',
              active: true,
            ),
        ],
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _GuideItem({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F2FC),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: _primaryBlue,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
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
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF929BA8),
                  fontSize: 11.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteLocation extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String location;
  final bool alignRight;

  const _RouteLocation({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.location,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(color: Color(0xFF949DA9), fontSize: 10.5),
        ),
        const SizedBox(height: 4),
        Text(
          location,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            color: _darkNavy,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ResultInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ResultInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primaryBlue, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF969FAC),
                  fontSize: 10.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: _darkNavy,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrackingUpdate extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final bool completed;
  final bool active;

  const _TrackingUpdate({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.completed = false,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = completed || active ? _primaryBlue : const Color(0xFFBCC4CE);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: completed || active
                  ? const Color(0xFFE8F2FC)
                  : const Color(0xFFF0F2F5),
              shape: BoxShape.circle,
              border: active
                  ? Border.all(color: const Color(0xFFBBDCF5), width: 3)
                  : null,
            ),
            child: Icon(icon, color: color, size: 19),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: completed || active
                              ? _darkNavy
                              : const Color(0xFF87919E),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    if (active)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F2FC),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Text(
                          'Current',
                          style: TextStyle(
                            color: _primaryBlue,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF929BA8),
                    fontSize: 11.5,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFFADB4BE),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
