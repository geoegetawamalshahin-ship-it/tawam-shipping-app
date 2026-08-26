import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'my_support_requests_screen.dart';
import 'shipment_details_screen.dart';
import 'my_quotes_screen.dart';
import '../locale_controller.dart';
import '../l10n/app_localizations.dart';

// ==========================================================
// TAWAM PREMIUM BRAND
// ==========================================================

const Color _primaryBlue = Color(0xFF0B5FB3);

const Color _darkNavy = Color(0xFF081F3A);

const Color _pageBackground = Color(0xFFF3F6FA);

const Color _borderColor = Color(0xFFDEE6F0);
const Color _mutedText = Color(0xFF7B899C);

const Color _accentRed = Color(0xFFD83B4E);
const Color _quotePurple = Color(0xFF7457D7);
const Color _supportOrange = Color(0xFFD98624);

// ==========================================================
// NOTIFICATIONS SCREEN
// ==========================================================

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  List<Map<String, dynamic>> _notifications = [];
  StreamSubscription<QuerySnapshot>? _notificationsSubscription;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  // ==========================================================
  // FIRESTORE — UNCHANGED
  // ==========================================================

  void _listenToNotifications() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    _notificationsSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen(
          (snapshot) {
            final items = snapshot.docs.map((doc) {
              final data = doc.data();

              final timestamp = data['createdAt'] as Timestamp?;
              final date = timestamp?.toDate();

              return <String, dynamic>{
                'id': doc.id,
                'referenceId': (data['referenceId'] ?? '').toString(),
                'title': (data['title'] ?? '').toString(),
                'message': (data['message'] ?? '').toString(),
                'event': data['event']?.toString(),
                'params': _notificationParams(data['params']),
                'type': _normalizeType(data['type']),
                'isRead': data['isRead'] == true,
                'createdAt': date,
              };
            }).toList();

            items.sort((a, b) {
              final aDate = a['createdAt'] as DateTime?;
              final bDate = b['createdAt'] as DateTime?;

              if (aDate == null && bDate == null) return 0;
              if (aDate == null) return 1;
              if (bDate == null) return -1;

              return bDate.compareTo(aDate);
            });

            if (!mounted) return;

            setState(() {
              _notifications = items;
              _isLoading = false;
              _loadError = null;
            });
          },
          onError: (error) {
            if (!mounted) return;

            setState(() {
              _isLoading = false;
              _loadError = 'error';
            });
          },
        );
  }

  String _normalizeType(dynamic value) {
    final type = (value ?? '').toString().toLowerCase();

    if (type == 'quote') return 'Quote';
    if (type == 'support') return 'Support';

    return 'Shipment';
  }

  Map<String, dynamic>? _notificationParams(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  String _notificationGroupKey(DateTime? date) {
    if (date == null) return 'earlier';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(notificationDate).inDays;

    if (difference == 0) return 'today';
    if (difference == 1) return 'yesterday';

    return 'earlier';
  }

  String _formatNotificationTime(AppLocalizations l10n, DateTime? date) {
    if (date == null) return '';

    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    }

    if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    }

    if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    }

    if (difference.inDays == 1) {
      return l10n.yesterday;
    }

    return l10n.daysAgo(difference.inDays);
  }

  String _displayTitle(
    AppLocalizations l10n,
    Map<String, dynamic> notification,
  ) {
    final event = notification['event'] as String?;
    final storedTitle = (notification['title'] ?? '').toString();

    return LocaleController.notificationTitle(l10n, event) ??
        (storedTitle.isNotEmpty ? storedTitle : l10n.notificationDefault);
  }

  String _displayMessage(
    AppLocalizations l10n,
    Map<String, dynamic> notification,
  ) {
    final event = notification['event'] as String?;
    final params = notification['params'] as Map<String, dynamic>?;
    final storedMessage = (notification['message'] ?? '').toString();

    return LocaleController.notificationBody(l10n, event, params) ??
        storedMessage;
  }

  @override
  void dispose() {
    _notificationsSubscription?.cancel();
    super.dispose();
  }

  int get _unreadCount {
    return _notifications
        .where((notification) => notification['isRead'] == false)
        .length;
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'Unread':
        return _notifications
            .where((notification) => notification['isRead'] == false)
            .toList();

      case 'Shipments':
        return _notifications
            .where((notification) => notification['type'] == 'Shipment')
            .toList();

      case 'Quotes':
        return _notifications
            .where((notification) => notification['type'] == 'Quote')
            .toList();

      default:
        return _notifications;
    }
  }

  IconData _notificationIcon(String type) {
    switch (type) {
      case 'Quote':
        return Icons.request_quote_rounded;

      case 'Support':
        return Icons.support_agent_rounded;

      default:
        return Icons.local_shipping_rounded;
    }
  }

  Color _notificationColor(String type) {
    switch (type) {
      case 'Quote':
        return _quotePurple;

      case 'Support':
        return _supportOrange;

      default:
        return _primaryBlue;
    }
  }

  // ==========================================================
  // ACTIONS — UNCHANGED
  // ==========================================================

  Future<void> _markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) {
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context)!.noUnreadNotifications);
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();

    if (!mounted) return;

    _showMessage(AppLocalizations.of(context)!.allMarkedAsRead);
  }

  Future<void> _markAsRead(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).update(
      {'isRead': true},
    );
  }

  Future<void> _markAsUnread(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).update(
      {'isRead': false},
    );
  }

  Future<void> _deleteNotification(String id) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(id)
        .delete();

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.notificationDeleted),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ==========================================================
  // GROUPED NOTIFICATIONS
  // ==========================================================

  List<Widget> _buildGroupedNotifications(AppLocalizations l10n) {
    final groups = <(String, String)>[
      ('today', l10n.today),
      ('yesterday', l10n.yesterday),
      ('earlier', l10n.earlier),
    ];

    final widgets = <Widget>[];

    for (final group in groups) {
      final groupKey = group.$1;
      final groupLabel = group.$2;

      final groupNotifications = _filteredNotifications.where((notification) {
        final createdAt = notification['createdAt'] as DateTime?;
        return _notificationGroupKey(createdAt) == groupKey;
      }).toList();

      if (groupNotifications.isEmpty) continue;

      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 14, 2, 13),
          child: Row(
            children: [
              Text(
                groupLabel,
                style: const TextStyle(
                  color: _darkNavy,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(width: 9),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${groupNotifications.length}',
                  style: const TextStyle(
                    color: _primaryBlue,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              const SizedBox(width: 11),

              const Expanded(
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE1E7EF),
                ),
              ),
            ],
          ),
        ),
      );

      for (final notification in groupNotifications) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Dismissible(
              key: ValueKey(notification['id']),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                _deleteNotification(notification['id']);
              },
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                padding: const EdgeInsetsDirectional.only(end: 25),
                decoration: BoxDecoration(
                  color: _accentRed,
                  borderRadius: BorderRadius.circular(23),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),

              child: _NotificationCard(
                title: _displayTitle(l10n, notification),
                message: _displayMessage(l10n, notification),
                time: _formatNotificationTime(
                  l10n,
                  notification['createdAt'] as DateTime?,
                ),
                icon: _notificationIcon(notification['type']),
                color: _notificationColor(notification['type']),
                isRead: notification['isRead'],

                // ==================================================
                // NAVIGATION — UNCHANGED
                // ==================================================
                onTap: () async {
                  _markAsRead(notification['id']);

                  final type = (notification['type'] ?? '')
                      .toString()
                      .toLowerCase();

                  final referenceId = (notification['referenceId'] ?? '')
                      .toString()
                      .trim();

                  // SUPPORT
                  if (type == 'support') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MySupportRequestsScreen(
                          initialRequestId: referenceId.isEmpty
                              ? null
                              : referenceId,
                        ),
                      ),
                    );
                    return;
                  }

                  // SHIPMENT
                  if (type == 'shipment' && referenceId.isNotEmpty) {
                    try {
                      final document = await FirebaseFirestore.instance
                          .collection('shipments')
                          .doc(referenceId)
                          .get();

                      if (!mounted) return;

                      if (!document.exists || document.data() == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.shipmentNotFoundShort),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      final shipment = <String, dynamic>{
                        ...document.data()!,
                        'id': document.id,
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ShipmentDetailsScreen(shipment: shipment),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.couldNotOpenShipmentDetails),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }

                  // QUOTE
                  if (type == 'quote') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MyQuotesScreen(
                          initialQuoteId: referenceId.isEmpty
                              ? null
                              : referenceId,
                        ),
                      ),
                    );
                    return;
                  }
                },

                onMenuSelected: (value) {
                  if (value == 'read') {
                    _markAsRead(notification['id']);
                  }

                  if (value == 'unread') {
                    _markAsUnread(notification['id']);
                  }

                  if (value == 'delete') {
                    _deleteNotification(notification['id']);
                  }
                },
              ),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  // ==========================================================
  // PAGE
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasNotifications = _filteredNotifications.isNotEmpty;

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 34),
          children: [
            _buildHeader(l10n),

            const SizedBox(height: 18),

            _buildFilters(l10n),

            const SizedBox(height: 23),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.notificationCenter,
                        style: const TextStyle(
                          color: _darkNavy,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.stayInformed,
                        style: const TextStyle(
                          color: _mutedText,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_unreadCount > 0)
                  TextButton.icon(
                    onPressed: _markAllAsRead,
                    style: TextButton.styleFrom(
                      foregroundColor: _primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.done_all_rounded, size: 17),
                    label: Text(
                      l10n.readAll,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 7),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 70),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF0B5FB3)),
                ),
              )
            else if (_loadError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 42),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F6FC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.cloud_off_rounded,
                          color: Color(0xFF0B5FB3),
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.unableToLoadNotifications,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF071D36),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          l10n.couldNotLoadNotifications,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF75869B),
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: _listenToNotifications,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(l10n.tryAgain),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B5FB3),
                          foregroundColor: Colors.white,
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
              )
            else if (hasNotifications)
              ..._buildGroupedNotifications(l10n)
            else
              _buildEmptyState(l10n),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PREMIUM HEADER
  // ==========================================================

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF071C35), Color(0xFF0A4F91), Color(0xFF1175C7)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24075AA7),
            blurRadius: 28,
            offset: Offset(0, 13),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -38,
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.055),
              ),
            ),
          ),

          Positioned(
            bottom: -62,
            right: 60,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.035),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(17, 17, 17, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Material(
                      color: Colors.white.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(15),
                        child: const SizedBox(
                          width: 45,
                          height: 45,
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A001B39),
                            blurRadius: 14,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: _primaryBlue,
                            size: 25,
                          ),

                          if (_unreadCount > 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: _accentRed,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Text(
                  l10n.notificationCenter.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFBFD9F2),
                    fontSize: 8.5,
                    letterSpacing: 2.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  l10n.notifications,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  l10n.notificationHeaderSubtitle,
                  style: const TextStyle(
                    color: Color(0xFFD6E7F7),
                    fontSize: 11.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 17),

                Container(
                  padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.11),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_outlined,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_unreadCount ${l10n.unread}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.liveNotificationStatus,
                            style: const TextStyle(
                              color: Color(0xFFC6DCEF),
                              fontSize: 8.5,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.sync_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.live,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
  // FILTERS
  // ==========================================================

  Widget _buildFilters(AppLocalizations l10n) {
    final filters = <(String, String)>[
      ('All', l10n.all),
      ('Unread', l10n.unread),
      ('Shipments', l10n.shipments),
      ('Quotes', l10n.quotes),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final filterValue = filter.$1;
          final filterLabel = filter.$2;
          final selected = _selectedFilter == filterValue;

          IconData icon;

          switch (filterValue) {
            case 'Unread':
              icon = Icons.mark_email_unread_outlined;
              break;

            case 'Shipments':
              icon = Icons.local_shipping_outlined;
              break;

            case 'Quotes':
              icon = Icons.request_quote_outlined;
              break;

            default:
              icon = Icons.grid_view_rounded;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedFilter = filterValue;
                  });
                },
                borderRadius: BorderRadius.circular(30),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _darkNavy : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: selected ? _darkNavy : _borderColor,
                    ),
                    boxShadow: selected
                        ? const [
                            BoxShadow(
                              color: Color(0x22081F3A),
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ]
                        : const [
                            BoxShadow(
                              color: Color(0x07081F3A),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF8090A3),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        filterLabel,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF718096),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE3EAF3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A081F3A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F6FC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF0B5FB3),
              size: 34,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            l10n.noNotificationsYet,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF071D36),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            l10n.notificationEmptyHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF75869B),
              fontSize: 12,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F8FC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sync_rounded,
                  size: 16,
                  color: Color(0xFF0B5FB3),
                ),
                const SizedBox(width: 7),
                Text(
                  l10n.updatesAppearAutomatically,
                  style: const TextStyle(
                    color: Color(0xFF0B5FB3),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} //
// ==========================================================
// PREMIUM NOTIFICATION CARD
// ==========================================================

class _NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final bool isRead;
  final VoidCallback onTap;
  final ValueChanged<String> onMenuSelected;

  const _NotificationCard({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    required this.isRead,
    required this.onTap,
    required this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isRead ? _borderColor : const Color(0xFFBBD9F2),
              width: isRead ? 1 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isRead
                    ? const Color(0x0A081F3A)
                    : const Color(0x140B5FB3),
                blurRadius: isRead ? 17 : 21,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Stack(
              children: [
                if (!isRead)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 4, color: _primaryBlue),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 15, 10, 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: color.withValues(alpha: 0.10),
                          ),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: _darkNavy,
                                            fontSize: 13.3,
                                            height: 1.25,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),

                                      if (!isRead) ...[
                                        const SizedBox(width: 7),

                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: _primaryBlue,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 170,
                                  ),
                                  icon: const Icon(
                                    Icons.more_horiz_rounded,
                                    color: Color(0xFF98A5B5),
                                    size: 21,
                                  ),
                                  color: Colors.white,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(17),
                                  ),
                                  onSelected: onMenuSelected,
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem<String>(
                                        value: isRead ? 'unread' : 'read',
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 33,
                                              height: 33,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEDF5FC),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                isRead
                                                    ? Icons
                                                          .mark_email_unread_outlined
                                                    : Icons.done_all_rounded,
                                                color: _primaryBlue,
                                                size: 17,
                                              ),
                                            ),

                                            const SizedBox(width: 10),

                                            Text(
                                              isRead
                                                  ? l10n.markAsUnread
                                                  : l10n.markAsRead,
                                              style: const TextStyle(
                                                color: _darkNavy,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const PopupMenuDivider(),

                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const SizedBox(
                                              width: 33,
                                              height: 33,
                                              child: Icon(
                                                Icons.delete_outline_rounded,
                                                color: _accentRed,
                                                size: 19,
                                              ),
                                            ),

                                            const SizedBox(width: 10),

                                            Text(
                                              l10n.deleteNotification,
                                              style: const TextStyle(
                                                color: _accentRed,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 5),

                            Text(
                              message,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _mutedText,
                                fontSize: 10.8,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F6FA),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.schedule_rounded,
                                        color: Color(0xFF9AA6B4),
                                        size: 12,
                                      ),

                                      const SizedBox(width: 4),

                                      Text(
                                        time,
                                        style: const TextStyle(
                                          color: Color(0xFF8D99A8),
                                          fontSize: 8.8,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Spacer(),

                                if (!isRead)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF4FD),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      l10n.newBadge,
                                      style: const TextStyle(
                                        color: _primaryBlue,
                                        fontSize: 8,
                                        letterSpacing: 0.8,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
