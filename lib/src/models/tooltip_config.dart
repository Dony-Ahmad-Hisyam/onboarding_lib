import 'package:flutter/material.dart';

class TooltipConfig {
  /// Background color for tooltips
  final Color backgroundColor;

  /// Text color for tooltips
  final Color textColor;

  /// Text style for the title
  final TextStyle titleStyle;

  /// Text style for the description
  final TextStyle descriptionStyle;

  /// Border radius for tooltips
  final double borderRadius;

  /// Padding inside tooltips
  final EdgeInsets padding;

  /// Distance between tooltip and target
  final double tooltipMargin;

  /// Width constraints for tooltips
  final double maxWidth;

  /// Arrow size for tooltips
  final double arrowSize;

  /// Next button text
  final String nextButtonText;

  /// Skip button text
  final String skipButtonText;

  /// Button theme for next/skip buttons
  final ButtonStyle? buttonStyle;

  /// Whether to show progress indicator
  final bool showProgress;

  const TooltipConfig({
    this.backgroundColor = const Color(0xFF6750A4),
    this.textColor = Colors.white,
    this.titleStyle = const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
    ),
    this.descriptionStyle = const TextStyle(
      fontSize: 14.0,
    ),
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(16.0),
    this.tooltipMargin = 12.0,
    this.maxWidth = 300.0,
    this.arrowSize = 10.0,
    this.nextButtonText = "Next",
    this.skipButtonText = "Skip",
    this.buttonStyle,
    this.showProgress = true,
  });
}
