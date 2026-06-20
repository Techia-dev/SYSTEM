import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
}

enum ScreenSize { mobile, tablet, desktop }

ScreenSize getScreenSize(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w < Breakpoints.mobile) return ScreenSize.mobile;
  if (w < Breakpoints.tablet) return ScreenSize.tablet;
  return ScreenSize.desktop;
}

bool isMobile(BuildContext context) => getScreenSize(context) == ScreenSize.mobile;
bool isTablet(BuildContext context) => getScreenSize(context) == ScreenSize.tablet;
bool isDesktop(BuildContext context) => getScreenSize(context) == ScreenSize.desktop;

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize size) builder;
  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) => builder(context, getScreenSize(context));
}

double contentMaxWidth(BuildContext context) {
  final size = getScreenSize(context);
  if (size == ScreenSize.mobile) return double.infinity;
  if (size == ScreenSize.tablet) return 900;
  return 1200;
}

EdgeInsets screenPadding(BuildContext context) {
  final size = getScreenSize(context);
  if (size == ScreenSize.mobile) return const EdgeInsets.all(16);
  if (size == ScreenSize.tablet) return const EdgeInsets.all(24);
  return const EdgeInsets.all(32);
}

int crossAxisCount(BuildContext context) {
  final size = getScreenSize(context);
  if (size == ScreenSize.mobile) return 1;
  if (size == ScreenSize.tablet) return 2;
  return 3;
}
