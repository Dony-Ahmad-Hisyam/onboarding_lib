import 'package:flutter/material.dart';
import '../controllers/onboarding_controller.dart';
import '../models/onboarding_step.dart';
import 'onboarding_tooltip.dart';
import 'animated_hint_icon.dart';
import '../utils/position_utils.dart';
import 'positioned_hint_icon.dart'; // Import PositionedHintIcon

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
          if (widget.controller.isVisible) _buildOverlay(),
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
                            package:
                                'onboarding_lib', // Ubah ke nama package yang benar
                            color: step.hintIconColor ?? Colors.white,
                            width: sourceSize.width * 0.5,
                            height: sourceSize.height * 0.5,
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

  Widget _buildOverlay() {
    final config = widget.controller.config;
    final currentStep = widget.controller.currentStep;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, _) {
        return Opacity(
          opacity: _fadeAnimation.value * config.overlayOpacity,
          child: Stack(
            children: [
              // Full screen colored overlay
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    // Optional: Dismiss onboarding on background tap
                    if (widget.controller.config.debug) {
                      widget.controller.skip();
                    }
                  },
                  child: Container(color: config.overlayColor),
                ),
              ),

              // Cut out for the target widget
              if (currentStep.targetKey.currentContext != null)
                _buildTargetCutout(currentStep.targetKey),

              // Cut out for destination widget if it's a drag operation
              if (currentStep.interactionType == InteractionType.dragDrop &&
                  currentStep.destinationKey?.currentContext != null)
                _buildTargetCutout(currentStep.destinationKey!,
                    isDestination: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTargetCutout(GlobalKey key, {bool isDestination = false}) {
    final RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox();

    final position = box.localToGlobal(Offset.zero);
    final size = box.size;
    final padding = widget.controller.config.targetPadding;
    final step = widget.controller.currentStep;

    return Positioned(
      left: position.dx - padding,
      top: position.dy - padding,
      width: size.width + (padding * 2),
      height: size.height + (padding * 2),
      child: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (step.interactionType == InteractionType.tap &&
                  !isDestination) {
                widget.controller.handleTap();
              }
            },
            onPanStart: (details) {
              if (step.interactionType == InteractionType.dragDrop &&
                  !isDestination) {
                setState(() {
                  _dragOffset = details.globalPosition;
                  _isUserDragging = true;
                  // Pause the automatic animation when user starts dragging
                  _dragAnimationController?.stop();
                });
                widget.controller.startDrag(details.globalPosition);
              }
            },
            onPanUpdate: (details) {
              if (step.interactionType == InteractionType.dragDrop &&
                  !isDestination) {
                setState(() {
                  _dragOffset = details.globalPosition;
                });
                widget.controller.updateDrag(details.globalPosition);
              }
            },
            onPanEnd: (details) {
              if (step.interactionType == InteractionType.dragDrop &&
                  !isDestination) {
                final bool success =
                    widget.controller.completeDrag(_dragOffset ?? Offset.zero);
                if (!success) {
                  // Animate back to original position
                  setState(() {
                    _dragOffset = null;
                    _isUserDragging = false;
                    // Resume automatic animation
                    _dragAnimationController?.forward();
                  });
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Gunakan hanya PositionedHintIcon dan hapus AnimatedHintIcon
          if (step.interactionType == InteractionType.tap && !isDestination)
            PositionedHintIcon(
              position: step.iconPosition, // Gunakan iconPosition dari step
              color: step.hintIconColor ?? Colors.white,
              size: size.width > size.height
                  ? size.height * 0.6
                  : size.width * 0.6,
              icon: step.hintIcon ?? Icons.touch_app,
              imagePath: step.hintImagePath,
              customWidget: step.customIconWidget,
            ),

          // Add destination indicator for drag operations
          if (isDestination && step.interactionType == InteractionType.dragDrop)
            Center(
              child: Icon(
                Icons.add_circle_outline,
                color: step.hintIconColor ?? Colors.white,
                size: size.width > size.height
                    ? size.height * 0.6
                    : size.width * 0.6,
              ),
            ),
        ],
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

    final tooltipPosition = PositionUtils.calculateTooltipPosition(
      targetPosition: targetPosition,
      targetSize: targetSize,
      tooltipSize: Size(widget.controller.config.tooltipConfig.maxWidth,
          0), // Height will be determined by content
      screenSize: MediaQuery.of(context).size,
      position: step.position,
      margin: widget.controller.config.tooltipConfig.tooltipMargin,
    );

    return Positioned(
      left: tooltipPosition.dx,
      top: tooltipPosition.dy,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, _) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: OnboardingTooltip(
              controller: widget.controller,
              step: step,
              position: PositionUtils.determineTooltipPosition(
                targetPosition: targetPosition,
                targetSize: targetSize,
                tooltipPosition: tooltipPosition,
              ),
            ),
          );
        },
      ),
    );
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
                          package:
                              'onboarding_lib', // Ubah ke nama package yang benar
                          color: step.hintIconColor ?? Colors.white,
                          width: targetSize.width * 0.5,
                          height: targetSize.height * 0.5,
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
