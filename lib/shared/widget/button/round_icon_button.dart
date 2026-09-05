import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';
import 'package:pizza_mobile_app/shared/widget/button/tap_scale.dart';

/// A circular, elevated icon button used for navbar actions across
/// features. Passing a null [onTap] renders a static button with no tap
/// feedback. Pass [child] instead of [icon] when the caller needs to
/// animate the glyph itself (e.g. a favorite heart's pop bounce) — exactly
/// one of the two must be given.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({super.key, this.icon, this.onTap, this.iconColor, this.child})
    : assert(icon != null || child != null, 'Provide either icon or child');

  final IconData? icon;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: child ?? Icon(icon, size: 22, color: iconColor ?? AppColors.black),
    );

    return TapScale(
      enabled: onTap != null,
      child: Material(
        color: AppColors.white,
        shape: const CircleBorder(),
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        child: onTap == null
            ? content
            : InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap!();
                },
                child: content,
              ),
      ),
    );
  }
}
