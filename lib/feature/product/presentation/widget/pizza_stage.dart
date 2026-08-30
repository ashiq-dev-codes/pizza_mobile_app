import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_catalog.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_size.dart';
import 'package:pizza_mobile_app/feature/product/constant/product_constants.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

/// The hero pizza plus its two peeking neighbours. Tapping a peek pulls that
/// pizza to center while the current center slides out to the opposite peek
/// slot — driven by [progress] sweeping 0→1 from [fromIndex] to [toIndex],
/// so every pizza's position, size, and opacity are just a function of how
/// far its own catalog index sits from that continuously-interpolated
/// center-of-focus.
class PizzaStage extends AnimatedWidget {
  const PizzaStage({
    super.key,
    required this.width,
    required this.selectedSize,
    required this.fromIndex,
    required this.toIndex,
    required Animation<double> progress,
    required this.onSelectIndex,
    required this.onTapZoom,
  }) : super(listenable: progress);

  final double width;
  final PizzaSize selectedSize;
  final int fromIndex;
  final int toIndex;
  final ValueChanged<int> onSelectIndex;
  final VoidCallback onTapZoom;

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final t = _progress.value;
    final focus = fromIndex + (toIndex - fromIndex) * t;
    final switching = t > 0.0 && t < 1.0;

    final stageHeight = width * 0.85;
    final pizzaSize = width * selectedSize.widthFactor;
    final peekSize = width * (80 / 375);
    final spacing = pizzaSize / 2;
    final centerX = width / 2;
    final centerY = stageHeight / 2;

    // Paint center-outward: a peek's small circle sits flush against the
    // edge of the center pizza's much larger (mostly-transparent) bounding
    // box, so without this ordering the center's box would swallow taps
    // meant for the peek right at that shared edge.
    final paintOrder = List<int>.generate(PizzaCatalog.all.length, (i) => i)
      ..sort((a, b) => (a - focus).abs().compareTo((b - focus).abs()));

    return SizedBox(
      width: width,
      height: stageHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final i in paintOrder)
            _stageItem(i, focus, pizzaSize, peekSize, spacing, centerX, centerY, switching),
          Positioned(
            left: centerX - width * (24 / 375),
            top: centerY - width * (24 / 375),
            child: GestureDetector(
              onTap: onTapZoom,
              child: Icon(
                LucideIcons.search,
                size: width * (48 / 375),
                color: AppColors.white,
                shadows: const [Shadow(color: Colors.black38, blurRadius: 6)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stageItem(
    int i,
    double focus,
    double pizzaSize,
    double peekSize,
    double spacing,
    double centerX,
    double centerY,
    bool switching,
  ) {
    final slot = i - focus;
    final absSlot = slot.abs();
    if (absSlot > 1.6) return const SizedBox.shrink();

    final overshoot = (absSlot - 1).clamp(0.0, 1.0);
    final size = absSlot <= 1
        ? lerpDouble(pizzaSize, peekSize, absSlot.clamp(0.0, 1.0))!
        : lerpDouble(peekSize, peekSize * 0.7, overshoot)!;
    final opacity = absSlot <= 1 ? 1.0 : 1 - overshoot;
    final dx = slot * spacing;

    Widget image = AnimatedContainer(
      duration: switching ? Duration.zero : const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      child: Image.asset(PizzaCatalog.all[i].image, fit: BoxFit.contain),
    );
    if (i == toIndex) {
      image = Hero(tag: ProductConstants.pizzaHeroTag, child: image);
    }

    final onTap = i == toIndex
        ? onTapZoom
        : (i - toIndex).abs() == 1
        ? () => onSelectIndex(i)
        : null;

    return Positioned(
      left: centerX + dx - size / 2,
      top: centerY - size / 2,
      width: size,
      height: size,
      child: Opacity(
        opacity: opacity,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: image,
        ),
      ),
    );
  }
}
