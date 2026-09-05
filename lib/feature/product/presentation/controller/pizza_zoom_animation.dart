import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/spring_curve.dart';

/// Drives the product page's tap-to-zoom: the center pizza grows in place,
/// anchored on its own on-screen rect, up to a screen-filling close-up, then
/// shrinks back the same way on the reverse tap. Matches the source Figma
/// prototype's own timing — a snappy sub-200ms scale with a faint settle,
/// not a page-transition-length animation — so [SpringCurve.snappy] retunes
/// [SpringCurve.gentle]'s stiffness/damping to keep the same damping *ratio*
/// (and so the same character of motion) at roughly this animation's own
/// natural response time; reusing [SpringCurve.gentle] outright at this
/// duration would get hard-snapped to its resting value long before its own
/// (much slower) physical settle ever plays out.
class PizzaZoomAnimation {
  PizzaZoomAnimation({required TickerProvider vsync})
    : controller = AnimationController(vsync: vsync, duration: _duration);

  static const _duration = Duration(milliseconds: 180);

  final AnimationController controller;

  late final Animation<double> progress = CurvedAnimation(
    parent: controller,
    curve: SpringCurve.snappy(settleDuration: _duration),
    reverseCurve: SpringCurve.snappy(settleDuration: _duration),
  );

  bool get isOpen => controller.status != AnimationStatus.dismissed;

  TickerFuture open() => controller.forward();

  TickerFuture close() => controller.reverse();

  void dispose() => controller.dispose();
}
