import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accentBlue,
      borderRadius: BorderRadius.circular(36),
      child: InkWell(
        borderRadius: BorderRadius.circular(36),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            'Add',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
