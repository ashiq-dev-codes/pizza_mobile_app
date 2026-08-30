import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/product/constant/product_constants.dart';

class ZoomedPizzaView extends StatelessWidget {
  const ZoomedPizzaView({super.key, required this.image});

  final String image;

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
              image,
              width: MediaQuery.sizeOf(context).width,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
