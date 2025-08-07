import 'package:flutter/material.dart';
import '../models/onboarding_step.dart';

class AnimatedHintIcon extends StatefulWidget {
  final InteractionType interactionType;
  final Color? color;
  final double size;
  final IconData? customIcon;
  final String? imagePath;
  final Widget? customIconWidget;

  const AnimatedHintIcon({
    Key? key,
    required this.interactionType,
    this.color = Colors.white,
    this.size = 40.0, // Increased from 32.0 to 40.0 for better visibility
    this.customIcon,
    this.imagePath,
    this.customIconWidget,
  }) : super(key: key);

  @override
  State<AnimatedHintIcon> createState() => _AnimatedHintIconState();
}

class _AnimatedHintIconState extends State<AnimatedHintIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color?.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: _buildIcon(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon() {
    // First priority: custom widget if provided
    if (widget.customIconWidget != null) {
      return SizedBox(
        width: widget.size *
            0.75, // Increased from 0.6 to 0.75 for better visibility
        height: widget.size * 0.75,
        child: widget.customIconWidget,
      );
    }

    // Second priority: image path if provided
    if (widget.imagePath != null) {
      return Image.asset(
        widget.imagePath!,
        package: 'flutter_game_onboarding',
        width: widget.size *
            0.75, // Increased from 0.6 to 0.75 for better visibility
        height: widget.size *
            0.75, // Fixed: changed from 0.6 to 0.75 to match width
        color: widget.color,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return _buildDefaultIcon();
        },
      );
    }

    // Third priority: custom icon or default
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Icon(
      widget.customIcon ??
          (widget.interactionType == InteractionType.tap
              ? Icons.touch_app
              : Icons.swipe),
      color: widget.color,
      size: widget.size *
          0.75, // Increased from 0.6 to 0.75 for better visibility
    );
  }
}
