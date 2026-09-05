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

  /// Same ~8% overshoot and damping *ratio* as [elastic] — a clearly
  /// readable bounce, not just a crisp settle — but retuned for a much
  /// shorter natural response time — a sub-200ms in-place scale, say —
  /// rather than [elastic]'s ~320ms. A spring's physical settle time comes
  /// from its mass/stiffness/damping, not from [settleDuration]; reusing
  /// [elastic]'s own tension at a much shorter [settleDuration] would sample
  /// only the very first sliver of its motion and hard-snap the rest,
  /// reading as an instant cut instead of a bounce.
  factory SpringCurve.snappy({Duration settleDuration = const Duration(milliseconds: 180)}) =>
      SpringCurve(mass: 1, stiffness: 1200, damping: 43, settleDuration: settleDuration);

  /// Tuned much more heavily damped than [elastic] — a ~3.5% overshoot,
  /// barely-there settle rather than a clearly bouncy one — with its own
  /// ~340ms natural response time. This is the "fluid, premium iOS" feel
  /// (think a Photos app image opening full-screen, or a sheet settling
  /// into place): a quick, smooth rise that's already most of the way
  /// there by the midpoint, then a gentle glide to rest, rather than a
  /// springy toy-like bounce. [settleDuration] must be retuned alongside
  /// stiffness/damping (not just widened) if the target duration changes —
  /// a spring's physical settle time comes from its own mass/stiffness/
  /// damping, not from [settleDuration]; widening this past that natural
  /// settle just adds a frozen hold at the end instead of a slower motion.
  factory SpringCurve.gentle({Duration settleDuration = const Duration(milliseconds: 340)}) =>
      SpringCurve(mass: 1, stiffness: 251, damping: 23, settleDuration: settleDuration);

  final double mass;
  final double stiffness;
  final double damping;
  final Duration settleDuration;

  final SpringSimulation _simulation;
  final double _settleSeconds;

  @override
  double transformInternal(double t) => _simulation.x(t * _settleSeconds);
}
