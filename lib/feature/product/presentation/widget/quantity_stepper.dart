import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';
import 'package:pizza_mobile_app/shared/widget/button/tap_scale.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/spring_curve.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({super.key, required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  static const _digitDuration = Duration(milliseconds: 240);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.highlightPeach,
        borderRadius: BorderRadius.circular(36),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: LucideIcons.minus,
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 32,
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: _digitDuration,
                switchInCurve: SpringCurve.elastic(settleDuration: _digitDuration),
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation.drive(CurveTween(curve: const Interval(0, 0.6))),
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
                        .animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  '$quantity',
                  key: ValueKey(quantity),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
          ),
          _StepperButton(icon: LucideIcons.plus, onTap: () => onChanged(quantity + 1)),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TapScale(
      enabled: onTap != null,
      child: Material(
        color: AppColors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onTap!();
                },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 16, color: onTap == null ? AppColors.gray400 : AppColors.black),
          ),
        ),
      ),
    );
  }
}
