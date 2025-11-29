import 'package:flutter/material.dart';

/// Animation durations and curves for CyberGuard
class AnimationConstants {
  // ============ DURATIONS ============
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // Page transitions
  static const Duration pageTransition = Duration(milliseconds: 350);
  
  // Card animations
  static const Duration cardHover = Duration(milliseconds: 200);
  static const Duration cardStagger = Duration(milliseconds: 50);
  
  // Loading animations
  static const Duration shimmer = Duration(milliseconds: 1500);
  static const Duration pulse = Duration(milliseconds: 1000);
  
  // ============ CURVES ============
  static const Curve easeInOutSmooth = Curves.easeInOutCubic;
  static const Curve easeInSmooth = Curves.easeInCubic;
  static const Curve easeOutSmooth = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve spring = Curves.elasticInOut;
  
  // ============ SCALE EFFECTS ============
  static const double hoverScaleUp = 1.02;
  static const double pressScale = 0.98;
  static const double pulseScale = 1.05;
  
  // ============ OPACITY ============
  static const double fadeIn = 1.0;
  static const double fadeOut = 0.0;
  static const double halfOpacity = 0.5;
  
  // ============ SLIDE DISTANCES ============
  static const double slideDistance = 30.0;
  static const double slideDistanceSmall = 15.0;
}

