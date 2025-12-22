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
  
  static double padding(BuildContext context) => 
    isMobile(context) ? 16.0 : isTablet(context) ? 24.0 : 32.0;
  
  static double fontSize(BuildContext context, {
    required double mobile, 
    double? tablet, 
    double? desktop
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}