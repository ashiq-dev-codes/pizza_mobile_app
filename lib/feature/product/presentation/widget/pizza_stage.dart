import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_catalog.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_size.dart';
import 'package:pizza_mobile_app/feature/product/constant/product_constants.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/spring_curve.dart';

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

  /// How long the center pizza's own resize tween runs when only the size
  /// (not the carousel focus) changes — kept equal to [SpringCurve.elastic]'s
  /// own settle window so its overshoot has room to read before the tween
  /// hard-stops at the target.
  static const _resizeDuration = Duration(milliseconds: 340);

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final t = _progress.value;
    final focus = fromIndex + (toIndex - fromIndex) * t;
    // True for the whole spring, overshoot and recoil included — not just
    // while the raw value sits between 0 and 1 — so the center pizza's own
    // resize (below) doesn't fight the spring with its own separate tween
    // once the curve first crosses 1.0 mid-bounce.
    final switching = _progress.status == AnimationStatus.forward;

    final stageHeight = width * 0.85;
    final pizzaSize = width * selectedSize.widthFactor;
    final peekSize = width * (85 / 375);
    // The peeking neighbours sit with their own center right at the screen
    // edge — so only about half of each is actually visible, sliced off by
    // the device edge itself — matching the source Figma prototype, rather
    // than floating fully on-screen next to the hero pizza.
    final spacing = width / 2;
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
            _stageItem(
              i,
              focus,
              pizzaSize,
              peekSize,
              spacing,
              centerX,
              centerY,
              switching,
            ),
          Positioned(
            left: centerX - width * (24 / 375),
            top: centerY - width * (24 / 375),
            child: GestureDetector(
              onTap: onTapZoom,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 48,
                      spreadRadius: 0,
                      offset: Offset(0, 0),
                      color: AppColors.black.withValues(alpha: 0.33),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.search200,
                  size: width * (48 / 375),
                  color: AppColors.white,
                  shadows: const [Shadow(color: Colors.black38, blurRadius: 6)],
                ),
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

    // At rest on the center pizza, `size` tracks `selectedSize` directly and
    // gets room (below) for its tween to actually show; every other case
    // (mid-switch, or a peek) just tracks `size` on the same curve.
    final atRestCenter = !switching && i == toIndex;

    Widget image = AnimatedContainer(
      duration: switching ? Duration.zero : _resizeDuration,
      curve: SpringCurve.elastic(settleDuration: _resizeDuration),
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

    // The Positioned box would otherwise snap straight to `size` on the very
    // next frame, forcing that exact size on the AnimatedContainer above via
    // tight layout constraints and clipping its own tween flat before it can
    // ever be seen. Sizing it a little past the largest the center pizza can
    // ever be (only while at rest — mid-switch still needs the box to track
    // `size` per frame, since that per-frame resize *is* the carousel
    // spring) leaves just enough room for the curve's modest overshoot,
    // centered by the wrapping [Center].
    final boxExtent = atRestCenter
        ? width * PizzaSize.large.widthFactor * 1.1
        : size;

    return Positioned(
      left: centerX + dx - boxExtent / 2,
      top: centerY - boxExtent / 2,
      width: boxExtent,
      height: boxExtent,
      child: Opacity(
        opacity: opacity,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: atRestCenter ? Center(child: image) : image,
        ),
      ),
    );
  }
}
