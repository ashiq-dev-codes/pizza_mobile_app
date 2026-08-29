import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_size.dart';
import 'package:pizza_mobile_app/feature/product/constant/product_constants.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/add_button.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/pizza_stage.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/product_navbar.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/quantity_stepper.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/size_area.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/zoomed_pizza_view.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  PizzaSize _selectedSize = PizzaSize.medium;
  int _quantity = 1;
  bool _isFavorite = false;

  double get _price => _selectedSize.price;

  void _openZoom() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        pageBuilder: (_, _, _) => const ZoomedPizzaView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            ProductNavbar(
              isFavorite: _isFavorite,
              onBack: () => Navigator.of(context).maybePop(),
              onFavorite: () => setState(() => _isFavorite = !_isFavorite),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    PizzaStage(width: width, selectedSize: _selectedSize, onTapZoom: _openZoom),
                    SizeArea(
                      selectedSize: _selectedSize,
                      onSelect: (size) => setState(() => _selectedSize = size),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        ProductConstants.description,
                        style: TextStyle(fontSize: 14, height: 1.7, color: AppColors.black),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          QuantityStepper(
                            quantity: _quantity,
                            onChanged: (q) => setState(() => _quantity = q),
                          ),
                          Text(
                            '\$${_price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.black,
                            ),
                          ),
                          AddButton(onTap: () {}),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
