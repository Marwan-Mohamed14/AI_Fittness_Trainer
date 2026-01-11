import 'package:flutter/material.dart';

class Responsive {
  static double screenWidth(BuildContext context) => 
    MediaQuery.of(context).size.width;
  
  static double screenHeight(BuildContext context) => 
    MediaQuery.of(context).size.height;
  
  static bool isMobile(BuildContext context) => 
    screenWidth(context) < 600;
  
  static bool isTablet(BuildContext context) => 
    screenWidth(context) >= 600 && screenWidth(context) < 1200;
  
  static bool isDesktop(BuildContext context) => 
    screenWidth(context) >= 1200;
  
  static bool isLandscape(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.landscape;
  
  static bool isPortrait(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.portrait;
  
  // Responsive padding that adapts to screen size and orientation
  static double padding(BuildContext context) {
    final isLand = isLandscape(context);
    if (isDesktop(context)) return isLand ? 24.0 : 32.0;
    if (isTablet(context)) return isLand ? 20.0 : 24.0;
    return isLand ? 12.0 : 16.0;
  }
  
  // Responsive font size
  static double fontSize(BuildContext context, {
    required double mobile, 
    double? tablet, 
    double? desktop,
    double? mobileLandscape,
    double? tabletLandscape,
  }) {
    final isLand = isLandscape(context);
    
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) {
      if (isLand && tabletLandscape != null) return tabletLandscape;
      return tablet ?? mobile;
    }
    // Mobile
    if (isLand && mobileLandscape != null) return mobileLandscape;
    return mobile;
  }
  
  // Responsive spacing
  static double spacing(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
    double? mobileLandscape,
  }) {
    final isLand = isLandscape(context);
    
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    if (isLand && mobileLandscape != null) return mobileLandscape;
    return mobile;
  }
  
  // Responsive icon size
  static double iconSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
  
  // Responsive border radius
  static double borderRadius(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
  
  // Get column count for grids
  static int getColumnCount(BuildContext context, {
    int mobilePortrait = 1,
    int mobileLandscape = 2,
    int tabletPortrait = 2,
    int tabletLandscape = 3,
    int desktop = 4,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) {
      return isLandscape(context) ? tabletLandscape : tabletPortrait;
    }
    return isLandscape(context) ? mobileLandscape : mobilePortrait;
  }
  
  // Responsive card padding
  static EdgeInsets cardPadding(BuildContext context) {
    final pad = padding(context);
    return EdgeInsets.all(pad);
  }
  
  // Responsive horizontal padding
  static EdgeInsets horizontalPadding(BuildContext context) {
    final pad = padding(context);
    return EdgeInsets.symmetric(horizontal: pad);
  }
  
  // Responsive vertical padding
  static EdgeInsets verticalPadding(BuildContext context) {
    final pad = padding(context);
    return EdgeInsets.symmetric(vertical: pad);
  }
}