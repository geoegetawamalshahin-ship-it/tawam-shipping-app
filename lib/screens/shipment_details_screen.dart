import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'support_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ==========================================================
// BRAND
// ==========================================================

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

// ==========================================================
// SCREEN
// ==========================================================

class ShipmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> shipment;

  const ShipmentDetailsScreen({super.key, required this.shipment});

  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _shipmentSubscription;

  late Map<String, dynamic> _shipment;
  String? _liveLocation;
  String? _liveLastUpdated;

  double? _liveLatitude;
  double? _liveLongitude;

  bool _isLoadingLiveLocation = false;
  String? _liveLocationError;

  Timer? _liveLocationTimer;
  @override
  @override
  void initState() {
    super.initState();

    _shipment = Map<String, dynamic>.from(widget.shipment);

    _startLiveListener();
    _loadLiveLocation();
    _liveLocationTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _loadLiveLocation(),
    );
  }

  @override
  void dispose() {
    _shipmentSubscription?.cancel();
    _liveLocationTimer?.cancel();
    super.dispose();
  }

  // ==========================================================
  // LIVE FIRESTORE
  // ==========================================================

  void _startLiveListener() {
    final documentId = (_shipment['id'] ?? '').toString().trim();

    if (documentId.isEmpty) {
      return;
    }

    _shipmentSubscription = FirebaseFirestore.instance
        .collection('shipments')
        .doc(documentId)
        .snapshots()
        .listen(
          (document) {
            if (!mounted || !document.exists || document.data() == null) {
              return;
            }

            setState(() {
              _shipment = {...document.data()!, 'id': document.id};
            });
          },
          onError: (_) {
            // Keep showing the last known shipment data.
          },
        );
  }

  Future<void> _loadLiveLocation() async {
    final trackingMode = (_shipment['trackingMode'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    // الشحنات اليدوية ما بدها GPS
    if (trackingMode != 'gps') {
      return;
    }

    if (_isLoadingLiveLocation) {
      return;
    }

    final shipmentId = (_shipment['id'] ?? '').toString().trim();
    final user = FirebaseAuth.instance.currentUser;

    if (shipmentId.isEmpty || user == null) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingLiveLocation = true;
        _liveLocationError = null;
      });
    }

    final client = HttpClient();

    try {
      final token = await user.getIdToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception('Authentication token unavailable');
      }

      final request = await client.postUrl(
        Uri.parse(
          'https://ofbnwaivxxdrxhtsniny.supabase.co/functions/v1/live-shipment',
        ),
      );

      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');

      request.write(jsonEncode({'shipmentId': shipmentId}));

      final response = await request.close();

      final responseBody = await response.transform(utf8.decoder).join();

      final decoded = jsonDecode(responseBody);

      if (response.statusCode == 200 &&
          decoded is Map<String, dynamic> &&
          decoded['success'] == true) {
        final data = decoded['data'];

        if (data is Map<String, dynamic>) {
          if (!mounted) {
            return;
          }

          setState(() {
            _liveLocation = data['address']?.toString().trim();

            _liveLastUpdated = data['lastUpdated']?.toString().trim();

            _liveLatitude = (data['latitude'] as num?)?.toDouble();

            _liveLongitude = (data['longitude'] as num?)?.toDouble();

            _liveLocationError = null;
          });
        }
      } else {
        String message = 'Live location temporarily unavailable.';

        if (decoded is Map<String, dynamic>) {
          final serverMessage = decoded['message']?.toString().trim();

          if (serverMessage != null && serverMessage.isNotEmpty) {
            message = serverMessage;
          }
        }

        if (mounted) {
          setState(() {
            _liveLocationError = message;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _liveLocationError = 'Live location temporarily unavailable.';
        });
      }
    } finally {
      client.close(force: true);

      if (mounted) {
        setState(() {
          _isLoadingLiveLocation = false;
        });
      }
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final trackingNumber = _stringValue(_shipment, [
      'trackingNumber',
      'number',
    ], fallback: '-');

    final pickup = _stringValue(_shipment, [
      'pickupLocation',
      'origin',
    ], fallback: 'Not specified');

    final delivery = _stringValue(_shipment, [
      'deliveryLocation',
      'destination',
    ], fallback: 'Not specified');

    final cargo = _stringValue(_shipment, [
      'cargo',
      'cargoType',
      'type',
    ], fallback: 'Not provided');

    final status = _normalizeStatus(
      _stringValue(_shipment, ['status'], fallback: 'pending'),
    );

    final statusInfo = _statusInfo(status);

    final currentLocation = _liveLocation?.trim().isNotEmpty == true
        ? _liveLocation!.trim()
        : _currentLocation(status: status, pickup: pickup, delivery: delivery);

    final lastUpdate = _liveLastUpdated?.trim().isNotEmpty == true
        ? _liveLastUpdated!.trim()
        : _formatDateTime(
            _firstValue(_shipment, [
              'lastLocationUpdate',
              'updatedAt',
              'lastUpdatedAt',
              'lastUpdate',
              'createdAt',
            ]),
          );

    final estimatedDelivery = _formatDate(
      _firstValue(_shipment, ['expectedDelivery', 'estimatedDelivery']),
    );

    final weight = _formatWeight();

    final quantity = _stringValue(_shipment, [
      'quantity',
    ], fallback: 'Not provided');

    final dimensions = _dimensionsText();

    final stage = _stringValue(_shipment, [
      'stage',
    ], fallback: statusInfo.description);

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(context),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 34),
                children: [
                  _buildHero(
                    trackingNumber: trackingNumber,
                    statusInfo: statusInfo,
                  ),

                  const SizedBox(height: 14),

                  _buildLiveLocationCard(
                    currentLocation: currentLocation,
                    lastUpdate: lastUpdate,
                    statusInfo: statusInfo,
                  ),

                  if (_liveLatitude != null && _liveLongitude != null) ...[
                    const SizedBox(height: 14),
                    _buildLiveMapCard(),
                  ],

                  const SizedBox(height: 14),

                  _buildRouteCard(
                    pickup: pickup,
                    delivery: delivery,
                    stage: stage,
                    statusInfo: statusInfo,
                  ),

                  const SizedBox(height: 18),

                  _sectionTitle(
                    title: 'Shipment Information',
                    subtitle: 'Complete logistics details for this shipment.',
                    icon: Icons.inventory_2_outlined,
                  ),

                  const SizedBox(height: 11),

                  _buildInformationGrid(
                    estimatedDelivery: estimatedDelivery,
                    cargo: cargo,
                    weight: weight,
                    quantity: quantity,
                    dimensions: dimensions,
                  ),

                  const SizedBox(height: 18),

                  _sectionTitle(
                    title: 'Shipment Journey',
                    subtitle: 'Live milestones and status history.',
                    icon: Icons.timeline_rounded,
                  ),

                  const SizedBox(height: 11),

                  _buildTimeline(status: status, lastUpdate: lastUpdate),

                  const SizedBox(height: 18),

                  _buildSupportCard(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TOP HEADER
  // ==========================================================

  Widget _buildTopHeader(BuildContext context) {
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
                  'Shipment Details',
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
              Icons.local_shipping_rounded,
              color: _primaryBlue,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HERO
  // ==========================================================

  Widget _buildHero({
    required String trackingNumber,
    required _StatusInfo statusInfo,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(19, 20, 19, 19),
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
            top: -25,
            child: Icon(
              Icons.public_rounded,
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
                    'LIVE SHIPMENT RECORD',
                    style: TextStyle(
                      color: Color(0xFFD2E3F3),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 17),

              const Text(
                'Tracking Number',
                style: TextStyle(
                  color: Color(0xFFBED6EC),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                trackingNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .25,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
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
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          statusInfo.label,
                          style: TextStyle(
                            color: statusInfo.color,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Text(
                    '${(statusInfo.progress * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 9),

              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: LinearProgressIndicator(
                  value: statusInfo.progress,
                  minHeight: 7,
                  backgroundColor: Colors.white.withValues(alpha: .14),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CURRENT LOCATION
  // ==========================================================

  Widget _buildLiveLocationCard({
    required String currentLocation,
    required String lastUpdate,
    required _StatusInfo statusInfo,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: _primaryBlue,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT LOCATION',
                  style: TextStyle(
                    color: _textGrey,
                    fontSize: 8.7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .65,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  currentLocation.trim().isEmpty ||
                          currentLocation == 'Location update pending'
                      ? 'Location temporarily unavailable'
                      : currentLocation,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: _textGrey,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        lastUpdate.trim().isEmpty ||
                                lastUpdate == 'Awaiting update'
                            ? 'Last update unavailable'
                            : 'Last update: $lastUpdate',
                        style: const TextStyle(
                          color: _textGrey,
                          fontSize: 9.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isLoadingLiveLocation) ...[
                  const SizedBox(height: 9),
                  const Row(
                    children: [
                      SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _primaryBlue,
                        ),
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Updating live location...',
                        style: TextStyle(
                          color: _textGrey,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],

                if (_liveLocationError != null) ...[
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: _warning,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _liveLocationError!,
                          style: const TextStyle(
                            color: _warning,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _loadLiveLocation,
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.refresh_rounded,
                            color: _primaryBlue,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          Icon(statusInfo.icon, color: statusInfo.color, size: 22),
        ],
      ),
    );
  }

  bool _isLiveLocationFresh() {
    final value = _liveLastUpdated?.trim();

    if (value == null || value.isEmpty) {
      return false;
    }

    try {
      // Locator format:
      // 22-08-2026 22:25:19

      final parts = value.split(' ');

      if (parts.length != 2) {
        return false;
      }

      final dateParts = parts[0].split('-');
      final timeParts = parts[1].split(':');

      if (dateParts.length != 3 || timeParts.length != 3) {
        return false;
      }

      final lastUpdate = DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        int.parse(timeParts[2]),
      );

      final difference = DateTime.now().difference(lastUpdate);

      return !difference.isNegative && difference.inMinutes <= 10;
    } catch (_) {
      return false;
    }
  }

  Widget _buildLiveMapCard() {
    final point = LatLng(_liveLatitude!, _liveLongitude!);
    final isLive = _isLiveLocationFresh();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4, 3, 4, 11),
            child: Row(
              children: [
                Icon(Icons.map_outlined, color: _primaryBlue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Live Shipment Map',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Spacer(),
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: isLive ? _success : _warning,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isLive ? 'LIVE' : 'LAST KNOWN LOCATION',
                  style: TextStyle(
                    color: isLive ? _success : _warning,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: _openFullScreenMap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: SizedBox(
                height: 245,
                child: Stack(
                  children: [
                    FlutterMap(
                      key: ValueKey('${_liveLatitude}_$_liveLongitude'),
                      options: MapOptions(
                        initialCenter: point,
                        initialZoom: 13.5,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.tawamalshahin.transport',
                        ),

                        MarkerLayer(
                          markers: [
                            Marker(
                              point: point,
                              width: 54,
                              height: 54,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _primaryBlue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _deepBlue.withValues(alpha: .25),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.local_shipping_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Positioned(
                      left: 8,
                      bottom: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .90),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Text(
                          '© OpenStreetMap contributors',
                          style: TextStyle(
                            color: _textGrey,
                            fontSize: 7,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }

  void _openFullScreenMap() {
    if (_liveLatitude == null || _liveLongitude == null) {
      return;
    }

    final point = LatLng(_liveLatitude!, _liveLongitude!);
    final mapController = MapController();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: _pageBg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: _deepBlue,
            elevation: 0,
            title: const Text(
              'Live Shipment Map',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
            ),
          ),
          body: FlutterMap(
            mapController: mapController,
            options: MapOptions(initialCenter: point, initialZoom: 14),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tawamalshahin.transport',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: point,
                    width: 58,
                    height: 58,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: _deepBlue.withValues(alpha: .25),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              mapController.move(point, 14);
            },
            backgroundColor: _primaryBlue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.my_location_rounded),
          ),
        ),
      ),
    );
  }
  // ==========================================================
  // ROUTE
  // ==========================================================

  Widget _buildRouteCard({
    required String pickup,
    required String delivery,
    required String stage,
    required _StatusInfo statusInfo,
  }) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Route Overview',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Icon(statusInfo.icon, color: statusInfo.color, size: 19),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFD),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _RoutePoint(
                    label: 'PICKUP',
                    value: pickup,
                    icon: Icons.radio_button_checked_rounded,
                    alignRight: false,
                  ),
                ),

                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _softBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: _primaryBlue,
                    size: 20,
                  ),
                ),

                Expanded(
                  child: _RoutePoint(
                    label: 'DELIVERY',
                    value: delivery,
                    icon: Icons.location_on_outlined,
                    alignRight: true,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.route_rounded, color: _primaryBlue, size: 19),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    stage,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
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

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: _softBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primaryBlue, size: 20),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _textGrey,
                  fontSize: 9.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // INFORMATION
  // ==========================================================

  Widget _buildInformationGrid({
    required String estimatedDelivery,
    required String cargo,
    required String weight,
    required String quantity,
    required String dimensions,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.inventory_2_outlined,
                label: 'CARGO',
                value: cargo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoCard(
                icon: Icons.scale_outlined,
                label: 'WEIGHT',
                value: weight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.numbers_rounded,
                label: 'QUANTITY',
                value: quantity,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoCard(
                icon: Icons.event_available_outlined,
                label: 'EST. DELIVERY',
                value: estimatedDelivery,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _WideInfoCard(
          icon: Icons.straighten_rounded,
          label: 'DIMENSIONS',
          value: dimensions,
        ),
      ],
    );
  }

  // ==========================================================
  // TIMELINE
  // ==========================================================

  Widget _buildTimeline({required String status, required String lastUpdate}) {
    final history = _historyItems();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: history.isNotEmpty
            ? List.generate(history.length, (index) {
                final item = history[index];
                final isLast = index == history.length - 1;

                return _TimelineRow(
                  title: item.title,
                  description: item.description,
                  time: item.time,
                  completed: true,
                  active: isLast,
                  showLine: !isLast,
                  icon: item.icon,
                );
              })
            : _fallbackTimeline(status: status, lastUpdate: lastUpdate),
      ),
    );
  }

  List<Widget> _fallbackTimeline({
    required String status,
    required String lastUpdate,
  }) {
    const stages = [
      _TimelineStage(
        keyName: 'pending',
        title: 'Shipment Created',
        description: 'Shipment information has been registered.',
        icon: Icons.inventory_2_outlined,
      ),
      _TimelineStage(
        keyName: 'confirmed',
        title: 'Booking Confirmed',
        description: 'Shipment has been confirmed by our operations team.',
        icon: Icons.verified_outlined,
      ),
      _TimelineStage(
        keyName: 'prepared',
        title: 'Prepared',
        description: 'Shipment is prepared and ready for movement.',
        icon: Icons.fact_check_outlined,
      ),
      _TimelineStage(
        keyName: 'in_transit',
        title: 'In Transit',
        description: 'Shipment is moving toward the destination.',
        icon: Icons.local_shipping_outlined,
      ),
      _TimelineStage(
        keyName: 'customs_clearance',
        title: 'Customs Clearance',
        description: 'Shipment is undergoing customs or border processing.',
        icon: Icons.gavel_outlined,
      ),
      _TimelineStage(
        keyName: 'out_for_delivery',
        title: 'Out for Delivery',
        description: 'Shipment is on the final delivery route.',
        icon: Icons.route_outlined,
      ),
      _TimelineStage(
        keyName: 'delivered',
        title: 'Delivered',
        description: 'Shipment has been delivered successfully.',
        icon: Icons.check_circle_outline_rounded,
      ),
    ];

    if (status == 'cancelled') {
      return const [
        _TimelineRow(
          title: 'Shipment Cancelled',
          description: 'This shipment has been cancelled.',
          time: 'Latest update',
          completed: false,
          active: true,
          showLine: false,
          icon: Icons.cancel_outlined,
          activeColor: _danger,
        ),
      ];
    }

    final timelineStatus = status == 'customs' ? 'customs_clearance' : status;

    int currentIndex = stages.indexWhere(
      (stage) => stage.keyName == timelineStatus,
    );

    if (currentIndex < 0) {
      currentIndex = 0;
    }

    return List.generate(stages.length, (index) {
      final stage = stages[index];

      final completed = index <= currentIndex;

      final active = index == currentIndex;

      final isLast = index == stages.length - 1;

      return _TimelineRow(
        title: stage.title,
        description: stage.description,
        time: active
            ? lastUpdate
            : completed
            ? 'Completed'
            : 'Waiting',
        completed: completed,
        active: active,
        showLine: !isLast,
        icon: stage.icon,
      );
    });
  }

  // ==========================================================
  // SUPPORT
  // ==========================================================

  Widget _buildSupportCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF6FD), Colors.white],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE9F4)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _primaryBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need shipment support?',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Our logistics team is ready to assist you.',
                  style: TextStyle(
                    color: _textGrey,
                    fontSize: 9.7,
                    height: 1.35,
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

  // ==========================================================
  // HELPERS
  // ==========================================================

  Object? _firstValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (!data.containsKey(key)) {
        continue;
      }

      final value = data[key];

      if (value == null) {
        continue;
      }

      if (value is String && value.trim().isEmpty) {
        continue;
      }

      return value;
    }

    return null;
  }

  String _stringValue(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '-',
  }) {
    final value = _firstValue(data, keys);

    if (value == null) {
      return fallback;
    }

    return value.toString().trim();
  }

  String _normalizeStatus(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    if (normalized == 'approved') {
      return 'confirmed';
    }

    if (normalized == 'canceled') {
      return 'cancelled';
    }

    return normalized;
  }

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'confirmed':
        return const _StatusInfo(
          label: 'CONFIRMED',
          color: _primaryBlue,
          background: Color(0xFFEAF3FF),
          icon: Icons.verified_rounded,
          progress: .25,
          description: 'Shipment confirmed by operations.',
        );

      case 'prepared':
        return const _StatusInfo(
          label: 'PREPARED',
          color: _primaryBlue,
          background: Color(0xFFEAF3FF),
          icon: Icons.fact_check_rounded,
          progress: .36,
          description: 'Shipment prepared for movement.',
        );

      case 'in_transit':
        return const _StatusInfo(
          label: 'IN TRANSIT',
          color: _primaryBlue,
          background: Color(0xFFEAF3FF),
          icon: Icons.local_shipping_rounded,
          progress: .58,
          description: 'Shipment moving toward destination.',
        );

      case 'customs':
      case 'customs_clearance':
        return const _StatusInfo(
          label: 'CUSTOMS',
          color: _warning,
          background: Color(0xFFFFF4DF),
          icon: Icons.gavel_rounded,
          progress: .72,
          description: 'Shipment is under customs processing.',
        );

      case 'out_for_delivery':
        return const _StatusInfo(
          label: 'OUT FOR DELIVERY',
          color: _primaryBlue,
          background: Color(0xFFEAF3FF),
          icon: Icons.route_rounded,
          progress: .88,
          description: 'Shipment is on the final delivery route.',
        );

      case 'delivered':
        return const _StatusInfo(
          label: 'DELIVERED',
          color: _success,
          background: Color(0xFFEAF8F0),
          icon: Icons.check_circle_rounded,
          progress: 1,
          description: 'Shipment delivered successfully.',
        );

      case 'cancelled':
        return const _StatusInfo(
          label: 'CANCELLED',
          color: _danger,
          background: Color(0xFFFFECEF),
          icon: Icons.cancel_rounded,
          progress: 0,
          description: 'Shipment has been cancelled.',
        );

      case 'pending':
      default:
        return const _StatusInfo(
          label: 'PENDING',
          color: _warning,
          background: Color(0xFFFFF4DF),
          icon: Icons.schedule_rounded,
          progress: .10,
          description: 'Shipment information is awaiting processing.',
        );
    }
  }

  String _currentLocation({
    required String status,
    required String pickup,
    required String delivery,
  }) {
    final liveLocation = _stringValue(_shipment, [
      'currentLocationName',
      'currentLocation',
      'currentArea',
      'lastLocation',
      'location',
    ], fallback: '');

    if (liveLocation.isNotEmpty) {
      return liveLocation;
    }

    if (status == 'delivered' || status == 'out_for_delivery') {
      return delivery;
    }

    if (status == 'pending' || status == 'confirmed' || status == 'prepared') {
      return pickup;
    }

    return 'Location update pending';
  }

  String _formatWeight() {
    final rawWeight =
        _shipment['weight'] ??
        _shipment['weightKg'] ??
        _shipment['totalWeight'];

    if (rawWeight == null) {
      return 'Not provided';
    }

    final weight = rawWeight.toString().trim();

    if (weight.isEmpty || weight == '-') {
      return 'Not provided';
    }

    // إذا الوزن مكتوب معه الوحدة أصلاً
    final lowerWeight = weight.toLowerCase();

    if (lowerWeight.contains('kg') ||
        lowerWeight.contains('ton') ||
        lowerWeight.contains('tonne')) {
      return weight;
    }

    // الوحدة المحفوظة من الأدمن
    final rawUnit = _shipment['weightUnit'];

    if (rawUnit != null && rawUnit.toString().trim().isNotEmpty) {
      final unit = rawUnit.toString().trim().toUpperCase();
      return '$weight $unit';
    }

    // للشحنات القديمة فقط
    return '$weight KG';
  }

  String _dimensionsText() {
    final length = _firstValue(_shipment, ['lengthCm', 'length']);

    final width = _firstValue(_shipment, ['widthCm', 'width']);

    final height = _firstValue(_shipment, ['heightCm', 'height']);

    if (length == null && width == null && height == null) {
      return 'Not provided';
    }

    final l = length?.toString() ?? '-';
    final w = width?.toString() ?? '-';
    final h = height?.toString() ?? '-';

    return '$l × $w × $h CM';
  }

  String _formatDate(Object? value) {
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

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String _formatDateTime(Object? value) {
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

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year} • '
        '$hour12:$minute $amPm';
  }

  DateTime? _toDateTime(Object? value) {
    if (value is Timestamp) {
      return value.toDate().toLocal();
    }

    if (value is DateTime) {
      return value.toLocal();
    }

    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim())?.toLocal();
    }

    return null;
  }

  List<_HistoryItem> _historyItems() {
    final raw = _firstValue(_shipment, [
      'statusHistory',
      'trackingHistory',
      'timeline',
      'history',
    ]);

    if (raw is! List || raw.isEmpty) {
      return [];
    }

    final items = <_HistoryItem>[];

    for (final item in raw) {
      if (item is! Map) {
        continue;
      }

      final map = Map<String, dynamic>.from(item);

      final title = _stringValue(map, [
        'title',
        'status',
        'event',
      ], fallback: 'Shipment Update');

      final description = _stringValue(map, [
        'description',
        'note',
        'details',
        'location',
      ], fallback: 'Shipment status updated.');

      final time = _formatDateTime(
        _firstValue(map, [
          'changedAt',
          'timestamp',
          'updatedAt',
          'date',
          'time',
        ]),
      );

      items.add(
        _HistoryItem(
          title: _prettyStatus(title),
          description: description,
          time: time,
          icon: _timelineIcon(title),
        ),
      );
    }

    return items;
  }

  String _prettyStatus(String value) {
    final normalized = value.trim().replaceAll('_', ' ').replaceAll('-', ' ');

    if (normalized.isEmpty) {
      return 'Shipment Update';
    }

    return normalized
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}'
              '${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  IconData _timelineIcon(String value) {
    final status = _normalizeStatus(value);

    if (status.contains('deliver')) {
      return Icons.check_circle_outline_rounded;
    }

    if (status.contains('custom')) {
      return Icons.gavel_outlined;
    }

    if (status.contains('transit') ||
        status.contains('depart') ||
        status.contains('moving')) {
      return Icons.local_shipping_outlined;
    }

    if (status.contains('confirm') || status.contains('approve')) {
      return Icons.verified_outlined;
    }

    if (status.contains('prepare') || status.contains('warehouse')) {
      return Icons.inventory_2_outlined;
    }

    return Icons.circle_outlined;
  }
}

// ==========================================================
// SMALL COMPONENTS
// ==========================================================

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

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.label,
    required this.value,
    required this.icon,
    required this.alignRight,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primaryBlue, size: 17),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(
            color: _textGrey,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: .55,
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
            fontSize: 10.8,
            height: 1.25,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
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
      constraints: const BoxConstraints(minHeight: 107),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: _primaryBlue, size: 19),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: _textGrey,
              fontSize: 7.8,
              fontWeight: FontWeight.w800,
              letterSpacing: .55,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textDark,
              fontSize: 10.8,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WideInfoCard extends StatelessWidget {
  const _WideInfoCard({
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
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: _primaryBlue, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _textGrey,
                    fontSize: 7.8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .55,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
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

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.description,
    required this.time,
    required this.completed,
    required this.active,
    required this.showLine,
    required this.icon,
    this.activeColor = _primaryBlue,
  });

  final String title;
  final String description;
  final String time;
  final bool completed;
  final bool active;
  final bool showLine;
  final IconData icon;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final circleColor = active
        ? activeColor
        : completed
        ? _primaryBlue
        : const Color(0xFFC6CED8);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 38,
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: active
                        ? activeColor.withValues(alpha: .10)
                        : completed
                        ? _softBlue
                        : const Color(0xFFF2F4F7),
                    shape: BoxShape.circle,
                    border: active
                        ? Border.all(
                            color: activeColor.withValues(alpha: .28),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Icon(icon, color: circleColor, size: 17),
                ),

                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: completed
                          ? const Color(0xFFC7DDF1)
                          : const Color(0xFFE3E8EE),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18, top: 2),
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
                                ? _textDark
                                : const Color(0xFF929BA8),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      if (active)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: activeColor.withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'CURRENT',
                            style: TextStyle(
                              color: activeColor,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .4,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: const TextStyle(
                      color: _textGrey,
                      fontSize: 9.7,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    time,
                    style: TextStyle(
                      color: active ? activeColor : const Color(0xFFA6AFBA),
                      fontSize: 8.7,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// MODELS
// ==========================================================

class _StatusInfo {
  const _StatusInfo({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
    required this.progress,
    required this.description,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData icon;
  final double progress;
  final String description;
}

class _TimelineStage {
  const _TimelineStage({
    required this.keyName,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String keyName;
  final String title;
  final String description;
  final IconData icon;
}

class _HistoryItem {
  const _HistoryItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
  });

  final String title;
  final String description;
  final String time;
  final IconData icon;
}
