import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../controllers/onboarding_controller.dart';
import '../models/onboarding_step.dart';
import 'onboarding_tooltip.dart';
import '../utils/position_utils.dart';
import 'positioned_hint_icon.dart';
import 'dart:ui' as ui;

class OnboardingOverlay extends StatefulWidget {
  final OnboardingController controller;
  final Widget child;

  const OnboardingOverlay({
    Key? key,
    required this.controller,
    required this.child,
  }) : super(key: key);

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // For continuous drag animation
  AnimationController? _dragAnimationController;
  Animation<double>? _dragAnimation;

  Offset? _dragOffset;
  Offset? _dragStartPosition;
  Offset? _dragDestination;
  bool _isUserDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    widget.controller.addListener(_handleControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerUpdate);
    _animationController.dispose();
    _dragAnimationController?.dispose();
    super.dispose();
  }

  void _handleControllerUpdate() {
    if (widget.controller.isVisible) {
      _animationController.forward();
      _updateDragPositions();
      _setupDragAnimation();
    } else {
      _animationController.reverse();
      _dragAnimationController?.stop();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _updateDragPositions() {
    final step = widget.controller.currentStep;
    if (step.interactionType == InteractionType.dragDrop &&
        step.targetKey.currentContext != null &&
        step.destinationKey?.currentContext != null) {
      final RenderBox sourceBox =
          step.targetKey.currentContext!.findRenderObject() as RenderBox;
      final RenderBox destBox =
          step.destinationKey!.currentContext!.findRenderObject() as RenderBox;

      final sourcePos = sourceBox.localToGlobal(Offset.zero);
      final sourceCenter = Offset(sourcePos.dx + (sourceBox.size.width / 2),
          sourcePos.dy + (sourceBox.size.height / 2));

      final destPos = destBox.localToGlobal(Offset.zero);
      final destCenter = Offset(destPos.dx + (destBox.size.width / 2),
          destPos.dy + (destBox.size.height / 2));

      setState(() {
        _dragStartPosition = sourceCenter;
        _dragDestination = destCenter;
      });
    }
  }

  void _setupDragAnimation() {
    final step = widget.controller.currentStep;
    if (step.interactionType == InteractionType.dragDrop &&
        _dragStartPosition != null &&
        _dragDestination != null) {
      _dragAnimationController?.dispose();

      _dragAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );

      _dragAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _dragAnimationController!,
          curve: Curves.easeInOut,
        ),
      );

      _dragAnimationController!.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_dragAnimationController != null &&
                mounted &&
                !_isUserDragging &&
                widget.controller.isVisible) {
              _dragAnimationController!.reset();
              _dragAnimationController!.forward();
            }
          });
        }
      });

      _dragAnimationController!.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          widget.child,

          // Visual overlay - doesn't interact with touch events
          if (widget.controller.isVisible)
            IgnorePointer(
              child: _buildVisualOverlay(),
            ),

          // Interaction layer - handles gestures but is transparent
          if (widget.controller.isVisible) _buildInteractionLayer(),

          if (widget.controller.isVisible) _buildTooltip(),

          if (widget.controller.isVisible &&
              widget.controller.currentStep.interactionType ==
                  InteractionType.dragDrop &&
              !_isUserDragging)
            _buildDragAnimation(),

          if (_dragOffset != null) _buildUserDragElement(),
        ],
      ),
    );
  }

  Widget _buildDragAnimation() {
    final step = widget.controller.currentStep;
    if (step.targetKey.currentContext == null ||
        step.destinationKey?.currentContext == null ||
        _dragStartPosition == null ||
        _dragDestination == null ||
        _dragAnimation == null ||
        _dragAnimationController == null) {
      return const SizedBox();
    }

    final RenderBox sourceBox =
        step.targetKey.currentContext!.findRenderObject() as RenderBox;
    final sourceSize = sourceBox.size;

    return AnimatedBuilder(
      animation: _dragAnimation!,
      builder: (context, child) {
        final currentPosition = Offset.lerp(
            _dragStartPosition, _dragDestination, _dragAnimation!.value);

        if (currentPosition == null) return const SizedBox();

        return Positioned(
          left: currentPosition.dx - (sourceSize.width / 2),
          top: currentPosition.dy - (sourceSize.height / 2),
          child: Opacity(
            opacity: 0.7,
            child: Container(
              width: sourceSize.width,
              height: sourceSize.height,
              decoration: BoxDecoration(
                color: step.hintIconColor?.withOpacity(0.5) ??
                    Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.hintIconColor ?? Colors.white,
                  width: 2,
                ),
              ),
              child: Center(
                child: step.customIconWidget != null
                    ? SizedBox(
                        width: sourceSize.width * 0.5,
                        height: sourceSize.height * 0.5,
                        child: step.customIconWidget,
                      )
                    : (step.hintImagePath != null
                        ? Image.asset(
                            step.hintImagePath!,
                            package: 'onboarding_lib',
                            color: step.hintIconColor ?? Colors.white,
                            width: sourceSize.width * 0.5,
                            height: sourceSize.height * 0.5,
                            errorBuilder: (ctx, error, _) => Icon(
                              step.hintIcon ?? Icons.touch_app,
                              color: step.hintIconColor ?? Colors.white,
                              size: sourceSize.width * 0.5,
                            ),
                          )
                        : Icon(
                            step.hintIcon ?? Icons.touch_app,
                            color: step.hintIconColor ?? Colors.white,
                            size: sourceSize.width * 0.5,
                          )),
              ),
            ),
          ),
        );
      },
    );
  }

  // This is purely visual - no interaction
  Widget _buildVisualOverlay() {
    final config = widget.controller.config;
    final currentStep = widget.controller.currentStep;

    return RepaintBoundary(
      child: CustomPaint(
        size: Size(MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height),
        painter: CleanCorridorPainter(
          sourceKey: currentStep.targetKey,
          destinationKey:
              currentStep.interactionType == InteractionType.dragDrop
                  ? currentStep.destinationKey
                  : null,
          padding: config.targetPadding,
          overlayColor: config.overlayColor
              .withOpacity(_fadeAnimation.value * config.overlayOpacity),
          corridorWidth: 60.0, // Reduced corridor width
          borderColor:
              currentStep.hintIconColor ?? Colors.red, // Changed to red
          borderWidth: 2.5,
          cornerRadius: 20.0, // Rounded corners radius
        ),
      ),
    );
  }

  // This layer handles all interactions
  Widget _buildInteractionLayer() {
    final currentStep = widget.controller.currentStep;

    if (currentStep.interactionType == InteractionType.dragDrop &&
        currentStep.targetKey.currentContext != null &&
        currentStep.destinationKey?.currentContext != null) {
      return _buildDragDropInteraction(currentStep);
    } else if (currentStep.interactionType == InteractionType.tap &&
        currentStep.targetKey.currentContext != null) {
      return _buildTapInteraction(currentStep);
    }

    return const SizedBox();
  }

  // Handles drag and drop interaction
  Widget _buildDragDropInteraction(OnboardingStep step) {
    if (step.targetKey.currentContext == null ||
        step.destinationKey?.currentContext == null) {
      return const SizedBox();
    }

    final RenderBox sourceBox =
        step.targetKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox destBox =
        step.destinationKey!.currentContext!.findRenderObject() as RenderBox;

    final sourcePos = sourceBox.localToGlobal(Offset.zero);
    final sourceSize = sourceBox.size;

    final destPos = destBox.localToGlobal(Offset.zero);
    final destSize = destBox.size;

    // Create a screen-sized widget to intercept all gestures
    return Positioned.fill(
      child: Stack(
        children: [
          // Source element hit area
          Positioned(
            left: sourcePos.dx,
            top: sourcePos.dy,
            width: sourceSize.width,
            height: sourceSize.height,
            child: GestureDetector(
              behavior: HitTestBehavior
                  .opaque, // This is crucial for capturing gestures
              onPanStart: (details) {
                setState(() {
                  _dragOffset = details.globalPosition;
                  _isUserDragging = true;
                  _dragAnimationController?.stop();
                });
                widget.controller.startDrag(details.globalPosition);
              },
              onPanUpdate: (details) {
                if (_isUserDragging) {
                  setState(() {
                    _dragOffset = details.globalPosition;
                  });
                  widget.controller.updateDrag(details.globalPosition);
                }
              },
              onPanEnd: (details) {
                if (_isUserDragging) {
                  // Check if dragged element is over the destination
                  final Rect destRect = Rect.fromLTWH(
                    destPos.dx,
                    destPos.dy,
                    destSize.width,
                    destSize.height,
                  ).inflate(20); // Add padding for easier drop

                  final bool success;
                  if (_dragOffset != null && destRect.contains(_dragOffset!)) {
                    // Successfully dragged to destination
                    success = true;
                    // Go to the next step after successful drag
                    Future.delayed(const Duration(milliseconds: 300), () {
                      widget.controller.nextStep();
                    });
                  } else {
                    success = widget.controller
                        .completeDrag(_dragOffset ?? Offset.zero);
                  }

                  if (!success) {
                    setState(() {
                      _dragOffset = null;
                      _isUserDragging = false;
                      _dragAnimationController?.forward();
                    });
                  }
                }
              },
              onPanCancel: () {
                setState(() {
                  _dragOffset = null;
                  _isUserDragging = false;
                  _dragAnimationController?.forward();
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: step.customIconWidget ??
                      Icon(
                        step.hintIcon ?? Icons.touch_app,
                        color: step.hintIconColor ?? Colors.white,
                        size:
                            math.min(sourceSize.width, sourceSize.height) * 0.5,
                      ),
                ),
              ),
            ),
          ),

          // Destination element indicator
          Positioned(
            left: destPos.dx,
            top: destPos.dy,
            width: destSize.width,
            height: destSize.height,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Icon(
                  Icons.add_circle_outline,
                  color: step.hintIconColor ?? Colors.white,
                  size: math.min(destSize.width, destSize.height) * 0.5,
                ),
              ),
            ),
          ),

          // Arrow indicator in the middle
          Positioned(
            left: (sourcePos.dx +
                        sourceSize.width / 2 +
                        destPos.dx +
                        destSize.width / 2) /
                    2 -
                15,
            top: (sourcePos.dy +
                        sourceSize.height / 2 +
                        destPos.dy +
                        destSize.height / 2) /
                    2 -
                15,
            child: Icon(
              Icons.arrow_forward,
              color: step.hintIconColor ?? Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // Handles tap interaction
  Widget _buildTapInteraction(OnboardingStep step) {
    if (step.targetKey.currentContext == null) return const SizedBox();

    final RenderBox box =
        step.targetKey.currentContext!.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    final padding = widget.controller.config.targetPadding;

    return Positioned(
      left: position.dx - padding,
      top: position.dy - padding,
      width: size.width + (padding * 2),
      height: size.height + (padding * 2),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.controller.handleTap();
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: PositionedHintIcon(
              position: step.iconPosition,
              color: step.hintIconColor ?? Colors.white,
              size: math.min(size.width, size.height) * 0.6,
              icon: step.hintIcon ?? Icons.touch_app,
              imagePath: step.hintImagePath,
              customWidget: step.customIconWidget,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTooltip() {
    final step = widget.controller.currentStep;
    final targetContext = step.targetKey.currentContext;

    if (targetContext == null) return const SizedBox();

    final RenderBox box = targetContext.findRenderObject() as RenderBox;
    final targetPosition = box.localToGlobal(Offset.zero);
    final targetSize = box.size;
    final screenSize = MediaQuery.of(context).size;

    // Calculate safe area to avoid notches and system UI
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final EdgeInsets safeArea = mediaQuery.padding;
    final double statusBarHeight = safeArea.top;
    final double bottomSafeArea = safeArea.bottom;

    // Available space for tooltip
    final double availableWidth =
        screenSize.width - 32; // 16px margin on each side
    final double availableHeight =
        screenSize.height - statusBarHeight - bottomSafeArea - 32;

    // Calculate tooltip dimensions (estimate)
    final double estimatedTooltipWidth = math.min(
        widget.controller.config.tooltipConfig.maxWidth, availableWidth);

    // Estimate tooltip height based on content (rough calculation)
    final double estimatedTooltipHeight =
        math.min(200.0, availableHeight * 0.4);

    // Calculate optimal position
    final tooltipPosition = _calculateOptimalTooltipPosition(
      targetPosition: targetPosition,
      targetSize: targetSize,
      tooltipSize: Size(estimatedTooltipWidth, estimatedTooltipHeight),
      screenSize: screenSize,
      safeArea: safeArea,
      step: step,
    );

    return Positioned(
      left: tooltipPosition.dx,
      top: tooltipPosition.dy,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, _) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: availableWidth,
                maxHeight: availableHeight,
              ),
              child: OnboardingTooltip(
                controller: widget.controller,
                step: step,
                position: _determineTooltipPosition(
                  targetPosition: targetPosition,
                  tooltipPosition: tooltipPosition,
                  screenSize: screenSize,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Offset _calculateOptimalTooltipPosition({
    required Offset targetPosition,
    required Size targetSize,
    required Size tooltipSize,
    required Size screenSize,
    required EdgeInsets safeArea,
    required OnboardingStep step,
  }) {
    final double margin = 16.0;
    final double spacing = 12.0; // Space between target and tooltip

    // Target center
    final Offset targetCenter = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    // Available areas
    final double leftSpace = targetPosition.dx - margin;
    final double rightSpace =
        screenSize.width - (targetPosition.dx + targetSize.width) - margin;
    final double topSpace = targetPosition.dy - safeArea.top - margin;
    final double bottomSpace = screenSize.height -
        (targetPosition.dy + targetSize.height) -
        safeArea.bottom -
        margin;

    double tooltipX = 0;
    double tooltipY = 0;

    // Priority order: bottom, top, right, left
    if (bottomSpace >= tooltipSize.height + spacing) {
      // Position below target
      tooltipY = targetPosition.dy + targetSize.height + spacing;
      tooltipX = _calculateHorizontalPosition(
          targetCenter.dx, tooltipSize.width, screenSize.width, margin);
    } else if (topSpace >= tooltipSize.height + spacing) {
      // Position above target
      tooltipY = targetPosition.dy - tooltipSize.height - spacing;
      tooltipX = _calculateHorizontalPosition(
          targetCenter.dx, tooltipSize.width, screenSize.width, margin);
    } else if (rightSpace >= tooltipSize.width + spacing) {
      // Position to the right
      tooltipX = targetPosition.dx + targetSize.width + spacing;
      tooltipY = _calculateVerticalPosition(targetCenter.dy, tooltipSize.height,
          screenSize.height, safeArea, margin);
    } else if (leftSpace >= tooltipSize.width + spacing) {
      // Position to the left
      tooltipX = targetPosition.dx - tooltipSize.width - spacing;
      tooltipY = _calculateVerticalPosition(targetCenter.dy, tooltipSize.height,
          screenSize.height, safeArea, margin);
    } else {
      // Fallback: position in available space with scrolling
      if (bottomSpace > topSpace) {
        tooltipY = targetPosition.dy + targetSize.height + spacing;
      } else {
        tooltipY = math.max(safeArea.top + margin,
            targetPosition.dy - tooltipSize.height - spacing);
      }

      tooltipX = _calculateHorizontalPosition(
          targetCenter.dx, tooltipSize.width, screenSize.width, margin);
    }

    // Ensure tooltip stays within screen bounds
    tooltipX =
        tooltipX.clamp(margin, screenSize.width - tooltipSize.width - margin);
    tooltipY = tooltipY.clamp(safeArea.top + margin,
        screenSize.height - safeArea.bottom - tooltipSize.height - margin);

    return Offset(tooltipX, tooltipY);
  }

  double _calculateHorizontalPosition(double targetCenterX, double tooltipWidth,
      double screenWidth, double margin) {
    // Try to center on target
    double x = targetCenterX - (tooltipWidth / 2);

    // Adjust if goes outside screen bounds
    if (x < margin) {
      x = margin;
    } else if (x + tooltipWidth > screenWidth - margin) {
      x = screenWidth - tooltipWidth - margin;
    }

    return x;
  }

  double _calculateVerticalPosition(double targetCenterY, double tooltipHeight,
      double screenHeight, EdgeInsets safeArea, double margin) {
    // Try to center on target
    double y = targetCenterY - (tooltipHeight / 2);

    // Adjust if goes outside screen bounds
    final double minY = safeArea.top + margin;
    final double maxY = screenHeight - safeArea.bottom - tooltipHeight - margin;

    return y.clamp(minY, maxY);
  }

  TooltipPosition _determineTooltipPosition({
    required Offset targetPosition,
    required Offset tooltipPosition,
    required Size screenSize,
  }) {
    if (tooltipPosition.dy > targetPosition.dy) {
      return TooltipPosition.bottom;
    } else {
      return TooltipPosition.top;
    }
  }

  Widget _buildUserDragElement() {
    if (_dragOffset == null) return const SizedBox();

    final step = widget.controller.currentStep;
    final targetContext = step.targetKey.currentContext;

    if (targetContext == null) return const SizedBox();

    final RenderBox box = targetContext.findRenderObject() as RenderBox;
    final targetSize = box.size;

    return Positioned(
      left: _dragOffset!.dx - (targetSize.width / 2),
      top: _dragOffset!.dy - (targetSize.height / 2),
      width: targetSize.width,
      height: targetSize.height,
      child: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: Container(
            decoration: BoxDecoration(
              color: (step.hintIconColor ?? Colors.white).withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: step.hintIconColor ?? Colors.white,
                width: 2,
              ),
            ),
            child: Center(
              child: step.customIconWidget != null
                  ? SizedBox(
                      width: targetSize.width * 0.5,
                      height: targetSize.height * 0.5,
                      child: step.customIconWidget,
                    )
                  : (step.hintImagePath != null
                      ? Image.asset(
                          step.hintImagePath!,
                          package: 'onboarding_lib',
                          color: step.hintIconColor ?? Colors.white,
                          width: targetSize.width * 0.5,
                          height: targetSize.height * 0.5,
                          errorBuilder: (ctx, error, _) => Icon(
                            step.hintIcon ?? Icons.touch_app,
                            color: step.hintIconColor ?? Colors.white,
                            size: targetSize.width * 0.5,
                          ),
                        )
                      : Icon(
                          step.hintIcon ?? Icons.touch_app,
                          color: step.hintIconColor ?? Colors.white,
                          size: targetSize.width * 0.5,
                        )),
            ),
          ),
        ),
      ),
    );
  }
}

class CleanCorridorPainter extends CustomPainter {
  final GlobalKey sourceKey;
  final GlobalKey? destinationKey;
  final double padding;
  final double corridorWidth;
  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;
  final double cornerRadius;

  CleanCorridorPainter({
    required this.sourceKey,
    this.destinationKey,
    required this.padding,
    this.corridorWidth = 60.0,
    required this.overlayColor,
    this.borderColor = Colors.red,
    this.borderWidth = 2.0,
    this.cornerRadius = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // For single target (tap interaction)
    if (destinationKey == null) {
      _paintSingleTarget(canvas, size);
      return;
    }

    // For drag-drop corridor
    _paintDragPathCorridor(canvas, size);
  }

  void _paintSingleTarget(Canvas canvas, Size size) {
    // Get the source target box
    final RenderBox? sourceBox =
        sourceKey.currentContext?.findRenderObject() as RenderBox?;
    if (sourceBox == null) return;

    final sourcePos = sourceBox.localToGlobal(Offset.zero);
    final sourceRect = Rect.fromLTWH(
      sourcePos.dx - padding,
      sourcePos.dy - padding,
      sourceBox.size.width + (padding * 2),
      sourceBox.size.height + (padding * 2),
    );

    // Create a rounded rect path for the target
    final targetPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        sourceRect,
        Radius.circular(cornerRadius),
      ));

    // Create a full screen path
    final fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a path that represents the darkened overlay area
    final overlayPath = Path.combine(
      PathOperation.difference,
      fullScreenPath,
      targetPath,
    );

    // Draw the darkened overlay
    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, overlayPaint);

    // Draw border around the target
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(
      RRect.fromRectAndRadius(sourceRect, Radius.circular(cornerRadius)),
      borderPaint,
    );
  }

  void _paintDragPathCorridor(Canvas canvas, Size size) {
    // Get source and destination boxes
    final RenderBox? sourceBox =
        sourceKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? destBox =
        destinationKey?.currentContext?.findRenderObject() as RenderBox?;

    if (sourceBox == null || destBox == null) return;

    final sourcePos = sourceBox.localToGlobal(Offset.zero);
    final sourceSize = sourceBox.size;

    final destPos = destBox.localToGlobal(Offset.zero);
    final destSize = destBox.size;

    // Calculate centers
    final sourceCenter = Offset(
      sourcePos.dx + sourceSize.width / 2,
      sourcePos.dy + sourceSize.height / 2,
    );

    final destCenter = Offset(
      destPos.dx + destSize.width / 2,
      destPos.dy + destSize.height / 2,
    );

    // Calculate angle between centers
    final angle = math.atan2(
      destCenter.dy - sourceCenter.dy,
      destCenter.dx - sourceCenter.dx,
    );

    // Create direction vector and perpendicular vector
    final direction = Offset(math.cos(angle), math.sin(angle));
    final perpendicular = Offset(-direction.dy, direction.dx);

    // Calculate elements corner points to create a thin corridor
    final elementRadius = math.min(
        30.0,
        math.min(
              math.min(sourceSize.width, sourceSize.height),
              math.min(destSize.width, destSize.height),
            ) /
            2);

    // Calculate narrower corridor width - just enough to include the elements
    final pathWidth = math.max(
        elementRadius * 2, corridorWidth / 2 // Make the corridor much narrower
        );

    // Create a path that follows from source to destination with minimal width
    final halfWidth = pathWidth / 2; // Half width for the corridor

    // Find the source element's edge point in the direction of dest
    final sourceEdgeOffset =
        direction * (elementRadius + 5); // Add small padding
    final destEdgeOffset = direction * (elementRadius + 5);

    // Calculate four corners of the corridor - using the edge points of elements
    final p1 = sourceCenter + perpendicular * halfWidth - sourceEdgeOffset;
    final p2 = destCenter + perpendicular * halfWidth + destEdgeOffset;
    final p3 = destCenter - perpendicular * halfWidth + destEdgeOffset;
    final p4 = sourceCenter - perpendicular * halfWidth - sourceEdgeOffset;

    // Create path
    final path = Path();
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.lineTo(p4.dx, p4.dy);
    path.close();

    // Create a path that includes both elements to ensure they're visible
    final sourceRect =
        Rect.fromCircle(center: sourceCenter, radius: elementRadius + 5);
    final destRect =
        Rect.fromCircle(center: destCenter, radius: elementRadius + 5);

    final sourcePath = Path()..addOval(sourceRect);

    final destPath = Path()..addOval(destRect);

    // Combine the paths
    final corridorPath = Path.combine(
      PathOperation.union,
      Path.combine(PathOperation.union, path, sourcePath),
      destPath,
    );

    // Create a full screen path
    final fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a path that represents the darkened overlay area
    final overlayPath = Path.combine(
      PathOperation.difference,
      fullScreenPath,
      corridorPath,
    );

    // Draw the darkened overlay
    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, overlayPaint);

    // Draw corridor border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(corridorPath, borderPaint);

    // Add direction arrow
    final midPoint = Offset(
      (sourceCenter.dx + destCenter.dx) / 2,
      (sourceCenter.dy + destCenter.dy) / 2,
    );

    final arrowSize = 12.0;

    // Draw arrow
    final arrowPath = Path();
    final arrowTip = midPoint + direction * arrowSize;
    final arrowBack = midPoint - direction * (arrowSize * 0.5);
    final arrowSide1 = arrowTip - direction.rotate(math.pi / 4) * arrowSize;
    final arrowSide2 = arrowTip - direction.rotate(-math.pi / 4) * arrowSize;

    arrowPath.moveTo(arrowTip.dx, arrowTip.dy);
    arrowPath.lineTo(arrowSide1.dx, arrowSide1.dy);
    arrowPath.lineTo(arrowBack.dx, arrowBack.dy);
    arrowPath.lineTo(arrowSide2.dx, arrowSide2.dy);
    arrowPath.close();

    final arrowPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CleanCorridorPainter oldDelegate) {
    return oldDelegate.overlayColor != overlayColor ||
        oldDelegate.corridorWidth != corridorWidth ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.cornerRadius != cornerRadius;
  }
}

extension VectorUtils on Offset {
  Offset normalized() {
    final magnitude = distance;
    if (magnitude == 0) return Offset.zero;
    return this / magnitude;
  }

  Offset rotate(double radians) {
    final cos = math.cos(radians);
    final sin = math.sin(radians);
    return Offset(dx * cos - dy * sin, dx * sin + dy * cos);
  }

  operator /(double operand) => Offset(dx / operand, dy / operand);

  operator *(double operand) => Offset(dx * operand, dy * operand);

  operator -(Offset other) => Offset(dx - other.dx, dy - other.dy);

  operator +(Offset other) => Offset(dx + other.dx, dy + other.dy);
}
