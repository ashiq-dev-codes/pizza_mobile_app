import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_size.dart';
import 'package:pizza_mobile_app/feature/splash/presentation/widget/slide_fade.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

/// Mirrors the product page's quantity/price/add row at its resting state
/// (quantity 1, Medium size) as a static reveal.
class OrderRowReveal extends StatelessWidget {
  const OrderRowReveal({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SlideFade.y(
      animation: animation,
      from: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.highlightPeach,
                borderRadius: BorderRadius.circular(36),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _staticStepperButton(LucideIcons.minus, enabled: false),
                  const SizedBox(
                    width: 32,
                    child: Text(
                      '1',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.black),
                    ),
                  ),
                  _staticStepperButton(LucideIcons.plus, enabled: true),
                ],
              ),
            ),
            Text(
              '\$${PizzaSize.medium.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.black),
            ),
            Material(
              color: AppColors.accentBlue,
              borderRadius: BorderRadius.circular(36),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'Add',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _staticStepperButton(IconData icon, {required bool enabled}) => Material(
    color: AppColors.white,
    shape: const CircleBorder(),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Icon(icon, size: 16, color: enabled ? AppColors.black : AppColors.gray400),
    ),
  );
}
