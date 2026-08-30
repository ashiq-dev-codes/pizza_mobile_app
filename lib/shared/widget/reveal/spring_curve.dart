import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

/// A [Curve] shaped by a real spring simulation (Hooke's law + damping)
/// rather than a hand-authored easing polynomial, so a driven value
/// overshoots its resting position and settles with an elastic recoil
/// instead of a mathematically clean ease-out.
///
/// [settleDuration] is how much wall-clock time the curve's `t=1` endpoint
/// represents — it must roughly match the interval/tween's own duration, or
/// the spring gets sampled either well before it has overshot (too stiff a
/// window) or long after it's already settled (overshoot never reads).
class SpringCurve extends Curve {
  SpringCurve({
    required this.mass,
    required this.stiffness,
    required this.damping,
    required this.settleDuration,
  }) : _simulation = SpringSimulation(
         SpringDescription(mass: mass, stiffness: stiffness, damping: damping),
         0,
         1,
         0,
       ),
       _settleSeconds =
           settleDuration.inMicroseconds / Duration.microsecondsPerSecond;

  /// Rubber-band tension tuned for entrance reveals: high stiffness and a
  /// light mass so the motion feels snappy, with damping underdamped enough
  /// to overshoot by ~8% (e.g. scaling past 1.0 to ~1.08, or a slide
  /// continuing ~8% past its resting offset) before recoiling back —
  /// enough to read as a genuine spring rather than a barely-there wobble.
  /// [settleDuration] is deliberately given a little slack over this
  /// spring's own ~320ms natural settle time, so it decays to a near-exact
  /// rest before getting hard-snapped there — too little slack and that
  /// snap lands mid-recoil, which reads as a stutter, not a settle.
  factory SpringCurve.elastic({Duration settleDuration = const Duration(milliseconds: 340)}) =>
      SpringCurve(mass: 0.7, stiffness: 280, damping: 17.5, settleDuration: settleDuration);

  final double mass;
  final double stiffness;
  final double damping;
  final Duration settleDuration;

  final SpringSimulation _simulation;
  final double _settleSeconds;

  @override
  double transformInternal(double t) => _simulation.x(t * _settleSeconds);
}
