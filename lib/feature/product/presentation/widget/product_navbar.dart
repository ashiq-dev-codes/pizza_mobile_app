import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';
import 'package:pizza_mobile_app/shared/widget/button/round_icon_button.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/cross_fade.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/slide_fade.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/spring_curve.dart';

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
  });

  final bool isFavorite;
  final VoidCallback onFavorite;
  final Animation<double> revealIn;

  /// The active pizza's name — swapping this crossfades the title in place.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: SlideFade.x(
              animation: revealIn,
              from: 80,
              child: _FavoriteButton(isFavorite: isFavorite, onTap: onFavorite),
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
                CrossFade(
                  value: title,
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

/// The favorite heart: pops well past its resting size and springs back
/// with a slight wobble the instant it's favorited — the same "like button"
/// bounce iOS users already know — rather than just swapping color flat.
class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 420);

  late final _controller = AnimationController(vsync: this, duration: _duration);
  late final _bounce = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.0, end: 1.5).chain(CurveTween(curve: Curves.easeOut)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1.5,
        end: 1.0,
      ).chain(CurveTween(curve: SpringCurve.elastic(settleDuration: const Duration(milliseconds: 300)))),
      weight: 70,
    ),
  ]).animate(_controller);

  @override
  void didUpdateWidget(covariant _FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite && !oldWidget.isFavorite) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RoundIconButton(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _bounce,
        builder: (context, child) => Transform.scale(scale: _bounce.value, child: child),
        child: Icon(
          LucideIcons.heart,
          size: 22,
          color: widget.isFavorite ? AppColors.primary : AppColors.black,
        ),
      ),
    );
  }
}
