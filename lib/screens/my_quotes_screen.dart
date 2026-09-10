import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/widgets/connection_error_panel.dart';
import '../app/widgets/list_empty_card.dart';
import '../app/widgets/list_filter_bar.dart';
import '../app/widgets/soft_back_header.dart';
import '../controllers/quote_controller.dart';
import '../l10n/app_localizations.dart';
import '../locale_controller.dart';

class MyQuotesScreen extends StatefulWidget {
  const MyQuotesScreen({super.key, this.initialQuoteId});

  final String? initialQuoteId;

  @override
  State<MyQuotesScreen> createState() => _MyQuotesScreenState();
}

class _MyQuotesScreenState extends State<MyQuotesScreen> {
  final QuoteController _quoteController = Get.find<QuoteController>();

  static const Color deepBlue = Color(0xFF062B55);
  static const Color primaryBlue = Color(0xFF0B4F9C);
  static const Color pageBg = Color(0xFFF4F7FB);
  static const Color softBlue = Color(0xFFEAF3FF);
  static const Color textDark = Color(0xFF101B2D);
  static const Color textGrey = Color(0xFF7E8A9A);
  static const Color border = Color(0xFFE2E8F0);

  String _filter = 'all';
  bool _openedInitialQuote = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = _quoteController.currentUser;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: user == null
                  ? Center(
                      child: Text(
                        l10n.pleaseSignInToViewQuotes,
                        style: const TextStyle(
                          color: textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _quoteController.watchQuoteRequests(user.uid),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return _buildError();
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: primaryBlue,
                            ),
                          );
                        }

                        final docs = [...?snapshot.data?.docs];

                        docs.sort((a, b) {
                          final aDate = _date(a.data()['createdAt']);
                          final bDate = _date(b.data()['createdAt']);
                          return bDate.compareTo(aDate);
                        });
                        final initialQuoteId = widget.initialQuoteId?.trim();

