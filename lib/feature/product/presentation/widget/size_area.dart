import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_size.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/size_selector_row.dart';
import 'package:pizza_mobile_app/shared/path/app_images.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';
import 'package:pizza_mobile_app/shared/widget/arc_text/arc_text.dart';

class SizeArea extends StatelessWidget {
  const SizeArea({
    super.key,
    required this.selectedSize,
    required this.onSelect,
  });

  final PizzaSize selectedSize;
  final ValueChanged<PizzaSize> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Painted first (underneath): the selected chip's white ring sits
          // on top of the banana, clipping its silhouette — not the other
          // way around — matching the source design.
          Positioned(
            bottom: 50,
            child: ArcText(
              text: 'Banana for scale',
              radius: 58,
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 0.5,
                fontStyle: FontStyle.italic,
                color: AppColors.black.withValues(alpha: 0.55),
              ),
            ),
          ),
          Positioned(
            bottom: 33,
            child: Image.asset(
              AppImages.bananaScale,
              width: 90,
              height: 58,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizeSelectorRow(
              selectedSize: selectedSize,
              onSelect: onSelect,
            ),
          ),
        ],
      ),
    );
  }
}
