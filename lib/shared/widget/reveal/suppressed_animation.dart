import 'package:flutter/animation.dart';

/// An animation that tracks [base] but gets pulled back toward 0 as
/// [suppressor] rises toward 1 — `value = base.value * (1 - suppressor.value)`.
///
/// Lets a page's entrance chrome (navbar, bottom bar) that already slid/faded
/// in via [base] also slide/fade back out when something else takes over the
/// screen (e.g. a full-bleed zoom), and back in when it recedes — reusing the
/// exact same [SlideFade]/[ScaleFade] widgets and travel distances as the
/// entrance itself, rather than a second, separately-tuned exit animation.
class SuppressedAnimation extends Animation<double>
    with
        AnimationLazyListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  SuppressedAnimation({required this.base, required this.suppressor});

  final Animation<double> base;
  final Animation<double> suppressor;

  @override
  void didStartListening() {
    base.addListener(notifyListeners);
    suppressor.addListener(notifyListeners);
    base.addStatusListener(_forwardStatus);
  }

  @override
  void didStopListening() {
    base.removeListener(notifyListeners);
    suppressor.removeListener(notifyListeners);
    base.removeStatusListener(_forwardStatus);
  }

  void _forwardStatus(AnimationStatus _) => notifyStatusListeners(status);

  @override
  AnimationStatus get status => base.status;

  @override
  double get value => base.value * (1 - suppressor.value);
}
