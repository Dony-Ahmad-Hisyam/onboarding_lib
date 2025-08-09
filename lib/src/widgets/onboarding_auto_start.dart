import 'dart:async';
import 'package:flutter/material.dart';
import '../models/onboarding_step.dart';
import '../utils/shortcuts.dart';

/// Invisible helper that auto-starts onboarding when the referenced keys
/// appear in the widget tree. No manual calls to start/show are needed.
class OnboardingAutoStart extends StatefulWidget {
  final List<OnboardingStep> steps;
  final Duration initialDelay;
  final Duration pollInterval;
  final int maxPolls;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  final bool enabled;

  const OnboardingAutoStart({
    super.key,
    required this.steps,
    this.initialDelay = const Duration(milliseconds: 200),
    this.pollInterval = const Duration(milliseconds: 120),
    this.maxPolls = 60, // ~7 seconds total by default
    this.onComplete,
    this.onSkip,
    this.enabled = true,
  });

  @override
  State<OnboardingAutoStart> createState() => _OnboardingAutoStartState();
}

class _OnboardingAutoStartState extends State<OnboardingAutoStart> {
  Timer? _timer;
  int _tries = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) return;
    Future.delayed(widget.initialDelay, _tick);
  }

  @override
  void didUpdateWidget(covariant OnboardingAutoStart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) return;
    if (!_started && oldWidget.steps != widget.steps) {
      _cancel();
      _tries = 0;
      Future.delayed(widget.initialDelay, _tick);
    }
  }

  void _tick() {
    if (!mounted || _started) return;
    if (onboardingIsActive()) {
      _cancel();
      return;
    }
    if (_allKeysReady(widget.steps)) {
      _started = true;
      showOnboarding(
        context: context,
        steps: widget.steps,
        onComplete: widget.onComplete,
        onSkip: widget.onSkip,
      );
      _cancel();
      return;
    }
    if (_tries++ >= widget.maxPolls) {
      _cancel();
      return;
    }
    _timer = Timer(widget.pollInterval, _tick);
  }

  bool _allKeysReady(List<OnboardingStep> steps) {
    for (final s in steps) {
      final ctx = s.targetKey.currentContext;
      if (ctx == null) return false;
      if (s.destinationKey != null &&
          s.destinationKey!.currentContext == null) {
        return false;
      }
    }
    return true;
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
