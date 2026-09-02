import 'package:flutter/widgets.dart';

import 'responsive_content.dart';

/// Shared width constraint for feature pages.
///
/// Phone layouts keep their existing spacing, while tablet and desktop
/// layouts remain readable instead of stretching edge to edge.
class FeaturePageBody extends StatelessWidget {
  const FeaturePageBody({
    required this.child,
    super.key,
    this.maxWidth = 900,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ResponsiveContent(
      maxWidth: maxWidth,
      padding: EdgeInsets.zero,
      child: child,
    );
  }
}
