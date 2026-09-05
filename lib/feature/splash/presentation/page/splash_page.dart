import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/product/presentation/page/product_page.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/controller/splash_intro_animation.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/widget/pizza_assembly_overlay.dart';
import 'package:pizza_mobile_app/shared/path/app_images.dart';

/// The splash intro — see [SplashIntroAnimation] for the timeline this
/// screen renders. Hands off to [ProductScreen] at a solid peach screen the
/// instant the tint finishes; [ProductScreen] takes it from there with its
/// own entrance animation.
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
          body: Stack(children: [PizzaAssemblyOverlay(width: width, t: t, anim: _anim)]),
        );
      },
    );
  }
}
