import 'package:flutter/widgets.dart';

abstract final class AppBreakpoints {
  static const double tablet = 600;
  static const double desktop = 1024;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tablet && width < desktop;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktop) return 48;
    if (width >= tablet) return 32;
    return 20;
  }

  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktop) return 1120;
    if (width >= tablet) return 840;
    return width;
  }
}
