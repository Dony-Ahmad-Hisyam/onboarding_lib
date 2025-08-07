import 'package:flutter/material.dart';
import '../models/onboarding_step.dart';

class PositionUtils {
  static Offset calculateTooltipPosition({
    required Offset targetPosition,
    required Size targetSize,
    required Size tooltipSize,
    required Size screenSize,
    required TooltipPosition position,
    double margin = 16.0,
  }) {
    final double targetCenterX = targetPosition.dx + (targetSize.width / 2);
    final double targetCenterY = targetPosition.dy + (targetSize.height / 2);

    TooltipPosition actualPosition = position;
    if (position == TooltipPosition.auto) {
      // Choose the best position based on available space
      final spaceAbove = targetPosition.dy;
      final spaceBelow =
          screenSize.height - (targetPosition.dy + targetSize.height);
      final spaceLeft = targetPosition.dx;
      final spaceRight =
          screenSize.width - (targetPosition.dx + targetSize.width);

      final Map<TooltipPosition, double> spaces = {
        TooltipPosition.top: spaceAbove,
        TooltipPosition.bottom: spaceBelow,
        TooltipPosition.left: spaceLeft,
        TooltipPosition.right: spaceRight,
      };

      actualPosition =
          spaces.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    switch (actualPosition) {
      case TooltipPosition.top:
        return Offset(
          targetCenterX - (tooltipSize.width / 2),
          targetPosition.dy - tooltipSize.height - margin,
        );
      case TooltipPosition.bottom:
        return Offset(
          targetCenterX - (tooltipSize.width / 2),
          targetPosition.dy + targetSize.height + margin,
        );
      case TooltipPosition.left:
        return Offset(
          targetPosition.dx - tooltipSize.width - margin,
          targetCenterY - (tooltipSize.height / 2),
        );
      case TooltipPosition.right:
        return Offset(
          targetPosition.dx + targetSize.width + margin,
          targetCenterY - (tooltipSize.height / 2),
        );
      case TooltipPosition.auto:
        // This case is handled above, but needed for the switch to compile
        return Offset.zero;
    }
  }

  static TooltipPosition determineTooltipPosition({
    required Offset targetPosition,
    required Size targetSize,
    required Offset tooltipPosition,
  }) {
    final double targetCenterY = targetPosition.dy + (targetSize.height / 2);
    final double targetCenterX = targetPosition.dx + (targetSize.width / 2);

    if (tooltipPosition.dy < targetPosition.dy) {
      return TooltipPosition.top;
    } else if (tooltipPosition.dy > targetPosition.dy + targetSize.height) {
      return TooltipPosition.bottom;
    } else if (tooltipPosition.dx < targetPosition.dx) {
      return TooltipPosition.left;
    } else {
      return TooltipPosition.right;
    }
  }
}
