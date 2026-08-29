import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/product/constant/product_constants.dart';
import 'package:pizza_mobile_app/shared/path/app_images.dart';

class ZoomedPizzaView extends StatelessWidget {
  const ZoomedPizzaView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Hero(
            tag: ProductConstants.pizzaHeroTag,
            child: Image.asset(
              AppImages.productPizzas.first,
              width: MediaQuery.sizeOf(context).width,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
