import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_size.dart';
import 'package:pizza_mobile_app/feature/product/presentation/page/product_page.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/controller/splash_intro_animation.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/widget/description_reveal.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/widget/order_row_reveal.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/widget/pizza_assembly_overlay.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/widget/pizza_assembly_stage.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/widget/size_reveal_area.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/widget/splash_navbar.dart';
import 'package:pizza_mobile_app/shared/path/app_images.dart';

/// The splash intro — see [SplashIntroAnimation] for the timeline this
/// screen renders. Hands off to [ProductScreen] with no visible seam once
/// the intro completes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final _anim = SplashIntroAnimation(vsync: this);

  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _anim.forward().whenComplete(_goToProduct);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      for (final path in AppImages.splashFrames) {
        precacheImage(AssetImage(path), context);
      }
      for (final path in AppImages.productPizzas) {
        precacheImage(AssetImage(path), context);
      }
      precacheImage(AssetImage(AppImages.bananaScale), context);
    }
  }

  void _goToProduct() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => const ProductScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return AnimatedBuilder(
      animation: _anim.controller,
      builder: (context, _) {
        final t = _anim.controller.value;
        return Scaffold(
          backgroundColor: _anim.bgColor(t),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    SplashNavbar(animation: _anim.navbarIn),
                    Expanded(
                      child: Column(
                        children: [
                          PizzaAssemblyStage(
                            width: width,
                            t: t,
                            anim: _anim,
                            peekIn: _anim.peekIn,
                            heroWidthFactor: PizzaSize.medium.widthFactor,
                          ),
                          SizeRevealArea(animation: _anim.bananaSizeIn),
                          const SizedBox(height: 20),
                          DescriptionReveal(animation: _anim.descriptionIn),
                          const SizedBox(height: 20),
                          OrderRowReveal(animation: _anim.orderRowIn),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
                // Rendered independently of the layout above, centered on the
                // full screen like a conventional splash logo — the lower
                // rows already reserve their final resting space even while
                // invisible, which would otherwise pin this to the top.
                PizzaAssemblyOverlay(width: width, t: t, anim: _anim),
              ],
            ),
          ),
        );
      },
    );
  }
}
