import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

/// A circular, elevated icon button used for navbar actions across
/// features. Passing a null [onTap] renders a static button with no tap
/// feedback — used by the splash screen's preview navbar, which only
/// mirrors the product page's look while the intro plays.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, required this.icon, this.onTap, this.iconColor});

  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Icon(icon, size: 22, color: iconColor ?? AppColors.black),
    );

    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: onTap == null
          ? content
          : InkWell(customBorder: const CircleBorder(), onTap: onTap, child: content),
    );
  }
}
