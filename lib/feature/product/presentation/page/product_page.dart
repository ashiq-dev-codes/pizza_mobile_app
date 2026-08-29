import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pizza_mobile_app/shared/path/app_images.dart';
import 'package:pizza_mobile_app/shared/theme/app_colors.dart';

enum _PizzaSize { small, medium, large }

const Map<_PizzaSize, String> _sizeLabels = {
  _PizzaSize.small: 'S',
  _PizzaSize.medium: 'M',
  _PizzaSize.large: 'L',
};

// Pizza width as a fraction of the frame width, matched to the Figma
// (S)/(M)/(L) art-boards: 196/375, 244/375, 274/375.
const Map<_PizzaSize, double> _sizeWidthFactor = {
  _PizzaSize.small: 196 / 375,
  _PizzaSize.medium: 244 / 375,
  _PizzaSize.large: 274 / 375,
};

const Map<_PizzaSize, double> _sizePrice = {
  _PizzaSize.small: 14.99,
  _PizzaSize.medium: 17.99,
  _PizzaSize.large: 20.99,
};

const String _pizzaHeroTag = 'pizza-image';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  _PizzaSize _selectedSize = _PizzaSize.medium;
  int _quantity = 1;
  bool _isFavorite = false;

  double get _price => _sizePrice[_selectedSize]!;

  void _openZoom() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        pageBuilder: (_, _, _) => const _ZoomedPizzaView(),
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
            _Navbar(
              isFavorite: _isFavorite,
              onBack: () => Navigator.of(context).maybePop(),
              onFavorite: () => setState(() => _isFavorite = !_isFavorite),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _PizzaStage(
                      width: width,
                      selectedSize: _selectedSize,
                      onTapZoom: _openZoom,
                    ),
                    _SizeArea(
                      selectedSize: _selectedSize,
                      onSelect: (size) => setState(() => _selectedSize = size),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'The combination of perfectly melted mozzarella cheese, '
                        'tangy tomato sauce, and a crispy yet chewy crust creates '
                        'a harmonious balance that leaves you wanting more.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.7,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _QuantityStepper(
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
                          _AddButton(onTap: () {}),
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

class _Navbar extends StatelessWidget {
  const _Navbar({
    required this.isFavorite,
    required this.onBack,
    required this.onFavorite,
  });

  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundIconButton(icon: LucideIcons.chevronLeft, onTap: onBack),
              _RoundIconButton(
                icon: LucideIcons.heart,
                iconColor: isFavorite ? AppColors.primary : AppColors.black,
                onTap: onFavorite,
              ),
            ],
          ),
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
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 22, color: iconColor ?? AppColors.black),
        ),
      ),
    );
  }
}

class _PizzaStage extends StatelessWidget {
  const _PizzaStage({
    required this.width,
    required this.selectedSize,
    required this.onTapZoom,
  });

  final double width;
  final _PizzaSize selectedSize;
  final VoidCallback onTapZoom;

  @override
  Widget build(BuildContext context) {
    final pizzaSize = width * _sizeWidthFactor[selectedSize]!;
    final peekSize = width * (80 / 375);
    final peekOffset = width * (40 / 375);

    return SizedBox(
      height: width * 0.85,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: width * 1.5,
            height: width * 1.5,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: -peekOffset,
            child: Image.asset(
              AppImages.productPizzas[1],
              width: peekSize,
              height: peekSize,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: -peekOffset,
            child: Image.asset(
              AppImages.productPizzas[2],
              width: peekSize,
              height: peekSize,
              fit: BoxFit.contain,
            ),
          ),
          GestureDetector(
            onTap: onTapZoom,
            child: Hero(
              tag: _pizzaHeroTag,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: pizzaSize,
                height: pizzaSize,
                child: Image.asset(
                  AppImages.productPizzas.first,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTapZoom,
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
}

class _SizeArea extends StatelessWidget {
  const _SizeArea({required this.selectedSize, required this.onSelect});

  final _PizzaSize selectedSize;
  final ValueChanged<_PizzaSize> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: _SizeSelectorRow(
              selectedSize: selectedSize,
              onSelect: onSelect,
            ),
          ),
          Positioned(
            bottom: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ArcText(
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
          ),
        ],
      ),
    );
  }
}

class _SizeSelectorRow extends StatelessWidget {
  const _SizeSelectorRow({required this.selectedSize, required this.onSelect});

  final _PizzaSize selectedSize;
  final ValueChanged<_PizzaSize> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _PizzaSize.values.map((size) {
        final selected = size == selectedSize;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () => onSelect(size),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.black : AppColors.white,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: AppColors.white, width: 2)
                    : null,
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
                _sizeLabels[size]!,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.white : AppColors.black,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

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
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
          ),
          _StepperButton(
            icon: LucideIcons.plus,
            onTap: () => onChanged(quantity + 1),
          ),
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
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 16,
            color: onTap == null ? AppColors.gray400 : AppColors.black,
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

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
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays out [text] one letter at a time along an upward arc, matching the
/// "Banana for scale" caption from the Figma design.
class _ArcText extends StatelessWidget {
  const _ArcText({
    required this.text,
    required this.style,
    required this.radius,
    this.sweep = 2.35,
  });

  final String text;
  final TextStyle style;
  final double radius;
  final double sweep;

  @override
  Widget build(BuildContext context) {
    final letters = text.split('');
    final count = letters.length;
    final height = radius * 0.7;

    return SizedBox(
      width: radius * 2,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(count, (i) {
          final t = count == 1 ? 0.5 : i / (count - 1);
          final angle = -sweep / 2 + sweep * t;
          final dx = radius + radius * math.sin(angle);
          final dy = height - radius * math.cos(angle);
          return Positioned(
            left: dx - 5,
            top: dy,
            child: Transform.rotate(angle: angle, child: Text(letters[i], style: style)),
          );
        }),
      ),
    );
  }
}

class _ZoomedPizzaView extends StatelessWidget {
  const _ZoomedPizzaView();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Hero(
            tag: _pizzaHeroTag,
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
