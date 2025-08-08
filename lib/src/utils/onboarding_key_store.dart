import 'package:flutter/material.dart';

/// Simple global key store that returns a stable GlobalKey for a given string id.
class OnboardingKeyStore {
  OnboardingKeyStore._();
  static final OnboardingKeyStore instance = OnboardingKeyStore._();

  final Map<String, GlobalKey> _keys = {};

  GlobalKey key(String id) {
    return _keys.putIfAbsent(id, () => GlobalKey(debugLabel: id));
  }

  void clear() => _keys.clear();
}
