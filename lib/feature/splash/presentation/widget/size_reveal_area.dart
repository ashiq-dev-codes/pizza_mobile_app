import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_size.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/widget/scale_fade.dart';
import 'package:pizza_mobile_app/shared/path/app_images.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';
import 'package:pizza_mobile_app/shared/widget/arc_text/arc_text.dart';

/// Mirrors the product page's size selector at its resting (Medium-selected)
/// state — the splash intro previews it as a static reveal rather than an
/// interactive control.
class SizeRevealArea extends StatelessWidget {
  const SizeRevealArea({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: ScaleFade(animation: animation, from: 0.82, child: _staticSizeRow()),
          ),
          Positioned(
            bottom: 32,
            child: ScaleFade(
              animation: animation,
              from: 0.82,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ArcText(
                    text: 'Banana for scale',
                    radius: 58,
                    style: TextStyle(
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: AppColors.black.withValues(alpha: 0.55),
                    ),
                  ),
                  Image.asset(
                    AppImages.bananaScale,
                    width: 90,
                    height: 58,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _staticSizeRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: PizzaSize.values.map((size) {
        final selected = size == PizzaSize.medium;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.black : AppColors.white,
              shape: BoxShape.circle,
              border: selected ? Border.all(color: AppColors.white, width: 2) : null,
              boxShadow: selected
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Text(
              size.label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
