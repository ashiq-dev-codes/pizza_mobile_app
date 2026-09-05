import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/shared/path/app_images.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

/// Drives the splash intro's timeline: recreates the real Figma prototype
/// sequence (traced frame-by-frame from a screen recording of the live
/// preview, starting at node 617:1019):
///
/// 1. A pizza logo assembles from 8 slices while growing, on a plain white
///    screen (the `splash_N` cumulative frames).
/// 2. Once whole, it fades out while the background tints from white to the
///    product page's peach.
///
/// That's the whole splash — it hands off to [ProductScreen] the instant the
/// tint finishes, at a solid peach screen. [ProductScreen] owns everything
/// that happens after that (see `ProductIntroAnimation`).
class SplashIntroAnimation {
  SplashIntroAnimation({required TickerProvider vsync})
    : controller = AnimationController(vsync: vsync, duration: _totalDuration);

  // Same absolute millisecond timings as the original single 900ms timeline
  // (assembly ends ~378ms, bg starts tinting ~360ms, finishes ~520ms) — only
  // rescaled onto a shorter total now that the wipe/reveal tail has moved to
  // ProductScreen.
  static const _totalDuration = Duration(milliseconds: 520);

  // Named breakpoints, as fractions of the total timeline.
  static const assemblyEnd = 0.727;
  static const _bgFadeStart = 0.692;
  static const _bgFadeEnd = 1.0;
  static const pizzaFadeStart = 0.762;
  static const pizzaFadeEnd = 1.0;

  static final int stepCount = AppImages.splashFrames.length - 1;

  final AnimationController controller;

  Future<void> forward() => controller.forward();

  void dispose() => controller.dispose();

  /// Assembly progress, eased, spanning the whole logo phase.
  double assemblyT(double t) => Curves.easeOut.transform((t / assemblyEnd).clamp(0.0, 1.0));

  /// Assembled-logo size, as a fraction of screen width: fixed at the
  /// resting splash-logo size for the whole assembly phase — slices reveal
  /// in place rather than the logo scaling up as they're added — but once
  /// whole, it shrinks back down toward nothing over the same window (and
  /// on the same curve) as [pizzaFadeOpacity]'s fade, so the logo visibly
  /// shrinks away rather than just fading out at a fixed size.
  double assemblySizeFactor(double t) {
    const restingSize = 0.72;
    if (t < pizzaFadeStart) return restingSize;
    final localT = ((t - pizzaFadeStart) / (pizzaFadeEnd - pizzaFadeStart)).clamp(0.0, 1.0);
    return restingSize * (1 - Curves.easeIn.transform(localT));
  }

  /// Fades the assembled logo out once the background starts tinting peach.
  double pizzaFadeOpacity(double t) {
    if (t < pizzaFadeStart) return 1;
    final localT = ((t - pizzaFadeStart) / (pizzaFadeEnd - pizzaFadeStart)).clamp(0.0, 1.0);
    return 1 - Curves.easeIn.transform(localT);
  }

  double bgBlend(double t) {
    if (t < _bgFadeStart) return 0;
    final localT = ((t - _bgFadeStart) / (_bgFadeEnd - _bgFadeStart)).clamp(0.0, 1.0);
    return Curves.easeInOut.transform(localT);
  }

  Color bgColor(double t) => Color.lerp(AppColors.white, AppColors.background, bgBlend(t))!;
}
