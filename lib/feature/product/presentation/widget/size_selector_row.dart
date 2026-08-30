import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_size.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

class SizeSelectorRow extends StatelessWidget {
  const SizeSelectorRow({
    super.key,
    required this.selectedSize,
    required this.onSelect,
  });

  final PizzaSize selectedSize;
  final ValueChanged<PizzaSize> onSelect;

  static const _circleSize = 48.0;

  /// How much lower the selected chip sits than its neighbours — the source
  /// design pops the active size down and out of the row rather than just
  /// recoloring it in place.
  static const _selectedDrop = 20.0;
  static const _slotHeight = _circleSize + _selectedDrop;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: PizzaSize.values.map((size) {
        final selected = size == selectedSize;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 33),
          child: SizedBox(
            height: _slotHeight,
            child: Align(
              alignment: selected
                  ? Alignment.bottomCenter
                  : Alignment.topCenter,
              child: GestureDetector(
                onTap: () => onSelect(size),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _circleSize,
                  height: _circleSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.black : AppColors.white,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: AppColors.white, width: 2)
                        : null,
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
            ),
          ),
        );
      }).toList(),
    );
  }
}
