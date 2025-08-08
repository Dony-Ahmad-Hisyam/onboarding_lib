import 'package:flutter/material.dart';

/// Generic drag payload used by Onboarding wrappers.
class OnboardingDragData<T> {
  final T data;
  final GlobalKey sourceKey;
  const OnboardingDragData({required this.data, required this.sourceKey});
}
