import 'package:flutter/material.dart';

/// Fades and scales [child] up into place as [animation] advances from 0 to
/// 1, growing from [from] (a fraction of resting scale) to 1.0. The scale
/// counterpart to [SlideFade], used where a reveal should read as a "pop"
/// rather than a slide — e.g. the size selector dial.
///
/// Only opacity is clamped to 0-1. The scale itself is left unclamped so
/// that a spring-shaped [animation] (see `SpringCurve`) can carry its
/// overshoot past 1.0 through to the transform, instead of it being cut off
/// at the resting scale.
class ScaleFade extends AnimatedWidget {
  const ScaleFade({
    super.key,
    required Animation<double> animation,
    this.from = 0.8,
    required this.child,
  }) : super(listenable: animation);

  final double from;
  final Widget child;

  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final value = _animation.value;
    return Opacity(
      opacity: value.clamp(0.0, 1.0),
      child: Transform.scale(scale: from + (1 - from) * value, child: child),
    );
  }
}
