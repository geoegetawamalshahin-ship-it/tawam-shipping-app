import 'package:flutter/material.dart';

class ResponsiveAppFrame extends StatelessWidget {
  const ResponsiveAppFrame({
    required this.child,
    super.key,
  });

  static const double tabletBreakpoint = 600;
  static const double maxContentWidth = 900;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletBreakpoint) {
          return child;
        }

        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
