import 'package:flutter/material.dart';

import '../controllers/onboarding_controller.dart';
import '../models/onboarding_config.dart';
import '../models/onboarding_step.dart';
import '../widgets/onboarding_overlay.dart';
import '../widgets/positioned_hint_icon.dart';

// Convenience builders to make onboarding calls simple and consistent

OnboardingStep tapStep({
  required String id,
  required GlobalKey targetKey,
  required String title,
  required String description,
  TooltipPosition position = TooltipPosition.auto,
  IconPosition iconPosition = IconPosition.center,
  IconData icon = Icons.touch_app,
  Color iconColor = const Color(0xFF6750A4),
  bool canSkip = true,
  VoidCallback? onShow,
  VoidCallback? onComplete,
}) {
  return OnboardingStep(
    id: id,
    targetKey: targetKey,
    title: title,
    description: description,
    interactionType: InteractionType.tap,
    position: position,
    iconPosition: iconPosition,
    hintIcon: icon,
    hintIconColor: iconColor,
    canSkip: canSkip,
    onShow: onShow,
    onComplete: onComplete,
  );
}

/// Generic dragStep that only cares about keys (works for any payload type)
OnboardingStep dragStep({
  required String id,
  required GlobalKey sourceKey,
  required GlobalKey destinationKey,
  required String title,
  required String description,
  TooltipPosition position = TooltipPosition.top,
  DragTooltipAnchor anchor = DragTooltipAnchor.destination,
  IconPosition iconPosition = IconPosition.center,
  Color iconColor = const Color(0xFF6750A4),
  bool canSkip = true,
  VoidCallback? onShow,
  VoidCallback? onComplete,
}) {
  return OnboardingStep(
    id: id,
    targetKey: sourceKey,
    destinationKey: destinationKey,
    title: title,
    description: description,
    interactionType: InteractionType.dragDrop,
    position: position,
    dragTooltipAnchor: anchor,
    iconPosition: iconPosition,
    hintIconColor: iconColor,
    canSkip: canSkip,
    onShow: onShow,
    onComplete: onComplete,
  );
}

OnboardingController ob({
  required List<OnboardingStep> steps,
  Color overlayColor = Colors.black,
  double overlayOpacity = 0.7,
  double targetPadding = 8.0,
  TooltipConfig tooltip = const TooltipConfig(
    backgroundColor: Color(0xFF6750A4),
    textColor: Colors.white,
    maxWidth: 320,
    padding: EdgeInsets.all(16),
  ),
  VoidCallback? onComplete,
}) {
  return OnboardingController(
    config: OnboardingConfig(
      steps: steps,
      overlayColor: overlayColor,
      overlayOpacity: overlayOpacity,
      targetPadding: targetPadding,
      tooltipConfig: tooltip,
      onComplete: onComplete,
    ),
  );
}

extension OnboardingOverlayX on Widget {
  Widget withOnboarding(OnboardingController controller) =>
      OnboardingOverlay(controller: controller, child: this);
}
