import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/spring_curve.dart';

/// Drives the product page's own entrance, picked up the instant the splash
/// screen hands off at a solid peach screen. Mirrors the source Figma
/// prototype's "Preload" -> "Pepperoni Blast" transition, where the peach
/// dome is already at rest throughout and only the content on top of it
/// moves, in two synchronized waves rather than many independently-timed
/// pieces:
///
/// 1. The peach background — a single circle, fixed in place — shrinks from
///    big enough to fill the whole screen down to its resting size. This
///    stays a plain ease-out, matching the splash hand-off rather than the
///    (static) Preload->product transition.
/// 2. [revealIn]: the navbar's three pieces converge from their own
///    off-canvas edge — back button from the left, title dropping from
///    above, favorite from the right — while the hero pizza grows from a
///    pinpoint at its own center. All four share this *one* animation
///    (rather than each getting its own independently-timed spring) so
///    they overshoot and settle in perfect lockstep — reading as one
///    cohesive snap instead of a jumble of slightly-offset pops.
/// 3. [springApartIn]: the size dial, description, and bottom bar — bunched
///    together off the bottom edge in the source design — spring apart
///    upward into their spread-out resting spots together, each traveling
///    its own real distance (370/250/140px) but on the same shared timing,
///    so the bundle opens up as one motion. That differential-distance,
///    single-timing spring is what actually produces the "elastic stretch"
///    look, not a per-item staggered slide.
class ProductIntroAnimation {
  ProductIntroAnimation({required TickerProvider vsync})
    : controller = AnimationController(vsync: vsync, duration: _totalDuration) {
    collapse = _interval(0, 200, curve: Curves.easeOut);
    revealIn = _spring(0, _revealMs);
    springApartIn = _spring(_springApartStart, _springApartMs);
  }

  // The two waves overlap deliberately: springApartIn starts while revealIn
  // is still mid-recoil, so the hero's settle and the lower bundle's
  // opening blend into one continuous motion rather than a visible
  // "first this, then that" handoff.
  static const _revealMs = 340.0;
  static const _springApartStart = 90.0;
  static const _springApartMs = 340.0;
  static const _totalDuration = Duration(milliseconds: 460);
  static const double _totalMs = 460;

  final AnimationController controller;

  late final Animation<double> collapse;
  late final Animation<double> revealIn;
  late final Animation<double> springApartIn;

  Animation<double> _interval(double startMs, double endMs, {required Curve curve}) =>
      CurvedAnimation(
        parent: controller,
        curve: Interval(startMs / _totalMs, endMs / _totalMs, curve: curve),
      );

  /// A [SpringCurve.elastic]-driven interval starting at [startMs] and
  /// running for [durationMs] — the curve's own settle window is kept in
  /// lockstep with the interval's real duration, since a spring sampled
  /// over a shorter window than it needs to settle would get hard-snapped
  /// to its resting value mid-overshoot.
  Animation<double> _spring(double startMs, double durationMs) => _interval(
    startMs,
    startMs + durationMs,
    curve: SpringCurve.elastic(settleDuration: Duration(milliseconds: durationMs.round())),
  );

  Future<void> forward() => controller.forward();

  void dispose() => controller.dispose();
}
