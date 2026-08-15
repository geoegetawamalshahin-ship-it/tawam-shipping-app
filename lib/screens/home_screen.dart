import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'shipments_screen.dart';
import 'shipment_details_screen.dart';
import 'track_shipment_screen.dart';
import 'request_quote_screen.dart';
import 'support_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'shipment_request_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static const Color primaryBlue = Color(0xFF07569E);
  static const Color darkBlue = Color(0xFF10233F);
  static const Color accentRed = Color(0xFFD72638);
  static const Color pageBackground = Color(0xFFF5F7FA);
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryBlue = HomeScreen.primaryBlue;
  static const Color darkBlue = HomeScreen.darkBlue;
  static const Color accentRed = HomeScreen.accentRed;
  static const Color pageBackground = HomeScreen.pageBackground;
  int _activeCount = 0;
  int _deliveredCount = 0;
  int _quotesCount = 0;
  String _customerName = '';

  Map<String, dynamic>? _recentShipment;

  bool _isLoadingHome = true;
  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _activeCount = 0;
        _deliveredCount = 0;
        _quotesCount = 0;
        _recentShipment = null;
        _isLoadingHome = false;
      });
      return;
    }
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data();

    final customerName = (userData?['name'] ?? user.displayName ?? '')
        .toString();
    try {
      final shipmentsSnapshot = await FirebaseFirestore.instance
          .collection('shipments')
          .where('userId', isEqualTo: user.uid)
          .get();

      final quotesSnapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where('userId', isEqualTo: user.uid)
          .get();

      final shipments = shipmentsSnapshot.docs.map((doc) {
        return <String, dynamic>{...doc.data(), 'id': doc.id};
      }).toList();

      shipments.sort((a, b) {
        final aDate = a['createdAt'];
        final bDate = b['createdAt'];

        if (aDate is Timestamp && bDate is Timestamp) {
          return bDate.compareTo(aDate);
        }

        return 0;
      });

      final activeCount = shipments.where((shipment) {
        final status = (shipment['status'] ?? '').toString().toLowerCase();

        return status != 'delivered' && status != 'cancelled';
      }).length;

      final deliveredCount = shipments.where((shipment) {
        final status = (shipment['status'] ?? '').toString().toLowerCase();

        return status == 'delivered';
      }).length;

      if (!mounted) return;

      setState(() {
        _activeCount = activeCount;
        _deliveredCount = deliveredCount;
        _quotesCount = quotesSnapshot.docs.length;
        _recentShipment = shipments.isNotEmpty ? shipments.first : null;
        _customerName = customerName;
        _isLoadingHome = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingHome = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load home data: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  SizedBox(
                    width: 190,
                    height: 72,
                    child: ClipRect(
                      child: Transform.scale(
                        scale: 2.1,
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/images/tawam_logo.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  _HeaderButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 10),

                  _HeaderButton(
                    icon: Icons.person_outline_rounded,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Text(
                _customerName.isEmpty ? 'Welcome' : 'Welcome, $_customerName',
                style: const TextStyle(
                  color: Color(0xFF7B8493),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Welcome to Tawam AL -SHAHIN',
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Track and manage your shipments easily.',
                style: TextStyle(color: Color(0xFF87909D), fontSize: 15),
              ),

              const SizedBox(height: 26),

              // Track Shipment Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0B294D),
                      Color(0xFF07569E),
                      Color(0xFF0874C9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0x26FFFFFF)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3D07569E),
                      blurRadius: 32,
                      offset: Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.local_shipping_outlined,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Track your shipment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Enter your tracking number to see the latest shipment updates.',
                      style: TextStyle(
                        color: Color(0xFFDCEBFA),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter tracking number',
                        hintStyle: const TextStyle(color: Color(0xFF9AA5B2)),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: primaryBlue,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 17,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 13),

                    SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const TrackShipmentScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Track Shipment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 9),
                            Icon(Icons.arrow_forward_rounded),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: _HomeStatCard(
                      icon: Icons.local_shipping_outlined,
                      value: _isLoadingHome ? '—' : '$_activeCount',
                      label: 'Active',
                      color: primaryBlue,
                    ),
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: _HomeStatCard(
                      icon: Icons.check_circle_outline_rounded,
                      value: _isLoadingHome ? '—' : '$_deliveredCount',
                      label: 'Delivered',
                      color: Color(0xFF177A61),
                    ),
                  ),

                  SizedBox(width: 10),

                  Expanded(
                    child: _HomeStatCard(
                      icon: Icons.request_quote_outlined,
                      value: _isLoadingHome ? '—' : '$_quotesCount',
                      label: 'Quotes',
                      color: accentRed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                'Quick Services',
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.28,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ServiceCard(
                    title: 'My Shipments',
                    subtitle: 'View all shipments',
                    icon: Icons.inventory_2_outlined,
                    color: primaryBlue,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ShipmentsScreen(),
                        ),
                      );
                    },
                  ),
                  _ServiceCard(
                    title: 'Request Quote',
                    subtitle: 'Get shipping price',
                    icon: Icons.request_quote_outlined,
                    color: accentRed,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RequestQuoteScreen(),
                        ),
                      );
                    },
                  ),
                  _ServiceCard(
                    title: 'Request Shipment',
                    subtitle: 'Create a new shipment request',
                    icon: Icons.add_road_rounded,
                    color: const Color(0xFF0D6EFD),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ShipmentRequestPage(),
                        ),
                      );
                    },
                  ),
                  _ServiceCard(
                    title: 'Track Shipment',
                    subtitle: 'Live shipment status',
                    icon: Icons.location_on_outlined,
                    color: const Color(0xFF177A61),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TrackShipmentScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ), // GridView.count
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 120,
                child: _ServiceCard(
                  title: 'Support',
                  subtitle: 'Contact our team',
                  icon: Icons.support_agent_rounded,
                  color: const Color(0xFF8155B7),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SupportScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  const Text(
                    'Recent Shipment',
                    style: TextStyle(
                      color: darkBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const Spacer(),

                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ShipmentsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              if (_recentShipment == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 34,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE4EAF1)),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: Color(0xFF9AA5B2),
                        size: 40,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No shipments yet',
                        style: TextStyle(
                          color: HomeScreen.darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Your latest shipment will appear here.',
                        style: TextStyle(
                          color: Color(0xFF929CAA),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            ShipmentDetailsScreen(shipment: _recentShipment!),
                      ),
                    );
                  },
                  child: _RecentShipmentCard(shipment: _recentShipment!),
                ),
            ], // Main Column children
          ), // Main Column
        ), // SingleChildScrollView
      ), // SafeArea
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: true,
                  onTap: () {},
                ),
                _BottomItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Shipments',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ShipmentsScreen(),
                      ),
                    );
                  },
                ),
                _BottomItem(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Track',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TrackShipmentScreen(),
                      ),
                    );
                  },
                ),
                _BottomItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  },
                ), // _BottomItem
              ], // children
            ), // Row
          ), // Padding
        ), // SafeArea
      ), // Container
    ); // Scaffold
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE7EAF0)),
          ),
          child: Icon(icon, color: HomeScreen.darkBlue, size: 23),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE4EAF1)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D10233F),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),

                  const Spacer(),

                  Container(
                    width: 29,
                    height: 29,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF9AA5B2),
                      size: 16,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF10233F),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF98A2B0),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? HomeScreen.primaryBlue : const Color(0xFF9AA2AE);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _HomeStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EAF0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D10233F),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              color: HomeScreen.darkBlue,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8B95A3),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentShipmentCard extends StatelessWidget {
  final Map<String, dynamic> shipment;

  const _RecentShipmentCard({required this.shipment});

  @override
  Widget build(BuildContext context) {
    final trackingNumber =
        (shipment['trackingNumber'] ?? shipment['number'] ?? '').toString();

    final origin = (shipment['pickupLocation'] ?? shipment['origin'] ?? '')
        .toString();

    final destination =
        (shipment['deliveryLocation'] ?? shipment['destination'] ?? '')
            .toString();

    final status = (shipment['status'] ?? 'pending').toString().toLowerCase();

    final cargo = (shipment['cargo'] ?? shipment['type'] ?? 'Shipment')
        .toString();

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

    String readableStatus = 'Pending';
    double progress = 0.10;

    switch (status) {
      case 'confirmed':
        readableStatus = 'Confirmed';
        progress = 0.25;
        break;
      case 'prepared':
        readableStatus = 'Prepared';
        progress = 0.40;
        break;

      case 'in_transit':
        readableStatus = 'In Transit';
        progress = 0.55;
        break;

      case 'out_for_delivery':
        readableStatus = 'Out for Delivery';
        progress = 0.85;
        break;

      case 'delivered':
        readableStatus = 'Delivered';
        progress = 1.0;
        break;

      case 'cancelled':
        readableStatus = 'Cancelled';
        progress = 0.0;
        break;

      default:
        readableStatus = 'Pending';
        progress = 0.10;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4EAF1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1010233F),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5FE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: HomeScreen.primaryBlue,
                  size: 25,
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
                        color: HomeScreen.darkBlue,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Shipment is moving to destination',
                      style: TextStyle(
                        color: Color(0xFF929CAA),
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
                  color: const Color(0xFFE8F7F1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  readableStatus,
                  style: const TextStyle(
                    color: Color(0xFF16765C),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.radio_button_checked_rounded,
                  color: HomeScreen.primaryBlue,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    origin,
                    style: const TextStyle(
                      color: HomeScreen.darkBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFA7B0BB),
                  size: 19,
                ),
                Expanded(
                  child: Text(
                    destination,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: HomeScreen.darkBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 7),
                Icon(
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
              Text(
                'Shipment progress',
                style: TextStyle(
                  color: Color(0xFF8E98A6),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: HomeScreen.primaryBlue,
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
              valueColor: const AlwaysStoppedAnimation<Color>(
                HomeScreen.primaryBlue,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Divider(height: 1, color: Color(0xFFE7ECF2)),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _ShipmentDetailItem(
                  icon: Icons.calendar_month_outlined,
                  title: 'Expected delivery',
                  value: formattedDelivery,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: _ShipmentDetailItem(
                  icon: Icons.route_outlined,
                  title: 'Shipment type',
                  value: cargo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShipmentDetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ShipmentDetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F6FC),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: HomeScreen.primaryBlue, size: 18),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF9AA4B1), fontSize: 9.5),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: HomeScreen.darkBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
