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
/// 3. A white circle grows in from below the screen and sweeps upward,
///    covering the peach everywhere except the small halo behind where the
///    hero pizza will sit.
/// 4. The navbar, hero pizza, banana/size row, description, and order row
///    fade/slide into their resting positions.
///
/// The whole thing runs in under a second in the source prototype, then
/// hands off to the product page with no visible seam.
class SplashIntroAnimation {
  SplashIntroAnimation({required TickerProvider vsync})
    : controller = AnimationController(vsync: vsync, duration: _totalDuration) {
    navbarIn = _interval(0.62, 0.80);
    peekIn = _interval(heroStart, heroEnd);
    bananaSizeIn = _interval(0.68, 0.88);
    descriptionIn = _interval(0.74, 0.92);
    orderRowIn = _interval(0.80, 1.0);
  }

  static const _totalDuration = Duration(milliseconds: 900);

  // Named breakpoints, as fractions of the total timeline.
  static const assemblyEnd = 0.42;
  static const _bgFadeStart = 0.40;
  static const _bgFadeEnd = 0.58;
  static const pizzaFadeStart = 0.44;
  static const pizzaFadeEnd = 0.58;
  static const _wipeStart = 0.56;
  static const _wipeEnd = 0.70;
  static const heroStart = 0.62;
  static const heroEnd = 0.82;

  static final int stepCount = AppImages.splashFrames.length - 1;

  final AnimationController controller;

  late final Animation<double> navbarIn;
  late final Animation<double> peekIn;
  late final Animation<double> bananaSizeIn;
  late final Animation<double> descriptionIn;
  late final Animation<double> orderRowIn;

  Animation<double> _interval(double start, double end) => CurvedAnimation(
    parent: controller,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
  );

  Future<void> forward() => controller.forward();

  void dispose() => controller.dispose();

  /// Assembly progress, eased, spanning the whole logo phase.
  double assemblyT(double t) => Curves.easeOut.transform((t / assemblyEnd).clamp(0.0, 1.0));

  /// Assembled-logo size, as a fraction of screen width: grows from a sliver
  /// up to the resting splash-logo size as slices are added.
  double assemblySizeFactor(double t) => 0.16 + 0.56 * assemblyT(t);

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

  /// The white wipe's diameter, as a multiple of screen width: 0 until the
  /// halo has faded in, then grows enough to sweep past the whole screen.
  double wipeDiameterFactor(double t) {
    if (t < _wipeStart) return 0;
    final localT = ((t - _wipeStart) / (_wipeEnd - _wipeStart)).clamp(0.0, 1.0);
    return Curves.easeInOut.transform(localT) * 4.2;
  }

  /// Hero pizza size, as a fraction of screen width: pops in to its resting
  /// size ([restingWidthFactor]) once the wipe has mostly covered the screen.
  double heroSizeFactor(double t, double restingWidthFactor) {
    final localT = ((t - heroStart) / (heroEnd - heroStart)).clamp(0.0, 1.0);
    return Curves.easeOutBack.transform(localT) * restingWidthFactor;
  }
}
