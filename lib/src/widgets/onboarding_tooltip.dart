import 'package:flutter/material.dart';
import '../models/onboarding_step.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingTooltip extends StatelessWidget {
  final OnboardingController controller;
  final OnboardingStep step;
  final TooltipPosition position;

  const OnboardingTooltip({
    Key? key,
    required this.controller,
    required this.step,
    required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (step.customTooltip != null) {
      return step.customTooltip!;
    }

    final config = controller.config.tooltipConfig;
    final arrowSize = 10.0;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: config.maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (position == TooltipPosition.bottom) _buildArrow(true),
          Container(
            padding: config.padding,
            decoration: BoxDecoration(
              color: config.backgroundColor,
              borderRadius: BorderRadius.circular(config.borderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  step.title,
                  style: config.titleStyle ??
                      TextStyle(
                        color: config.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  step.description,
                  style: config.descriptionStyle ??
                      TextStyle(
                        color: config.textColor,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 16),
                _buildButtons(),
              ],
            ),
          ),
          if (position == TooltipPosition.top) _buildArrow(false),
        ],
      ),
    );
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

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (step.canSkip)
          TextButton(
            onPressed: controller.skip,
            style: TextButton.styleFrom(
              foregroundColor: controller.config.tooltipConfig.textColor.withOpacity(0.7),
            ),
            child: const Text('Skip'),
          ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: controller.nextStep,
          style: TextButton.styleFrom(
            foregroundColor: controller.config.tooltipConfig.textColor,
          ),
          child: Text(
            controller.currentStepIndex >= controller.config.steps.length - 1
                ? 'Finish'
                : 'Next',
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