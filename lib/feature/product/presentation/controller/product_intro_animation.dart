import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/spring_curve.dart';

/// Drives the product page's own entrance, picked up the instant the splash
/// screen hands off at a solid peach screen. Mirrors the source Figma
/// prototype's "Preload" -> "Pepperoni Blast" transition, where the peach
/// dome is already at rest throughout and only the content on top of it
/// moves:
///
/// 1. The peach background — a single circle, fixed in place — shrinks from
///    big enough to fill the whole screen down to its resting size. This
///    stays a plain ease-out, matching the splash hand-off rather than the
///    (static) Preload->product transition.
/// 2. The navbar's three pieces converge from their own off-canvas edge —
///    back button from the left, title dropping from above, favorite from
///    the right — while the hero pizza grows from a pinpoint at its own
///    center. Then the size dial, description, and bottom bar — bunched
///    together off the bottom edge in the source design — spring apart
///    upward into their spread-out resting spots, each traveling its own
///    real distance (370/250/140px), which is what actually produces the
///    "elastic stretch" look: a tight bundle springing open, not a uniform
///    slide-up.
class ProductIntroAnimation {
  ProductIntroAnimation({required TickerProvider vsync})
    : controller = AnimationController(vsync: vsync, duration: _totalDuration) {
    collapse = _interval(0, 200, curve: Curves.easeOut);

    backIn = _spring(0);
    titleIn = _spring(15);
    favIn = _spring(30);
    heroIn = _spring(45);
    sizeAreaIn = _spring(110);
    descriptionIn = _spring(150);
    orderRowIn = _spring(190);
  }

  // Every staggered element rides the same spring settle window
  // (_springMs) — only its start offset changes — so the cascade reads as
  // one continuous ripple rather than independently-timed pieces. Tighter
  // than the source prototype's own pacing so the whole reveal reads as
  // quick and fluid rather than a visible sequence of steps: 15ms between
  // navbar pieces, 65/40/40ms between the hero and the size dial/
  // description/bottom bar waves.
  static const _springMs = 280;
  static const _totalDuration = Duration(milliseconds: 490);
  static const double _totalMs = 490;

  final AnimationController controller;

  late final Animation<double> collapse;
  late final Animation<double> backIn;
  late final Animation<double> titleIn;
  late final Animation<double> favIn;
  late final Animation<double> heroIn;
  late final Animation<double> sizeAreaIn;
  late final Animation<double> descriptionIn;
  late final Animation<double> orderRowIn;

  Animation<double> _interval(double startMs, double endMs, {required Curve curve}) =>
      CurvedAnimation(
        parent: controller,
        curve: Interval(startMs / _totalMs, endMs / _totalMs, curve: curve),
      );

  /// A [SpringCurve.elastic]-driven interval starting at [startMs] and
  /// running for [_springMs] — the curve's own settle window is kept in
  /// lockstep with the interval's real duration, since a spring sampled
  /// over a shorter window than it needs to settle would get hard-snapped
  /// to its resting value mid-overshoot.
  Animation<double> _spring(double startMs) => _interval(
    startMs,
    startMs + _springMs,
    curve: SpringCurve.elastic(settleDuration: const Duration(milliseconds: _springMs)),
  );

  Future<void> forward() => controller.forward();

  void dispose() => controller.dispose();
}
