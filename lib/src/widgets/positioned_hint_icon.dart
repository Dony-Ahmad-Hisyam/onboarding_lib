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
    this.color = Colors.white,
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
    // Menentukan alignment berdasarkan posisi yang dipilih
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
    // Prioritas: 1) Widget kustom, 2) Gambar, 3) Icon
    if (widget.customWidget != null) {
      return SizedBox(
        width: widget.size * 0.6,
        height: widget.size * 0.6,
        child: widget.customWidget,
      );
    }

    if (widget.imagePath != null) {
      return Image.asset(
        widget.imagePath!,
        package: 'onboarding_lib', // Sesuaikan dengan nama package Anda
        width: widget.size * 0.6,
        height: widget.size * 0.6,
        color: widget.color,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error');
          return _buildDefaultIcon();
        },
      );
    }

    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    return Icon(
      widget.icon ?? Icons.touch_app,
      color: widget.color,
      size: widget.size * 0.6,
    );
  }
}
