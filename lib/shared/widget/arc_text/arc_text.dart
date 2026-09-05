import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lays out [text] one letter at a time along an upward arc, matching the
/// "Banana for scale" caption from the Figma design. Shared between the
/// splash and product screens so the caption is pixel-identical in both.
class ArcText extends StatelessWidget {
  const ArcText({
    super.key,
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
