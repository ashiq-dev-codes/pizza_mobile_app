import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/product/presentation/page/product_page.dart';
import 'package:pizza_mobile_app/shared/path/app_images.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _assemblyDuration = Duration(milliseconds: 700);
  static const _holdOnComplete = Duration(milliseconds: 80);
  static const _backgroundFadeDuration = Duration(milliseconds: 180);

  final int _stepCount = AppImages.splashFrames.length - 1;

  late final AnimationController _assemblyController;
  late final AnimationController _bgController;
  late final Animation<Color?> _bgColor = ColorTween(
    begin: AppColors.white,
    end: AppColors.background,
  ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _assemblyController = AnimationController(
      vsync: this,
      duration: _assemblyDuration,
    );
    _bgController = AnimationController(
      vsync: this,
      duration: _backgroundFadeDuration,
    );

    _runSequence();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      for (final path in AppImages.splashFrames) {
        precacheImage(AssetImage(path), context);
      }
    }
  }

  Future<void> _runSequence() async {
    await _assemblyController.forward();
    if (!mounted) return;

    await Future.delayed(_holdOnComplete);
    if (!mounted) return;

    await _bgController.forward();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) => const ProductScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _assemblyController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pizzaSize = MediaQuery.sizeOf(context).width * 0.72;

    return AnimatedBuilder(
      animation: Listenable.merge([_assemblyController, _bgColor]),
      builder: (context, child) {
        // Frames are cumulative (each has one more slice than the last), so a
        // smooth dissolve only needs the next frame to fade in on top of a
        // fully opaque current frame — fading the current one out too would
        // wash out the slices they share in common, reading as a flicker.
        final progress = _assemblyController.value * _stepCount;
        final baseIndex = progress.floor().clamp(0, _stepCount - 1);
        final sliceT = Curves.easeOut.transform(
          (progress - baseIndex).clamp(0.0, 1.0),
        );

        return Scaffold(
          backgroundColor: _bgColor.value,
          body: Center(
            child: SizedBox(
              width: pizzaSize,
              height: pizzaSize,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    AppImages.splashFrames[baseIndex],
                    fit: BoxFit.contain,
                  ),
                  Opacity(
                    opacity: sliceT,
                    child: Image.asset(
                      AppImages.splashFrames[baseIndex + 1],
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
