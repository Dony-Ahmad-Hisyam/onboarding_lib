import 'package:flutter/material.dart';
import '../utils/onboarding_key_store.dart';

/// Minimal wrapper to bind a child with a stable GlobalKey derived from a string id.
/// Use this to keep your UI simple (no GlobalKey fields), while onboarding can still target it.
class ObBindId extends StatelessWidget {
  final String id;
  final Widget child;
  const ObBindId({super.key, required this.id, required this.child});

  @override
  Widget build(BuildContext context) {
    final keyRef = OnboardingKeyStore.instance.key(id);
    return KeyedSubtree(key: keyRef, child: child);
  }
}
