import 'package:flutter/material.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_catalog.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_size.dart';
import 'package:pizza_mobile_app/feature/product/presentation/controller/pizza_switch_animation.dart';
import 'package:pizza_mobile_app/feature/product/presentation/controller/product_intro_animation.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/add_button.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/pizza_stage.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/product_backdrop.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/product_navbar.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/quantity_stepper.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/size_area.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/zoomed_pizza_view.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/scale_fade.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/slide_cross_fade.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/slide_fade.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with TickerProviderStateMixin {
  late final _anim = ProductIntroAnimation(vsync: this);
  late final _switchAnim = PizzaSwitchAnimation(
    vsync: this,
    initialIndex: PizzaCatalog.defaultIndex,
  );

  PizzaSize _selectedSize = PizzaSize.medium;
  int _quantity = 1;
  bool _isFavorite = false;

  double get _price => _selectedSize.price;
  PizzaProduct get _activePizza => PizzaCatalog.all[_switchAnim.toIndex];

  @override
  void initState() {
    super.initState();
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _switchAnim.dispose();
    super.dispose();
  }

  void _switchPizza(int index) => setState(() => _switchAnim.switchTo(index));

  void _openZoom() {
    final image = _activePizza.image;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        pageBuilder: (_, _, _) => ZoomedPizzaView(image: image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final width = screenSize.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          ProductBackdrop(
            width: width,
            height: screenSize.height,
            collapse: _anim.collapse,
          ),
          SafeArea(
            child: Column(
              children: [
                ProductNavbar(
                  isFavorite: _isFavorite,
                  onFavorite: () => setState(() => _isFavorite = !_isFavorite),
                  revealIn: _anim.revealIn,
                  title: _activePizza.name,
                  titleDirection: _switchAnim.direction,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ScaleFade(
                          animation: _anim.revealIn,
                          from: 40 / 244,
                          child: PizzaStage(
                            width: width,
                            selectedSize: _selectedSize,
                            fromIndex: _switchAnim.fromIndex,
                            toIndex: _switchAnim.toIndex,
                            progress: _switchAnim.progress,
                            onSelectIndex: _switchPizza,
                            onTapZoom: _openZoom,
                          ),
                        ),
                        SlideFade.y(
                          animation: _anim.springApartIn,
                          from: 370,
                          child: SizeArea(
                            selectedSize: _selectedSize,
                            onSelect: (size) =>
                                setState(() => _selectedSize = size),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SlideFade.y(
                          animation: _anim.springApartIn,
                          from: 250,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: SlideCrossFade(
                              value: _activePizza.description,
                              direction: _switchAnim.direction,
                              child: Text(
                                _activePizza.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.7,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SlideFade.y(
                          animation: _anim.springApartIn,
                          from: 140,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                QuantityStepper(
                                  quantity: _quantity,
                                  onChanged: (q) =>
                                      setState(() => _quantity = q),
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
                        ),
                        const SizedBox(height: 20),
                      ],
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
