import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isMediumScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double getResponsiveWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isLargeScreen(context)) return screenWidth * 0.4;
    if (isMediumScreen(context)) return screenWidth * 0.6;
    return screenWidth * 0.9;
  }

  static double getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isLargeScreen(context)) return screenWidth * 0.05;
    if (isMediumScreen(context)) return screenWidth * 0.06;
    return screenWidth * 0.08;
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isSmallScreen(context)) return screenWidth * baseSize * 0.8;
    if (isMediumScreen(context)) return screenWidth * baseSize * 0.9;
    return screenWidth * baseSize;
  }
}
