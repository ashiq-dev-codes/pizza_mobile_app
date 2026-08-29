import 'package:flutter/material.dart';

/// Fades and scales [child] up into place as [animation] advances from 0 to
/// 1, growing from [from] (a fraction of resting scale) to 1.0. The scale
/// counterpart to [SlideFade], used where a reveal should read as a "pop"
/// rather than a slide — e.g. the size selector dial.
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
    final value = _animation.value.clamp(0.0, 1.0);
    return Opacity(
      opacity: value,
      child: Transform.scale(scale: from + (1 - from) * value, child: child),
    );
  }
}
