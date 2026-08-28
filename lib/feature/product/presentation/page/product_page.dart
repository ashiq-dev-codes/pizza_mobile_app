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

const Map<_PizzaSize, double> _sizeWidthFactor = {
  _PizzaSize.small: 0.62,
  _PizzaSize.medium: 0.78,
  _PizzaSize.large: 0.94,
};

const Map<_PizzaSize, double> _sizePriceMultiplier = {
  _PizzaSize.small: 1.0,
  _PizzaSize.medium: 1.25,
  _PizzaSize.large: 1.55,
};

const double _basePrice = 8.99;
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

  double get _price => _basePrice * _sizePriceMultiplier[_selectedSize]!;

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _openZoom,
                      child: Hero(
                        tag: _pizzaHeroTag,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: width * _sizeWidthFactor[_selectedSize]!,
                          height: width * _sizeWidthFactor[_selectedSize]!,
                          child: Image.asset(
                            AppImages.productPizzas.first,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 16,
                    child: _RoundIconButton(
                      icon: LucideIcons.chevronLeft,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 16,
                    child: _RoundIconButton(
                      icon: LucideIcons.heart,
                      iconColor: _isFavorite ? AppColors.primary : AppColors.gray900,
                      onTap: () => setState(() => _isFavorite = !_isFavorite),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pepperoni Blast',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A fiery classic loaded with double pepperoni, melted '
                    'mozzarella, and our signature tomato sauce.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: _PizzaSize.values.map((size) {
                      final selected = size == _selectedSize;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedSize = size),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary : AppColors.gray100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected ? AppColors.primary : AppColors.gray300,
                              ),
                            ),
                            child: Text(
                              _sizeLabels[size]!,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: selected ? AppColors.white : AppColors.gray700,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: TextStyle(fontSize: 13, color: AppColors.gray500),
                            ),
                            Text(
                              '\$${_price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gray900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _QuantityStepper(
                        quantity: _quantity,
                        onChanged: (q) => setState(() => _quantity = q),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      color: AppColors.white.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: iconColor ?? AppColors.gray900),
        ),
      ),
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
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: LucideIcons.minus,
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.gray900),
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
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 16,
            color: onTap == null ? AppColors.gray400 : AppColors.gray900,
          ),
        ),
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
