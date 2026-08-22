import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            if (user == null)
              const Expanded(
                child: Center(
                  child: Text(
                    'Please sign in to view your bookings.',
                    style: TextStyle(
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
                  stream: FirebaseFirestore.instance
                      .collection('shipment_requests')
                      .where('userId', isEqualTo: user.uid)
                      .snapshots(),
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

                          const Text(
                            'Your Bookings',
                            style: TextStyle(
                              color: textDark,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.4,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Track every booking request and its latest status.',
                            style: TextStyle(
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

          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Bookings',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'TAWAM AL-SHAHIN TRANSPORT',
                  style: TextStyle(
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

          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'SECURE CUSTOMER PORTAL',
                    style: TextStyle(
                      color: Color(0xFFD6E6F6),
                      fontSize: 9,
                      letterSpacing: .9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              Text(
                'Your Shipping Bookings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.4,
                ),
              ),

              SizedBox(height: 7),

              Text(
                'Follow your booking requests from submission to final confirmation.',
                style: TextStyle(
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
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.receipt_long_outlined,
            value: total.toString(),
            label: 'Total',
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _statCard(
            icon: Icons.hourglass_top_rounded,
            value: pending.toString(),
            label: 'Pending',
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _statCard(
            icon: Icons.verified_outlined,
            value: approved.toString(),
            label: 'Confirmed',
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
    const filters = [
      ['all', 'All'],
      ['pending', 'Pending'],
      ['approved', 'Confirmed'],
      ['rejected', 'Rejected'],
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
    final data = doc.data();

    final bookingReference = _value(data, 'bookingReference');

    final service = _value(data, 'serviceType');

    final pickup = _value(data, 'pickupLocation', _value(data, 'from'));

    final delivery = _value(data, 'deliveryLocation', _value(data, 'to'));

    final cargo = _value(data, 'cargoType', _value(data, 'cargo'));

    final status = _normalizedStatus(data['status']);

    final statusInfo = _statusInfo(status);

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
                      service,
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
                    label: 'FROM',
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
                    label: 'TO',
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
              const Text(
                'Cargo:',
                style: TextStyle(
                  color: textGrey,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  cargo,
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
              label: const Text(
                'VIEW BOOKING DETAILS',
                style: TextStyle(
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
              ? TextAlign.right
              : TextAlign.left,
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

    final statusInfo = _statusInfo(status);

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
                            const Text(
                              'TAWAM AL-SHAHIN TRANSPORT',
                              style: TextStyle(
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
                              service,
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
                        title: 'Shipment Details',
                        children: [
                          _detailLine('Cargo Type', cargo),
                          _detailLine('Weight', '$weight KG'),
                          _detailLine('Quantity', quantity),
                          _detailLine(
                            'Dimensions',
                            '$length × $width × $height CM',
                          ),
                          _detailLine('Pickup Date', pickupDate),
                          _detailLine('Preferred Time', preferredTime),
                          _detailLine(
                            'Contact Phone',
                            phone,
                            showDivider: false,
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      _detailCard(
                        title: 'Special Instructions',
                        children: [
                          _detailLine(
                            'Customer Notes',
                            notes,
                            showDivider: adminNote != '-',
                          ),
                          if (adminNote != '-')
                            _detailLine(
                              'Message From Our Team',
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
                          child: const Text(
                            'CLOSE',
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_note_outlined, color: primaryBlue, size: 45),
          SizedBox(height: 13),
          Text(
            'No bookings found',
            style: TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your booking requests will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textGrey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
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

            const Text(
              'Unable to load bookings',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textDark,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
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
              label: const Text('Try Again'),
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
    if (value is Timestamp) {
      final date = value.toDate();

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

  _BookingStatusInfo _statusInfo(String status) {
    switch (status) {
      case 'approved':
      case 'confirmed':
        return const _BookingStatusInfo(
          label: 'CONFIRMED',
          color: Color(0xFF16765C),
          background: Color(0xFFEAF8F0),
          icon: Icons.check_circle_rounded,
        );

      case 'rejected':
        return const _BookingStatusInfo(
          label: 'REJECTED',
          color: Color(0xFFD72638),
          background: Color(0xFFFFECEF),
          icon: Icons.cancel_rounded,
        );

      case 'pending_review':
      case 'pending':
      default:
        return const _BookingStatusInfo(
          label: 'PENDING',
          color: Color(0xFFB26A00),
          background: Color(0xFFFFF4DF),
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
