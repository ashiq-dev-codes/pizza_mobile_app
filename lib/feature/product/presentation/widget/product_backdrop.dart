import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

/// The product page's peach background: a single circle, fixed in place,
/// whose radius is driven by [collapse] (0 = big enough to fill the whole
/// screen, 1 = its resting size). Because the circle's center never moves —
/// only the radius shrinks — the top of the screen stays fully covered for
/// the whole collapse, and only the bottom edge visibly rises into its
/// resting dome curve.
///
/// Must be painted as a direct [Stack] sibling of the page's `SafeArea`
/// (not nested inside the scrollable content) so it can bleed behind the
/// status bar/navbar — a `SingleChildScrollView` clips to its own viewport
/// regardless of any descendant's `clipBehavior`.
class ProductBackdrop extends AnimatedWidget {
  const ProductBackdrop({
    super.key,
    required this.width,
    required this.height,
    required Animation<double> collapse,
  }) : super(listenable: collapse);

  final double width;
  final double height;

  Animation<double> get _collapse => listenable as Animation<double>;

  /// Resting radius, as a multiple of screen width.
  static const _restRadiusFactor = 0.95;

  /// Resting bottom edge (center-bottom of the dome), as a fraction of
  /// screen height. Deep enough that the dome's lowest point clears the
  /// pizza stage entirely (navbar + PizzaStage's `width * 0.85` height),
  /// so the pizza never gets cut across by the peach/white seam.
  static const _restBottomFactor = 0.53;

  @override
  Widget build(BuildContext context) {
    final restRadius = width * _restRadiusFactor;
    final restBottomY = height * _restBottomFactor;
    final centerY = restBottomY - restRadius;
    final hugeRadius = height * 1.3;
    final t = _collapse.value.clamp(0.0, 1.0);
    final radius = hugeRadius + (restRadius - hugeRadius) * t;

    return Positioned(
      left: width / 2 - radius,
      top: centerY - radius,
      width: radius * 2,
      height: radius * 2.6,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
