import 'package:pizza_mobile_app/shared/path/app_images.dart';

/// One product in the pizza carousel — its own name, blurb, and photo.
class PizzaProduct {
  const PizzaProduct({required this.name, required this.description, required this.image});

  final String name;
  final String description;
  final String image;
}

/// The pizzas the product page carousel steps through, in the fixed
/// left-to-right order [PizzaStage] arranges them in — matching
/// [AppImages.productPizzas]' own order so image and copy stay paired.
class PizzaCatalog {
  const PizzaCatalog._();

  static final List<PizzaProduct> all = [
    PizzaProduct(
      name: 'Midnight Harvest',
      description:
          'This pizza celebrates the rich and bold flavors of black olives '
          'paired with a medley of cheeses. The deep, earthy taste of black '
          'olives harmonizes beautifully with the creamy, melted cheeses.',
      image: AppImages.productPizzas[0],
    ),
    PizzaProduct(
      name: 'Pepperoni Blast',
      description:
          'The combination of perfectly melted mozzarella cheese, '
          'tangy tomato sauce, and a crispy yet chewy crust creates '
          'a harmonious balance that leaves you wanting more.',
      image: AppImages.productPizzas[1],
    ),
    PizzaProduct(
      name: 'Shrimptastic',
      description:
          'This pizza showcases the perfect combination of shrimp and cheese, '
          'with gooey melted cheeses complementing the savory shrimp toppings '
          'for a truly indulgent experience.',
      image: AppImages.productPizzas[2],
    ),
  ];

  /// "Pepperoni Blast" starts centered, matching the source Figma prototype.
  static const int defaultIndex = 1;
}
