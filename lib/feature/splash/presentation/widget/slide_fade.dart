import 'package:flutter/material.dart';

/// Fades and slides [child] into place as [animation] advances from 0 to 1,
/// sliding in from [from] pixels along the given axis. Used throughout the
/// splash intro so each element's entrance reads as a "reveal" rather than
/// an abrupt appearance.
class SlideFade extends AnimatedWidget {
  const SlideFade.x({super.key, required Animation<double> animation, required double from, required this.child})
    : _dx = from,
      _dy = 0,
      super(listenable: animation);

  const SlideFade.y({super.key, required Animation<double> animation, required double from, required this.child})
    : _dx = 0,
      _dy = from,
      super(listenable: animation);

  final double _dx;
  final double _dy;
  final Widget child;

  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final value = _animation.value;
    return Opacity(
      opacity: value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset((1 - value) * _dx, (1 - value) * _dy),
        child: child,
      ),
    );
  }
}
