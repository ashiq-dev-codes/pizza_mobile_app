import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/spring_curve.dart';

/// Wraps [child] with the tactile press feedback iOS controls have and
/// Material's `InkWell` ripple alone doesn't: it scales down the instant a
/// finger touches down and springs back with a slight overshoot on release,
/// so every tappable control in the app reads as physical rather than flat.
///
/// Built on [Listener] rather than a tap [GestureDetector] specifically so
/// it never enters the gesture arena — it observes raw pointer down/up/
/// cancel purely to drive the animation, leaving whatever tap recognizer
/// [child] already owns (an `InkWell`, another `GestureDetector`) completely
/// unaffected. That means this can wrap any existing tappable widget without
/// risk of stealing or double-firing its tap.
class TapScale extends StatefulWidget {
  const TapScale({
    super.key,
    required this.child,
    this.pressedScale = 0.92,
    this.enabled = true,
  });

  final Widget child;

  /// How far the child shrinks while pressed, as a fraction of its size.
  final double pressedScale;

  /// When false, presses produce no visual feedback — for controls whose
  /// action is currently disabled (e.g. a stepper button at its bound).
  final bool enabled;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  static const _releaseDuration = Duration(milliseconds: 260);

  late final Animation<double> _scale = _controller
      .drive(CurveTween(curve: Curves.easeOut))
      .drive(Tween<double>(begin: 1, end: widget.pressedScale));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _press(PointerDownEvent _) {
    if (!widget.enabled) return;
    _controller.animateTo(1, duration: const Duration(milliseconds: 90), curve: Curves.easeOut);
  }

  void _release([PointerEvent? _]) {
    if (!widget.enabled) return;
    _controller.animateTo(
      0,
      duration: _releaseDuration,
      curve: SpringCurve.snappy(settleDuration: _releaseDuration),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _press,
      onPointerUp: _release,
      onPointerCancel: _release,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}
