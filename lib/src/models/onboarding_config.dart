import 'package:flutter/material.dart';
import 'onboarding_step.dart';

class TooltipConfig {
  final Color backgroundColor;
  final Color textColor;
  final double maxWidth;
  final double borderRadius;
  final double tooltipMargin;
  final EdgeInsets padding;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  // NEW: Global header and bottom bar options
  final bool
      headerAtTop; // show a global header at top instead of near-target tooltip
  final bool showBottomBar; // show Skip/Next bar at bottom edges
  final EdgeInsets bottomBarPadding; // horizontal padding for bottom bar
  final double? headerMaxWidth; // optional max width for header card
  final EdgeInsets headerPadding; // header card padding
  // NEW: Standardized header size & border styling
  final double? headerWidth; // fixed width for uniform header size across steps
  final double headerMinHeight; // minimum height for header card
  final double? headerHeight; // fixed height for header card (overrides min)
  final Color? headerBorderColor; // optional border color
  final double headerBorderWidth; // border width
  final Color? headerBackgroundColor; // header bg override
  final Color? headerTextColor; // header text override
  final double? headerFontSize; // header main text font size
  final EdgeInsets headerOuterMargin; // outer margin for header card

  const TooltipConfig({
    this.backgroundColor = const Color(0xFF333333),
    this.textColor = Colors.white,
    this.maxWidth = 300.0,
    this.borderRadius = 8.0,
    this.tooltipMargin = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.titleStyle,
    this.descriptionStyle,
    this.headerAtTop = false,
    this.showBottomBar = false,
    this.bottomBarPadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
    this.headerMaxWidth,
    this.headerPadding = const EdgeInsets.all(16.0),
    this.headerWidth,
    this.headerMinHeight = 64.0,
    this.headerHeight,
    this.headerBorderColor,
    this.headerBorderWidth = 1.5,
    this.headerBackgroundColor,
    this.headerTextColor,
    this.headerFontSize,
    this.headerOuterMargin = const EdgeInsets.symmetric(horizontal: 12),
  });
}

class OnboardingConfig {
  final List<OnboardingStep> steps;
  final Color overlayColor;
  final double overlayOpacity;
  final double targetPadding;
  final TooltipConfig tooltipConfig;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  final bool debug;

  const OnboardingConfig({
    required this.steps,
    this.overlayColor = Colors.black,
    this.overlayOpacity = 0.8,
    this.targetPadding = 8.0,
    this.tooltipConfig = const TooltipConfig(),
    this.onComplete,
    this.onSkip,
    this.debug = false,
  });
}
