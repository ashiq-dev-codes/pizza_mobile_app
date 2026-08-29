import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_size.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

class SizeSelectorRow extends StatelessWidget {
  const SizeSelectorRow({super.key, required this.selectedSize, required this.onSelect});

  final PizzaSize selectedSize;
  final ValueChanged<PizzaSize> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: PizzaSize.values.map((size) {
        final selected = size == selectedSize;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () => onSelect(size),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
          ),
        );
      }).toList(),
    );
  }
}
