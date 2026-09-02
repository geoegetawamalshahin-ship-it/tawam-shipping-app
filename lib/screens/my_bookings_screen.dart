import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../l10n/app_localizations.dart';
import '../locale_controller.dart';
import '../presentation/controllers/booking_controller.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingController _bookingController = Get.find<BookingController>();
  static const Color deepBlue = Color(0xFF062B55);
  static const Color primaryBlue = Color(0xFF0B4F9C);
  static const Color pageBg = Color(0xFFF4F7FB);
  static const Color textDark = Color(0xFF10233F);
  static const Color textGrey = Color(0xFF8793A4);
  static const Color borderColor = Color(0xFFE3EAF2);
  static const Color softBlue = Color(0xFFEAF3FF);

  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = _bookingController.currentUser;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            if (user == null)
              Expanded(
                child: Center(
                  child: Text(
                    l10n.pleaseSignInToViewBookings,
                    style: const TextStyle(
                      color: textGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _bookingController.watchMyBookings(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _buildError(snapshot.error.toString());
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: primaryBlue),
                      );
                    }

                    final docs = snapshot.data?.docs.toList() ?? [];

                    // أحدث طلب أولاً بدون الحاجة إلى Firestore Index.
                    docs.sort((a, b) {
                      final aDate = a.data()['createdAt'];
                      final bDate = b.data()['createdAt'];

                      final aMilliseconds = aDate is Timestamp
                          ? aDate.millisecondsSinceEpoch
                          : 0;

                      final bMilliseconds = bDate is Timestamp
                          ? bDate.millisecondsSinceEpoch
                          : 0;

                      return bMilliseconds.compareTo(aMilliseconds);
                    });

                    final bookingDocs = docs.where((doc) {
                      final data = doc.data();

                      final requestType = (data['requestType'] ?? '')
                          .toString()
                          .toLowerCase();

                      // الحجوزات الجديدة عندنا booking.
                      // ونسمح للطلبات القديمة أيضاً إذا ما كان الحقل موجود.
                      return requestType.isEmpty || requestType == 'booking';
                    }).toList();

                    final filtered = bookingDocs.where((doc) {
                      final status = _normalizedStatus(doc.data()['status']);

                      if (_selectedFilter == 'all') {
                        return true;
                      }

                      if (_selectedFilter == 'pending') {
                        return status == 'pending' ||
                            status == 'pending_review';
                      }

                      if (_selectedFilter == 'approved') {
                        return status == 'approved' || status == 'confirmed';
                      }

                      if (_selectedFilter == 'rejected') {
                        return status == 'rejected';
                      }

                      return true;
                    }).toList();

                    final pendingCount = bookingDocs.where((doc) {
                      final status = _normalizedStatus(doc.data()['status']);

                      return status == 'pending' || status == 'pending_review';
                    }).length;

                    final approvedCount = bookingDocs.where((doc) {
                      final status = _normalizedStatus(doc.data()['status']);

                      return status == 'approved' || status == 'confirmed';
                    }).length;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 34),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHero(),

                          const SizedBox(height: 18),

                          _buildStats(
                            total: bookingDocs.length,
                            pending: pendingCount,
                            approved: approvedCount,
                          ),

                          const SizedBox(height: 24),

                          Text(
                            l10n.yourBookings,
                            style: const TextStyle(
                              color: textDark,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.4,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            l10n.trackEveryBooking,
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 15),

                          _buildFilters(),

                          const SizedBox(height: 17),

                          if (filtered.isEmpty)
                            _buildEmptyState()
                          else
                            ...filtered.map((doc) => _buildBookingCard(doc)),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              child: const Icon(Icons.arrow_back_rounded, color: deepBlue),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.myBookings,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.tawamAlShahinTransport,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 9,
                    letterSpacing: .8,
                    fontWeight: FontWeight.w800,
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
              Icons.calendar_month_outlined,
              color: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // HERO
  // =========================================================

  Widget _buildHero() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 21, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [deepBlue, Color(0xFF0A4C91), Color(0xFF1268BC)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: .16),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -32,
            child: Icon(
              Icons.public_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: .05),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    l10n.secureCustomerPortal,
                    style: const TextStyle(
                      color: Color(0xFFD6E6F6),
                      fontSize: 9,
                      letterSpacing: .9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Text(
                l10n.yourShippingBookings,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.4,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                l10n.followBookingRequests,
                style: const TextStyle(
                  color: Color(0xFFD6E6F6),
                  fontSize: 11.5,
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

  // =========================================================
  // STATS
  // =========================================================

  Widget _buildStats({
    required int total,
    required int pending,
    required int approved,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.receipt_long_outlined,
            value: total.toString(),
            label: l10n.total,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _statCard(
            icon: Icons.hourglass_top_rounded,
            value: pending.toString(),
            label: l10n.statusPending,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _statCard(
            icon: Icons.verified_outlined,
            value: approved.toString(),
            label: l10n.statusConfirmed,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryBlue, size: 22),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: deepBlue,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: textGrey,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FILTERS
  // =========================================================

  Widget _buildFilters() {
    final l10n = AppLocalizations.of(context)!;
    final filters = [
      ['all', l10n.all],
      ['pending', l10n.statusPending],
      ['approved', l10n.statusConfirmed],
      ['rejected', l10n.rejected],
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final key = filter[0];
          final label = filter[1];

          final selected = _selectedFilter == key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = key;
                });
              },
              borderRadius: BorderRadius.circular(30),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? primaryBlue : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected ? primaryBlue : borderColor,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : textGrey,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // =========================================================
  // BOOKING CARD
  // =========================================================

  Widget _buildBookingCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final l10n = AppLocalizations.of(context)!;
    final data = doc.data();

    final bookingReference = _value(data, 'bookingReference');

    final service = _value(data, 'serviceType');

    final pickup = _value(data, 'pickupLocation', _value(data, 'from'));

    final delivery = _value(data, 'deliveryLocation', _value(data, 'to'));

    final cargo = _value(data, 'cargoType', _value(data, 'cargo'));

    final status = _normalizedStatus(data['status']);

    final statusInfo = _statusInfo(l10n, status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: softBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _serviceIcon(service),
                  color: primaryBlue,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookingReference,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _serviceDisplay(l10n, service),
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
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
                  children: [
                    Icon(statusInfo.icon, color: statusInfo.color, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      statusInfo.label,
                      style: TextStyle(
                        color: statusInfo.color,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _routeSide(
                    label: l10n.from,
                    value: pickup,
                    alignment: CrossAxisAlignment.start,
                  ),
                ),

                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: softBlue,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: primaryBlue,
                    size: 18,
                  ),
                ),

                Expanded(
                  child: _routeSide(
                    label: l10n.to,
                    value: delivery,
                    alignment: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: primaryBlue,
                size: 16,
              ),
              const SizedBox(width: 7),
              Text(
                '${l10n.cargo}:',
                style: const TextStyle(
                  color: textGrey,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  LocaleController.displayOption(
                    l10n,
                    cargo,
                    emptyLabel: l10n.notProvided,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: () {
                _showBookingDetails(context, data);
              },
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: Text(
                l10n.viewBookingDetails,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .3,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                side: const BorderSide(color: Color(0xFFB8C7D8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeSide({
    required String label,
    required String value,
    required CrossAxisAlignment alignment,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textGrey,
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: alignment == CrossAxisAlignment.end
              ? TextAlign.end
              : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: textDark,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // DETAILS
  // =========================================================

  Future<void> _showBookingDetails(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final bookingReference = _value(data, 'bookingReference');

    final service = _value(data, 'serviceType');

    final pickup = _value(data, 'pickupLocation', _value(data, 'from'));

    final delivery = _value(data, 'deliveryLocation', _value(data, 'to'));

    final cargo = _value(data, 'cargoType', _value(data, 'cargo'));

    final phone = _value(data, 'customerPhone', _value(data, 'phone'));

    final weight = _value(data, 'weightKg');

    final quantity = _value(data, 'quantity');

    final length = _value(data, 'lengthCm');

    final width = _value(data, 'widthCm');

    final height = _value(data, 'heightCm');

    final pickupDate = _formatDate(data['pickupDate']);

    final preferredTime = _value(data, 'preferredTime');

    final notes = _value(data, 'notes');

    final adminNote = _value(data, 'adminNote');

    final status = _normalizedStatus(data['status']);

    final statusInfo = _statusInfo(l10n, status);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * .88,
          ),
          decoration: const BoxDecoration(
            color: pageBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),

              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD3DAE4),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [deepBlue, primaryBlue],
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.tawamAlShahinTransport,
                              style: const TextStyle(
                                color: Color(0xFFD6E6F6),
                                fontSize: 8.5,
                                letterSpacing: .8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              bookingReference,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _serviceDisplay(l10n, service),
                              style: const TextStyle(
                                color: Color(0xFFD6E6F6),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    pickup,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                ),
                                Expanded(
                                  child: Text(
                                    delivery,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusInfo.background,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                statusInfo.label,
                                style: TextStyle(
                                  color: statusInfo.color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _detailCard(
                        title: l10n.shipmentDetails,
                        children: [
                          _detailLine(
                            l10n.cargoType,
                            LocaleController.displayOption(
                              l10n,
                              cargo,
                              emptyLabel: l10n.notProvided,
                            ),
                          ),
                          _detailLine(l10n.weight, '$weight KG'),
                          _detailLine(l10n.quantity, quantity),
                          _detailLine(
                            l10n.dimensions,
                            '$length × $width × $height CM',
                          ),
                          _detailLine(l10n.pickupDate, pickupDate),
                          _detailLine(
                            l10n.preferredTime,
                            _preferredTimeLabel(l10n, preferredTime),
                          ),
                          _detailLine(
                            l10n.contactPhone,
                            phone,
                            showDivider: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      _detailCard(
                        title: l10n.specialInstructions,
                        children: [
                          _detailLine(
                            l10n.customerNotes,
                            notes,
                            showDivider: adminNote != '-',
                          ),
                          if (adminNote != '-')
                            _detailLine(
                              l10n.messageFromOurTeam,
                              adminNote,
                              showDivider: false,
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: deepBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            l10n.closeUpper,
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: textDark,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailLine(String label, String value, {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: borderColor),
      ],
    );
  }

  // =========================================================
  // EMPTY / ERROR
  // =========================================================

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_note_outlined, color: primaryBlue, size: 45),
          const SizedBox(height: 13),
          Text(
            l10n.noBookingsFound,
            style: const TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.bookingsEmptyBody,
            textAlign: TextAlign.center,
            style: const TextStyle(color: textGrey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F6FC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: primaryBlue,
                size: 29,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              l10n.unableToLoadBookings,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textDark,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              l10n.pleaseCheckConnectionTryAgain,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textGrey,
                fontSize: 11.5,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.tryAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HELPERS
  // =========================================================

  String _normalizedStatus(dynamic value) {
    return (value ?? 'pending').toString().trim().toLowerCase();
  }

  String _value(
    Map<String, dynamic> data,
    String key, [
    String fallback = '-',
  ]) {
    final value = data[key];

    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  String _formatDate(dynamic value) {
    final l10n = AppLocalizations.of(context)!;
    if (value is Timestamp) {
      final date = value.toDate();

      return '${date.day} '
          '${LocaleController.monthAbbrev(l10n, date.month)} '
          '${date.year}';
    }

    return value?.toString() ?? '-';
  }

  IconData _serviceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'sea freight':
        return Icons.directions_boat_filled_outlined;
      case 'air freight':
        return Icons.flight_rounded;
      case 'land freight':
        return Icons.local_shipping_outlined;
      case 'car shipping':
        return Icons.directions_car_filled_outlined;
      case 'international moving':
        return Icons.home_work_outlined;
      case 'parcel shipping':
        return Icons.inventory_2_outlined;
      default:
        return Icons.local_shipping_outlined;
    }
  }

  String _serviceDisplay(AppLocalizations l10n, String raw) {
    switch (raw) {
      case 'Sea Freight':
      case 'Air Freight':
      case 'Land Freight':
      case 'Car Shipping':
      case 'International Moving':
      case 'Parcel Shipping':
        return LocaleController.serviceLabel(l10n, raw);
      default:
        return raw;
    }
  }

  String _preferredTimeLabel(AppLocalizations l10n, String raw) {
    switch (raw) {
      case 'Morning':
        return l10n.morning;
      case 'Afternoon':
        return l10n.afternoon;
      case 'Evening':
        return l10n.evening;
      case 'Flexible':
        return l10n.flexible;
      default:
        return raw;
    }
  }

  _BookingStatusInfo _statusInfo(AppLocalizations l10n, String status) {
    switch (status) {
      case 'approved':
      case 'confirmed':
        return _BookingStatusInfo(
          label: l10n.confirmedUpper,
          color: const Color(0xFF16765C),
          background: const Color(0xFFEAF8F0),
          icon: Icons.check_circle_rounded,
        );

      case 'rejected':
        return _BookingStatusInfo(
          label: l10n.rejectedUpper,
          color: const Color(0xFFD72638),
          background: const Color(0xFFFFECEF),
          icon: Icons.cancel_rounded,
        );

      case 'pending_review':
      case 'pending':
      default:
        return _BookingStatusInfo(
          label: l10n.pendingUpper,
          color: const Color(0xFFB26A00),
          background: const Color(0xFFFFF4DF),
          icon: Icons.schedule_rounded,
        );
    }
  }
}

class _BookingStatusInfo {
  const _BookingStatusInfo({
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
