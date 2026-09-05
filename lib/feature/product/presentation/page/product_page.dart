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
import 'package:pizza_mobile_app/shared/widget/reveal/suppressed_animation.dart';

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

  // The navbar and the bottom bundle (dial/description/stepper) already
  // slide/fade in via _anim's own reveal — reusing those same animations
  // (rather than separate ones) as the *base* here means their zoom-driven
  // exit retraces the identical path in reverse, so opening zoom reads as
  // "the entrance playing backwards to make room" instead of a distinct,
  // separately-tuned motion. See [SuppressedAnimation].
  late final _chromeVisibility = SuppressedAnimation(
    base: _anim.revealIn,
    suppressor: _zoomAnim.progress,
  );
  late final _bottomVisibility = SuppressedAnimation(
    base: _anim.springApartIn,
    suppressor: _zoomAnim.progress,
  );

  final _stackKey = GlobalKey();
  final _pizzaKey = GlobalKey();

  PizzaSize _selectedSize = PizzaSize.medium;
  int _quantity = 1;
  bool _isFavorite = false;

  // The rect the center pizza occupies on screen the moment it's tapped —
  // the zoom overlay grows from exactly this rect in place, rather than
  // flying to a different route, matching the source Figma prototype. The
  // rest of the page's chrome doesn't just sit there waiting to be covered
  // up, either — see [_chromeVisibility]/[_bottomVisibility] — it slides
  // and fades out of the way in lockstep with the growth, retracing its own
  // entrance in reverse, matching the source rather than looking like a
  // circle merely growing on top of a frozen page. Cleared once the reverse
  // animation fully settles, so the real stage pizza underneath is only
  // ever revealed at a matching size — see [_onZoomStatusChanged].
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

  void _closeZoom() {
    HapticFeedback.lightImpact();
    _zoomAnim.close();
  }

  void _addToCart() {
    HapticFeedback.mediumImpact();
    final pizza = _activePizza;
    final total = _price * _quantity;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.black,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        duration: const Duration(milliseconds: 1600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(36)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.accentBlue, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$_quantity × ${pizza.name} (${_selectedSize.label}) added — '
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                    _ExitScale(
                      animation: _chromeVisibility,
                      from: 0.9,
                      child: ProductNavbar(
                        isFavorite: _isFavorite,
                        onFavorite: () =>
                            setState(() => _isFavorite = !_isFavorite),
                        revealIn: _chromeVisibility,
                        title: _activePizza.name,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ScaleFade(
                              animation: _anim.revealIn,
                              from: 0.72,
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
                            _ExitScale(
                              animation: _bottomVisibility,
                              from: 0.92,
                              child: SlideFade.y(
                                animation: _bottomVisibility,
                                from: 370,
                                child: SizeArea(
                                  selectedSize: _selectedSize,
                                  onSelect: (size) =>
                                      setState(() => _selectedSize = size),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _ExitScale(
                              animation: _bottomVisibility,
                              from: 0.92,
                              child: SlideFade.y(
                                animation: _bottomVisibility,
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
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    _ExitScale(
                      animation: _bottomVisibility,
                      from: 0.92,
                      child: SlideFade.y(
                        animation: _bottomVisibility,
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
                              CrossFade(
                                value: _selectedSize,
                                child: Text(
                                  '\$${_price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              AddButton(onTap: _addToCart),
                            ],
                          ),
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

/// Scales [child] down toward [from] as [animation] recedes from 1 to 0 —
/// the depth companion to [SlideFade]'s slide+fade, used alongside it
/// (rather than [ScaleFade], which also drives opacity) so the exiting
/// chrome reads as receding into the distance, not just sliding off and
/// fading — while leaving opacity solely to the [SlideFade] it wraps, so
/// the two don't compound into a fade that's twice as fast as intended.
class _ExitScale extends AnimatedWidget {
  const _ExitScale({required Animation<double> animation, required this.from, required this.child})
    : super(listenable: animation);

  final double from;
  final Widget child;

  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final value = _animation.value;
    return Transform.scale(scale: from + (1 - from) * value, child: child);
  }
}
