import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/product/constant/product_constants.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/widget/slide_fade.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

class DescriptionReveal extends StatelessWidget {
  const DescriptionReveal({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SlideFade.y(
      animation: animation,
      from: 20,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          ProductConstants.description,
          style: TextStyle(fontSize: 14, height: 1.7, color: AppColors.black),
        ),
      ),
    );
  }
}
