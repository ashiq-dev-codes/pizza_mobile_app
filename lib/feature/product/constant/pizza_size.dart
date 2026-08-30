/// The three pizza sizes offered on the product page, matched to the
/// Figma (S)/(M)/(L) art-boards.
enum PizzaSize { small, medium, large }

extension PizzaSizeX on PizzaSize {
  String get label => switch (this) {
    PizzaSize.small => 'S',
    PizzaSize.medium => 'M',
    PizzaSize.large => 'L',
  };

  /// Pizza width as a fraction of the frame width: 196/375, 244/375, 274/375.
  double get widthFactor => switch (this) {
    PizzaSize.small => 196 / 375,
    PizzaSize.medium => 244 / 375,
    PizzaSize.large => 274 / 375,
  };

  double get price => switch (this) {
    PizzaSize.small => 15.99,
    PizzaSize.medium => 17.99,
    PizzaSize.large => 25.99,
  };
}
