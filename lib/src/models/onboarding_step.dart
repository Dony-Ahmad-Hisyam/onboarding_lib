import 'package:flutter/material.dart';
import '../widgets/positioned_hint_icon.dart'; // Import IconPosition

enum InteractionType {
  tap,
  dragDrop,
  custom,
}

enum TooltipPosition {
  top,
  bottom,
  left,
  right,
  auto,
}

class OnboardingStep {
  /// The unique identifier for this step
  final String id;

  /// The GlobalKey of the widget to highlight
  final GlobalKey targetKey;

  /// Optional destination key for drag operations
  final GlobalKey? destinationKey;

  /// The interaction type required to complete this step
  final InteractionType interactionType;

  /// Title text to display in the tooltip
  final String title;

  /// Description text to display in the tooltip
  final String description;

  /// Position of the tooltip relative to the target (top, bottom, left, right)
  final TooltipPosition position;

  /// Position of the hint icon within the target (center, topLeft, etc.)
  final IconPosition iconPosition;

  /// Optional custom widget to show instead of default tooltip
  final Widget? customTooltip;

  /// Optional animation duration for tooltip appearance
  final Duration animationDuration;

  /// Callback that will be called when this step is shown
  final VoidCallback? onShow;

  /// Callback that will be called when this step is completed
  final VoidCallback? onComplete;

  /// Whether this step can be skipped
  final bool canSkip;

  /// Custom hint icon to use (defaults to touch_app for tap and drag for dragDrop)
  final IconData? hintIcon;

  /// Image path for custom hint icon
  final String? hintImagePath;

  /// Custom widget to use as the hint icon
  final Widget? customIconWidget;

  /// Color for the hint icon
  final Color? hintIconColor;

  const OnboardingStep({
    required this.id,
    required this.targetKey,
    required this.title,
    required this.description,
    this.destinationKey,
    this.interactionType = InteractionType.tap,
    this.position = TooltipPosition.auto,
    this.iconPosition = IconPosition.center, // Default ke posisi tengah
    this.customTooltip,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onShow,
    this.onComplete,
    this.canSkip = true,
    this.hintIcon,
    this.hintImagePath,
    this.customIconWidget,
    this.hintIconColor,
  });
}
