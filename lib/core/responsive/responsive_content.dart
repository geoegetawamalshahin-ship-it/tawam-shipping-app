import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';

/// Keeps phone layouts unchanged while constraining content on tablets/iPad.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    required this.child,
    super.key,
    this.padding,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? AppBreakpoints.contentMaxWidth(context),
        ),
        child: Padding(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: AppBreakpoints.horizontalPadding(context),
              ),
          child: child,
        ),
      ),
    );
  }
}
