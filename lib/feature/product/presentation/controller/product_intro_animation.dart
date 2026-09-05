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
///    (static) Preload->product transition. It resolves quickly, then holds
///    on a plain empty dome for a beat — the source reference sits on a
///    completely blank peach screen for ~90ms before anything else appears,
///    a deliberate pause rather than content popping in immediately on the
///    dome's heels.
/// 2. [revealIn]: the navbar's three pieces converge from their own
///    off-canvas edge — back button from the left, title dropping from
///    above, favorite from the right — while the hero pizza fades in near
///    its resting size (a subtle pop, not a dramatic grow-from-a-pinpoint —
///    the source reference shows the pizza already close to full size
///    within the very first visible frame of the reveal). All four share
///    this *one* animation (rather than each getting its own
///    independently-timed spring) so they overshoot and settle in perfect
///    lockstep — reading as one cohesive snap instead of a jumble of
///    slightly-offset pops.
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
    collapse = _interval(0, _collapseMs, curve: Curves.easeOut);
    revealIn = _spring(_revealStart, _revealMs);
    springApartIn = _spring(_revealStart + _springApartOffset, _springApartMs);
  }

  // The two waves overlap deliberately: springApartIn starts while revealIn
  // is still mid-recoil, so the hero's settle and the lower bundle's
  // opening blend into one continuous motion rather than a visible
  // "first this, then that" handoff.
  //
  // Retimed to match the source Figma prototype's own hand-off — traced
  // frame-by-frame at 120fps from a second reference recording (UI/6.mov):
  // the dome settles almost immediately, then the screen sits completely
  // blank for ~90ms (_pauseMs) before the whole reveal snaps in and settles
  // in another ~110ms. That pause is what actually reads as a deliberate
  // "beat" rather than the content just arriving late — skipping it (as
  // this page's own earlier ~460ms single-block timeline did) makes the
  // hand-off feel rushed instead of anticipated.
  static const _collapseMs = 80.0;
  static const _pauseMs = 90.0;
  static const _revealStart = _collapseMs + _pauseMs;
  static const _revealMs = 180.0;
  static const _springApartOffset = 40.0;
  static const _springApartMs = 200.0;
  static const _totalDuration = Duration(milliseconds: 420);
  static const double _totalMs = 420;

  final AnimationController controller;

  late final Animation<double> collapse;
  late final Animation<double> revealIn;
  late final Animation<double> springApartIn;

  Animation<double> _interval(double startMs, double endMs, {required Curve curve}) =>
      CurvedAnimation(
        parent: controller,
        curve: Interval(startMs / _totalMs, endMs / _totalMs, curve: curve),
      );

  /// A [SpringCurve.snappy]-driven interval starting at [startMs] and
  /// running for [durationMs] — the curve's own settle window is kept in
  /// lockstep with the interval's real duration, since a spring sampled
  /// over a shorter window than it needs to settle would get hard-snapped
  /// to its resting value mid-overshoot. Uses the snappy (not elastic)
  /// tuning: at this reveal's now much shorter ~200-220ms window, elastic's
  /// own ~320ms natural settle time would get cut off mid-recoil.
  Animation<double> _spring(double startMs, double durationMs) => _interval(
    startMs,
    startMs + durationMs,
    curve: SpringCurve.snappy(settleDuration: Duration(milliseconds: durationMs.round())),
  );

  Future<void> forward() => controller.forward();

  void dispose() => controller.dispose();
}
