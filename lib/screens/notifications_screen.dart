import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

const Color _primaryBlue = Color(0xFF07569E);
const Color _darkNavy = Color(0xFF10233F);
const Color _pageBackground = Color(0xFFF4F7FB);
const Color _borderColor = Color(0xFFE3E9F0);
const Color _mutedText = Color(0xFF8B95A3);
const Color _accentRed = Color(0xFFD72638);
const Color _quotePurple = Color(0xFF8155B7);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'All';

  List<Map<String, dynamic>> _notifications = [];
  StreamSubscription<QuerySnapshot>? _notificationsSubscription;

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    _notificationsSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          final items = snapshot.docs.map((doc) {
            final data = doc.data();

            final timestamp = data['createdAt'] as Timestamp?;
            final date = timestamp?.toDate();

            return <String, dynamic>{
              'id': doc.id,
              'title': (data['title'] ?? 'Notification').toString(),
              'message': (data['message'] ?? '').toString(),
              'type': _normalizeType(data['type']),
              'isRead': data['isRead'] == true,
              'time': _formatNotificationTime(date),
              'group': _notificationGroup(date),
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
          });
        });
  }

  String _normalizeType(dynamic value) {
    final type = (value ?? '').toString().toLowerCase();

    if (type == 'quote') return 'Quote';
    if (type == 'support') return 'Support';

    return 'Shipment';
  }

  String _notificationGroup(DateTime? date) {
    if (date == null) return 'Earlier';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(notificationDate).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';

    return 'Earlier';
  }

  String _formatNotificationTime(DateTime? date) {
    if (date == null) return '';

    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    }

    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    return '${difference.inDays} days ago';
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
        return Icons.request_quote_outlined;

      case 'Support':
        return Icons.support_agent_outlined;

      default:
        return Icons.local_shipping_outlined;
    }
  }

  Color _notificationColor(String type) {
    switch (type) {
      case 'Quote':
        return _quotePurple;

      case 'Support':
        return const Color(0xFFDC8B21);

      default:
        return _primaryBlue;
    }
  }

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
      _showMessage('No unread notifications');
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();

    if (!mounted) return;

    _showMessage('All notifications marked as read');
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  List<Widget> _buildGroupedNotifications() {
    const groups = ['Today', 'Yesterday', 'Earlier'];

    final widgets = <Widget>[];

    for (final group in groups) {
      final groupNotifications = _filteredNotifications
          .where((notification) => notification['group'] == group)
          .toList();

      if (groupNotifications.isEmpty) continue;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Row(
            children: [
              Text(
                group,
                style: const TextStyle(
                  color: _darkNavy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Container(height: 1, color: const Color(0xFFE4E9EF)),
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
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: _accentRed,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              child: _NotificationCard(
                title: notification['title'],
                message: notification['message'],
                time: notification['time'],
                icon: _notificationIcon(notification['type']),
                color: _notificationColor(notification['type']),
                isRead: notification['isRead'],
                onTap: () {
                  _markAsRead(notification['id']);
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

  @override
  Widget build(BuildContext context) {
    final hasNotifications = _filteredNotifications.isNotEmpty;

    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            _buildFilters(),

            const SizedBox(height: 17),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      color: _darkNavy,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_unreadCount > 0)
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: const Text(
                      'Mark all as read',
                      style: TextStyle(
                        color: _primaryBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 5),

            if (hasNotifications)
              ..._buildGroupedNotifications()
            else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                    width: 47,
                    height: 47,
                    child: Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                ),
              ),

              const Spacer(),

              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: _primaryBlue,
                      size: 27,
                    ),
                    if (_unreadCount > 0)
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _accentRed,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Shipment updates, quotations and important account alerts.',
            style: TextStyle(
              color: Color(0xFFD9E9F8),
              fontSize: 13.5,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0x20FFFFFF),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: const Color(0x25FFFFFF)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.mark_email_unread_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 9),
                Text(
                  '$_unreadCount unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Updated now',
                  style: TextStyle(
                    color: Color(0xFFD7E7F6),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ['All', 'Unread', 'Shipments', 'Quotes'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                borderRadius: BorderRadius.circular(30),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
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
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: selected ? Colors.white : _mutedText,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 46),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _borderColor),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            color: Color(0xFFADB6C1),
            size: 52,
          ),
          SizedBox(height: 17),
          Text(
            'No Notifications',
            style: TextStyle(
              color: _darkNavy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No notifications match the selected filter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _mutedText, fontSize: 12.5, height: 1.5),
          ),
        ],
      ),
    );
  }
}

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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 230),
          padding: const EdgeInsets.fromLTRB(0, 18, 14, 18),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : const Color(0xFFF7FBFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isRead ? _borderColor : const Color(0xFFC9E2F6),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D0B294D),
                blurRadius: 20,
                offset: Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 230),
                width: 4,
                height: 72,
                decoration: BoxDecoration(
                  color: isRead ? Colors.transparent : _primaryBlue,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(6),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 24),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: _darkNavy,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.more_horiz_rounded,
                            color: Color(0xFF9BA4AF),
                          ),
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
                                    Icon(
                                      isRead
                                          ? Icons.mark_email_unread_outlined
                                          : Icons.done_all_rounded,
                                      color: _primaryBlue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 11),
                                    Text(
                                      isRead
                                          ? 'Mark as unread'
                                          : 'Mark as read',
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: _accentRed,
                                      size: 20,
                                    ),
                                    SizedBox(width: 11),
                                    Text('Delete notification'),
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
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: Color(0xFFA3ABB6),
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          time,
                          style: const TextStyle(
                            color: Color(0xFFA3ABB6),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
