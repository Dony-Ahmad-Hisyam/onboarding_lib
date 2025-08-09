import 'package:flutter/material.dart';
import '../models/onboarding_step.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingTooltip extends StatelessWidget {
  final OnboardingController controller;
  final OnboardingStep step;
  final TooltipPosition position;

  const OnboardingTooltip({
    super.key,
    required this.controller,
    required this.step,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    if (step.customTooltip != null) {
      return step.customTooltip!;
    }

    final config = controller.config.tooltipConfig;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Calculate responsive max width with padding
    final horizontalPadding = 32.0; // 16px on each side
    final maxWidth =
        (screenWidth - horizontalPadding).clamp(200.0, config.maxWidth);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: screenHeight * 0.7, // Max 70% of screen height
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (position == TooltipPosition.bottom) _buildArrow(true),
                Container(
                  width: double.infinity,
                  padding: _getResponsivePadding(screenWidth, config.padding),
                  decoration: BoxDecoration(
                    color: config.backgroundColor,
                    borderRadius: BorderRadius.circular(config.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (step.title != null && step.title!.trim().isNotEmpty)
                        Text(
                          step.title!,
                          style: _getResponsiveTitleStyle(screenWidth, config),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (step.title != null && step.title!.trim().isNotEmpty)
                        SizedBox(height: _getResponsiveSpacing(screenWidth, 8)),
                      Text(
                        step.description,
                        style:
                            _getEnhancedDescriptionStyle(screenWidth, config),
                        maxLines: 8,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: _getResponsiveSpacing(screenWidth, 16)),
                      _buildButtons(screenWidth),
                    ],
                  ),
                ),
                if (position == TooltipPosition.top) _buildArrow(false),
              ],
            ),
          ),
        );
      },
    );
  }

  EdgeInsets _getResponsivePadding(
      double screenWidth, EdgeInsets defaultPadding) {
    if (screenWidth < 360) {
      // Small phones
      return const EdgeInsets.all(12);
    } else if (screenWidth < 400) {
      // Medium phones
      return const EdgeInsets.all(16);
    } else {
      // Large phones and tablets
      return defaultPadding;
    }
  }

  TextStyle _getResponsiveTitleStyle(double screenWidth, dynamic config) {
    double fontSize;
    if (screenWidth < 360) {
      fontSize = 16;
    } else if (screenWidth < 400) {
      fontSize = 17;
    } else {
      fontSize = 18;
    }

    return config.titleStyle ??
        TextStyle(
          color: config.textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          height: 1.2,
        );
  }

  TextStyle _getResponsiveDescriptionStyle(double screenWidth, dynamic config) {
    double fontSize;
    if (screenWidth < 360) {
      fontSize = 12;
    } else if (screenWidth < 400) {
      fontSize = 13;
    } else {
      fontSize = 14;
    }

    return config.descriptionStyle ??
        TextStyle(
          color: config.textColor,
          fontSize: fontSize,
          height: 1.4,
        );
  }

  // Enhanced description style for description-first UX
  TextStyle _getEnhancedDescriptionStyle(double screenWidth, dynamic config) {
    double fontSize;
    if (screenWidth < 360) {
      fontSize = 14; // larger than default
    } else if (screenWidth < 400) {
      fontSize = 15;
    } else {
      fontSize = 16; // emphasize description
    }

    final base = _getResponsiveDescriptionStyle(screenWidth, config);
    return base.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.35,
    );
  }

  double _getResponsiveSpacing(double screenWidth, double defaultSpacing) {
    if (screenWidth < 360) {
      return defaultSpacing * 0.75;
    } else if (screenWidth < 400) {
      return defaultSpacing * 0.875;
    } else {
      return defaultSpacing;
    }
  }

  Widget _buildArrow(bool pointingUp) {
    return Container(
      alignment: pointingUp ? Alignment.topCenter : Alignment.bottomCenter,
      child: CustomPaint(
        size: const Size(20, 10),
        painter: ArrowPainter(
          color: controller.config.tooltipConfig.backgroundColor,
          pointingUp: pointingUp,
        ),
      ),
    );
  }

  Widget _buildButtons(double screenWidth) {
    final isSmallScreen = screenWidth < 360;

    return Flex(
      direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment:
          isSmallScreen ? MainAxisAlignment.center : MainAxisAlignment.end,
      children: [
        if (step.canSkip)
          SizedBox(
            width: isSmallScreen ? double.infinity : null,
            child: TextButton(
              onPressed: controller.skip,
              style: TextButton.styleFrom(
                foregroundColor:
                    controller.config.tooltipConfig.textColor.withOpacity(0.7),
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 12,
                  vertical: 8,
                ),
              ),
              child: const Text('Skip'),
            ),
          ),
        if (!isSmallScreen && step.canSkip) const SizedBox(width: 8),
        if (isSmallScreen && step.canSkip) const SizedBox(height: 8),
        SizedBox(
          width: isSmallScreen ? double.infinity : null,
          child: TextButton(
            onPressed: controller.nextStep,
            style: TextButton.styleFrom(
              foregroundColor: controller.config.tooltipConfig.textColor,
              backgroundColor:
                  controller.config.tooltipConfig.textColor.withOpacity(0.1),
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 12,
                vertical: 8,
              ),
            ),
            child: Text(
              controller.currentStepIndex >= controller.config.steps.length - 1
                  ? 'Finish'
                  : 'Next',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ArrowPainter extends CustomPainter {
  final Color color;
  final bool pointingUp;

  ArrowPainter({required this.color, required this.pointingUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (pointingUp) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width / 2, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
