import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_catalog.dart';
import 'package:pizza_mobile_app/feature/product/constant/pizza_size.dart';
import 'package:pizza_mobile_app/feature/product/presentation/controller/pizza_switch_animation.dart';
import 'package:pizza_mobile_app/feature/product/presentation/controller/pizza_zoom_animation.dart';
import 'package:pizza_mobile_app/feature/product/presentation/controller/product_intro_animation.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/add_button.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/pizza_stage.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/product_backdrop.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/product_navbar.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/quantity_stepper.dart';
import 'package:pizza_mobile_app/feature/product/presentation/widget/size_area.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/cross_fade.dart';
import 'package:pizza_mobile_app/shared/widget/reveal/scale_fade.dart';
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
  late final _zoomAnim = PizzaZoomAnimation(vsync: this)
    ..controller.addStatusListener(_onZoomStatusChanged);

  final _stackKey = GlobalKey();
  final _pizzaKey = GlobalKey();

  PizzaSize _selectedSize = PizzaSize.medium;
  int _quantity = 1;
  bool _isFavorite = false;

  // The rect the center pizza occupies on screen the moment it's tapped —
  // the zoom overlay grows from exactly this rect in place, rather than
  // flying to a different route, matching the source Figma prototype (the
  // rest of the page never moves or fades; the pizza simply grows large
  // enough to cover it). Cleared once the reverse animation fully settles,
  // so the real stage pizza underneath is only ever revealed at a matching
  // size — see [_onZoomStatusChanged].
  Rect? _zoomRect;

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
    _zoomAnim.dispose();
    super.dispose();
  }

  void _onZoomStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      setState(() => _zoomRect = null);
    }
  }

  void _switchPizza(int index) => setState(() => _switchAnim.switchTo(index));

  void _openZoom() {
    final pizzaBox = _pizzaKey.currentContext?.findRenderObject() as RenderBox?;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (pizzaBox == null || stackBox == null) return;
    final topLeft = stackBox.globalToLocal(pizzaBox.localToGlobal(Offset.zero));
    setState(() => _zoomRect = topLeft & pizzaBox.size);
    _zoomAnim.open();
  }

  void _closeZoom() => _zoomAnim.close();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final width = screenSize.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _zoomRect != null
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: _zoomRect == null,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _closeZoom();
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: Stack(
            key: _stackKey,
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
                      onFavorite: () =>
                          setState(() => _isFavorite = !_isFavorite),
                      revealIn: _anim.revealIn,
                      title: _activePizza.name,
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
                                centerPizzaKey: _pizzaKey,
                                hideCenterPizza: _zoomRect != null,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: CrossFade(
                                  value: _activePizza.description,
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
                          ],
                        ),
                      ),
                    ),
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
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              if (_zoomRect != null)
                AnimatedBuilder(
                  animation: _zoomAnim.progress,
                  builder: (context, child) {
                    final t = _zoomAnim.progress.value;
                    final startRect = _zoomRect!;
                    // Big enough that even the shorter (width) screen
                    // dimension is fully covered with room to spare, so the
                    // settled shot never shows the crust — matching the
                    // source Figma prototype's close-up.
                    final finalSize = screenSize.height * 1.35;
                    final size = lerpDouble(startRect.width, finalSize, t)!;
                    final center = startRect.center;
                    return Positioned(
                      left: center.dx - size / 2,
                      top: center.dy - size / 2,
                      width: size,
                      height: size,
                      // A soft shadow — the same weight already used under
                      // the stage's own search-icon affordance — so the
                      // pizza reads as lifting into focus rather than just
                      // resizing flat against the page. Its blur sits just
                      // past the circle's own edge, so once the circle has
                      // grown bigger than the screen the shadow is carried
                      // off-screen with it and never needs a manual fade.
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 48,
                              color: AppColors.black.withValues(alpha: 0.33),
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: _closeZoom,
                          child: Image.asset(
                            _activePizza.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
