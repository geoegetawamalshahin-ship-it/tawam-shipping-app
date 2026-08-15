import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'shipment_details_screen.dart';

const Color _primaryBlue = Color(0xFF07569E);
const Color _darkNavy = Color(0xFF10233F);
const Color _pageBackground = Color(0xFFF4F7FB);
const Color _borderColor = Color(0xFFE3E9F0);

class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';

  final List<String> _filters = const [
    'All',
    'Pending',
    'Confirmed',
    'In Transit',
    'Out for Delivery',
    'Delivered',
    'Cancelled',
  ];

  List<Map<String, dynamic>> _shipments = [];

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _shipmentsSubscription;

  bool _isLoadingShipments = true;
  @override
  void initState() {
    super.initState();
    _listenToShipments();
  }

  void _listenToShipments() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _shipments = [];
        _isLoadingShipments = false;
      });
      return;
    }

    _shipmentsSubscription = FirebaseFirestore.instance
        .collection('shipments')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen(
          (snapshot) {
            final items = snapshot.docs.map((doc) {
              final data = doc.data();

              final rawStatus = (data['status'] ?? 'pending')
                  .toString()
                  .toLowerCase();

              final displayStatus = _displayStatus(rawStatus);
              final progress = _statusProgress(rawStatus);
              final stage = _statusStage(rawStatus);

              return <String, dynamic>{
                ...data,
                'id': doc.id,
                'number': (data['trackingNumber'] ?? '').toString(),
                'origin': (data['pickupLocation'] ?? '').toString(),
                'destination': (data['deliveryLocation'] ?? '').toString(),
                'status': displayStatus,
                'rawStatus': rawStatus,
                'date': _formatDeliveryDate(data['expectedDelivery']),
                'type': (data['cargo'] ?? 'Shipment').toString(),
                'stage': stage,
                'progress': progress,
              };
            }).toList();

            items.sort((a, b) {
              final aCreated = a['createdAt'];
              final bCreated = b['createdAt'];

              if (aCreated is Timestamp && bCreated is Timestamp) {
                return bCreated.compareTo(aCreated);
              }

              return 0;
            });

            if (!mounted) return;

            setState(() {
              _shipments = items;
              _isLoadingShipments = false;
            });
          },
          onError: (error) {
            if (!mounted) return;

            setState(() {
              _isLoadingShipments = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not load shipments: $error'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
  }

  String _displayStatus(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'prepared':
        return 'Prepared';
      case 'in_transit':
        return 'In Transit';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  double _statusProgress(String status) {
    switch (status) {
      case 'confirmed':
        return 0.25;
      case 'prepared':
        return 0.40;
      case 'in_transit':
        return 0.55;
      case 'out_for_delivery':
        return 0.85;
      case 'delivered':
        return 1.0;
      case 'cancelled':
        return 0.0;
      default:
        return 0.10;
    }
  }

  String _statusStage(String status) {
    switch (status) {
      case 'confirmed':
        return 'Shipment confirmed';
      case 'prepared':
        return 'Shipment has been prepared';
      case 'in_transit':
        return 'Shipment is moving to destination';
      case 'out_for_delivery':
        return 'Shipment is out for final delivery';
      case 'delivered':
        return 'Shipment delivered successfully';
      case 'cancelled':
        return 'Shipment has been cancelled';
      default:
        return 'Waiting for shipment processing';
    }
  }

  String _formatDeliveryDate(dynamic value) {
    if (value is Timestamp) {
      final date = value.toDate();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    if (value == null || value.toString().trim().isEmpty) {
      return 'Not specified';
    }

    return value.toString();
  }

  @override
  void dispose() {
    _shipmentsSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _visibleShipments {
    final query = _searchController.text.trim().toLowerCase();

    return _shipments.where((shipment) {
      final status = shipment['status'] as String;
      final number = shipment['number'] as String;
      final origin = shipment['origin'] as String;
      final destination = shipment['destination'] as String;

      final matchesFilter =
          _selectedFilter == 'All' || status == _selectedFilter;

      final searchableText = '$number $origin $destination $status'
          .toLowerCase();

      final matchesSearch = query.isEmpty || searchableText.contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  int _countStatus(String status) {
    return _shipments.where((shipment) => shipment['status'] == status).length;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return const Color(0xFF16765C);
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

  void _openShipmentDetails(Map<String, dynamic> shipment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShipmentDetailsScreen(shipment: shipment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shipments = _visibleShipments;

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 34),
          children: [
            _buildPremiumHeader(),

            const SizedBox(height: 22),

            _buildSearchField(),

            const SizedBox(height: 18),

            _buildFilters(),

            const SizedBox(height: 26),

            Row(
              children: [
                const Text(
                  'Shipment List',
                  style: TextStyle(
                    color: _darkNavy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${shipments.length} shipments',
                  style: const TextStyle(
                    color: Color(0xFF8993A1),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            if (_isLoadingShipments)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: CircularProgressIndicator(color: _primaryBlue),
                ),
              )
            else if (shipments.isEmpty)
              _buildEmptyState()
            else
              ...shipments.map(
                (shipment) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ShipmentCard(
                    shipment: shipment,
                    statusColor: _statusColor(shipment['status'] as String),
                    statusBackground: _statusBackground(
                      shipment['status'] as String,
                    ),
                    onTap: () {
                      _openShipmentDetails(shipment);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2747), Color(0xFF07569E), Color(0xFF0874C9)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3507569E),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
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

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Shipments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Track every shipment in one place',
                      style: TextStyle(
                        color: Color(0xFFD8E8F8),
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: _primaryBlue,
                  size: 25,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _HeaderStat(
                  value: '${_shipments.length}',
                  label: 'Total',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderStat(
                  value: '${_countStatus('In Transit')}',
                  label: 'In Transit',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderStat(
                  value: '${_countStatus('Delivered')}',
                  label: 'Delivered',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: 'Search by tracking number',
        hintStyle: const TextStyle(color: Color(0xFFA0A8B4)),
        prefixIcon: const Icon(Icons.search_rounded, color: _primaryBlue),
        suffixIcon: _searchController.text.isEmpty
            ? const Icon(Icons.tune_rounded, color: Color(0xFF7F8997))
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.close_rounded, color: Color(0xFF7F8997)),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
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
          borderSide: const BorderSide(color: _primaryBlue, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 10);
        },
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = filter == _selectedFilter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                color: selected ? _primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selected ? _primaryBlue : _borderColor,
                ),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x2607569E),
                          blurRadius: 14,
                          offset: Offset(0, 7),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF76808E),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, color: Color(0xFF9BA6B4), size: 48),
          SizedBox(height: 16),
          Text(
            'No shipments found',
            style: TextStyle(
              color: _darkNavy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Try another tracking number or filter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF929BA8), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeaderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0x20FFFFFF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0x25FFFFFF)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFDCEAF8),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final Map<String, dynamic> shipment;
  final Color statusColor;
  final Color statusBackground;
  final VoidCallback onTap;

  const _ShipmentCard({
    required this.shipment,
    required this.statusColor,
    required this.statusBackground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final number = shipment['number'] as String;
    final origin = shipment['origin'] as String;
    final destination = shipment['destination'] as String;
    final status = shipment['status'] as String;
    final date = shipment['date'] as String;
    final type = shipment['type'] as String;
    final stage = shipment['stage'] as String;
    final progress = shipment['progress'] as double;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(20),
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
                        colors: [Color(0xFFEAF4FD), Color(0xFFDDEEFF)],
                      ),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: _primaryBlue,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          number,
                          style: const TextStyle(
                            color: _darkNavy,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          stage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF929BA8),
                            fontSize: 12.5,
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
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.radio_button_checked_rounded,
                      color: _primaryBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        origin,
                        style: const TextStyle(
                          color: _darkNavy,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF9EA7B3),
                        size: 20,
                      ),
                    ),

                    Expanded(
                      child: Text(
                        destination,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: _darkNavy,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFD72638),
                      size: 18,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  const Text(
                    'Shipment progress',
                    style: TextStyle(
                      color: Color(0xFF788391),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: _primaryBlue,
                      fontSize: 12,
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
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE8EDF3),
                  color: status == 'Delivered'
                      ? const Color(0xFF16765C)
                      : _primaryBlue,
                ),
              ),

              const SizedBox(height: 19),

              const Divider(color: Color(0xFFE8EDF2), height: 1),

              const SizedBox(height: 17),

              Row(
                children: [
                  Expanded(
                    child: _ShipmentInfo(
                      icon: Icons.calendar_today_outlined,
                      title: 'Expected delivery',
                      value: date,
                    ),
                  ),
                  Expanded(
                    child: _ShipmentInfo(
                      icon: Icons.route_outlined,
                      title: 'Shipment type',
                      value: type,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFFB0B8C2),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShipmentInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ShipmentInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primaryBlue, size: 17),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
