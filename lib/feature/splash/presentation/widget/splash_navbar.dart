import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/widget/slide_fade.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';
import 'package:pizza_mobile_app/shared/widget/button/round_icon_button.dart';

/// The navbar's entrance for the splash intro: mirrors the product page's
/// navbar layout exactly (it previews the destination screen) but is
/// non-interactive and slides/fades in as [animation] advances.
class SplashNavbar extends StatelessWidget {
  const SplashNavbar({super.key, required this.animation});

  final Animation<double> animation;

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
              animation: animation,
              from: 64,
              child: const RoundIconButton(icon: LucideIcons.heart),
            ),
          ),
          SlideFade.y(
            animation: animation,
            from: -24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pizzas',
                  style: TextStyle(fontSize: 10, color: AppColors.black.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Pepperoni Blast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    letterSpacing: -0.48,
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
