import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_size.dart';
import 'package:pizza_mobile_app/feature/product/constant/product_constants.dart';
import 'package:pizza_mobile_app/shared/path/app_images.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

class PizzaStage extends StatelessWidget {
  const PizzaStage({
    super.key,
    required this.width,
    required this.selectedSize,
    required this.onTapZoom,
  });

  final double width;
  final PizzaSize selectedSize;
  final VoidCallback onTapZoom;

  @override
  Widget build(BuildContext context) {
    final pizzaSize = width * selectedSize.widthFactor;
    final peekSize = width * (80 / 375);
    final peekOffset = width * (40 / 375);

    return SizedBox(
      height: width * 0.85,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -peekOffset,
            child: Image.asset(
              AppImages.productPizzas[0],
              width: peekSize,
              height: peekSize,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: -peekOffset,
            child: Image.asset(
              AppImages.productPizzas[2],
              width: peekSize,
              height: peekSize,
              fit: BoxFit.contain,
            ),
          ),
          GestureDetector(
            onTap: onTapZoom,
            child: Hero(
              tag: ProductConstants.pizzaHeroTag,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: pizzaSize,
                height: pizzaSize,
                child: Image.asset(
                  AppImages.productPizzas[1],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTapZoom,
            child: Icon(
              LucideIcons.search,
              size: width * (48 / 375),
              color: AppColors.white,
              shadows: const [Shadow(color: Colors.black38, blurRadius: 6)],
            ),
          ),
        ],
      ),
    );
  }
}
