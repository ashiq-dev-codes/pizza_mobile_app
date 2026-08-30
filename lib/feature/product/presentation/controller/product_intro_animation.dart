import 'package:flutter/material.dart';

/// Drives the product page's own entrance, picked up the instant the splash
/// screen hands off at a solid peach screen:
///
/// 1. The peach background — a single circle, fixed in place — shrinks from
///    big enough to fill the whole screen down to its resting size, reading
///    as "the background reduces down into the dome behind the pizza".
/// 2. The real navbar, pizza, size dial, description, and order row cascade
///    in on top of it — same relative stagger/durations/curves as the old
///    splash reveal (navbar first, then size dial, description, order row),
///    just re-anchored to "after the background settles" instead of "after
///    the hero pizza pops in".
class ProductIntroAnimation {
  ProductIntroAnimation({required TickerProvider vsync})
    : controller = AnimationController(vsync: vsync, duration: _totalDuration) {
    collapse = _interval(0, collapseEnd, curve: Curves.easeOut);
    heroIn = _interval(heroStart, heroEnd);
    navbarIn = _reveal(afterHeroMs: 50, durationMs: 170);
    sizeAreaIn = _reveal(afterHeroMs: 90, durationMs: 180);
    descriptionIn = _reveal(afterHeroMs: 130, durationMs: 175);
    orderRowIn = _reveal(afterHeroMs: 150, durationMs: 165);
  }

  // The collapse gets more room than the old splash wipe did (260ms vs.
  // 126ms) — at the wipe's original duration, easeOut's front-loading made
  // the shrink resolve within the first video-recorded frame or two, reading
  // as an instant cut rather than a visible "bg reduces size" motion. The
  // reveal cascade keeps the old stagger deltas/durations relative to the
  // hero pop (50/170, 90/180, 130/175, 150/165ms), just re-anchored to a
  // later hero start so it still picks up right as the bg settles.
  static const _totalDuration = Duration(milliseconds: 650);
  static const double _totalMs = 650;

  static const collapseEnd = 260 / _totalMs;
  static const heroStart = 180 / _totalMs;
  static const heroEnd = 400 / _totalMs;

  final AnimationController controller;

  late final Animation<double> collapse;
  late final Animation<double> heroIn;
  late final Animation<double> navbarIn;
  late final Animation<double> sizeAreaIn;
  late final Animation<double> descriptionIn;
  late final Animation<double> orderRowIn;

  Animation<double> _interval(double start, double end, {Curve curve = Curves.easeOutCubic}) =>
      CurvedAnimation(parent: controller, curve: Interval(start, end, curve: curve));

  /// A reveal-phase interval timed relative to the hero pizza's own pop-in
  /// ([heroStart]), so each element's delay and duration can be specified in
  /// milliseconds rather than as raw fractions of the total timeline.
  Animation<double> _reveal({required double afterHeroMs, required double durationMs}) {
    final start = heroStart + afterHeroMs / _totalMs;
    final end = start + durationMs / _totalMs;
    return _interval(start, end);
  }

  Future<void> forward() => controller.forward();

  void dispose() => controller.dispose();
}
