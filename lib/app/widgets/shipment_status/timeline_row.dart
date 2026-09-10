import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

const Color _primaryBlue = Color(0xFF0B4F9C);
const Color _softBlue = Color(0xFFEAF3FF);
const Color _textDark = Color(0xFF101B2D);
const Color _textGrey = Color(0xFF7E8A9A);

class ShipmentTimelineRow extends StatelessWidget {
  const ShipmentTimelineRow({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.completed,
    required this.active,
    required this.showLine,
    required this.contentBottomPadding,
    required this.icon,
    this.activeColor = _primaryBlue,
  });

  final String title;
  final String description;
  final String time;
  final bool completed;
  final bool active;
  final bool showLine;
  final double contentBottomPadding;
  final IconData icon;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              padding: EdgeInsets.only(bottom: contentBottomPadding, top: 2),
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
                            l10n.currentBadge,
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

const Color _danger = Color(0xFFD72638);

class _FallbackTimelineStage {
  const _FallbackTimelineStage({
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

List<Widget> shipmentFallbackTimeline({
  required AppLocalizations l10n,
  required String status,
  required String lastUpdate,
  required double lastRowBottomPadding,
}) {
  final stages = [
    _FallbackTimelineStage(
      keyName: 'pending',
      title: l10n.timelineCreatedTitle,
      description: l10n.timelineCreatedDesc,
      icon: Icons.inventory_2_outlined,
    ),
    _FallbackTimelineStage(
      keyName: 'confirmed',
      title: l10n.timelineConfirmedTitle,
      description: l10n.timelineConfirmedDesc,
      icon: Icons.verified_outlined,
    ),
    _FallbackTimelineStage(
      keyName: 'prepared',
      title: l10n.timelinePreparedTitle,
      description: l10n.timelinePreparedDesc,
      icon: Icons.fact_check_outlined,
    ),
    _FallbackTimelineStage(
      keyName: 'in_transit',
      title: l10n.timelineInTransitTitle,
      description: l10n.timelineInTransitDesc,
      icon: Icons.local_shipping_outlined,
    ),
    _FallbackTimelineStage(
      keyName: 'customs_clearance',
      title: l10n.timelineCustomsTitle,
      description: l10n.timelineCustomsDesc,
      icon: Icons.gavel_outlined,
    ),
    _FallbackTimelineStage(
      keyName: 'out_for_delivery',
      title: l10n.timelineOutForDeliveryTitle,
      description: l10n.timelineOutForDeliveryDesc,
      icon: Icons.route_outlined,
    ),
    _FallbackTimelineStage(
      keyName: 'delivered',
      title: l10n.timelineDeliveredTitle,
      description: l10n.timelineDeliveredDesc,
      icon: Icons.check_circle_outline_rounded,
    ),
  ];

  if (status == 'cancelled') {
    return [
      ShipmentTimelineRow(
        title: l10n.timelineCancelledTitle,
        description: l10n.timelineCancelledDesc,
        time: l10n.latestUpdate,
        completed: false,
        active: true,
        showLine: false,
        contentBottomPadding: lastRowBottomPadding,
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

    return ShipmentTimelineRow(
      title: stage.title,
      description: stage.description,
      time: active
          ? lastUpdate
          : completed
          ? l10n.completed
          : l10n.waiting,
      completed: completed,
      active: active,
      showLine: !isLast,
      contentBottomPadding: isLast ? lastRowBottomPadding : 18,
      icon: stage.icon,
    );
  });
}
