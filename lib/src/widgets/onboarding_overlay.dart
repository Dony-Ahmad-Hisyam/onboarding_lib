import 'dart:math' as math;
// HAPUS import 'dart:ui' karena blur dipindahkan/ tidak digunakan di file ini.

import 'package:flutter/material.dart';
import 'package:onboarding_lib/src/widgets/onboarding_nav_card.dart';
import '../controllers/onboarding_controller.dart';
import '../models/onboarding_step.dart';
import 'onboarding_tooltip.dart';
import 'positioned_hint_icon.dart';

// BARU: header & nav bar terpisah
import 'onboarding_header_card.dart';

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
          // Disable all underlying interactions while onboarding is visible
          AbsorbPointer(
            absorbing: widget.controller.isVisible,
            child: widget.child,
          ),

          // Visual overlay - show immediately when controller is visible
          if (widget.controller.isVisible)
            IgnorePointer(
              child: _buildVisualOverlay(),
            ),

          // Interaction layer - handles ONLY the active step's gestures
          if (widget.controller.isVisible) _buildInteractionLayer(),

          if (widget.controller.isVisible &&
              !widget.controller.config.tooltipConfig.headerAtTop)
            _buildTooltip(),

          // Global header at top (dipisah file)
          if (widget.controller.isVisible &&
              widget.controller.config.tooltipConfig.headerAtTop)
            _buildGlobalHeader(),

          // Bottom bar Back/Next (dipisah file)
          if (widget.controller.isVisible &&
              widget.controller.config.tooltipConfig.showBottomBar)
            _buildBottomBar(),

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
                        width: math.max(24.0, sourceSize.width * 0.6),
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
                            size: math.max(24.0, sourceSize.width * 0.6),
                          )),
              ),
            ),
          ),
        );
      },
    );
  }

  // Purely visual overlay
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
              corridorWidth: 84.0,
              borderColor: currentStep.hintIconColor ?? Colors.amber,
              borderWidth: 4.0,
              cornerRadius: 20.0,
            ),
          );
        },
      ),
    );
  }

  // Interaction layer
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

  // Drag & drop interaction
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

    return Positioned.fill(
      child: Stack(
        children: [
          // Source hit area
          Positioned(
            left: sourcePos.dx,
            top: sourcePos.dy,
            width: sourceSize.width,
            height: sourceSize.height,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
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
                  final Rect destRect = Rect.fromLTWH(
                    destPos.dx,
                    destPos.dy,
                    destSize.width,
                    destSize.height,
                  ).inflate(20);

                  final bool success;
                  if (_dragOffset != null && destRect.contains(_dragOffset!)) {
                    success = true;
                    setState(() {
                      _dragOffset = null;
                      _isUserDragging = false;
                      _dragAnimationController?.stop();
                      _dragAnimationController?.reset();
                    });
                    Future.delayed(const Duration(milliseconds: 300), () {
                      widget.controller.nextStep();
                    });
                  } else {
                    success = widget.controller
                        .completeDrag(_dragOffset ?? Offset.zero);

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
                            math.min(sourceSize.width, sourceSize.height) * 0.7,
                          ),
                        );
                  })(),
                ),
              ),
            ),
          ),

          // Destination indicator
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
                    math.min(destSize.width, destSize.height) * 0.6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tap interaction
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
                math.min(size.width, size.height) * 0.8,
              ),
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
    if (widget.controller.config.tooltipConfig.headerAtTop) {
      return const SizedBox.shrink();
    }
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

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final EdgeInsets safeArea = mediaQuery.padding;
    final double statusBarHeight = safeArea.top;
    final double bottomSafeArea = safeArea.bottom;

    final double availableWidth = screenSize.width - 32;
    final double availableHeight =
        screenSize.height - statusBarHeight - bottomSafeArea - 32;

    final double estimatedTooltipWidth = math.min(
        widget.controller.config.tooltipConfig.maxWidth, availableWidth);

    final double estimatedTooltipHeight =
        math.min(200.0, availableHeight * 0.4);

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

  // ============== DIGANTI: header dipindah ke widget terpisah ==============
  Widget _buildGlobalHeader() {
    final step = widget.controller.currentStep;
    final mq = MediaQuery.of(context);
    final top = mq.padding.top + 12;

    final int stepNumber = widget.controller.currentStepIndex + 1;

    final cfg = widget.controller.config.tooltipConfig;
    final double? headerWidth = cfg.headerWidth;
    final double? headerHeight = cfg.headerHeight;
    final double minHeight = cfg.headerMinHeight;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: cfg.headerOuterMargin,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: minHeight,
              maxWidth: cfg.headerMaxWidth ?? MediaQuery.of(context).size.width,
            ),
            child: SizedBox(
              width: headerWidth,
              height: headerHeight,
              child: OnboardingHeaderCard(
                title: step.title,
                description: step.description,
                stepNumber: stepNumber,
                totalSteps: widget.controller.config.steps.length,
                backgroundColor:
                    cfg.headerBackgroundColor ?? const Color(0xFFAEC6FF),
                textColor: cfg.headerTextColor ?? const Color(0xFF10213A),
                mainFontSize: cfg.headerFontSize,
                padding: cfg.headerPadding,
                margin: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============== DIGANTI: bottom bar dipindah ke widget terpisah ==========
  Widget _buildBottomBar() {
    final cfg = widget.controller.config.tooltipConfig;
    final mq = MediaQuery.of(context);
    final bottom = mq.padding.bottom + cfg.bottomBarPadding.bottom;

    final int current = widget.controller.currentStepIndex + 1;
    final int total = widget.controller.config.steps.length;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: OnboardingNavBar(
        currentStep: current,
        totalSteps: total,
        onNext: widget.controller.nextStep,
        onSkip: widget.controller.skip,
        onBack: widget.controller.previousStep,
        useSkipOnFirst: true,
        // Margin tambahan bisa disesuaikan dari config
        margin: EdgeInsets.only(
          left: cfg.bottomBarPadding.left + 16,
          right: cfg.bottomBarPadding.right + 16,
        ),
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
    final double spacing = 12.0;

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

    final Offset targetCenter = Offset(
      targetPosition.dx + targetSize.width / 2,
      targetPosition.dy + targetSize.height / 2,
    );

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

    TooltipPosition preferredPosition = step.position;

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

    final double minX = margin;
    final double maxX = screenSize.width - tooltipSize.width - margin;
    final double minY = safeArea.top + margin;
    final double maxY =
        screenSize.height - safeArea.bottom - tooltipSize.height - margin;

    tooltipX = tooltipX.clamp(minX, maxX.isNaN ? minX : maxX);
    tooltipY = tooltipY.clamp(minY, maxY.isNaN ? minY : maxY);

    final Rect targetRect = Rect.fromLTWH(
      targetPosition.dx,
      targetPosition.dy,
      targetSize.width,
      targetSize.height,
    ).inflate(8);
    Rect tooltipRect = Rect.fromLTWH(
        tooltipX, tooltipY, tooltipSize.width, tooltipSize.height);

    if (tooltipRect.overlaps(targetRect)) {
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
              targetPosition.dy + targetSize.height + 12,
            );
            break;
          case TooltipPosition.top:
            test = Offset(
              _calculateHorizontalPosition(
                  targetCenter.dx, tooltipSize.width, screenSize.width, margin),
              targetPosition.dy - tooltipSize.height - 12,
            );
            break;
          case TooltipPosition.right:
            test = Offset(
              targetPosition.dx + targetSize.width + 12,
              _calculateVerticalPosition(targetCenter.dy, tooltipSize.height,
                  screenSize.height, EdgeInsets.zero, margin),
            );
            break;
          case TooltipPosition.left:
            test = Offset(
              targetPosition.dx - tooltipSize.width - 12,
              _calculateVerticalPosition(targetCenter.dy, tooltipSize.height,
                  screenSize.height, EdgeInsets.zero, margin),
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

      if (nonOverlap != null) {
        tooltipX = nonOverlap.dx;
        tooltipY = nonOverlap.dy;
      }
    }

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

      final Rect lineBounds = Rect.fromPoints(srcCenter, dstCenter);
      final double corridorThickness = 120.0;
      final Rect corridorRect = lineBounds.inflate(corridorThickness / 2);

      final Rect srcRect =
          Rect.fromLTWH(srcPos.dx, srcPos.dy, srcSize.width, srcSize.height)
              .inflate(8);
      final Rect dstRect =
          Rect.fromLTWH(dstPos.dx, dstPos.dy, dstSize.width, dstSize.height)
              .inflate(8);

      Rect currentTooltipRect = Rect.fromLTWH(
              tooltipX, tooltipY, tooltipSize.width, tooltipSize.height)
          .inflate(12);

      bool overlaps = currentTooltipRect.overlaps(corridorRect) ||
          currentTooltipRect.overlaps(srcRect) ||
          currentTooltipRect.overlaps(dstRect);

      final bool anchoredToDestination =
          step.dragTooltipAnchor == DragTooltipAnchor.destination;
      final bool tooltipAboveDest = currentTooltipRect.bottom <= dstPos.dy - 4;
      if (anchoredToDestination && tooltipAboveDest) {
        overlaps = currentTooltipRect.overlaps(srcRect) ||
            currentTooltipRect.overlaps(dstRect);
      }

      if (overlaps) {
        List<TooltipPosition> candidates = [
          TooltipPosition.top,
          TooltipPosition.bottom,
          TooltipPosition.left,
          TooltipPosition.right,
        ];

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
            TooltipPosition.left,
            TooltipPosition.right,
            TooltipPosition.top,
            TooltipPosition.bottom
          ];
        }

        Offset? nonOverlap;
        final double extraSpacing = 24;
        for (final candidate in candidates) {
          Offset test;
          switch (candidate) {
            case TooltipPosition.top:
              test = Offset(
                _calculateHorizontalPosition(
                    targetCenter.dx, tooltipSize.width, screenSize.width, 16),
                targetPosition.dy - tooltipSize.height - extraSpacing,
              );
              break;
            case TooltipPosition.bottom:
              test = Offset(
                _calculateHorizontalPosition(
                    targetCenter.dx, tooltipSize.width, screenSize.width, 16),
                targetPosition.dy + targetSize.height + extraSpacing,
              );
              break;
            case TooltipPosition.left:
              test = Offset(
                targetPosition.dx - tooltipSize.width - extraSpacing,
                _calculateVerticalPosition(targetCenter.dy, tooltipSize.height,
                    screenSize.height, EdgeInsets.zero, 16),
              );
              break;
            case TooltipPosition.right:
              test = Offset(
                targetPosition.dx + targetSize.width + extraSpacing,
                _calculateVerticalPosition(targetCenter.dy, tooltipSize.height,
                    screenSize.height, EdgeInsets.zero, 16),
              );
              break;
            case TooltipPosition.auto:
              test = Offset(tooltipX, tooltipY);
              break;
          }

          final double cx =
              test.dx.clamp(16, screenSize.width - tooltipSize.width - 16);
          final double cy = test.dy.clamp(
              16 + MediaQuery.of(context).padding.top,
              screenSize.height -
                  MediaQuery.of(context).padding.bottom -
                  tooltipSize.height -
                  16);
          final Rect testRect =
              Rect.fromLTWH(cx, cy, tooltipSize.width, tooltipSize.height)
                  .inflate(12);
          bool candidateOverlaps = testRect.overlaps(corridorRect);
          if (anchoredToDestination &&
              (cy + tooltipSize.height) <= dstPos.dy - 4) {
            candidateOverlaps = false;
          }

          if (!candidateOverlaps &&
              !testRect.overlaps(srcRect) &&
              !testRect.overlaps(dstRect)) {
            nonOverlap = Offset(cx, cy);
            break;
          }
        }

        if (nonOverlap == null) {
          final double push = corridorThickness + 24;
          if (isMostlyHorizontal) {
            final tryUp = (targetPosition.dy -
                    MediaQuery.of(context).padding.top) >
                (screenSize.height - (targetPosition.dy + targetSize.height));
            final double proposedY = tryUp
                ? (targetPosition.dy - tooltipSize.height - extraSpacing - push)
                : (targetPosition.dy + targetSize.height + extraSpacing + push);
            final double cy = proposedY.clamp(
              16 + MediaQuery.of(context).padding.top,
              screenSize.height -
                  MediaQuery.of(context).padding.bottom -
                  tooltipSize.height -
                  16,
            );
            final double cx = _calculateHorizontalPosition(
                    targetCenter.dx, tooltipSize.width, screenSize.width, 16)
                .clamp(16.0, screenSize.width - tooltipSize.width - 16.0);
            nonOverlap = Offset(cx, cy);
          } else {
            final tryLeft = targetPosition.dx >
                (screenSize.width - (targetPosition.dx + targetSize.width));
            final double proposedX = tryLeft
                ? (targetPosition.dx - tooltipSize.width - extraSpacing - push)
                : (targetPosition.dx + targetSize.width + extraSpacing + push);
            final double cx = proposedX.clamp(
              16,
              screenSize.width - tooltipSize.width - 16,
            );
            final double cy = _calculateVerticalPosition(
                    targetCenter.dy,
                    tooltipSize.height,
                    screenSize.height,
                    MediaQuery.of(context).padding,
                    16)
                .clamp(
              16 + MediaQuery.of(context).padding.top,
              screenSize.height -
                  MediaQuery.of(context).padding.bottom -
                  tooltipSize.height -
                  16,
            );
            nonOverlap = Offset(cx, cy);
          }
        }

        tooltipX = nonOverlap.dx;
        tooltipY = nonOverlap.dy;

        tooltipX =
            tooltipX.clamp(16, screenSize.width - tooltipSize.width - 16);
        tooltipY = tooltipY.clamp(
          16 + MediaQuery.of(context).padding.top,
          screenSize.height -
              MediaQuery.of(context).padding.bottom -
              tooltipSize.height -
              16,
        );
      }
    }

    return Offset(tooltipX, tooltipY);
  }

  double _calculateHorizontalPosition(double targetCenterX, double tooltipWidth,
      double screenWidth, double margin) {
    double x = targetCenterX - (tooltipWidth / 2);
    if (x < margin) {
      x = margin;
    } else if (x + tooltipWidth > screenWidth - margin) {
      x = screenWidth - tooltipWidth - margin;
    }
    return x;
  }

  double _calculateVerticalPosition(double targetCenterY, double tooltipHeight,
      double screenHeight, EdgeInsets safeArea, double margin) {
    double y = targetCenterY - (tooltipHeight / 2);
    final double minY = safeArea.top + margin;
    final double maxY = screenHeight - safeArea.bottom - tooltipHeight - margin;
    return y.clamp(minY, maxY);
  }

  TooltipPosition _determineTooltipPosition({
    required Offset targetPosition,
    required Offset tooltipPosition,
    required Size screenSize,
  }) {
    final double tolerance = 20.0;

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
                      width: math.max(24.0, targetSize.width * 0.6),
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
                          size: math.max(24.0, targetSize.width * 0.6),
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
    if (size.width <= 0 || size.height <= 0) return;

    if (destinationKey == null) {
      _paintSingleTarget(canvas, size);
      return;
    }

    _paintDragPathCorridor(canvas, size);
  }

  void _paintSingleTarget(Canvas canvas, Size size) {
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

    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final clampedSourceRect = Rect.fromLTWH(
      sourceRect.left.clamp(0, size.width),
      sourceRect.top.clamp(0, size.height),
      (sourceRect.width)
          .clamp(0, size.width - sourceRect.left.clamp(0, size.width)),
      (sourceRect.height)
          .clamp(0, size.height - sourceRect.top.clamp(0, size.height)),
    );

    final targetPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        clampedSourceRect,
        Radius.circular(cornerRadius),
      ));

    final fullScreenPath = Path()..addRect(screenRect);

    final overlayPath = Path.combine(
      PathOperation.difference,
      fullScreenPath,
      targetPath,
    );

    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, overlayPaint);

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

    final sourceCenter = Offset(
      sourcePos.dx + sourceSize.width / 2,
      sourcePos.dy + sourceSize.height / 2,
    );

    final destCenter = Offset(
      destPos.dx + destSize.width / 2,
      destPos.dy + destSize.height / 2,
    );

    final angle = math.atan2(
      destCenter.dy - sourceCenter.dy,
      destCenter.dx - sourceCenter.dx,
    );

    final direction = Offset(math.cos(angle), math.sin(angle));
    final perpendicular = Offset(-direction.dy, direction.dx);

    final double sourceRadius =
        math.min(sourceSize.width, sourceSize.height) / 2;
    final double destRadius = math.min(destSize.width, destSize.height) / 2;
    const double bubbleExtra = 6.0;

    final halfWidth = (corridorWidth / 2);

    final double sR = sourceRadius + bubbleExtra;
    final double dR = destRadius + bubbleExtra;
    double _tangentDist(double r, double hw) {
      final double v = r * r - hw * hw;
      return v <= 0 ? 0.0 : math.sqrt(v);
    }

    final double startOffset = _tangentDist(sR, halfWidth);
    final double endOffset = _tangentDist(dR, halfWidth);

    final startPoint = sourceCenter + direction * startOffset;
    final endPoint = destCenter - direction * endOffset;

    final p1 = startPoint + perpendicular * halfWidth;
    final p2 = endPoint + perpendicular * halfWidth;
    final p3 = endPoint - perpendicular * halfWidth;
    final p4 = startPoint - perpendicular * halfWidth;

    final rectPath = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();

    final sourceBubble = Path()
      ..addOval(Rect.fromCircle(
          center: sourceCenter, radius: sourceRadius + bubbleExtra));
    final destBubble = Path()
      ..addOval(Rect.fromCircle(
          center: destCenter, radius: destRadius + bubbleExtra));

    // Build capsule before cutting overlay so we can clear the rounded ends too
    final startCap = Path()
      ..addOval(Rect.fromCircle(center: startPoint, radius: halfWidth));
    final endCap = Path()
      ..addOval(Rect.fromCircle(center: endPoint, radius: halfWidth));

    final capsulePath = Path.combine(
      PathOperation.union,
      Path.combine(PathOperation.union, rectPath, startCap),
      endCap,
    );

    // Use capsule (rect + rounded caps) UNION bubbles to cut the overlay.
    // This prevents any dark semi-circular rim near the source/destination.
    final corridorClearPath = Path.combine(
      PathOperation.union,
      Path.combine(PathOperation.union, capsulePath, sourceBubble),
      destBubble,
    );

    final fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final overlayPath = Path.combine(
      PathOperation.difference,
      fullScreenPath,
      corridorClearPath,
    );

    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, overlayPaint);

    // Soft corridor tint only on the capsule (clean ends, no circular halos)
    final fillPaint = Paint()
      ..color = borderColor.withOpacity(0.18)
      ..style = PaintingStyle.fill;
    canvas.drawPath(capsulePath, fillPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(capsulePath, borderPaint);

    // Clean capsule without directional arrow for a minimal look
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
  Offset rotate(double radians) {
    final cos = math.cos(radians);
    final sin = math.sin(radians);
    return Offset(dx * cos - dy * sin, dx * sin + dy * cos);
  }
}
