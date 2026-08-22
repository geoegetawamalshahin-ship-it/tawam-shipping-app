import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'shipment_details_screen.dart';

// ==========================================================
// BRAND COLORS
// ==========================================================

const Color _primaryBlue = Color(0xFF0B4F9C);
const Color _brightBlue = Color(0xFF1268BC);
const Color _deepBlue = Color(0xFF062B55);

const Color _pageBg = Color(0xFFF4F7FB);
const Color _cardBg = Colors.white;
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

class TrackShipmentScreen extends StatefulWidget {
  final String? initialTrackingNumber;

  const TrackShipmentScreen({super.key, this.initialTrackingNumber});

  @override
  State<TrackShipmentScreen> createState() => _TrackShipmentScreenState();
}

class _TrackShipmentScreenState extends State<TrackShipmentScreen> {
  final TextEditingController _trackingController = TextEditingController();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _shipmentSubscription;

  bool _isSearching = false;
  bool _showResult = false;

  Map<String, dynamic>? _shipment;

  // ==========================================================
  // INIT / DISPOSE
  // ==========================================================

  @override
  void initState() {
    super.initState();

    final initialNumber = widget.initialTrackingNumber?.trim().toUpperCase();

    if (initialNumber != null && initialNumber.isNotEmpty) {
      _trackingController.text = initialNumber;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _trackShipment();
        }
      });
    }
  }

  @override
  void dispose() {
    _shipmentSubscription?.cancel();
    _trackingController.dispose();
    super.dispose();
  }

  // ==========================================================
  // TRACK SHIPMENT
  // ==========================================================

  Future<void> _trackShipment() async {
    final trackingNumber = _trackingController.text.trim().toUpperCase();

    FocusScope.of(context).unfocus();

    if (trackingNumber.isEmpty) {
      _showMessage('Please enter your tracking number.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please sign in to track your shipment.');
      return;
    }

    await _shipmentSubscription?.cancel();
    _shipmentSubscription = null;

    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _showResult = false;
      _shipment = null;
    });

    try {
      // IMPORTANT:
      // A shipment must match BOTH:
      // 1) the signed-in customer's userId
      // 2) the exact tracking number entered
      //
      // So a customer cannot use this page to view another
      // customer's shipment.
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

        _showMessage('Shipment not found. Please check the tracking number.');

        return;
      }

      final doc = snapshot.docs.first;

      _applyShipment(documentId: doc.id, data: doc.data());

      // REAL-TIME:
      // Once the shipment is found, listen to this exact
      // Firestore document. Any admin update to the document
      // will appear automatically on the customer's screen.
      _shipmentSubscription = doc.reference.snapshots().listen(
        (document) {
          if (!mounted) return;

          if (!document.exists || document.data() == null) {
            setState(() {
              _isSearching = false;
              _showResult = false;
              _shipment = null;
            });

            _showMessage('This shipment is no longer available.');
            return;
          }

          _applyShipment(documentId: document.id, data: document.data()!);
        },
        onError: (Object error) {
          if (!mounted) return;

          _showMessage('Live tracking connection was interrupted.');
        },
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _showResult = false;
        _shipment = null;
      });

      _showMessage('Could not track shipment. Please try again.');
    }
  }

  void _applyShipment({
    required String documentId,
    required Map<String, dynamic> data,
  }) {
    if (!mounted) return;

    setState(() {
      _isSearching = false;
      _showResult = true;

      _shipment = {...data, 'id': documentId};
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  // ==========================================================
  // NAVIGATION
  // ==========================================================

  void _openShipmentDetails() {
    final shipment = _shipment;

    if (shipment == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShipmentDetailsScreen(shipment: shipment),
      ),
    );
  }

  void _scanCode() {
    _showMessage('QR code scanning will be available soon.');
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
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

                  const SizedBox(height: 18),

                  _buildTrackingSearch(),

                  const SizedBox(height: 20),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _showResult
                        ? _buildShipmentExperience()
                        : _buildBeforeTracking(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

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
                  'Shipment Tracking',
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
              Icons.location_searching_rounded,
              color: _primaryBlue,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PREMIUM HERO
  // ==========================================================

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_deepBlue, Color(0xFF0A4789), _brightBlue],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .17),
            blurRadius: 26,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -31,
            top: -25,
            child: Icon(
              Icons.public_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: .055),
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _LiveDot(),
                  SizedBox(width: 8),
                  Text(
                    'LIVE SHIPMENT VISIBILITY',
                    style: TextStyle(
                      color: Color(0xFFD6E6F6),
                      fontSize: 9.2,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .95,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              Text(
                'Track Every Move',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Enter your tracking number to view the latest status, location and shipment journey.',
                style: TextStyle(
                  color: Color(0xFFD7E6F5),
                  fontSize: 11.8,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 18),

              Row(
                children: [
                  _HeroFeature(
                    icon: Icons.lock_outline_rounded,
                    label: 'Private',
                  ),
                  SizedBox(width: 18),
                  _HeroFeature(icon: Icons.sync_rounded, label: 'Live Updates'),
                  SizedBox(width: 18),
                  _HeroFeature(icon: Icons.verified_outlined, label: 'Secure'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SEARCH CARD
  // ==========================================================

  Widget _buildTrackingSearch() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tracking Number',
            style: TextStyle(
              color: _textDark,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Only shipments assigned to your account can be displayed.',
            style: TextStyle(
              color: _textGrey,
              fontSize: 10.3,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 13),

          TextField(
            controller: _trackingController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _trackShipment(),
            style: const TextStyle(
              color: _textDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: .35,
            ),
            decoration: InputDecoration(
              hintText: 'Enter tracking number',
              hintStyle: const TextStyle(
                color: Color(0xFFA0A9B5),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: _primaryBlue),
              suffixIcon: IconButton(
                onPressed: _scanCode,
                icon: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: _deepBlue,
                ),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFD),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 17,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 11),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSearching ? null : _trackShipment,
              icon: _isSearching
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : const Icon(Icons.location_searching_rounded, size: 20),
              label: Text(
                _isSearching ? 'TRACKING...' : 'TRACK SHIPMENT',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: .45,
                  fontSize: 11,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF7DA7CF),
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BEFORE TRACKING
  // ==========================================================

  Widget _buildBeforeTracking() {
    return Container(
      key: const ValueKey('before-tracking'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 19, 17, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Shipment Visibility',
            style: TextStyle(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Your tracking view is protected and connected directly to your shipment record.',
            style: TextStyle(color: _textGrey, fontSize: 10.5, height: 1.4),
          ),

          SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _FeatureBox(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  subtitle: 'Latest update',
                ),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _FeatureBox(
                  icon: Icons.timeline_rounded,
                  title: 'Timeline',
                  subtitle: 'Shipment journey',
                ),
              ),
              SizedBox(width: 9),
              Expanded(
                child: _FeatureBox(
                  icon: Icons.schedule_rounded,
                  title: 'Delivery',
                  subtitle: 'ETA details',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // COMPLETE RESULT
  // ==========================================================

  Widget _buildShipmentExperience() {
    final shipment = _shipment;

    if (shipment == null) {
      return const SizedBox.shrink(key: ValueKey('no-shipment'));
    }

    final trackingNumber = _stringValue(shipment, [
      'trackingNumber',
      'number',
    ], fallback: '-');

    final pickup = _stringValue(shipment, [
      'pickupLocation',
      'origin',
    ], fallback: 'Not specified');

    final delivery = _stringValue(shipment, [
      'deliveryLocation',
      'destination',
    ], fallback: 'Not specified');

    final cargo = _stringValue(shipment, [
      'cargo',
      'cargoType',
      'type',
    ], fallback: 'Shipment');

    final status = _normalizeStatus(
      _stringValue(shipment, ['status'], fallback: 'pending'),
    );

    final statusInfo = _statusInfo(status);

    final expectedDelivery = _formatDate(
      _firstValue(shipment, ['expectedDelivery', 'estimatedDelivery']),
    );

    final currentLocation = _currentLocation(
      shipment,
      status,
      pickup,
      delivery,
    );

    final lastUpdate = _formatDateTime(
      _firstValue(shipment, [
        'updatedAt',
        'lastUpdatedAt',
        'lastUpdate',
        'createdAt',
      ]),
    );

    return Column(
      key: ValueKey('shipment-$trackingNumber'),
      children: [
        _buildStatusCard(
          trackingNumber: trackingNumber,
          statusInfo: statusInfo,
        ),

        const SizedBox(height: 12),

        _buildCurrentLocationCard(
          currentLocation: currentLocation,
          lastUpdate: lastUpdate,
          statusInfo: statusInfo,
        ),

        const SizedBox(height: 12),

        _buildRouteCard(pickup: pickup, delivery: delivery),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _InformationCard(
                icon: Icons.inventory_2_outlined,
                label: 'CARGO',
                value: cargo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InformationCard(
                icon: Icons.event_available_outlined,
                label: 'EST. DELIVERY',
                value: expectedDelivery,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _buildTimelineCard(
          shipment: shipment,
          status: status,
          lastUpdate: lastUpdate,
        ),

        const SizedBox(height: 12),

        _buildDetailsButton(),
      ],
    );
  }

  // ==========================================================
  // STATUS CARD
  // ==========================================================

  Widget _buildStatusCard({
    required String trackingNumber,
    required _StatusInfo statusInfo,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_deepBlue, Color(0xFF0A4A8E), _primaryBlue],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _deepBlue.withValues(alpha: .14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .12),
                  ),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TRACKING NUMBER',
                      style: TextStyle(
                        color: Color(0xFFBED6EC),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trackingNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .2,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusInfo.background,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusInfo.icon, color: statusInfo.color, size: 13),
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
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const _LiveDot(),
              const SizedBox(width: 7),
              const Text(
                'LIVE TRACKING',
                style: TextStyle(
                  color: Color(0xFFD4E4F3),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .55,
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
    );
  }

  // ==========================================================
  // CURRENT LOCATION
  // ==========================================================

  Widget _buildCurrentLocationCard({
    required String currentLocation,
    required String lastUpdate,
    required _StatusInfo statusInfo,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
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
                    fontSize: 8.8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .65,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  currentLocation,
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
                        'Last update: $lastUpdate',
                        style: const TextStyle(
                          color: _textGrey,
                          fontSize: 9.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Icon(statusInfo.icon, color: statusInfo.color, size: 22),
        ],
      ),
    );
  }

  // ==========================================================
  // ROUTE
  // ==========================================================

  Widget _buildRouteCard({required String pickup, required String delivery}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RouteSide(
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
            child: _RouteSide(
              label: 'DELIVERY',
              value: delivery,
              icon: Icons.location_on_outlined,
              alignRight: true,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TIMELINE
  // ==========================================================

  Widget _buildTimelineCard({
    required Map<String, dynamic> shipment,
    required String status,
    required String lastUpdate,
  }) {
    final history = _historyItems(shipment);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline_rounded, color: _primaryBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Shipment Timeline',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          const Text(
            'Latest milestones from your shipment journey.',
            style: TextStyle(color: _textGrey, fontSize: 9.8),
          ),

          const SizedBox(height: 17),

          if (history.isNotEmpty)
            ...List.generate(history.length, (index) {
              final item = history[index];
              final isLast = index == history.length - 1;

              return _TimelineRow(
                title: item.title,
                description: item.description,
                time: item.time,
                completed: true,
                active: isLast,
                isLast: isLast,
                icon: item.icon,
              );
            })
          else
            ..._fallbackTimeline(status: status, lastUpdate: lastUpdate),
        ],
      ),
    );
  }

  Widget _buildDetailsButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _openShipmentDetails,
        icon: const Icon(Icons.receipt_long_outlined, size: 19),
        label: const Text(
          'VIEW FULL SHIPMENT DETAILS',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: .35,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _deepBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // FALLBACK TIMELINE
  // ==========================================================

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
        description: 'Shipment is undergoing border or customs processing.',
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
          isLast: true,
          icon: Icons.cancel_outlined,
          activeColor: _danger,
        ),
      ];
    }

    final normalizedStatus = status == 'customs' ? 'customs_clearance' : status;

    int currentIndex = stages.indexWhere(
      (stage) => stage.keyName == normalizedStatus,
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
        isLast: isLast,
        icon: stage.icon,
      );
    });
  }

  // ==========================================================
  // OPTIONAL REAL TIMELINE FROM FIRESTORE
  // ==========================================================

  List<_HistoryItem> _historyItems(Map<String, dynamic> shipment) {
    final raw = _firstValue(shipment, [
      'trackingHistory',
      'timeline',
      'history',
    ]);

    if (raw is! List || raw.isEmpty) {
      return [];
    }

    final result = <_HistoryItem>[];

    for (final item in raw) {
      if (item is! Map) continue;

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
        _firstValue(map, ['timestamp', 'updatedAt', 'date', 'time']),
      );

      result.add(
        _HistoryItem(
          title: _prettyStatus(title),
          description: description,
          time: time,
          icon: _timelineIcon(title),
        ),
      );
    }

    return result;
  }

  // ==========================================================
  // DATA HELPERS
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

  String _currentLocation(
    Map<String, dynamic> shipment,
    String status,
    String pickup,
    String delivery,
  ) {
    final liveLocation = _stringValue(shipment, [
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
        );

      case 'prepared':
        return const _StatusInfo(
          label: 'PREPARED',
          color: _primaryBlue,
          background: Color(0xFFEAF3FF),
          icon: Icons.fact_check_rounded,
          progress: .36,
        );

      case 'in_transit':
        return const _StatusInfo(
          label: 'IN TRANSIT',
          color: _primaryBlue,
          background: Color(0xFFEAF3FF),
          icon: Icons.local_shipping_rounded,
          progress: .58,
        );

      case 'customs':
      case 'customs_clearance':
        return const _StatusInfo(
          label: 'CUSTOMS',
          color: _warning,
          background: Color(0xFFFFF4DF),
          icon: Icons.gavel_rounded,
          progress: .72,
        );

      case 'out_for_delivery':
        return const _StatusInfo(
          label: 'OUT FOR DELIVERY',
          color: _primaryBlue,
          background: Color(0xFFEAF3FF),
          icon: Icons.route_rounded,
          progress: .88,
        );

      case 'delivered':
        return const _StatusInfo(
          label: 'DELIVERED',
          color: _success,
          background: Color(0xFFEAF8F0),
          icon: Icons.check_circle_rounded,
          progress: 1,
        );

      case 'cancelled':
        return const _StatusInfo(
          label: 'CANCELLED',
          color: _danger,
          background: Color(0xFFFFECEF),
          icon: Icons.cancel_rounded,
          progress: 0,
        );

      case 'pending':
      default:
        return const _StatusInfo(
          label: 'PENDING',
          color: _warning,
          background: Color(0xFFFFF4DF),
          icon: Icons.schedule_rounded,
          progress: .10,
        );
    }
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
// SMALL UI COMPONENTS
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

class _HeroFeature extends StatelessWidget {
  const _HeroFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _FeatureBox extends StatelessWidget {
  const _FeatureBox({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Icon(icon, color: _primaryBlue, size: 21),
          const SizedBox(height: 7),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textDark,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              color: _textGrey,
              fontSize: 7.8,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteSide extends StatelessWidget {
  const _RouteSide({
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

class _InformationCard extends StatelessWidget {
  const _InformationCard({
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
      constraints: const BoxConstraints(minHeight: 106),
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

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.title,
    required this.description,
    required this.time,
    required this.completed,
    required this.active,
    required this.isLast,
    required this.icon,
    this.activeColor = _primaryBlue,
  });

  final String title;
  final String description;
  final String time;
  final bool completed;
  final bool active;
  final bool isLast;
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
                if (!isLast)
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
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18, top: 2),
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
// DATA MODELS
// ==========================================================

class _StatusInfo {
  const _StatusInfo({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
    required this.progress,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData icon;
  final double progress;
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
