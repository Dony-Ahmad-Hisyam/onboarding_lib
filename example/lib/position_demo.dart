import 'package:flutter/material.dart';
import 'package:onboarding_lib/onboarding_lib.dart';

class PositionDemo extends StatelessWidget {
  const PositionDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Position Demo'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildPositionBox('Center', IconPosition.center, Colors.blue),
          _buildPositionBox('Top Left', IconPosition.topLeft, Colors.red),
          _buildPositionBox('Top Right', IconPosition.topRight, Colors.green),
          _buildPositionBox(
              'Bottom Left', IconPosition.bottomLeft, Colors.orange),
          _buildPositionBox(
              'Bottom Right', IconPosition.bottomRight, Colors.purple),
          _buildPositionBox('Top Center', IconPosition.topCenter, Colors.teal),
          _buildPositionBox(
              'Bottom Center', IconPosition.bottomCenter, Colors.pink),
          _buildPositionBox(
              'Center Left', IconPosition.centerLeft, Colors.amber),
          _buildPositionBox(
              'Center Right', IconPosition.centerRight, Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildPositionBox(String title, IconPosition position, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color, width: 2.0),
      ),
      child: Stack(
        children: [
          // Title in the center
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),

          // Positioned icon
          PositionedHintIcon(
            position: position,
            color: color,
            size: 50.0,
            icon: Icons.touch_app,
          ),
        ],
      ),
    );
  }
}
