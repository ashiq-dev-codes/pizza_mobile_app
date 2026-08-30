import 'package:flutter/material.dart';

/// Drives the product page's pizza-carousel swap: tapping a peeking pizza
/// pulls it to center while the current center slides out to the opposite
/// peek slot. [progress] is the per-frame value the carousel reads to place
/// each pizza; the title and description key off [toIndex] alone, since
/// they crossfade in place rather than sliding with the pizza.
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

  void switchTo(int index) {
    if (index == toIndex) return;
    fromIndex = toIndex;
    toIndex = index;
    controller.forward(from: 0);
  }

  void dispose() => controller.dispose();
}
