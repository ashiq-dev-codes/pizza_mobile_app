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
    peekIn = _interval(heroStart, heroEnd);
    // Hand-off cascade: the hero pizza pops in first, then the rest of the
    // product chrome follows behind it — header first, with a 50ms stagger,
    // then the size selector and description, with the order row settling
    // last. Each element keeps a full ~170-180ms glide (rather than being
    // compressed to fit), and all of them clear their rest state well
    // before the 900ms mark so nothing pops on the swap to the product page.
    navbarIn = _reveal(afterHeroMs: 50, durationMs: 170);
    bananaSizeIn = _reveal(afterHeroMs: 90, durationMs: 180);
    descriptionIn = _reveal(afterHeroMs: 130, durationMs: 175);
    orderRowIn = _reveal(afterHeroMs: 150, durationMs: 165);
  }

  static const _totalDuration = Duration(milliseconds: 900);
  static const double _totalMs = 900;

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

  /// A reveal-phase interval timed relative to the hero image's own entrance
  /// ([heroStart]), so each element's delay and duration can be specified in
  /// milliseconds rather than as raw fractions of the total timeline.
  Animation<double> _reveal({required double afterHeroMs, required double durationMs}) {
    final start = heroStart + afterHeroMs / _totalMs;
    final end = start + durationMs / _totalMs;
    return _interval(start, end);
  }

  Future<void> forward() => controller.forward();

  void dispose() => controller.dispose();

  /// Assembly progress, eased, spanning the whole logo phase.
  double assemblyT(double t) => Curves.easeOut.transform((t / assemblyEnd).clamp(0.0, 1.0));

  /// Assembled-logo size, as a fraction of screen width: fixed at the
  /// resting splash-logo size for the whole assembly phase — slices reveal
  /// in place rather than the logo scaling up as they're added.
  double assemblySizeFactor(double t) => 0.72;

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

  /// Hero pizza's pop-in scale (0→1), once the wipe has mostly covered the
  /// screen. Meant to drive a `Transform.scale` on a fixed-size child rather
  /// than the child's actual width/height, so the pop is a cheap paint-time
  /// transform instead of a per-frame relayout — and shares the same ease as
  /// the rest of the reveal cascade so nothing reads as the odd one out.
  double heroScale(double t) {
    final localT = ((t - heroStart) / (heroEnd - heroStart)).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(localT);
  }
}
