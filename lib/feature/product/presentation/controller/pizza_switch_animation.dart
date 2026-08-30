import 'package:flutter/material.dart';

/// Drives the product page's pizza-carousel swap: tapping a peeking pizza
/// pulls it to center while the current center slides out to the opposite
/// peek slot. [progress] is the single per-frame value the carousel, the
/// title, and the description all read to place themselves, so the three
/// move as one piece instead of drifting out of sync.
class PizzaSwitchAnimation {
  PizzaSwitchAnimation({required TickerProvider vsync, required int initialIndex})
    : controller = AnimationController(vsync: vsync, duration: _duration),
      fromIndex = initialIndex,
      toIndex = initialIndex;

  static const _duration = Duration(milliseconds: 380);

  final AnimationController controller;

  late final Animation<double> progress = CurvedAnimation(
    parent: controller,
    curve: Curves.easeOutCubic,
  );

  /// The carousel index being left, and the one being entered — both held
  /// fixed for the whole transition while [progress] sweeps 0 to 1 between
  /// them.
  int fromIndex;
  int toIndex;

  /// +1 when the newly-centered pizza came from the right (tapped the right
  /// peek), -1 from the left. Lets the title/description know which way to
  /// slide so they read as part of the same motion as the pizza itself.
  int direction = 0;

  void switchTo(int index) {
    if (index == toIndex) return;
    fromIndex = toIndex;
    toIndex = index;
    direction = (toIndex - fromIndex).sign;
    controller.forward(from: 0);
  }

  void dispose() => controller.dispose();
}
