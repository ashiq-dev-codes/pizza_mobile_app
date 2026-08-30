import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';
import 'package:pizza_mobile_app/shared/widget/button/round_icon_button.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/slide_cross_fade.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/slide_fade.dart';

/// The product page's top bar: a back button and favorite button converge
/// in from opposite screen edges while the title drops in from above —
/// matching the source design's entrance, where each of the three pieces
/// starts off-canvas on its own side and springs into the resting row
/// together rather than the row appearing as one block.
///
/// All three share one [revealIn] animation (rather than each getting its
/// own independently-timed one) so they read the exact same progress value
/// every tick — they overshoot and settle in perfect lockstep, which is
/// what makes the convergence read as one cohesive snap instead of three
/// slightly-offset pops.
class ProductNavbar extends StatelessWidget {
  const ProductNavbar({
    super.key,
    required this.isFavorite,
    required this.onFavorite,
    required this.revealIn,
    required this.title,
    required this.titleDirection,
  });

  final bool isFavorite;
  final VoidCallback onFavorite;
  final Animation<double> revealIn;

  /// The active pizza's name — swapping this crossfades/slides the title in
  /// [titleDirection], staying in lockstep with the pizza carousel.
  final String title;
  final int titleDirection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SlideFade.x(
              animation: revealIn,
              from: -80,
              child: RoundIconButton(
                icon: LucideIcons.arrowLeft,
                iconColor: AppColors.black,
                onTap: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SlideFade.x(
              animation: revealIn,
              from: 80,
              child: RoundIconButton(
                icon: LucideIcons.heart,
                iconColor: isFavorite ? AppColors.primary : AppColors.black,
                onTap: onFavorite,
              ),
            ),
          ),
          SlideFade.y(
            animation: revealIn,
            from: -130,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pizzas',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.black.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                SlideCrossFade(
                  value: title,
                  direction: titleDirection,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                      letterSpacing: -0.48,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
