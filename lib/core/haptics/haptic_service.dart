import 'package:flutter/services.dart';

class HapticService {
  bool _enabled = true;

  void setEnabled(bool v) => _enabled = v;
  bool get isEnabled => _enabled;

  // Successful arrow removal — light satisfying tap
  void light() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  // Blocked arrow tap — noticeable thud
  void medium() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
  }

  // Win — double pulse
  void success() {
    if (!_enabled) return;
    HapticFeedback.mediumImpact();
    Future.delayed(
      const Duration(milliseconds: 120),
      HapticFeedback.lightImpact,
    );
  }

  // Heavy error — e.g. out of lives
  void heavy() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }
}
