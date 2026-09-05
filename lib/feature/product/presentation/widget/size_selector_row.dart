import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_size.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';
import 'package:pizza_mobile_app/shared/widget/button/tap_scale.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/spring_curve.dart';

class SizeSelectorRow extends StatelessWidget {
  const SizeSelectorRow({
    super.key,
    required this.selectedSize,
    required this.onSelect,
  });

  final PizzaSize selectedSize;
  final ValueChanged<PizzaSize> onSelect;

  static const _circleSize = 48.0;

  /// How much lower M sits than S and L — a fixed curve matching the
  /// banana-arc theme, tied to *which size* a chip is rather than whether
  /// it's currently selected, so the row's shape never moves on tap.
  static const _midDrop = 20.0;
  static const _rowHeight = _circleSize + _midDrop;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: PizzaSize.values.map((size) {
        final selected = size == selectedSize;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 33),
          child: SizedBox(
            height: _rowHeight,
            child: Align(
              alignment: size == PizzaSize.medium
                  ? Alignment.bottomCenter
                  : Alignment.topCenter,
              child: TapScale(
                enabled: !selected,
                child: GestureDetector(
                  onTap: () {
                    if (!selected) HapticFeedback.selectionClick();
                    onSelect(size);
                  },
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(selected),
                    tween: Tween(begin: selected ? 0.8 : 1, end: 1),
                    duration: const Duration(milliseconds: 260),
                    curve: SpringCurve.elastic(settleDuration: const Duration(milliseconds: 260)),
                    builder: (context, pop, child) => Transform.scale(scale: pop, child: child),
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
            ),
          ),
        );
      }).toList(),
    );
  }
}
