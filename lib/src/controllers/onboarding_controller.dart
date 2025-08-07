import 'package:flutter/material.dart';
import '../models/onboarding_config.dart';
import '../models/onboarding_step.dart';

class OnboardingController extends ChangeNotifier {
  final OnboardingConfig config;

  int _currentStepIndex = 0;
  bool _isVisible = false;
  Offset? _dragStart;

  OnboardingController({
    required this.config,
  });

  bool get isVisible => _isVisible;
  int get currentStepIndex => _currentStepIndex;
  OnboardingStep get currentStep => config.steps[_currentStepIndex];

  void start() {
    if (config.steps.isEmpty) return;
    _currentStepIndex = 0;
    _isVisible = true;
    currentStep.onShow?.call();
    notifyListeners();
  }

  void skip() {
    _isVisible = false;
    config.onSkip?.call();
    notifyListeners();
  }

  void reset() {
    _currentStepIndex = 0;
    _isVisible = false;
    notifyListeners();
  }

  void nextStep() {
    currentStep.onComplete?.call();

    if (_currentStepIndex >= config.steps.length - 1) {
      _isVisible = false;
      config.onComplete?.call();
    } else {
      _currentStepIndex++;
      currentStep.onShow?.call();
    }

    notifyListeners();
  }

  void handleTap() {
    if (currentStep.interactionType == InteractionType.tap) {
      nextStep();
    }
  }

  void startDrag(Offset position) {
    if (currentStep.interactionType == InteractionType.dragDrop) {
      _dragStart = position;
    }
  }

  void updateDrag(Offset position) {
    // Tracking drag but no need to notify listeners
  }

  bool completeDrag(Offset position) {
    if (currentStep.interactionType != InteractionType.dragDrop ||
        _dragStart == null ||
        currentStep.destinationKey == null ||
        currentStep.destinationKey!.currentContext == null) {
      return false;
    }

    // Check if drag ended over the destination
    final RenderBox destBox = currentStep.destinationKey!.currentContext!
        .findRenderObject() as RenderBox;
    final Offset destPosition = destBox.localToGlobal(Offset.zero);
    final Size destSize = destBox.size;

    final Rect destRect = Rect.fromLTWH(
      destPosition.dx,
      destPosition.dy,
      destSize.width,
      destSize.height,
    );

    if (destRect.contains(position)) {
      nextStep();
      return true;
    }

    return false;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
