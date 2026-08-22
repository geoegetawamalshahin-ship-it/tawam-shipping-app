import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'shipment_details_screen.dart';

const Color _primaryBlue = Color(0xFF0B4F9C);
const Color _brightBlue = Color(0xFF1268BC);
const Color _deepBlue = Color(0xFF062B55);
const Color _pageBg = Color(0xFFF4F7FB);
const Color _softBlue = Color(0xFFEAF3FF);
const Color _border = Color(0xFFE2EAF2);
const Color _textDark = Color(0xFF101B2D);
const Color _textGrey = Color(0xFF7E8A9A);
const Color _success = Color(0xFF16765C);
const Color _warning = Color(0xFFB26A00);
const Color _danger = Color(0xFFD72638);

class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  String? _loadError;
  bool _isLoading = true;
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _shipments = [];

  final List<String> _filters = const [
    'All',
    'Pending',
    'Confirmed',
    'Prepared',
    'In Transit',
    'Customs',
    'Out for Delivery',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _listenToShipments();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _listenToShipments() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _shipments = [];
        _isLoading = false;
      });
      return;
    }
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    _subscription?.cancel();

    _subscription = FirebaseFirestore.instance
        .collection('shipments')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen(
          (snapshot) {
            final items = snapshot.docs.map((doc) {
              final data = doc.data();
              final rawStatus = _normalizeStatus(
                (data['status'] ?? 'pending').toString(),
              );

              return <String, dynamic>{
                ...data,
                'id': doc.id,
                'number': (data['trackingNumber'] ?? '').toString(),
                'origin': (data['pickupLocation'] ?? '').toString(),
                'destination': (data['deliveryLocation'] ?? '').toString(),
                'rawStatus': rawStatus,
                'displayStatus': _displayStatus(rawStatus),
                'progress': _statusProgress(rawStatus),
                'stage': _statusStage(rawStatus),
                'type': (data['cargo'] ?? data['cargoType'] ?? 'Shipment')
                    .toString(),
                'date': _formatDate(
                  data['expectedDelivery'] ?? data['estimatedDelivery'],
                ),
                'currentLocation': _currentLocation(data, rawStatus),
                'lastUpdate': _formatDateTime(
                  data['updatedAt'] ??
                      data['lastUpdatedAt'] ??
                      data['lastUpdate'] ??
                      data['createdAt'],
                ),
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
              _isLoading = false;
            });
          },
          onError: (error) {
            if (!mounted) return;

            setState(() {
              _isLoading = false;
              _loadError =
                  'We couldn\'t load your shipments. Please check your connection and try again.';
            });
          },
        );
  }

  List<Map<String, dynamic>> get _visibleShipments {
    final query = _searchController.text.trim().toLowerCase();

    return _shipments.where((shipment) {
      final status = (shipment['displayStatus'] ?? '').toString();
      final searchable = [
        shipment['number'],
        shipment['origin'],
        shipment['destination'],
        shipment['type'],
        shipment['currentLocation'],
        status,
      ].join(' ').toLowerCase();

      final matchesFilter =
          _selectedFilter == 'All' || status == _selectedFilter;
      final matchesSearch = query.isEmpty || searchable.contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  int _countStatus(String status) {
    return _shipments
        .where((shipment) => shipment['displayStatus'] == status)
        .length;
  }

  void _openShipmentDetails(Map<String, dynamic> shipment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShipmentDetailsScreen(shipment: shipment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleShipments;

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 34),
                children: [
                  _buildHero(),
                  const SizedBox(height: 16),
                  _buildSearchField(),
                  const SizedBox(height: 14),
                  _buildFilters(),
                  const SizedBox(height: 20),
                  _buildListHeader(visible.length),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: CircularProgressIndicator(color: _primaryBlue),
                      ),
                    )
                  else if (_loadError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 45),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF3FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.cloud_off_rounded,
                                color: _primaryBlue,
                                size: 30,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Unable to load shipments',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _deepBlue,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                _loadError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: _textGrey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: _listenToShipments,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (visible.isEmpty)
                    _buildEmptyState()
                  else
                    ...visible.map(
                      (shipment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ShipmentCard(
                          shipment: shipment,
                          statusInfo: _statusInfo(
                            shipment['rawStatus'] as String,
                          ),
                          onTap: () => _openShipmentDetails(shipment),
                        ),
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

  Widget _buildTopHeader() {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _SquareButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Shipments',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.35,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'TAWAM AL-SHAHIN TRANSPORT',
                  style: TextStyle(
                    color: _primaryBlue,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .85,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: _primaryBlue,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(19, 20, 19, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_deepBlue, Color(0xFF0A4789), _brightBlue],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .16),
            blurRadius: 26,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -28,
            child: Icon(
              Icons.local_shipping_rounded,
              size: 145,
              color: Colors.white.withValues(alpha: .05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  _LiveDot(),
                  SizedBox(width: 7),
                  Text(
                    'LIVE CUSTOMER SHIPMENT PORTAL',
                    style: TextStyle(
                      color: Color(0xFFD2E3F3),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .75,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Shipping Network',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.45,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Monitor every active and completed shipment from one secure place.',
                style: TextStyle(
                  color: Color(0xFFD7E6F5),
                  fontSize: 10.8,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  Expanded(
                    child: _HeroStat(
                      value: '${_shipments.length}',
                      label: 'TOTAL',
                      icon: Icons.inventory_2_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HeroStat(
                      value: '${_countStatus('In Transit')}',
                      label: 'IN TRANSIT',
                      icon: Icons.local_shipping_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _HeroStat(
                      value: '${_countStatus('Delivered')}',
                      label: 'DELIVERED',
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                ],
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
      onChanged: (_) => setState(() {}),
      style: const TextStyle(
        color: _textDark,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: 'Search tracking number, route or cargo',
        hintStyle: const TextStyle(color: Color(0xFFA0A8B4), fontSize: 11.5),
        prefixIcon: const Icon(Icons.search_rounded, color: _primaryBlue),
        suffixIcon: _searchController.text.isEmpty
            ? const Icon(Icons.manage_search_rounded, color: Color(0xFF7F8997))
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
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = filter == _selectedFilter;

          return InkWell(
            onTap: () => setState(() => _selectedFilter = filter),
            borderRadius: BorderRadius.circular(30),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: selected ? _primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: selected ? _primaryBlue : _border),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _primaryBlue.withValues(alpha: .14),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF748090),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListHeader(int count) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shipment Portfolio',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Select a shipment to view full details.',
                style: TextStyle(color: _textGrey, fontSize: 9.5),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _softBlue,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: _primaryBlue,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchController.text.trim().isNotEmpty;
    final hasFilter = _selectedFilter != 'All';
    final isFiltered = hasSearch || hasFilter;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              isFiltered
                  ? Icons.search_off_rounded
                  : Icons.local_shipping_outlined,
              color: _primaryBlue,
              size: 34,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            isFiltered ? 'No matching shipments' : 'No shipments yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            isFiltered
                ? 'We could not find any shipments matching your current search or filter.'
                : 'Your shipments will appear here as soon as they are created by our operations team.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textGrey,
              fontSize: 12,
              height: 1.55,
            ),
          ),

          if (isFiltered) ...[
            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();

                setState(() {
                  _selectedFilter = 'All';
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Clear Search & Filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryBlue,
                side: const BorderSide(color: _primaryBlue),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _normalizeStatus(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    if (normalized == 'approved') return 'confirmed';
    if (normalized == 'canceled') return 'cancelled';
    return normalized;
  }

  String _displayStatus(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmed';
      case 'prepared':
        return 'Prepared';
      case 'in_transit':
        return 'In Transit';
      case 'customs':
      case 'customs_clearance':
        return 'Customs';
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
        return .25;
      case 'prepared':
        return .36;
      case 'in_transit':
        return .58;
      case 'customs':
      case 'customs_clearance':
        return .72;
      case 'out_for_delivery':
        return .88;
      case 'delivered':
        return 1;
      case 'cancelled':
        return 0;
      default:
        return .10;
    }
  }

  String _statusStage(String status) {
    switch (status) {
      case 'confirmed':
        return 'Shipment confirmed by operations';
      case 'prepared':
        return 'Shipment prepared for movement';
      case 'in_transit':
        return 'Shipment moving toward destination';
      case 'customs':
      case 'customs_clearance':
        return 'Shipment under customs processing';
      case 'out_for_delivery':
        return 'Shipment on final delivery route';
      case 'delivered':
        return 'Shipment delivered successfully';
      case 'cancelled':
        return 'Shipment has been cancelled';
      default:
        return 'Shipment awaiting processing';
    }
  }

  String _currentLocation(Map<String, dynamic> data, String status) {
    for (final key in [
      'currentLocation',
      'currentArea',
      'lastLocation',
      'location',
    ]) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    final pickup = (data['pickupLocation'] ?? '').toString().trim();
    final delivery = (data['deliveryLocation'] ?? '').toString().trim();

    if (status == 'delivered' || status == 'out_for_delivery') {
      return delivery.isEmpty ? 'Location update pending' : delivery;
    }

    if (status == 'pending' || status == 'confirmed' || status == 'prepared') {
      return pickup.isEmpty ? 'Location update pending' : pickup;
    }

    return 'Location update pending';
  }

  String _formatDate(dynamic value) {
    final date = _toDateTime(value);
    if (date == null) {
      final text = value?.toString().trim() ?? '';
      return text.isEmpty ? 'Not specified' : text;
    }

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

  String _formatDateTime(dynamic value) {
    final date = _toDateTime(value);
    if (date == null) {
      final text = value?.toString().trim() ?? '';
      return text.isEmpty ? 'Awaiting update' : text;
    }

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

    final hour12 = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day} ${months[date.month - 1]} ${date.year} • '
        '$hour12:$minute $amPm';
  }

  DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate().toLocal();
    if (value is DateTime) return value.toLocal();
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim())?.toLocal();
    }
    return null;
  }

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'confirmed':
        return const _StatusInfo(
          label: 'CONFIRMED',
          color: _primaryBlue,
          background: Color(0xFFEAF3FF),
          icon: Icons.verified_rounded,
        );
      case 'prepared':
        return const _StatusInfo(
          label: 'PREPARED',
          color: _primaryBlue,
          background: Color(0xFFEAF3FF),
          icon: Icons.fact_check_rounded,
        );
      case 'in_transit':
        return const _StatusInfo(
          label: 'IN TRANSIT',
          color: _primaryBlue,
          background: Color(0xFFEAF3FF),
          icon: Icons.local_shipping_rounded,
        );
      case 'customs':
      case 'customs_clearance':
        return const _StatusInfo(
          label: 'CUSTOMS',
          color: _warning,
          background: Color(0xFFFFF4DF),
          icon: Icons.gavel_rounded,
        );
      case 'out_for_delivery':
        return const _StatusInfo(
          label: 'OUT FOR DELIVERY',
          color: _primaryBlue,
          background: Color(0xFFEAF3FF),
          icon: Icons.route_rounded,
        );
      case 'delivered':
        return const _StatusInfo(
          label: 'DELIVERED',
          color: _success,
          background: Color(0xFFEAF8F0),
          icon: Icons.check_circle_rounded,
        );
      case 'cancelled':
        return const _StatusInfo(
          label: 'CANCELLED',
          color: _danger,
          background: Color(0xFFFFECEF),
          icon: Icons.cancel_rounded,
        );
      default:
        return const _StatusInfo(
          label: 'PENDING',
          color: _warning,
          background: Color(0xFFFFF4DF),
          icon: Icons.schedule_rounded,
        );
    }
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFDCEAF8),
              fontSize: 7.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  const _ShipmentCard({
    required this.shipment,
    required this.statusInfo,
    required this.onTap,
  });

  final Map<String, dynamic> shipment;
  final _StatusInfo statusInfo;
  final VoidCallback onTap;
  String _formatLastUpdate(Object? value) {
    if (value == null) {
      return 'Awaiting update';
    }

    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else {
      date = DateTime.tryParse(value.toString());
    }

    if (date == null) {
      final text = value.toString().trim();
      return text.isEmpty ? 'Awaiting update' : text;
    }

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

    final hour12 = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day} ${months[date.month - 1]} ${date.year} • '
        '$hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final number = (shipment['number'] ?? '-').toString();
    final origin = (shipment['origin'] ?? 'Not specified').toString();
    final destination = (shipment['destination'] ?? 'Not specified').toString();
    final date = (shipment['date'] ?? 'Not specified').toString();
    final type = (shipment['type'] ?? 'Shipment').toString();
    final stage = (shipment['stage'] ?? '').toString();
    final currentLocation =
        (shipment['currentLocationName'] ??
                shipment['currentLocation'] ??
                'Location update pending')
            .toString();
    final lastUpdate = _formatLastUpdate(
      shipment['updatedAt'] ??
          shipment['lastLocationUpdate'] ??
          shipment['lastUpdate'],
    );
    final progress = (shipment['progress'] as num?)?.toDouble() ?? .10;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: _deepBlue.withValues(alpha: .035),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 47,
                    height: 47,
                    decoration: BoxDecoration(
                      color: _softBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      color: _primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          number,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textDark,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textGrey,
                            fontSize: 9.5,
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
                      color: statusInfo.background,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusInfo.icon,
                          color: statusInfo.color,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusInfo.label,
                          style: TextStyle(
                            color: statusInfo.color,
                            fontSize: 7.7,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _RouteSide(
                        label: 'PICKUP',
                        value: origin,
                        alignRight: false,
                      ),
                    ),
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: _softBlue,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: _primaryBlue,
                        size: 19,
                      ),
                    ),
                    Expanded(
                      child: _RouteSide(
                        label: 'DELIVERY',
                        value: destination,
                        alignRight: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  const Text(
                    'Shipment Progress',
                    style: TextStyle(
                      color: _textGrey,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      color: statusInfo.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE8EDF3),
                  color: statusInfo.color,
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: _SmallInfo(
                      icon: Icons.location_on_outlined,
                      label: 'CURRENT LOCATION',
                      value: currentLocation,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _SmallInfo(
                      icon: Icons.event_available_outlined,
                      label: 'EST. DELIVERY',
                      value: date,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    color: _textGrey,
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Last update: $lastUpdate',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _textGrey, fontSize: 8.7),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _primaryBlue,
                      fontSize: 8.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFFB0B8C2),
                    size: 12,
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

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Icon(icon, color: _deepBlue, size: 22),
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: Color(0xFF55D6A5),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _RouteSide extends StatelessWidget {
  const _RouteSide({
    required this.label,
    required this.value,
    required this.alignRight,
  });

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textGrey,
            fontSize: 7.5,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: const TextStyle(
            color: _textDark,
            fontSize: 10.5,
            height: 1.25,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SmallInfo extends StatelessWidget {
  const _SmallInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primaryBlue, size: 16),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              color: _textGrey,
              fontSize: 6.8,
              fontWeight: FontWeight.w800,
              letterSpacing: .45,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textDark,
              fontSize: 9.3,
              height: 1.2,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusInfo {
  const _StatusInfo({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData icon;
}
