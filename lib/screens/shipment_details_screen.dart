import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'support_screen.dart';

const Color _primaryBlue = Color(0xFF07569E);
const Color _darkNavy = Color(0xFF10233F);
const Color _pageBackground = Color(0xFFF4F7FB);
const Color _borderColor = Color(0xFFE3E9F0);
const Color _successGreen = Color(0xFF16765C);
const Color _accentRed = Color(0xFFD72638);

class ShipmentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> shipment;

  const ShipmentDetailsScreen({super.key, required this.shipment});

  int get _currentStep {
    final status = (shipment['status'] ?? 'pending')
        .toString()
        .trim()
        .toLowerCase();

    switch (status) {
      case 'delivered':
        return 3;

      case 'out_for_delivery':
      case 'customs_clearance':
        return 2;

      case 'in_transit':
        return 1;

      case 'pending':
      case 'confirmed':
      case 'prepared':
      default:
        return 0;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return _successGreen;
      case 'Pending':
        return const Color(0xFFC97908);
      default:
        return _primaryBlue;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Delivered':
        return const Color(0xFFE7F7F0);
      case 'Pending':
        return const Color(0xFFFFF1D8);
      default:
        return const Color(0xFFE8F2FC);
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final number = (shipment['trackingNumber'] ?? shipment['number'] ?? '')
        .toString();

    final origin =
        (shipment['pickupLocation'] ?? shipment['origin'] ?? 'Origin')
            .toString();

    final destination =
        (shipment['deliveryLocation'] ??
                shipment['destination'] ??
                'Destination')
            .toString();

    final status = (shipment['status'] ?? 'pending').toString().toLowerCase();

    final expectedDelivery = shipment['expectedDelivery'];

    String date = 'Not available';

    if (expectedDelivery is Timestamp) {
      final deliveryDate = expectedDelivery.toDate();

      date =
          '${deliveryDate.day.toString().padLeft(2, '0')}/'
          '${deliveryDate.month.toString().padLeft(2, '0')}/'
          '${deliveryDate.year}';
    } else if (expectedDelivery != null &&
        expectedDelivery.toString().trim().isNotEmpty) {
      date = expectedDelivery.toString();
    }

    final type = (shipment['cargo'] ?? shipment['type'] ?? 'Not provided')
        .toString();

    final stage = (shipment['stage'] ?? '').toString();

    double progress;

    switch (status) {
      case 'confirmed':
        progress = 0.25;
        break;

      case 'prepared':
        progress = 0.40;
        break;

      case 'in_transit':
        progress = 0.55;
        break;

      case 'out_for_delivery':
        progress = 0.85;
        break;

      case 'delivered':
        progress = 1.0;
        break;

      case 'cancelled':
        progress = 0.0;
        break;

      default:
        progress = 0.10;
    }
    final weight = (shipment['weight'] ?? shipment['totalWeight'] ?? '')
        .toString();
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 35),
          children: [
            _buildPremiumHeader(
              context: context,
              number: number,
              status: status,
            ),

            const SizedBox(height: 22),

            _buildRouteCard(
              origin: origin,
              destination: destination,
              status: status,
              stage: stage,
              progress: progress,
            ),

            const SizedBox(height: 22),

            const Text(
              'Shipment Information',
              style: TextStyle(
                color: _darkNavy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 14),

            _buildInformationCard(
              number: number,
              date: date,
              type: type,
              weight: weight,
            ),

            const SizedBox(height: 24),

            const Text(
              'Shipment Journey',
              style: TextStyle(
                color: _darkNavy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 14),

            _buildTimeline(),

            const SizedBox(height: 24),

            _buildSupportCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader({
    required BuildContext context,
    required String number,
    required String status,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
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

              Material(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: () {
                    _showMessage(context, 'Sharing will be connected later');
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.ios_share_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Container(
            width: 57,
            height: 57,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: _primaryBlue,
              size: 28,
            ),
          ),

          const SizedBox(height: 17),

          const Text(
            'Shipment Details',
            style: TextStyle(
              color: Color(0xFFD9E9F8),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: _statusColor(status),
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard({
    required String origin,
    required String destination,
    required String status,
    required String stage,
    required double progress,
  }) {
    final safeProgress = progress.clamp(0.0, 1.0);

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
          Row(
            children: [
              const Text(
                'Route Overview',
                style: TextStyle(
                  color: _darkNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _statusBackground(status),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _statusColor(status),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _LocationPoint(
                  icon: Icons.radio_button_checked_rounded,
                  iconColor: _primaryBlue,
                  label: 'Origin',
                  location: origin,
                  alignRight: false,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      color: _primaryBlue,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 54,
                      height: 2,
                      color: const Color(0xFFD7DEE7),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _LocationPoint(
                  icon: Icons.location_on_rounded,
                  iconColor: _accentRed,
                  label: 'Destination',
                  location: destination,
                  alignRight: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F9FC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 39,
                  height: 39,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2FC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: _primaryBlue,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    stage,
                    style: const TextStyle(
                      color: Color(0xFF6F7A89),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
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
                '${(safeProgress * 100).round()}%',
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
              value: safeProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE6EBF1),
              color: status == 'Delivered' ? _successGreen : _primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard({
    required String number,
    required String date,
    required String type,
    required String weight,
  }) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Tracking number',
                  value: number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  icon: Icons.calendar_today_outlined,
                  title: 'Expected delivery',
                  value: date,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.route_outlined,
                  title: 'Shipment type',
                  value: type,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  icon: Icons.scale_outlined,
                  title: 'Total weight',
                  value: weight.isEmpty ? 'Not provided' : weight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    const stages = [
      {
        'title': 'Shipment received',
        'description': 'Shipment information has been received.',
        'date': '06 Aug 2026 • 09:30 AM',
      },
      {
        'title': 'In transit',
        'description': 'Shipment is currently moving to destination.',
        'date': '07 Aug 2026 • 02:15 PM',
      },
      {
        'title': 'Customs clearance',
        'description': 'Shipment will be processed by customs.',
        'date': 'Expected soon',
      },
      {
        'title': 'Delivered',
        'description': 'Shipment delivered to the recipient.',
        'date': 'Expected delivery',
      },
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(19, 21, 19, 9),
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
        children: List.generate(stages.length, (index) {
          final completed = index < _currentStep;
          final active = index == _currentStep;
          final last = index == stages.length - 1;

          return _TimelineStep(
            title: stages[index]['title']!,
            description: stages[index]['description']!,
            date: stages[index]['date']!,
            completed: completed,
            active: active,
            showLine: !last,
          );
        }),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF6FD), Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDE9F4)),
      ),
      child: Row(
        children: [
          Container(
            width: 51,
            height: 51,
            decoration: BoxDecoration(
              color: _primaryBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need shipment support?',
                  style: TextStyle(
                    color: _darkNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Our logistics team is ready to assist you.',
                  style: TextStyle(
                    color: Color(0xFF87919F),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SupportScreen()),
              );
            },
            icon: const Icon(Icons.arrow_forward_rounded, color: _primaryBlue),
          ),
        ],
      ),
    );
  }
}

class _LocationPoint extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String location;
  final bool alignRight;

  const _LocationPoint({
    required this.icon,
    required this.iconColor,
    required this.label,
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
        Icon(icon, color: iconColor, size: 19),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF949DAA), fontSize: 11),
        ),
        const SizedBox(height: 5),
        Text(
          location,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            color: _darkNavy,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primaryBlue, size: 21),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF949DA9), fontSize: 10.5),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _darkNavy,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final bool completed;
  final bool active;
  final bool showLine;

  const _TimelineStep({
    required this.title,
    required this.description,
    required this.date,
    required this.completed,
    required this.active,
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    final circleColor = completed || active
        ? _primaryBlue
        : const Color(0xFFE4E9EF);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 38,
          child: Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  border: active
                      ? Border.all(color: const Color(0xFFB8DCF8), width: 4)
                      : null,
                ),
                child: Icon(
                  completed
                      ? Icons.check_rounded
                      : active
                      ? Icons.local_shipping_rounded
                      : Icons.circle,
                  color: completed || active
                      ? Colors.white
                      : const Color(0xFFB6BEC8),
                  size: completed ? 18 : 14,
                ),
              ),

              if (showLine)
                Container(
                  width: 2,
                  height: 65,
                  color: completed ? _primaryBlue : const Color(0xFFE3E8EE),
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: active || completed
                              ? _darkNavy
                              : const Color(0xFF8993A0),
                          fontSize: 14,
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
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF8D96A3),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFFABB2BC),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
