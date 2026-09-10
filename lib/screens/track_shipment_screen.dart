import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/utils/shipment_status_info.dart';
import '../app/utils/value_formatters.dart';
import '../app/widgets/shipment_status_widgets.dart';
import '../app/widgets/shipping/show_shipping_message.dart';
import '../controllers/shipment_controller.dart';
import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
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
  final ShipmentController _shipmentController = Get.find<ShipmentController>();

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
    final l10n = AppLocalizations.of(context)!;
    final trackingNumber = _trackingController.text.trim().toUpperCase();

    FocusScope.of(context).unfocus();

    if (trackingNumber.isEmpty) {
      _showMessage(l10n.pleaseEnterTrackingNumber);
      return;
    }

    final user = _shipmentController.currentUser;

    if (user == null) {
      _showMessage(l10n.pleaseSignInToTrack);
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
      final snapshot = await _shipmentController.findShipment(
        userId: user.uid,
        trackingNumber: trackingNumber,
      );

      if (!mounted) return;

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isSearching = false;
          _showResult = false;
          _shipment = null;
        });

        _showMessage(l10n.shipmentNotFoundCheck);

        return;
      }

      final doc = snapshot.docs.first;

      _applyShipment(documentId: doc.id, data: doc.data());

      // REAL-TIME:
      // Once the shipment is found, listen to this exact
      // Firestore document. Any admin update to the document
      // will appear automatically on the customer's screen.
      _shipmentSubscription = _shipmentController.watchShipment(doc.id).listen(
        (document) {
          if (!mounted) return;

          if (!document.exists || document.data() == null) {
            setState(() {
              _isSearching = false;
              _showResult = false;
              _shipment = null;
            });

            _showMessage(l10n.shipmentNoLongerAvailable);
            return;
          }

          _applyShipment(documentId: document.id, data: document.data()!);
        },
        onError: (Object error) {
          if (!mounted) return;

          _showMessage(l10n.liveTrackingInterrupted);
        },
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isSearching = false;
        _showResult = false;
        _shipment = null;
      });

      _showMessage(l10n.couldNotTrackShipment);
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
    showFloatingRadiusMessage(context, message: message);
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
    final l10n = AppLocalizations.of(context)!;
    _showMessage(l10n.qrScanningSoon);
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
    final l10n = AppLocalizations.of(context)!;
    return ShipmentBackHeader(
      title: l10n.shipmentTracking,
      subtitle: l10n.tawamAlShahinTransport,
      trailingIcon: Icons.location_searching_rounded,
      trailingIconSize: 23,
      onBack: () => Navigator.pop(context),
    );
  }

  // ==========================================================
  // PREMIUM HERO
  // ==========================================================

  Widget _buildHero() {
    final l10n = AppLocalizations.of(context)!;
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShipmentLiveDot(),
                  const SizedBox(width: 8),
                  Text(
                    l10n.liveShipmentVisibility,
                    style: const TextStyle(
                      color: Color(0xFFD6E6F6),
                      fontSize: 9.2,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .95,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                l10n.trackEveryMove,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                l10n.trackEveryMoveSubtitle,
                style: const TextStyle(
                  color: Color(0xFFD7E6F5),
                  fontSize: 11.8,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  ShipmentHeroFeature(
                    icon: Icons.lock_outline_rounded,
                    label: l10n.private,
                  ),
                  const SizedBox(width: 18),
                  ShipmentHeroFeature(
                    icon: Icons.sync_rounded,
                    label: l10n.liveUpdates,
                  ),
                  const SizedBox(width: 18),
                  ShipmentHeroFeature(
                    icon: Icons.verified_outlined,
                    label: l10n.secure,
                  ),
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
    final l10n = AppLocalizations.of(context)!;
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
          Text(
            l10n.trackingNumber,
            style: const TextStyle(
              color: _textDark,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            l10n.onlyAssignedShipments,
            style: const TextStyle(
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
              hintText: l10n.enterTrackingNumber,
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
                _isSearching ? l10n.trackingInProgress : l10n.trackShipment,
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      key: const ValueKey('before-tracking'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 19, 17, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.professionalVisibility,
            style: const TextStyle(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            l10n.trackingViewProtected,
            style: const TextStyle(color: _textGrey, fontSize: 10.5, height: 1.4),
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _FeatureBox(
                  icon: Icons.location_on_outlined,
                  title: l10n.location,
                  subtitle: l10n.latestUpdate,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _FeatureBox(
                  icon: Icons.timeline_rounded,
                  title: l10n.timeline,
                  subtitle: l10n.shipmentJourneyShort,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _FeatureBox(
                  icon: Icons.schedule_rounded,
                  title: l10n.delivery,
                  subtitle: l10n.etaDetails,
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
    final l10n = AppLocalizations.of(context)!;
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
    ], fallback: l10n.notSpecified);

    final delivery = _stringValue(shipment, [
      'deliveryLocation',
      'destination',
    ], fallback: l10n.notSpecified);

    final cargoRaw = _stringValue(shipment, [
      'cargo',
      'cargoType',
      'type',
    ], fallback: '');
    final cargo = LocaleController.displayOption(
      l10n,
      cargoRaw,
      emptyLabel: l10n.shipment,
    );

    final status = LocaleController.normalizeStatus(
      _stringValue(shipment, ['status'], fallback: 'pending'),
    );

    final statusInfo = _statusInfo(l10n, status);

    final expectedDelivery = _formatDate(
      l10n,
      _firstValue(shipment, ['expectedDelivery', 'estimatedDelivery']),
    );

    final currentLocation = _currentLocation(
      shipment,
      status,
      pickup,
      delivery,
    );

    final lastUpdate = _formatDateTime(
      l10n,
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
                label: l10n.cargoUpper,
                value: cargo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InformationCard(
                icon: Icons.event_available_outlined,
                label: l10n.estDelivery,
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
    required ShipmentStatusInfo statusInfo,
  }) {
    final l10n = AppLocalizations.of(context)!;
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
                    Text(
                      l10n.trackingNumberUpper,
                      style: const TextStyle(
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
              const ShipmentLiveDot(),
              const SizedBox(width: 7),
              Text(
                l10n.liveTracking,
                style: const TextStyle(
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
    required ShipmentStatusInfo statusInfo,
  }) {
    final l10n = AppLocalizations.of(context)!;
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
                  Text(
                    l10n.currentLocation,
                    style: const TextStyle(
                      color: _textGrey,
                      fontSize: 8.8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .65,
                    ),
                  ),
                const SizedBox(height: 5),
                Text(
                  currentLocation.isEmpty
                      ? l10n.locationUpdatePending
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
                        l10n.lastUpdatePrefix(lastUpdate),
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
    final l10n = AppLocalizations.of(context)!;
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
              label: l10n.pickupUpper,
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
              label: l10n.deliveryUpper,
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
    final l10n = AppLocalizations.of(context)!;
    final history = _historyItems(l10n, shipment);

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
          Row(
            children: [
              const Icon(Icons.timeline_rounded, color: _primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.shipmentTimeline,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            l10n.latestMilestones,
            style: const TextStyle(color: _textGrey, fontSize: 9.8),
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
            ..._fallbackTimeline(
              l10n: l10n,
              status: status,
              lastUpdate: lastUpdate,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsButton() {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _openShipmentDetails,
        icon: const Icon(Icons.receipt_long_outlined, size: 19),
        label: Text(
          l10n.viewFullShipmentDetails,
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
    required AppLocalizations l10n,
    required String status,
    required String lastUpdate,
  }) {
    return shipmentFallbackTimeline(
      l10n: l10n,
      status: status,
      lastUpdate: lastUpdate,
      lastRowBottomPadding: 0,
    );
  }

  // ==========================================================
  // OPTIONAL REAL TIMELINE FROM FIRESTORE
  // ==========================================================

  List<ShipmentHistoryItem> _historyItems(
    AppLocalizations l10n,
    Map<String, dynamic> shipment,
  ) {
    return shipmentHistoryItems(l10n, shipment);
  }

  // ==========================================================
  // DATA HELPERS
  // ==========================================================

  Object? _firstValue(Map<String, dynamic> data, List<String> keys) {
    return firstKeyedValue(data, keys);
  }

  String _stringValue(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '-',
  }) {
    return stringFromKeys(data, keys, fallback: fallback);
  }

  String _currentLocation(
    Map<String, dynamic> shipment,
    String status,
    String pickup,
    String delivery,
  ) {
    return shipmentCurrentLocation(
      shipment: shipment,
      status: status,
      pickup: pickup,
      delivery: delivery,
    );
  }

  ShipmentStatusInfo _statusInfo(AppLocalizations l10n, String status) {
    return shipmentStatusInfo(l10n, status);
  }

  String _formatDate(AppLocalizations l10n, Object? value) {
    return formatOptionalLocalizedDate(
      l10n,
      value,
      emptyFallback: l10n.notSpecified,
    );
  }

  String _formatDateTime(AppLocalizations l10n, Object? value) {
    return formatOptionalLocalizedDateTime(
      l10n,
      value,
      emptyFallback: l10n.awaitingUpdate,
    );
  }
}

// ==========================================================
// SMALL UI COMPONENTS
// ==========================================================


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
          textAlign: alignRight ? TextAlign.end : TextAlign.start,
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
  });

  final String title;
  final String description;
  final String time;
  final bool completed;
  final bool active;
  final bool isLast;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ShipmentTimelineRow(
      title: title,
      description: description,
      time: time,
      completed: completed,
      active: active,
      showLine: !isLast,
      contentBottomPadding: isLast ? 0 : 18,
      icon: icon,
    );
  }
}
