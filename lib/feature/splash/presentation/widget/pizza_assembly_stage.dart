import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pizza_mobile_app/feature/product/constant/product_constants.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/controller/splash_intro_animation.dart';
import 'package:pizza_mobile_app/shared/path/app_images.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

/// The pizza reveal area: the white wipe sweeping in, the peach halo behind
/// it, and (once the assembly logo has faded) the peeking side pizzas, hero
/// pizza and search icon that hand off into the product page.
class PizzaAssemblyStage extends StatelessWidget {
  const PizzaAssemblyStage({
    super.key,
    required this.width,
    required this.t,
    required this.anim,
    required this.peekIn,
    required this.heroWidthFactor,
  });

  final double width;
  final double t;
  final SplashIntroAnimation anim;
  final Animation<double> peekIn;
  final double heroWidthFactor;

  @override
  Widget build(BuildContext context) {
    final peekSize = width * (80 / 375);
    final peekOffset = width * (40 / 375);
    final showAssembly = t < SplashIntroAnimation.pizzaFadeEnd;
    final wipeDiameter = width * anim.wipeDiameterFactor(t);
    final heroSize = width * anim.heroSizeFactor(t, heroWidthFactor);

    return SizedBox(
      height: width * 0.85,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // White wipe: anchored below this stage so its leading edge sweeps
          // upward across the screen as it grows.
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0, width * 0.35),
              child: Container(
                width: wipeDiameter,
                height: wipeDiameter,
                decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
              ),
            ),
          ),
          // Halo: fixed at its resting size/position, fading in with the
          // background tint so there is no visible seam once it's revealed.
          Opacity(
            opacity: anim.bgBlend(t),
            child: Container(
              width: width * 1.5,
              height: width * 1.5,
              decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
            ),
          ),
          if (!showAssembly) ...[
            Positioned(
              left: -peekOffset,
              child: Opacity(
                opacity: peekIn.value,
                child: Transform.scale(
                  scale: 0.9 + 0.1 * peekIn.value,
                  child: Image.asset(
                    AppImages.productPizzas[1],
                    width: peekSize,
                    height: peekSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -peekOffset,
              child: Opacity(
                opacity: peekIn.value,
                child: Transform.scale(
                  scale: 0.9 + 0.1 * peekIn.value,
                  child: Image.asset(
                    AppImages.productPizzas[2],
                    width: peekSize,
                    height: peekSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: peekIn.value,
              child: Hero(
                tag: ProductConstants.pizzaHeroTag,
                child: SizedBox(
                  width: heroSize,
                  height: heroSize,
                  child: Image.asset(AppImages.productPizzas.first, fit: BoxFit.contain),
                ),
              ),
            ),
            Opacity(
              opacity: peekIn.value,
              child: Icon(
                LucideIcons.search,
                size: width * (48 / 375),
                color: AppColors.white,
                shadows: const [Shadow(color: Colors.black38, blurRadius: 6)],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
