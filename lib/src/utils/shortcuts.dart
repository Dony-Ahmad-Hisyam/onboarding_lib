import 'package:flutter/material.dart';

import '../controllers/onboarding_controller.dart';
import '../models/onboarding_config.dart';
import '../models/onboarding_step.dart';
import '../widgets/onboarding_overlay.dart';
import '../widgets/positioned_hint_icon.dart';
import 'onboarding_key_store.dart';

// Convenience builders to make onboarding calls simple and consistent

OnboardingStep tapStep({
  required String id,
  required GlobalKey targetKey,
  String? title,
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

/// ID-based variation of tapStep that resolves the GlobalKey from OnboardingKeyStore
OnboardingStep tapStepById({
  required String id,
  required String targetId,
  String? title,
  required String description,
  TooltipPosition position = TooltipPosition.auto,
  IconPosition iconPosition = IconPosition.center,
  IconData icon = Icons.touch_app,
  Color iconColor = const Color(0xFF6750A4),
  bool canSkip = true,
  VoidCallback? onShow,
  VoidCallback? onComplete,
}) {
  final key = OnboardingKeyStore.instance.key(targetId);
  return tapStep(
    id: id,
    targetKey: key,
    title: title,
    description: description,
    position: position,
    iconPosition: iconPosition,
    icon: icon,
    iconColor: iconColor,
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
  String? title,
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

/// ID-based variation of dragStep that resolves the GlobalKeys from OnboardingKeyStore
OnboardingStep dragStepById({
  required String id,
  required String sourceId,
  required String destinationId,
  String? title,
  required String description,
  TooltipPosition position = TooltipPosition.top,
  DragTooltipAnchor anchor = DragTooltipAnchor.destination,
  IconPosition iconPosition = IconPosition.center,
  Color iconColor = const Color(0xFF6750A4),
  bool canSkip = true,
  VoidCallback? onShow,
  VoidCallback? onComplete,
}) {
  final store = OnboardingKeyStore.instance;
  return dragStep(
    id: id,
    sourceKey: store.key(sourceId),
    destinationKey: store.key(destinationId),
    title: title,
    description: description,
    position: position,
    anchor: anchor,
    iconPosition: iconPosition,
    iconColor: iconColor,
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
    headerAtTop: true,
    showBottomBar: true,
    // Kid-friendly header defaults (let width be flexible)
    headerMinHeight: 68,
    headerBackgroundColor: Color(0xFFB5F5C9),
    headerTextColor: Color(0xFF0D1B2A),
    headerFontSize: 18,
    headerPadding: EdgeInsets.all(15),
    headerOuterMargin: EdgeInsets.symmetric(horizontal: 12),
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
