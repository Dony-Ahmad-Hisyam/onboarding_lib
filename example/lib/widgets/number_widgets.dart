import 'package:flutter/material.dart';
import 'package:onboarding_lib/onboarding_lib.dart';

/// Simple, reusable widgets to keep the example concise
class NumberChip extends StatelessWidget {
  final String number;
  final GlobalKey keyRef;
  final bool enabled;
  const NumberChip(
      {super.key,
      required this.number,
      required this.keyRef,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: 60,
      height: 60,
      decoration:
          const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );

    final fb = Material(
      color: Colors.transparent,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8)
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    return ObDraggable<String>(
      keyRef: keyRef,
      data: number,
      child: enabled ? circle : Opacity(opacity: 0.4, child: circle),
      feedback: fb,
      enabled: enabled,
    );
  }
}

class NumberSlotLabel extends StatelessWidget {
  final String label;
  final GlobalKey keyRef;
  final String expectedValue;
  final String? currentValue;
  final ValueChanged<String> onAccept;
  const NumberSlotLabel({
    super.key,
    required this.label,
    required this.keyRef,
    required this.expectedValue,
    required this.currentValue,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return ObDragTarget<String>(
      keyRef: keyRef,
      canAccept: (d) => d == expectedValue && currentValue == null,
      onAccept: onAccept,
      builder: (context, cand, _) {
        final hasValue = currentValue != null;
        final color = hasValue
            ? Colors.green
            : (cand.isNotEmpty ? Colors.purple.shade700 : Colors.purple);
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

class NumberSlotEmpty extends StatelessWidget {
  final GlobalKey keyRef;
  final String expectedValue;
  final String? currentValue;
  final ValueChanged<String> onAccept;
  const NumberSlotEmpty({
    super.key,
    required this.keyRef,
    required this.expectedValue,
    required this.currentValue,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return ObDragTarget<String>(
      keyRef: keyRef,
      canAccept: (d) => d == expectedValue && currentValue == null,
      onAccept: onAccept,
      builder: (context, cand, _) {
        final highlight = cand.isNotEmpty;
        final hasValue = currentValue != null;
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: hasValue ? Colors.purple : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: highlight ? Colors.purple.shade700 : Colors.purple,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              hasValue ? currentValue! : '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
