import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../controllers/onboarding_controller.dart';
import '../models/onboarding_step.dart';
import 'onboarding_tooltip.dart';
import 'positioned_hint_icon.dart';

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

      // Clean up previous drag state when switching steps
      if (widget.controller.currentStep.interactionType !=
          InteractionType.dragDrop) {
        _dragAnimationController?.stop();
        _dragAnimationController?.reset();
        setState(() {
          _dragOffset = null;
          _isUserDragging = false;
          _dragStartPosition = null;
          _dragDestination = null;
        });
      } else {
        _updateDragPositions();
        _setupDragAnimation();
      }
    } else {
      _animationController.reverse();
      _dragAnimationController?.stop();
      _dragAnimationController?.reset();
      setState(() {
        _dragOffset = null;
        _isUserDragging = false;
        _dragStartPosition = null;
        _dragDestination = null;
      });
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
                widget.controller.isVisible &&
                widget.controller.currentStep.interactionType ==
                    InteractionType.dragDrop &&
                widget.controller.currentStep.id == step.id) {
              // Check if still on same step
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

          // Visual overlay - show immediately when controller is visible
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
              !_isUserDragging &&
              _dragAnimationController != null &&
              !_dragAnimationController!.isDismissed)
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
                        width: math.max(
                            24.0,
                            sourceSize.width *
                                0.6), // Increased from 0.5 to 0.6 with minimum 24px
                        height: math.max(24.0, sourceSize.height * 0.6),
                        child: step.customIconWidget,
                      )
                    : (step.hintImagePath != null
                        ? Image.asset(
                            step.hintImagePath!,
                            package: 'onboarding_lib',
                            color: step.hintIconColor ?? Colors.white,
                            width: math.max(24.0, sourceSize.width * 0.6),
                            height: math.max(24.0, sourceSize.height * 0.6),
                            errorBuilder: (ctx, error, _) => Icon(
                              step.hintIcon ?? Icons.touch_app,
                              color: step.hintIconColor ?? Colors.white,
                              size: math.max(24.0, sourceSize.width * 0.6),
                            ),
                          )
                        : Icon(
                            step.hintIcon ?? Icons.touch_app,
                            color: step.hintIconColor ?? Colors.white,
                            size: math.max(
                                24.0,
                                sourceSize.width *
                                    0.6), // Increased from 0.5 to 0.6 with minimum 24px
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: CleanCorridorPainter(
              sourceKey: currentStep.targetKey,
              destinationKey:
                  currentStep.interactionType == InteractionType.dragDrop
                      ? currentStep.destinationKey
                      : null,
              padding: config.targetPadding,
              overlayColor:
                  config.overlayColor.withOpacity(config.overlayOpacity),
              corridorWidth: 60.0, // Reduced corridor width
              borderColor: currentStep.hintIconColor ??
                  Colors.amber, // Changed to amber for better visibility
              borderWidth: 3.0, // Increased border width
              cornerRadius: 20.0, // Rounded corners radius
            ),
          );
        },
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
                    // Clean up drag state immediately
                    setState(() {
                      _dragOffset = null;
                      _isUserDragging = false;
                      _dragAnimationController?.stop();
                      _dragAnimationController?.reset();
                    });
                    // Go to the next step after successful drag
                    Future.delayed(const Duration(milliseconds: 300), () {
                      widget.controller.nextStep();
                    });
                  } else {
                    success = widget.controller
                        .completeDrag(_dragOffset ?? Offset.zero);

                    // Clean up drag state regardless of success
                    setState(() {
                      _dragOffset = null;
                      _isUserDragging = false;
                      if (!success) {
                        _dragAnimationController?.forward();
                      }
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
                  // Only show the static hint icon when not animating and not dragging
                  child: (() {
                    final bool showSourceHintIcon = !_isUserDragging &&
                        (_dragAnimationController == null ||
                            _dragAnimationController!.isDismissed);
                    if (!showSourceHintIcon) return const SizedBox.shrink();
                    return step.customIconWidget ??
                        Icon(
                          step.hintIcon ?? Icons.touch_app,
                          color: step.hintIconColor ?? Colors.white,
                          size: math.max(
                              32.0,
                              math.min(sourceSize.width, sourceSize.height) *
                                  0.7), // Increased from 0.5 to 0.7 with minimum 32px
                        );
                  })(),
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
                  size: math.max(
                      28.0,
                      math.min(destSize.width, destSize.height) *
                          0.6), // Increased from 0.5 to 0.6 with minimum 28px
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
              size: math.max(
                  40.0,
                  math.min(size.width, size.height) *
                      0.8), // Increased from 0.6 to 0.8 with minimum 40px
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
    // Determine which element to anchor the tooltip to (for arrow/orientation)
    BuildContext? targetContext = step.targetKey.currentContext;
    if (step.interactionType == InteractionType.dragDrop &&
        step.dragTooltipAnchor == DragTooltipAnchor.destination &&
        step.destinationKey?.currentContext != null) {
      targetContext = step.destinationKey!.currentContext;
    }

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

    // Allow dev to anchor tooltip near source or destination for drag & drop
    if (step.interactionType == InteractionType.dragDrop &&
        step.destinationKey?.currentContext != null &&
        step.targetKey.currentContext != null &&
        step.dragTooltipAnchor != DragTooltipAnchor.auto) {
      final RenderBox srcBox =
          step.targetKey.currentContext!.findRenderObject() as RenderBox;
      final RenderBox dstBox =
          step.destinationKey!.currentContext!.findRenderObject() as RenderBox;
      final Offset srcPos = srcBox.localToGlobal(Offset.zero);
      final Size srcSize = srcBox.size;
      final Offset dstPos = dstBox.localToGlobal(Offset.zero);
      final Size dstSize = dstBox.size;

      if (step.dragTooltipAnchor == DragTooltipAnchor.destination) {
        targetPosition = dstPos;
        targetSize = dstSize;
      } else {
        targetPosition = srcPos;
        targetSize = srcSize;
      }
    }

    // Target center AFTER any anchor override
    final Offset targetCenter = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

    // Available areas computed AFTER any anchor override
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

    // Determine best position based on available space and step preference
    TooltipPosition preferredPosition = step.position;

    // NEW: For drag & drop, allow dev to anchor tooltip near source or destination
    if (step.interactionType == InteractionType.dragDrop &&
        step.destinationKey?.currentContext != null &&
        step.targetKey.currentContext != null &&
        step.dragTooltipAnchor != DragTooltipAnchor.auto) {
      final RenderBox srcBox =
          step.targetKey.currentContext!.findRenderObject() as RenderBox;
      final RenderBox dstBox =
          step.destinationKey!.currentContext!.findRenderObject() as RenderBox;
      final Offset srcPos = srcBox.localToGlobal(Offset.zero);
      final Size srcSize = srcBox.size;
      final Offset dstPos = dstBox.localToGlobal(Offset.zero);
      final Size dstSize = dstBox.size;

      // Override targetPosition/size based on anchor preference
      if (step.dragTooltipAnchor == DragTooltipAnchor.destination) {
        targetPosition = dstPos;
        targetSize = dstSize;
      } else {
        targetPosition = srcPos;
        targetSize = srcSize;
      }

      // Recompute dependent values for anchored target
      final Offset anchoredCenter = Offset(
        targetPosition.dx + targetSize.width / 2,
        targetPosition.dy + targetSize.height / 2,
      );
      // Replace local copies
      // ignore: unused_local_variable
      final _ = anchoredCenter; // keep analyzer happy for structure
    }

    // Position based on determined optimal position
    switch (preferredPosition) {
      case TooltipPosition.bottom:
        tooltipY = targetPosition.dy + targetSize.height + spacing;
        tooltipX = _calculateHorizontalPosition(
            targetCenter.dx, tooltipSize.width, screenSize.width, margin);
        break;
      case TooltipPosition.top:
        tooltipY = targetPosition.dy - tooltipSize.height - spacing;
        tooltipX = _calculateHorizontalPosition(
            targetCenter.dx, tooltipSize.width, screenSize.width, margin);
        break;
      case TooltipPosition.right:
        tooltipX = targetPosition.dx + targetSize.width + spacing;
        tooltipY = _calculateVerticalPosition(targetCenter.dy,
            tooltipSize.height, screenSize.height, safeArea, margin);
        break;
      case TooltipPosition.left:
        tooltipX = targetPosition.dx - tooltipSize.width - spacing;
        tooltipY = _calculateVerticalPosition(targetCenter.dy,
            tooltipSize.height, screenSize.height, safeArea, margin);
        break;
      case TooltipPosition.auto:
        // Auto positioning - choose the best available space
        if (bottomSpace >= tooltipSize.height + spacing) {
          tooltipY = targetPosition.dy + targetSize.height + spacing;
          tooltipX = _calculateHorizontalPosition(
              targetCenter.dx, tooltipSize.width, screenSize.width, margin);
        } else if (topSpace >= tooltipSize.height + spacing) {
          tooltipY = targetPosition.dy - tooltipSize.height - spacing;
          tooltipX = _calculateHorizontalPosition(
              targetCenter.dx, tooltipSize.width, screenSize.width, margin);
        } else if (rightSpace >= tooltipSize.width + spacing) {
          tooltipX = targetPosition.dx + targetSize.width + spacing;
          tooltipY = _calculateVerticalPosition(targetCenter.dy,
              tooltipSize.height, screenSize.height, safeArea, margin);
        } else {
          tooltipX = targetPosition.dx - tooltipSize.width - spacing;
          tooltipY = _calculateVerticalPosition(targetCenter.dy,
              tooltipSize.height, screenSize.height, safeArea, margin);
        }
        break;
    }

    // Ensure tooltip stays within screen bounds with more robust clamping
    final double minX = margin;
    final double maxX = screenSize.width - tooltipSize.width - margin;
    final double minY = safeArea.top + margin;
    final double maxY =
        screenSize.height - safeArea.bottom - tooltipSize.height - margin;

    tooltipX = tooltipX.clamp(minX, maxX.isNaN ? minX : maxX);
    tooltipY = tooltipY.clamp(minY, maxY.isNaN ? minY : maxY);

    // --- NEW (generic): Avoid covering the highlighted target ---
    final Rect targetRect = Rect.fromLTWH(
      targetPosition.dx,
      targetPosition.dy,
      targetSize.width,
      targetSize.height,
    ).inflate(8);
    Rect tooltipRect = Rect.fromLTWH(
        tooltipX, tooltipY, tooltipSize.width, tooltipSize.height);

    if (tooltipRect.overlaps(targetRect)) {
      // Rank candidate positions by available space
      final candidates = <MapEntry<TooltipPosition, double>>[
        MapEntry(TooltipPosition.bottom, bottomSpace),
        MapEntry(TooltipPosition.top, topSpace),
        MapEntry(TooltipPosition.right, rightSpace),
        MapEntry(TooltipPosition.left, leftSpace),
      ]..sort((a, b) => b.value.compareTo(a.value));

      Offset? nonOverlap;
      for (final entry in candidates) {
        late Offset test;
        switch (entry.key) {
          case TooltipPosition.bottom:
            test = Offset(
              _calculateHorizontalPosition(
                  targetCenter.dx, tooltipSize.width, screenSize.width, margin),
              targetPosition.dy + targetSize.height + spacing,
            );
            break;
          case TooltipPosition.top:
            test = Offset(
              _calculateHorizontalPosition(
                  targetCenter.dx, tooltipSize.width, screenSize.width, margin),
              targetPosition.dy - tooltipSize.height - spacing,
            );
            break;
          case TooltipPosition.right:
            test = Offset(
              targetPosition.dx + targetSize.width + spacing,
              _calculateVerticalPosition(targetCenter.dy, tooltipSize.height,
                  screenSize.height, safeArea, margin),
            );
            break;
          case TooltipPosition.left:
            test = Offset(
              targetPosition.dx - tooltipSize.width - spacing,
              _calculateVerticalPosition(targetCenter.dy, tooltipSize.height,
                  screenSize.height, safeArea, margin),
            );
            break;
          case TooltipPosition.auto:
            test = Offset(tooltipX, tooltipY);
            break;
        }

        final double cx = test.dx.clamp(minX, maxX.isNaN ? minX : maxX);
        final double cy = test.dy.clamp(minY, maxY.isNaN ? minY : maxY);
        final Rect testRect =
            Rect.fromLTWH(cx, cy, tooltipSize.width, tooltipSize.height);
        if (!testRect.overlaps(targetRect)) {
          nonOverlap = Offset(cx, cy);
          break;
        }
      }

      // Resolve final position; if no better candidate, keep current
      if (nonOverlap != null) {
        tooltipX = nonOverlap.dx;
        tooltipY = nonOverlap.dy;
      }
    }

    // --- NEW: Avoid covering the highlight/corridor on drag & drop ---
    if (step.interactionType == InteractionType.dragDrop &&
        step.destinationKey?.currentContext != null &&
        step.targetKey.currentContext != null) {
      final RenderBox srcBox =
          step.targetKey.currentContext!.findRenderObject() as RenderBox;
      final RenderBox dstBox =
          step.destinationKey!.currentContext!.findRenderObject() as RenderBox;

      final Offset srcPos = srcBox.localToGlobal(Offset.zero);
      final Size srcSize = srcBox.size;
      final Offset dstPos = dstBox.localToGlobal(Offset.zero);
      final Size dstSize = dstBox.size;

      final Offset srcCenter =
          Offset(srcPos.dx + srcSize.width / 2, srcPos.dy + srcSize.height / 2);
      final Offset dstCenter =
          Offset(dstPos.dx + dstSize.width / 2, dstPos.dy + dstSize.height / 2);

      // Corridor as a bounding box around the center line between src & dst
      final Rect lineBounds = Rect.fromPoints(srcCenter, dstCenter);
      // Make corridor avoidance thicker so tooltip keeps a safe distance
      final double corridorThickness = 120.0; // px (increased)
      final Rect corridorRect = lineBounds.inflate(corridorThickness / 2);

      // Also avoid overlapping exact source & destination targets
      final Rect srcRect =
          Rect.fromLTWH(srcPos.dx, srcPos.dy, srcSize.width, srcSize.height)
              .inflate(8);
      final Rect dstRect =
          Rect.fromLTWH(dstPos.dx, dstPos.dy, dstSize.width, dstSize.height)
              .inflate(8);

      // Inflate tooltip rect a bit to account for arrow and layout diffs
      Rect currentTooltipRect = Rect.fromLTWH(
              tooltipX, tooltipY, tooltipSize.width, tooltipSize.height)
          .inflate(12);

      bool overlaps = currentTooltipRect.overlaps(corridorRect) ||
          currentTooltipRect.overlaps(srcRect) ||
          currentTooltipRect.overlaps(dstRect);

      // If anchored to destination and tooltip sits completely above destination,
      // allow it even if it intersects the corridor rectangle (to honor UX request)
      final bool anchoredToDestination =
          step.dragTooltipAnchor == DragTooltipAnchor.destination;
      final bool tooltipAboveDest =
          currentTooltipRect.bottom <= dstPos.dy - 4; // small gap
      if (anchoredToDestination && tooltipAboveDest) {
        // Ignore corridor overlap in this case
        overlaps = currentTooltipRect.overlaps(srcRect) ||
            currentTooltipRect.overlaps(dstRect);
      }

      if (overlaps) {
        // Try alternative positions that do not intersect the drag path or nodes
        List<TooltipPosition> candidates = [
          // Prefer TOP first to keep tooltip above destination
          TooltipPosition.top,
          TooltipPosition.bottom,
          TooltipPosition.left,
          TooltipPosition.right,
        ];

        // Prefer placing perpendicular to the drag direction
        final bool isMostlyHorizontal = (dstCenter.dx - srcCenter.dx).abs() >=
            (dstCenter.dy - srcCenter.dy).abs();
        if (isMostlyHorizontal) {
          candidates = [
            TooltipPosition.top,
            TooltipPosition.bottom,
            TooltipPosition.left,
            TooltipPosition.right
          ];
        } else {
          candidates = [
            // Still prefer left/right for vertical drags, but keep top after
            TooltipPosition.left,
            TooltipPosition.right,
            TooltipPosition.top,
            TooltipPosition.bottom
          ];
        }

        Offset? nonOverlap;
        final double extraSpacing = spacing + 12; // push a bit further away
        for (final candidate in candidates) {
          Offset test;
          switch (candidate) {
            case TooltipPosition.top:
              test = Offset(
                _calculateHorizontalPosition(targetCenter.dx, tooltipSize.width,
                    screenSize.width, margin),
                targetPosition.dy - tooltipSize.height - extraSpacing,
              );
              break;
            case TooltipPosition.bottom:
              test = Offset(
                _calculateHorizontalPosition(targetCenter.dx, tooltipSize.width,
                    screenSize.width, margin),
                targetPosition.dy + targetSize.height + extraSpacing,
              );
              break;
            case TooltipPosition.left:
              test = Offset(
                targetPosition.dx - tooltipSize.width - extraSpacing,
                _calculateVerticalPosition(targetCenter.dy, tooltipSize.height,
                    screenSize.height, safeArea, margin),
              );
              break;
            case TooltipPosition.right:
              test = Offset(
                targetPosition.dx + targetSize.width + extraSpacing,
                _calculateVerticalPosition(targetCenter.dy, tooltipSize.height,
                    screenSize.height, safeArea, margin),
              );
              break;
            case TooltipPosition.auto:
              test = Offset(tooltipX, tooltipY);
              break;
          }

          // Clamp and re-check
          final double cx = test.dx.clamp(minX, maxX.isNaN ? minX : maxX);
          final double cy = test.dy.clamp(minY, maxY.isNaN ? minY : maxY);
          final Rect testRect =
              Rect.fromLTWH(cx, cy, tooltipSize.width, tooltipSize.height)
                  .inflate(12);
          bool candidateOverlaps = testRect.overlaps(corridorRect);
          if (anchoredToDestination &&
              (cy + tooltipSize.height) <= dstPos.dy - 4) {
            // If candidate is above destination, ignore corridor overlap
            candidateOverlaps = false;
          }

          if (!candidateOverlaps &&
              !testRect.overlaps(srcRect) &&
              !testRect.overlaps(dstRect)) {
            nonOverlap = Offset(cx, cy);
            break;
          }
        }

        // If nothing works, push the tooltip away from corridor along the
        // perpendicular direction by a small offset
        if (nonOverlap == null) {
          final double push = corridorThickness + 24; // stronger push
          if (isMostlyHorizontal) {
            // Push above or below depending on available space
            final tryUp = (targetPosition.dy - safeArea.top) >
                (screenSize.height - (targetPosition.dy + targetSize.height));
            final double proposedY = tryUp
                ? (targetPosition.dy - tooltipSize.height - extraSpacing - push)
                : (targetPosition.dy + targetSize.height + extraSpacing + push);
            final double cy = proposedY.clamp(minY, maxY.isNaN ? minY : maxY);
            final double cx = _calculateHorizontalPosition(targetCenter.dx,
                    tooltipSize.width, screenSize.width, margin)
                .clamp(minX, maxX.isNaN ? minX : maxX);
            nonOverlap = Offset(cx, cy);
          } else {
            // Push left or right
            final tryLeft = targetPosition.dx >
                (screenSize.width - (targetPosition.dx + targetSize.width));
            final double proposedX = tryLeft
                ? (targetPosition.dx - tooltipSize.width - extraSpacing - push)
                : (targetPosition.dx + targetSize.width + extraSpacing + push);
            final double cx = proposedX.clamp(minX, maxX.isNaN ? minX : maxX);
            final double cy = _calculateVerticalPosition(targetCenter.dy,
                    tooltipSize.height, screenSize.height, safeArea, margin)
                .clamp(minY, maxY.isNaN ? minY : maxY);
            nonOverlap = Offset(cx, cy);
          }
        }

        // After trying candidates and fallback, nonOverlap must be set
        tooltipX = nonOverlap.dx;
        tooltipY = nonOverlap.dy;

        // Final safety: clamp again
        tooltipX = tooltipX.clamp(minX, maxX.isNaN ? minX : maxX);
        tooltipY = tooltipY.clamp(minY, maxY.isNaN ? minY : maxY);
      }
    }

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
    // Determine relative position of tooltip to target
    final double tolerance = 20.0; // Tolerance for position determination

    if (tooltipPosition.dy > targetPosition.dy + tolerance) {
      return TooltipPosition.bottom;
    } else if (tooltipPosition.dy < targetPosition.dy - tolerance) {
      return TooltipPosition.top;
    } else if (tooltipPosition.dx > targetPosition.dx + tolerance) {
      return TooltipPosition.right;
    } else if (tooltipPosition.dx < targetPosition.dx - tolerance) {
      return TooltipPosition.left;
    } else {
      return TooltipPosition.auto;
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
                      width: math.max(
                          24.0,
                          targetSize.width *
                              0.6), // Increased from 0.5 to 0.6 with minimum 24px
                      height: math.max(24.0, targetSize.height * 0.6),
                      child: step.customIconWidget,
                    )
                  : (step.hintImagePath != null
                      ? Image.asset(
                          step.hintImagePath!,
                          package: 'onboarding_lib',
                          color: step.hintIconColor ?? Colors.white,
                          width: math.max(24.0, targetSize.width * 0.6),
                          height: math.max(24.0, targetSize.height * 0.6),
                          errorBuilder: (ctx, error, _) => Icon(
                            step.hintIcon ?? Icons.touch_app,
                            color: step.hintIconColor ?? Colors.white,
                            size: math.max(24.0, targetSize.width * 0.6),
                          ),
                        )
                      : Icon(
                          step.hintIcon ?? Icons.touch_app,
                          color: step.hintIconColor ?? Colors.white,
                          size: math.max(
                              24.0,
                              targetSize.width *
                                  0.6), // Increased from 0.5 to 0.6 with minimum 24px
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
    // Early return if size is invalid
    if (size.width <= 0 || size.height <= 0) return;

    // For single target (tap interaction)
    if (destinationKey == null) {
      _paintSingleTarget(canvas, size);
      return;
    }

    // For drag-drop corridor
    _paintDragPathCorridor(canvas, size);
  }

  void _paintSingleTarget(Canvas canvas, Size size) {
    // Get the source target box with additional null checks
    final context = sourceKey.currentContext;
    if (context == null) return;

    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;

    final RenderBox? sourceBox =
        renderObject is RenderBox ? renderObject : null;
    if (sourceBox == null || !sourceBox.hasSize) return;

    final sourcePos = sourceBox.localToGlobal(Offset.zero);

    final sourceRect = Rect.fromLTWH(
      sourcePos.dx - padding,
      sourcePos.dy - padding,
      sourceBox.size.width + (padding * 2),
      sourceBox.size.height + (padding * 2),
    );

    // Ensure the source rect is within screen bounds
    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final clampedSourceRect = Rect.fromLTWH(
      sourceRect.left.clamp(0, size.width),
      sourceRect.top.clamp(0, size.height),
      (sourceRect.width)
          .clamp(0, size.width - sourceRect.left.clamp(0, size.width)),
      (sourceRect.height)
          .clamp(0, size.height - sourceRect.top.clamp(0, size.height)),
    );

    // Create a rounded rect path for the target
    final targetPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        clampedSourceRect,
        Radius.circular(cornerRadius),
      ));

    // Create a full screen path
    final fullScreenPath = Path()..addRect(screenRect);

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
      RRect.fromRectAndRadius(clampedSourceRect, Radius.circular(cornerRadius)),
      borderPaint,
    );
  }

  void _paintDragPathCorridor(Canvas canvas, Size size) {
    // Get source and destination boxes with better null checks
    final sourceContext = sourceKey.currentContext;
    final destContext = destinationKey?.currentContext;

    if (sourceContext == null || destContext == null) return;

    final sourceRenderObject = sourceContext.findRenderObject();
    final destRenderObject = destContext.findRenderObject();

    if (sourceRenderObject == null ||
        destRenderObject == null ||
        !sourceRenderObject.attached ||
        !destRenderObject.attached) return;

    final RenderBox? sourceBox =
        sourceRenderObject is RenderBox ? sourceRenderObject : null;
    final RenderBox? destBox =
        destRenderObject is RenderBox ? destRenderObject : null;

    if (sourceBox == null ||
        destBox == null ||
        !sourceBox.hasSize ||
        !destBox.hasSize) return;

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