                        if (!_openedInitialQuote &&
                            initialQuoteId != null &&
                            initialQuoteId.isNotEmpty) {
                          QueryDocumentSnapshot<Map<String, dynamic>>?
                          matchingDoc;

                          for (final doc in docs) {
                            if (doc.id == initialQuoteId) {
                              matchingDoc = doc;
                              break;
                            }
                          }

                          final quoteDoc = matchingDoc;

                          if (quoteDoc != null) {
                            _openedInitialQuote = true;

                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;

                              _showQuoteDetails(quoteDoc);
                            });
                          }
                        }

                        return _buildContent(docs);
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
    return SoftBackHeader(
      title: l10n.myQuotes,
      subtitle: l10n.tawamAlShahinTransport,
      trailingIcon: Icons.request_quote_outlined,
      onBack: () => Navigator.pop(context),
      height: 84,
      shadowColor: deepBlue,
      shadowAlpha: .06,
      shadowBlur: 22,
      shadowOffset: const Offset(0, 7),
      borderColor: border,
      backIconColor: deepBlue,
      titleColor: textDark,
      titleFontWeight: FontWeight.w800,
      subtitleColor: primaryBlue,
      subtitleFontSize: 9.5,
      subtitleFontWeight: FontWeight.w700,
      trailingBackground: softBlue,
      trailingIconColor: primaryBlue,
    );
  }

  Widget _buildContent(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final l10n = AppLocalizations.of(context)!;
    final waitingCount = docs.where((doc) => !_hasPrice(doc.data())).length;
    final quotedCount = docs.where((doc) => _hasPrice(doc.data())).length;

    final filtered = docs.where((doc) {
      final data = doc.data();
      final decision = _text(data['customerDecision']).toLowerCase();

      switch (_filter) {
        case 'waiting':
          return !_hasPrice(data);
        case 'quoted':
          return _hasPrice(data) && decision.isEmpty;
        case 'accepted':
          return decision == 'accepted';
        case 'declined':
          return decision == 'declined';
        default:
          return true;
      }
    }).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
      children: [
        _buildHero(),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _summaryBox(
                icon: Icons.receipt_long_outlined,
                value: '${docs.length}',
                label: l10n.total,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _summaryBox(
                icon: Icons.hourglass_bottom_rounded,
                value: '$waitingCount',
                label: l10n.waiting,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _summaryBox(
                icon: Icons.price_check_outlined,
                value: '$quotedCount',
                label: l10n.quoted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          l10n.yourQuotations,
          style: const TextStyle(
            color: textDark,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          l10n.reviewRatesSubtitle,
          style: const TextStyle(color: textGrey, fontSize: 11.5, height: 1.4),
        ),
        const SizedBox(height: 15),
        _buildFilters(),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          _buildEmpty()
        else
          ...filtered.map(
            (doc) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: _buildQuoteCard(doc),
            ),
          ),
      ],
    );
  }

  Widget _buildHero() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [deepBlue, Color(0xFF0A4B8F), Color(0xFF1268BC)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: deepBlue.withValues(alpha: .16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -30,
            child: Icon(
              Icons.public_rounded,
              size: 145,
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
                    size: 21,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.secureCustomerPortal,
                    style: const TextStyle(
                      color: Color(0xFFD8E8F7),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .9,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                l10n.yourShippingQuotations,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.trackEveryQuotation,
                style: const TextStyle(
                  color: Color(0xFFD6E5F4),
                  fontSize: 12,
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

  Widget _summaryBox({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: primaryBlue, size: 22),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: textGrey,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final l10n = AppLocalizations.of(context)!;
    return ListFilterBar(
      items: [
        ListFilterItem(value: 'all', label: l10n.all),
        ListFilterItem(value: 'waiting', label: l10n.waiting),
        ListFilterItem(value: 'quoted', label: l10n.quoted),
        ListFilterItem(value: 'accepted', label: l10n.accepted),
        ListFilterItem(value: 'declined', label: l10n.declined),
      ],
      selectedValue: _filter,
      onSelected: (value) {
        setState(() {
          _filter = value;
        });
      },
      height: 39,
      useSeparatedList: true,
      animationDuration: const Duration(milliseconds: 180),
      chipPadding: const EdgeInsets.symmetric(horizontal: 15),
      chipAlignment: Alignment.center,
      selectedColor: primaryBlue,
      unselectedBorderColor: border,
      unselectedTextColor: textGrey,
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
    );
  }

  Widget _buildQuoteCard(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final l10n = AppLocalizations.of(context)!;
    final data = doc.data();
    final status = _text(data['status']).trim().toLowerCase();
    final serviceRaw = _fallback(data['serviceType'], '');
    final service = _serviceDisplay(l10n, serviceRaw);
    final quoteNumber = _fallback(data['quoteNumber'], l10n.quotations);
    final from = _fallback(data['from'], l10n.origin);
    final to = _fallback(data['to'], l10n.destination);
    final decision = _text(data['customerDecision']).toLowerCase();
    final hasPrice = _hasPrice(data);
    final currency = _fallback(data['currency'], 'AED');
    final price = _toDouble(data['quotedPrice']);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showQuoteDetails(doc),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: deepBlue.withValues(alpha: .04),
                blurRadius: 16,
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
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: softBlue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(_serviceIcon(serviceRaw), color: primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quoteNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service,
                          style: const TextStyle(
                            color: textGrey,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(
                    hasPrice: hasPrice,
                    decision: decision,
                    status: status,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(child: _routePoint(l10n.from, from)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: primaryBlue,
                        size: 18,
                      ),
                    ),
                    Expanded(child: _routePoint(l10n.to, to, alignEnd: true)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: hasPrice
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.quotedPrice,
                                style: const TextStyle(
                                  color: textGrey,
                                  fontSize: 8.8,
                                  letterSpacing: .65,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$currency ${_formatMoney(price)}',
                                style: const TextStyle(
                                  color: deepBlue,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.rateStatus,
                                style: const TextStyle(
                                  color: textGrey,
                                  fontSize: 8.8,
                                  letterSpacing: .65,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _quoteStatusText(
                                  hasPrice: hasPrice,
                                  decision: decision,
                                  status: status,
                                ),
                                style: const TextStyle(
                                  color: textDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: softBlue,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: primaryBlue,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _routePoint(String label, String value, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textGrey,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: textDark,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge({
    required bool hasPrice,
    required String decision,
    required String status,
  }) {
    Color bg;
    Color fg;
    final text = _quoteStatusText(
      hasPrice: hasPrice,
      decision: decision,
      status: status,
    );

    if (decision == 'accepted' || status == 'completed') {
      bg = const Color(0xFFEAF8F0);
      fg = const Color(0xFF16765C);
    } else if (decision == 'declined' || status == 'cancelled') {
      bg = const Color(0xFFFFECEC);
      fg = const Color(0xFFD72638);
    } else if (status == 'in_progress' || status == 'quoted' || hasPrice) {
      bg = softBlue;
      fg = primaryBlue;
    } else {
      bg = const Color(0xFFFFF6E5);
      fg = const Color(0xFFB26A00);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 9, fontWeight: FontWeight.w800),
      ),
    );
  }

  String _quoteStatusText({
    required bool hasPrice,
    required String decision,
    required String status,
  }) {
    final l10n = AppLocalizations.of(context)!;

    if (decision == 'accepted') return l10n.accepted;
    if (decision == 'declined') return l10n.declined;

    switch (status) {
      case 'in_progress':
        return l10n.statusInProgress;
      case 'quoted':
        return l10n.quoteReady;
      case 'completed':
        return l10n.completed;
      case 'cancelled':
        return l10n.statusCancelled;
      case 'new':
        return l10n.underReview;
      default:
        return hasPrice ? l10n.quoteReady : l10n.underReview;
    }
  }

  void _showQuoteDetails(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final hasPrice = _hasPrice(data);
    final currency = _fallback(data['currency'], 'AED');
    final price = _toDouble(data['quotedPrice']);
    final decision = _text(data['customerDecision']).toLowerCase();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: .88,
          minChildSize: .62,
          maxChildSize: .95,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: pageBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 9),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2D8E0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                      children: [
                        _quoteHeader(data),
                        const SizedBox(height: 16),
                        hasPrice
                            ? _pricePanel(
                                currency,
                                price,
                                _text(data['adminNote']),
                              )
                            : _waitingPanel(),
                        const SizedBox(height: 16),
                        _detailsPanel(data),
                        const SizedBox(height: 18),
                        if (hasPrice && decision.isEmpty)
                          _decisionButtons(sheetContext, doc)
                        else if (decision.isNotEmpty)
                          _decisionResult(decision),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _quoteHeader(Map<String, dynamic> data) {
    final l10n = AppLocalizations.of(context)!;
    final serviceRaw = _fallback(data['serviceType'], '');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [deepBlue, primaryBlue]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tawamAlShahinTransport,
            style: const TextStyle(
              color: Color(0xFFD5E5F4),
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _fallback(data['quoteNumber'], l10n.quotation),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _serviceDisplay(l10n, serviceRaw),
            style: const TextStyle(
              color: Color(0xFFD6E5F4),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _headerRoute(
                  l10n.from,
                  _fallback(data['from'], l10n.origin),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 19,
              ),
              Expanded(
                child: _headerRoute(
                  l10n.to,
                  _fallback(data['to'], l10n.destination),
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerRoute(String label, String value, {bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFBFD3E7),
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _pricePanel(String currency, double price, String adminNote) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quotedPrice,
            style: const TextStyle(
              color: textGrey,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$currency ${_formatMoney(price)}',
            style: const TextStyle(
              color: deepBlue,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (adminNote.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: border),
            const SizedBox(height: 12),
            Text(
              l10n.messageFromOurTeam,
              style: const TextStyle(
                color: textGrey,
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .75,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              adminNote.trim(),
              style: const TextStyle(
                color: textDark,
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _waitingPanel() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF4E4B9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_bottom_rounded, color: Color(0xFFB26A00)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.quoteTeamReviewing,
              style: const TextStyle(
                color: Color(0xFF7B5A12),
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsPanel(Map<String, dynamic> data) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.shipmentDetails,
            style: const TextStyle(
              color: textDark,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          _detailRow(
            l10n.cargoType,
            LocaleController.displayOption(
              l10n,
              _text(data['cargoType']),
              emptyLabel: l10n.notProvided,
            ),
          ),
          _detailRow(l10n.weight, '${_fallback(data['weightKg'], '—')} KG'),
          _detailRow(l10n.quantity, _fallback(data['quantity'], '—')),
          _detailRow(l10n.dimensions, _dimensions(data)),
          _detailRow(l10n.pickupDate, _formatDate(data['pickupDate'])),
          _detailRow(l10n.requestedOn, _formatDate(data['createdAt'])),
          _detailRow(
            l10n.additionalNotes,
            _text(data['notes']).trim().isEmpty
                ? l10n.noAdditionalNotes
                : _text(data['notes']),
            last: true,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool last = false}) {
    return Container(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      margin: EdgeInsets.only(bottom: last ? 0 : 12),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFEEF2F6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: textGrey,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: textDark,
                fontSize: 11,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decisionButtons(
    BuildContext sheetContext,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () => _confirmDecision(sheetContext, doc, 'accepted'),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(
              l10n.acceptQuote,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: .4,
              ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: deepBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () => _confirmDecision(sheetContext, doc, 'declined'),
            icon: const Icon(Icons.close_rounded),
            label: Text(
              l10n.declineQuote,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFB32635),
              side: const BorderSide(color: Color(0xFFE7B8BE)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDecision(
    BuildContext sheetContext,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String decision,
  ) async {
    final accepted = decision == 'accepted';
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            accepted
                ? l10n.acceptQuotationQuestion
                : l10n.declineQuotationQuestion,
            style: const TextStyle(
              color: textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            accepted
                ? l10n.confirmAcceptQuotation
                : l10n.confirmDeclineQuotation,
            style: const TextStyle(color: textGrey, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: accepted ? deepBlue : const Color(0xFFB32635),
                foregroundColor: Colors.white,
              ),
              child: Text(accepted ? l10n.accept : l10n.decline),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _quoteController.updateCustomerDecision(doc.reference, decision);

      if (!mounted) return;

      if (sheetContext.mounted) {
        Navigator.pop(sheetContext);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: deepBlue,
          content: Text(
            accepted
                ? l10n.quotationAccepted
                : l10n.quotationDeclined,
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF9D2732),
          content: Text(
            error.message ?? l10n.unableToUpdateQuoteDecision,
          ),
        ),
      );
    }
  }

  Widget _decisionResult(String decision) {
    final l10n = AppLocalizations.of(context)!;
    final accepted = decision == 'accepted';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: accepted ? const Color(0xFFEAF8F0) : const Color(0xFFFFECEC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            accepted ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: accepted ? const Color(0xFF16765C) : const Color(0xFFD72638),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              accepted
                  ? l10n.youAcceptedQuotation
                  : l10n.youDeclinedQuotation,
              style: TextStyle(
                color: accepted
                    ? const Color(0xFF135B47)
                    : const Color(0xFFA51D2C),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final l10n = AppLocalizations.of(context)!;
    return ListEmptyCard(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 38),
      borderColor: border,
      icon: Icons.request_quote_outlined,
      iconColor: primaryBlue,
      iconSize: 42,
      afterIconGap: 14,
      title: l10n.noQuotationsYet,
      titleColor: textDark,
      titleFontWeight: FontWeight.w800,
      afterTitleGap: 7,
      body: l10n.quotationsEmptyBody,
      bodyColor: textGrey,
      bodyFontSize: 11,
      bodyHeight: 1.4,
    );
  }

  Widget _buildError() {
    final l10n = AppLocalizations.of(context)!;
    return ConnectionErrorPanel(
      title: l10n.unableToLoadQuotations,
      body: l10n.pleaseCheckConnectionTryAgain,
      retryLabel: l10n.tryAgain,
      onRetry: () {
        setState(() {});
      },
      borderColor: border,
      titleColor: textDark,
      bodyColor: textGrey,
      accentColor: primaryBlue,
    );
  }

  String _serviceDisplay(AppLocalizations l10n, String raw) {
    if (raw.trim().isEmpty) return l10n.shippingService;
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

  bool _hasPrice(Map<String, dynamic> data) {
    return _toDouble(data['quotedPrice']) > 0;
  }

  IconData _serviceIcon(String service) {
    final value = service.toLowerCase();

    if (value.contains('sea')) {
      return Icons.directions_boat_filled_outlined;
    }
    if (value.contains('air')) {
      return Icons.flight_rounded;
    }
    if (value.contains('car')) {
      return Icons.directions_car_filled_outlined;
    }
    if (value.contains('moving')) {
      return Icons.home_work_outlined;
    }
    if (value.contains('parcel')) {
      return Icons.inventory_2_outlined;
    }

    return Icons.local_shipping_outlined;
  }

  DateTime _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _formatDate(dynamic value) {
    final l10n = AppLocalizations.of(context)!;
    final date = _date(value);

    if (date.millisecondsSinceEpoch == 0) {
      return l10n.notProvided;
    }

    return '${date.day} ${LocaleController.monthAbbrev(l10n, date.month)} ${date.year}';
  }

  String _dimensions(Map<String, dynamic> data) {
    final l10n = AppLocalizations.of(context)!;
    final l = _text(data['lengthCm']).trim();
    final w = _text(data['widthCm']).trim();
    final h = _text(data['heightCm']).trim();

    if (l.isEmpty && w.isEmpty && h.isEmpty) {
      return l10n.notProvided;
    }

    return '${l.isEmpty ? '—' : l} × '
        '${w.isEmpty ? '—' : w} × '
        '${h.isEmpty ? '—' : h} CM';
  }

  String _formatMoney(double value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final digits = parts[0];
    final decimal = parts[1];

    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }

    return '${buffer.toString()}.$decimal';
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _fallback(dynamic value, String fallback) {
    final text = _text(value).trim();
    return text.isEmpty ? fallback : text;
  }

  String _text(dynamic value) {
    return value?.toString() ?? '';
  }
}
