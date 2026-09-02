import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../l10n/app_localizations.dart';
import '../core/responsive/feature_page_body.dart';
import '../locale_controller.dart';
import '../presentation/controllers/support_controller.dart';

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

class MySupportRequestsScreen extends StatefulWidget {
  const MySupportRequestsScreen({super.key, this.initialRequestId});

  final String? initialRequestId;

  @override
  State<MySupportRequestsScreen> createState() =>
      _MySupportRequestsScreenState();
}

class _MySupportRequestsScreenState extends State<MySupportRequestsScreen> {
  final SupportController _supportController = Get.find<SupportController>();
  String _selectedFilter = 'all';
  bool _openedInitialRequest = false;

  final List<String> _filters = const ['all', 'new', 'in_progress', 'resolved'];

  @override
  Widget build(BuildContext context) {
    final user = _supportController.currentUser;

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: user == null
                  ? _buildSignedOut()
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _supportController.watchMine(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: _primaryBlue,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return _buildError();
                        }

                        final requests =
                            snapshot.data?.docs.map((doc) {
                              return <String, dynamic>{
                                ...doc.data(),
                                'id': doc.id,
                              };
                            }).toList() ??
                            [];

                        requests.sort((a, b) {
                          final aTime = a['createdAt'];
                          final bTime = b['createdAt'];

                          if (aTime is Timestamp && bTime is Timestamp) {
                            return bTime.compareTo(aTime);
                          }

                          return 0;
                        });
                        final initialRequestId = widget.initialRequestId
                            ?.trim();

                        if (!_openedInitialRequest &&
                            initialRequestId != null &&
                            initialRequestId.isNotEmpty) {
                          final matchingRequests = requests.where((request) {
                            return (request['id'] ?? '').toString() ==
                                initialRequestId;
                          }).toList();

                          if (matchingRequests.isNotEmpty) {
                            _openedInitialRequest = true;

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;

                              _showRequestDetails(
                                context,
                                matchingRequests.first,
                              );
                            });
                          }
                        }
                        final filtered = requests.where((request) {
                          if (_selectedFilter == 'all') {
                            return true;
                          }

                          return _normalizeSupportStatus(
                                (request['status'] ?? 'new').toString(),
                              ) ==
                              _selectedFilter;
                        }).toList();

                        return ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: FeaturePageInsets.list(context),
                          children: [
                            _buildHero(requests),

                            const SizedBox(height: 16),

                            _buildFilters(),

                            const SizedBox(height: 20),

                            _buildSectionHeader(filtered.length),

                            const SizedBox(height: 12),

                            if (filtered.isEmpty)
                              _buildEmpty()
                            else
                              ...filtered.map(
                                (request) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildRequestCard(context, request),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: _deepBlue,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.mySupportRequests,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.35,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.tawamAlShahinTransport,
                  style: const TextStyle(
                    color: _primaryBlue,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .8,
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
              Icons.support_agent_rounded,
              color: _primaryBlue,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(List<Map<String, dynamic>> requests) {
    final l10n = AppLocalizations.of(context)!;
    final total = requests.length;
    final newCount = requests
        .where(
          (r) =>
              _normalizeSupportStatus((r['status'] ?? '').toString()) == 'new',
        )
        .length;
    final progressCount = requests
        .where(
          (r) =>
              _normalizeSupportStatus((r['status'] ?? '').toString()) ==
              'in_progress',
        )
        .length;
    final resolvedCount = requests
        .where(
          (r) =>
              _normalizeSupportStatus((r['status'] ?? '').toString()) ==
              'resolved',
        )
        .length;

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
            right: -28,
            top: -26,
            child: Icon(
              Icons.headset_mic_rounded,
              size: 145,
              color: Colors.white.withValues(alpha: .05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _LiveDot(),
                  const SizedBox(width: 7),
                  Text(
                    l10n.liveSupportPortal,
                    style: const TextStyle(
                      color: Color(0xFFD2E3F3),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.yourSupportCases,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.45,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                l10n.followEveryRequest,
                style: const TextStyle(
                  color: Color(0xFFD7E6F5),
                  fontSize: 10.8,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 17),
              Row(
                children: [
                  Expanded(
                    child: _HeroStat(
                      value: '$total',
                      label: l10n.total,
                      icon: Icons.list_alt_rounded,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _HeroStat(
                      value: '$newCount',
                      label: l10n.newBadge,
                      icon: Icons.fiber_new_rounded,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _HeroStat(
                      value: '$progressCount',
                      label: l10n.statusInProgress,
                      icon: Icons.autorenew_rounded,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: _HeroStat(
                      value: '$resolvedCount',
                      label: l10n.statusResolved,
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

  Widget _buildFilters() {
    final l10n = AppLocalizations.of(context)!;
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
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            borderRadius: BorderRadius.circular(30),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: selected ? _primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: selected ? _primaryBlue : _border),
              ),
              child: Text(
                _supportFilterLabel(l10n, filter),
                style: TextStyle(
                  color: selected ? Colors.white : _textGrey,
                  fontSize: 10.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(int count) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.supportHistory,
                style: const TextStyle(
                  color: _textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.tapAnyCase,
                style: const TextStyle(color: _textGrey, fontSize: 9.5),
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

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request) {
    final l10n = AppLocalizations.of(context)!;
    final category = LocaleController.displayOption(
      l10n,
      (request['category'] ?? '').toString(),
      emptyLabel: l10n.supportRequest,
    );
    final shipmentNumber = (request['shipmentNumber'] ?? '').toString().trim();
    final message = (request['message'] ?? '').toString();
    final rawStatus = (request['status'] ?? 'new').toString();
    final status = LocaleController.supportStatusLabel(l10n, rawStatus);
    final createdAt = _formatDateTime(l10n, request['createdAt']);
    final statusInfo = _statusInfo(_normalizeSupportStatus(rawStatus));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showRequestDetails(context, request);
        },
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _softBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
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
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _textDark,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shipmentNumber.isEmpty
                              ? l10n.generalSupportCase
                              : '${l10n.shipment}: $shipmentNumber',
                          style: const TextStyle(
                            color: _textGrey,
                            fontSize: 9.3,
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
                          status,
                          style: TextStyle(
                            color: statusInfo.color,
                            fontSize: 7.5,
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
                width: double.infinity,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  message.isEmpty ? l10n.noMessageProvided : message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 10.2,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                      createdAt,
                      style: const TextStyle(color: _textGrey, fontSize: 8.7),
                    ),
                  ),
                  Text(
                    l10n.viewDetailsUpper,
                    style: TextStyle(
                      color: _primaryBlue,
                      fontSize: 8.2,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .35,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: _primaryBlue,
                    size: 11,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestDetails(BuildContext context, Map<String, dynamic> request) {
    final l10n = AppLocalizations.of(context)!;
    final category = LocaleController.displayOption(
      l10n,
      (request['category'] ?? '').toString(),
      emptyLabel: l10n.supportRequest,
    );
    final shipmentNumber = (request['shipmentNumber'] ?? '').toString().trim();
    final message = (request['message'] ?? '').toString();
    final rawStatus = (request['status'] ?? 'new').toString();
    final status = LocaleController.supportStatusLabel(l10n, rawStatus);
    final createdAt = _formatDateTime(l10n, request['createdAt']);
    final adminReply = _firstText(request, ['adminReply', 'reply', 'response']);
    final updatedAt = _formatDateTime(
      l10n,
      request['updatedAt'] ?? request['adminUpdatedAt'],
    );

    final statusInfo = _statusInfo(_normalizeSupportStatus(rawStatus));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * .82,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 46,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8DEE6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _softBlue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
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
                            category,
                            style: const TextStyle(
                              color: _textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            createdAt,
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
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: statusInfo.background,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusInfo.color,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (shipmentNumber.isNotEmpty)
                  _DetailBox(
                    icon: Icons.local_shipping_outlined,
                    label: l10n.shipmentNumber,
                    value: shipmentNumber,
                  ),
                if (shipmentNumber.isNotEmpty) const SizedBox(height: 10),
                _DetailBox(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: l10n.yourMessage,
                  value: message.isEmpty ? l10n.noMessageProvided : message,
                ),
                const SizedBox(height: 10),
                _DetailBox(
                  icon: Icons.update_rounded,
                  label: l10n.latestStatusUpdate,
                  value: updatedAt == l10n.awaitingUpdate
                      ? createdAt
                      : updatedAt,
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: adminReply.isEmpty
                        ? const Color(0xFFF8FAFD)
                        : const Color(0xFFEEF6FD),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: adminReply.isEmpty
                          ? _border
                          : const Color(0xFFD6E8F7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.admin_panel_settings_outlined,
                            color: _primaryBlue,
                            size: 19,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            l10n.tawamSupportResponse,
                            style: const TextStyle(
                              color: _primaryBlue,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .55,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        adminReply.isEmpty
                            ? l10n.noSupportResponseYet
                            : adminReply,
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 10.5,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: _deepBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      l10n.closeUpper,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 42),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.support_agent_outlined,
            color: Color(0xFF9BA6B4),
            size: 45,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.noSupportRequestsFound,
            style: const TextStyle(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.supportRequestsEmptyBody,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textGrey,
              fontSize: 10.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          l10n.couldNotLoadSupportRequests,
          style: const TextStyle(color: _textDark, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildSignedOut() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l10n.pleaseSignInToViewSupport,
        textAlign: TextAlign.center,
        style: const TextStyle(color: _textDark, fontWeight: FontWeight.w700),
      ),
    );
  }

  String _supportFilterLabel(AppLocalizations l10n, String filter) {
    switch (filter) {
      case 'new':
        return l10n.statusNew;
      case 'in_progress':
        return l10n.statusInProgress;
      case 'resolved':
        return l10n.statusResolved;
      default:
        return l10n.all;
    }
  }

  String _normalizeSupportStatus(String raw) {
    final status = raw
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    if (status == 'resolved' || status == 'closed' || status == 'completed') {
      return 'resolved';
    }

    if (status == 'in_progress' || status == 'processing' || status == 'open') {
      return 'in_progress';
    }

    return 'new';
  }

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'resolved':
        return const _StatusInfo(
          color: _success,
          background: Color(0xFFEAF8F0),
          icon: Icons.check_circle_rounded,
        );

      case 'in_progress':
        return const _StatusInfo(
          color: _primaryBlue,
          background: Color(0xFFEAF3FF),
          icon: Icons.autorenew_rounded,
        );

      default:
        return const _StatusInfo(
          color: _warning,
          background: Color(0xFFFFF4DF),
          icon: Icons.fiber_new_rounded,
        );
    }
  }

  String _formatDateTime(AppLocalizations l10n, dynamic value) {
    DateTime? date;

    if (value is Timestamp) {
      date = value.toDate().toLocal();
    } else if (value is DateTime) {
      date = value.toLocal();
    } else if (value is String && value.trim().isNotEmpty) {
      date = DateTime.tryParse(value.trim())?.toLocal();
    }

    if (date == null) {
      return l10n.awaitingUpdate;
    }

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2, '0');

    final amPm = LocaleController.timePeriod(l10n, date.hour);

    return '${date.day} '
        '${LocaleController.monthAbbrev(l10n, date.month)} '
        '${date.year} • '
        '$hour:$minute $amPm';
  }

  String _firstText(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];

      if (value == null) {
        continue;
      }

      final text = value.toString().trim();

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
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
      constraints: const BoxConstraints(minHeight: 79),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              color: Color(0xFFDCEAF8),
              fontSize: 6.8,
              height: 1.1,
              fontWeight: FontWeight.w700,
              letterSpacing: .2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  const _DetailBox({
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
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: _softBlue,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: _primaryBlue, size: 19),
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
                    fontSize: 10.8,
                    height: 1.4,
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

class _StatusInfo {
  const _StatusInfo({
    required this.color,
    required this.background,
    required this.icon,
  });

  final Color color;
  final Color background;
  final IconData icon;
}
