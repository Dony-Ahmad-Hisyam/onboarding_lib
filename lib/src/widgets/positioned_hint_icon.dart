import 'package:flutter/material.dart';

enum IconPosition {
  center,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topCenter,
  bottomCenter,
  centerLeft,
  centerRight,
  fingerpoint, // Added new position type for finger pointing
}

class PositionedHintIcon extends StatefulWidget {
  final IconPosition position;
  final Color? color;
  final double size;
  final IconData? icon;
  final String? imagePath;
  final Widget? customWidget;
  final EdgeInsets padding;

  const PositionedHintIcon({
    Key? key,
    this.position = IconPosition.center,
    this.color = Colors.amber, // Changed from white to amber
    this.size = 32.0,
    this.icon,
    this.imagePath,
    this.customWidget,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

  @override
  State<PositionedHintIcon> createState() => _PositionedHintIconState();
}

class _PositionedHintIconState extends State<PositionedHintIcon>
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

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      // Smaller animation range
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
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
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
        ),
        _buildPositionedIcon(),
      ],
    );
  }

  Widget _buildPositionedIcon() {
    // Standard positions
    Alignment alignment;
    switch (widget.position) {
      case IconPosition.topLeft:
        alignment = Alignment.topLeft;
        break;
      case IconPosition.topRight:
        alignment = Alignment.topRight;
        break;
      case IconPosition.bottomLeft:
        alignment = Alignment.bottomLeft;
        break;
      case IconPosition.bottomRight:
        alignment = Alignment.bottomRight;
        break;
      case IconPosition.topCenter:
        alignment = Alignment.topCenter;
        break;
      case IconPosition.bottomCenter:
        alignment = Alignment.bottomCenter;
        break;
      case IconPosition.centerLeft:
        alignment = Alignment.centerLeft;
        break;
      case IconPosition.centerRight:
        alignment = Alignment.centerRight;
        break;
      case IconPosition.center:
      default:
        alignment = Alignment.center;
        break;
    }

    return Align(
      alignment: alignment,
      child: Padding(
        padding: widget.padding,
        child: _buildAnimatedIcon(),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
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
    if (widget.customWidget != null) {
      return SizedBox(
        width: widget.size * 0.6,
        height: widget.size * 0.6,
        child: widget.customWidget,
      );
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    // Use the icon specified by the developer
    return Icon(
      widget.icon ?? Icons.touch_app, // Default to touch_app if not specified
      color: widget.color,
      size: widget.size * 0.6,
    );
  }
}
