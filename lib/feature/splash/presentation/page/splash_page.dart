import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pizza_mobile_app/feature/product/presentation/page/product_page.dart';
import 'package:pizza_mobile_app/shared/path/app_images.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

// Must match the Hero tag used on the product page's hero pizza image so the
// handoff at the end of this animation is a seamless continuation.
const String _pizzaHeroTag = 'pizza-image';

// The product page always opens on the Medium size — matches its default
// selection and the exact price/width ratio pulled from the Figma (M) frame.
const double _pizzaWidthFactor = 244 / 375;
const double _price = 17.99;

/// Recreates the real Figma prototype sequence (traced frame-by-frame from a
/// screen recording of the live preview, starting at node 617:1019):
///
/// 1. A pizza logo assembles from 8 slices while growing, on a plain white
///    screen (the `splash_N` cumulative frames).
/// 2. Once whole, it fades out while the background tints from white to the
///    product page's peach.
/// 3. A white circle grows in from below the screen and sweeps upward,
///    covering the peach everywhere except the small halo behind where the
///    hero pizza will sit.
/// 4. The navbar, hero pizza, banana/size row, description, and order row
///    fade/slide into their resting positions.
///
/// The whole thing runs in under a second in the source prototype, then
/// hands off to [ProductScreen] with no visible seam.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _totalDuration = Duration(milliseconds: 900);

  // Named breakpoints, as fractions of the total timeline.
  static const _assemblyEnd = 0.42;
  static const _bgFadeStart = 0.40;
  static const _bgFadeEnd = 0.58;
  static const _pizzaFadeStart = 0.44;
  static const _pizzaFadeEnd = 0.58;
  static const _wipeStart = 0.56;
  static const _wipeEnd = 0.70;
  static const _heroStart = 0.62;
  static const _heroEnd = 0.82;

  static final int _stepCount = AppImages.splashFrames.length - 1;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _totalDuration,
  );

  late final Animation<double> _navbarIn = _interval(0.62, 0.80);
  late final Animation<double> _peekIn = _interval(_heroStart, _heroEnd);
  late final Animation<double> _bananaSizeIn = _interval(0.68, 0.88);
  late final Animation<double> _descriptionIn = _interval(0.74, 0.92);
  late final Animation<double> _orderRowIn = _interval(0.80, 1.0);

  bool _precached = false;

  Animation<double> _interval(double start, double end) => CurvedAnimation(
    parent: _controller,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(_goToProduct);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      for (final path in AppImages.splashFrames) {
        precacheImage(AssetImage(path), context);
      }
      for (final path in AppImages.productPizzas) {
        precacheImage(AssetImage(path), context);
      }
      precacheImage(AssetImage(AppImages.bananaScale), context);
    }
  }

  void _goToProduct() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, _, _) => const ProductScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Assembly progress, eased, spanning the whole logo phase.
  double _assemblyT(double t) =>
      Curves.easeOut.transform((t / _assemblyEnd).clamp(0.0, 1.0));

  /// Assembled-logo size, as a fraction of screen width: grows from a sliver
  /// up to the resting splash-logo size as slices are added.
  double _assemblySizeFactor(double t) => 0.16 + 0.56 * _assemblyT(t);

  /// Fades the assembled logo out once the background starts tinting peach.
  double _pizzaFadeOpacity(double t) {
    if (t < _pizzaFadeStart) return 1;
    final localT = ((t - _pizzaFadeStart) / (_pizzaFadeEnd - _pizzaFadeStart))
        .clamp(0.0, 1.0);
    return 1 - Curves.easeIn.transform(localT);
  }

  double _bgBlend(double t) {
    if (t < _bgFadeStart) return 0;
    final localT = ((t - _bgFadeStart) / (_bgFadeEnd - _bgFadeStart)).clamp(0.0, 1.0);
    return Curves.easeInOut.transform(localT);
  }

  Color _bgColor(double t) =>
      Color.lerp(AppColors.white, AppColors.background, _bgBlend(t))!;

  /// The white wipe's diameter, as a multiple of screen width: 0 until the
  /// halo has faded in, then grows enough to sweep past the whole screen.
  double _wipeDiameterFactor(double t) {
    if (t < _wipeStart) return 0;
    final localT = ((t - _wipeStart) / (_wipeEnd - _wipeStart)).clamp(0.0, 1.0);
    return Curves.easeInOut.transform(localT) * 4.2;
  }

  /// Hero pizza size, as a fraction of screen width: pops in to its resting
  /// (Medium) size once the wipe has mostly covered the screen.
  double _heroSizeFactor(double t) {
    final localT = ((t - _heroStart) / (_heroEnd - _heroStart)).clamp(0.0, 1.0);
    return Curves.easeOutBack.transform(localT) * _pizzaWidthFactor;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Scaffold(
          backgroundColor: _bgColor(t),
          body: SafeArea(
            child: Column(
              children: [
                _buildNavbar(),
                Expanded(
                  child: Column(
                    children: [
                      _buildPizzaStage(width, t),
                      _buildSizeArea(),
                      const SizedBox(height: 20),
                      _buildDescription(),
                      const SizedBox(height: 20),
                      _buildOrderRow(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _slideX(
                _staticRoundButton(LucideIcons.chevronLeft),
                _navbarIn,
                from: -64,
              ),
              _slideX(
                _staticRoundButton(LucideIcons.heart),
                _navbarIn,
                from: 64,
              ),
            ],
          ),
          _slideY(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pizzas',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.black.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Pepperoni Blast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    letterSpacing: -0.48,
                  ),
                ),
              ],
            ),
            _navbarIn,
            from: -24,
          ),
        ],
      ),
    );
  }

  Widget _staticRoundButton(IconData icon) => Material(
    color: AppColors.white,
    shape: const CircleBorder(),
    elevation: 3,
    shadowColor: Colors.black.withValues(alpha: 0.15),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Icon(icon, size: 22, color: AppColors.black),
    ),
  );

  Widget _buildPizzaStage(double width, double t) {
    final peekSize = width * (80 / 375);
    final peekOffset = width * (40 / 375);
    final showAssembly = t < _pizzaFadeEnd;

    return SizedBox(
      height: width * 0.85,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // White wipe: anchored below this stage so its leading edge sweeps
          // upward across the screen as it grows.
          Align(
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0, width * 0.35),
              child: Container(
                width: width * _wipeDiameterFactor(t),
                height: width * _wipeDiameterFactor(t),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Halo: fixed at its resting size/position, fading in with the
          // background tint so there is no visible seam once it's revealed.
          Opacity(
            opacity: _bgBlend(t),
            child: Container(
              width: width * 1.5,
              height: width * 1.5,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (!showAssembly) ...[
            Positioned(
              left: -peekOffset,
              child: Opacity(
                opacity: _peekIn.value,
                child: Image.asset(
                  AppImages.productPizzas[1],
                  width: peekSize,
                  height: peekSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              right: -peekOffset,
              child: Opacity(
                opacity: _peekIn.value,
                child: Image.asset(
                  AppImages.productPizzas[2],
                  width: peekSize,
                  height: peekSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
          if (showAssembly)
            Opacity(
              opacity: _pizzaFadeOpacity(t),
              child: _assemblyPizza(width, t),
            )
          else
            Opacity(
              opacity: _peekIn.value,
              child: Hero(
                tag: _pizzaHeroTag,
                child: SizedBox(
                  width: width * _heroSizeFactor(t),
                  height: width * _heroSizeFactor(t),
                  child: Image.asset(
                    AppImages.productPizzas.first,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          if (!showAssembly)
            Opacity(
              opacity: _peekIn.value,
              child: Icon(
                LucideIcons.search,
                size: width * (48 / 375),
                color: AppColors.white,
                shadows: const [Shadow(color: Colors.black38, blurRadius: 6)],
              ),
            ),
        ],
      ),
    );
  }

  Widget _assemblyPizza(double width, double t) {
    final assemblyT = _assemblyT(t);
    final progress = assemblyT * _stepCount;
    final baseIndex = progress.floor().clamp(0, _stepCount - 1);
    final sliceT = Curves.easeOut.transform((progress - baseIndex).clamp(0.0, 1.0));
    final size = width * _assemblySizeFactor(t);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppImages.splashFrames[baseIndex], fit: BoxFit.contain),
          Opacity(
            opacity: sliceT,
            child: Image.asset(
              AppImages.splashFrames[baseIndex + 1],
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeArea() {
    return SizedBox(
      height: 108,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: _slideY(_staticSizeRow(), _bananaSizeIn, from: 40),
          ),
          Positioned(
            bottom: 32,
            child: _slideY(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ArcText(
                    text: 'Banana for scale',
                    radius: 58,
                    style: TextStyle(
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: AppColors.black.withValues(alpha: 0.55),
                    ),
                  ),
                  Image.asset(
                    AppImages.bananaScale,
                    width: 90,
                    height: 58,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
              _bananaSizeIn,
              from: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _staticSizeRow() {
    const labels = ['S', 'M', 'L'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: labels.map((label) {
        final selected = label == 'M';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.black : AppColors.white,
              shape: BoxShape.circle,
              border: selected ? Border.all(color: AppColors.white, width: 2) : null,
              boxShadow: selected
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescription() {
    return _slideY(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          'The combination of perfectly melted mozzarella cheese, '
          'tangy tomato sauce, and a crispy yet chewy crust creates '
          'a harmonious balance that leaves you wanting more.',
          style: TextStyle(fontSize: 14, height: 1.7, color: AppColors.black),
        ),
      ),
      _descriptionIn,
      from: 40,
    );
  }

  Widget _buildOrderRow() {
    return _slideY(
      Padding(
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  _staticStepperButton(LucideIcons.plus, enabled: true),
                ],
              ),
            ),
            const Text(
              '\$$_price',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            Material(
              color: AppColors.accentBlue,
              borderRadius: BorderRadius.circular(36),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      _orderRowIn,
      from: 40,
    );
  }

  Widget _staticStepperButton(IconData icon, {required bool enabled}) => Material(
    color: AppColors.white,
    shape: const CircleBorder(),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Icon(
        icon,
        size: 16,
        color: enabled ? AppColors.black : AppColors.gray400,
      ),
    ),
  );

  Widget _slideY(Widget child, Animation<double> animation, {required double from}) {
    return Opacity(
      opacity: animation.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, (1 - animation.value) * from),
        child: child,
      ),
    );
  }

  Widget _slideX(Widget child, Animation<double> animation, {required double from}) {
    return Opacity(
      opacity: animation.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset((1 - animation.value) * from, 0),
        child: child,
      ),
    );
  }
}
