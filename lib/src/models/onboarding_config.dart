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

  const TooltipConfig({
    this.backgroundColor = const Color(0xFF333333),
    this.textColor = Colors.white,
    this.maxWidth = 300.0,
    this.borderRadius = 8.0,
    this.tooltipMargin = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.titleStyle,
    this.descriptionStyle,
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
