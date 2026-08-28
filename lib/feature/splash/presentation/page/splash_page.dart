import 'dart:async';

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
    with SingleTickerProviderStateMixin {
  static const _frameInterval = Duration(milliseconds: 220);
  static const _holdOnComplete = Duration(milliseconds: 500);
  static const _backgroundFadeDuration = Duration(milliseconds: 450);

  late final AnimationController _bgController;
  late final Animation<Color?> _bgColor;

  int _frameIndex = 0;
  Timer? _frameTimer;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: _backgroundFadeDuration,
    );
    _bgColor = ColorTween(
      begin: AppColors.white,
      end: AppColors.background,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _startAssembly();
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

  void _startAssembly() {
    _frameTimer = Timer.periodic(_frameInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_frameIndex >= AppImages.splashFrames.length - 1) {
        timer.cancel();
        _finishAssembly();
        return;
      }
      setState(() => _frameIndex++);
    });
  }

  Future<void> _finishAssembly() async {
    await Future.delayed(_holdOnComplete);
    if (!mounted) return;

    await _bgController.forward();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => const ProductScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pizzaSize = MediaQuery.sizeOf(context).width * 0.72;

    return AnimatedBuilder(
      animation: _bgColor,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _bgColor.value,
          body: Center(
            child: AnimatedSwitcher(
              duration: _frameInterval,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: Image.asset(
                AppImages.splashFrames[_frameIndex],
                key: ValueKey(_frameIndex),
                width: pizzaSize,
                height: pizzaSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}
