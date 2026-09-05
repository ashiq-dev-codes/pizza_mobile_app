import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/spring_curve.dart';

/// Drives the product page's tap-to-zoom: the center pizza grows in place,
/// anchored on its own on-screen rect, up to a screen-filling close-up, then
/// shrinks back the same way on the reverse tap — while the rest of the
/// page's chrome slides/fades out of the way in lockstep (see
/// [ProductScreen]'s `_chromeVisibility`/`_bottomVisibility`, which are
/// driven directly off this animation's [progress]).
///
/// The source Figma prototype itself plays this in well under 200ms, but at
/// that speed the chrome's own push-out is essentially subliminal — this is
/// the one place this app deliberately runs slower than the source, so both
/// halves of the motion (pizza growing, chrome clearing out) are actually
/// visible rather than just implied. [SpringCurve.gentle] gives it a full,
/// clearly-readable settle with a gentle overshoot across the whole
/// duration, rather than [SpringCurve.snappy]'s near-instant snap.
class PizzaZoomAnimation {
  PizzaZoomAnimation({required TickerProvider vsync})
    : controller = AnimationController(vsync: vsync, duration: _duration);

  static const _duration = Duration(milliseconds: 340);

  final AnimationController controller;

  late final Animation<double> progress = CurvedAnimation(
    parent: controller,
    curve: SpringCurve.gentle(settleDuration: _duration),
    reverseCurve: SpringCurve.gentle(settleDuration: _duration),
  );

  bool get isOpen => controller.status != AnimationStatus.dismissed;

  TickerFuture open() => controller.forward();

  TickerFuture close() => controller.reverse();

  void dispose() => controller.dispose();
}
