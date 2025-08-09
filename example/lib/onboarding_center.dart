import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onboarding_lib/onboarding_lib.dart';

/// Centralized onboarding registry + route-based auto start.
/// - Register steps per scope (usually route name without leading slash).
/// - Starts when route appears (with a tiny readiness poll for keys).
class OnboardingCenter extends GetxService {
  static OnboardingCenter get to => Get.find<OnboardingCenter>();

  final _registrars = <String, List<OnboardingStep> Function()>{}.obs;
  final _startedOnce = <String>{}.obs; // prevent double starts per scope

  void register(String scope, List<OnboardingStep> Function() builder) {
    _registrars[scope] = builder;
  }

  bool has(String scope) => _registrars.containsKey(scope);

  Future<void> start(BuildContext context, String scope,
      {bool once = true}) async {
    if (once && _startedOnce.contains(scope)) return;
    final builder = _registrars[scope];
    if (builder == null) return;
    final steps = builder();
    if (steps.isEmpty) return;

    // Poll a few times until keys are ready, then fire showOnboarding.
    const int maxPolls = 60;
    const Duration pollInterval = Duration(milliseconds: 120);
    for (int i = 0; i < maxPolls; i++) {
      if (_allKeysReady(steps)) {
        showOnboarding(context: context, steps: steps);
        _startedOnce.add(scope);
        return;
      }
      await Future.delayed(pollInterval);
    }
    // Give up silently if keys never become ready.
  }

  bool _allKeysReady(List<OnboardingStep> steps) {
    for (final s in steps) {
      if (s.targetKey.currentContext == null) return false;
      if (s.destinationKey != null &&
          s.destinationKey!.currentContext == null) {
        return false;
      }
    }
    return true;
  }
}

class OnbRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _maybeStart(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _maybeStart(newRoute);
  }

  void _maybeStart(Route route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty || name == Navigator.defaultRouteName) {
      return;
    }
    final scope = name.startsWith('/') ? name.substring(1) : name;
    final ctx = route.navigator?.context;
    if (ctx == null) return;
    if (OnboardingCenter.to.has(scope)) {
      // Fire-and-forget; center does readiness polling and single-active guard is in lib
      // ignore: discarded_futures
      OnboardingCenter.to.start(ctx, scope, once: true);
    }
  }
}
