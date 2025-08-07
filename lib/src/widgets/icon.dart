import 'package:flutter/material.dart';

class MyCustomIconPng extends StatelessWidget {
  final Color? color;
  final double width;
  final double height;

  const MyCustomIconPng({
    Key? key,
    this.color,
    this.width = 40,
    this.height = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      PackageAssets.logo, // No package reference needed
      width: width,
      height: height,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading custom icon: $error');
        return Icon(
          Icons.touch_app,
          color: color,
          size: width,
        );
      },
    );
  }
}

class PackageAssets {
  static const String logo = '../assets/click.png';
}
