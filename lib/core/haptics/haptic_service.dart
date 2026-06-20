import 'package:flutter/services.dart';

class HapticService {
  bool _enabled = true;

  void setEnabled(bool v) => _enabled = v;
  bool get isEnabled => _enabled;

  void light() {
    if (_enabled) HapticFeedback.lightImpact();
  }

  void medium() {
    if (_enabled) HapticFeedback.mediumImpact();
  }

  void heavy() {
    if (_enabled) HapticFeedback.heavyImpact();
  }

  void success() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 120), HapticFeedback.lightImpact);
  }
}
