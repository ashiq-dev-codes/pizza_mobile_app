import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/controller/splash_intro_animation.dart';
import 'package:pizza_mobile_app/shared/path/app_images.dart';

/// The pizza logo assembling from cumulative slice frames, centered over the
/// full screen independently of the layout beneath it — like a conventional
/// splash logo. It must be a full-screen overlay rather than laid out inline
/// because the rows beneath it already reserve their final resting space
/// even while invisible, which would otherwise pin this to the top.
class PizzaAssemblyOverlay extends StatelessWidget {
  const PizzaAssemblyOverlay({super.key, required this.width, required this.t, required this.anim});

  final double width;
  final double t;
  final SplashIntroAnimation anim;

  @override
  Widget build(BuildContext context) {
    if (t >= SplashIntroAnimation.pizzaFadeEnd) return const SizedBox.shrink();

    final stepCount = SplashIntroAnimation.stepCount;
    final progress = anim.assemblyT(t) * stepCount;
    final baseIndex = progress.floor().clamp(0, stepCount - 1);
    final sliceT = Curves.easeOut.transform((progress - baseIndex).clamp(0.0, 1.0));
    final size = width * anim.assemblySizeFactor(t);

    return Positioned.fill(
      child: Center(
        child: Opacity(
          opacity: anim.pizzaFadeOpacity(t),
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(AppImages.splashFrames[baseIndex], fit: BoxFit.contain),
                Opacity(
                  opacity: sliceT,
                  child: Image.asset(AppImages.splashFrames[baseIndex + 1], fit: BoxFit.contain),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
