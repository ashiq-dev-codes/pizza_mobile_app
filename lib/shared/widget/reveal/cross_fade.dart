import 'package:flutter/material.dart';

/// Cross-fades [child] whenever [value] changes, staying put — the outgoing
/// content fades out while the incoming content fades in at the same spot,
/// matching the source Figma prototype's title/description swap (a plain
/// crossfade in place, not a slide).
class CrossFade extends StatelessWidget {
  const CrossFade({super.key, required this.value, required this.child});

  /// Unique per piece of content — changing this triggers the transition.
  final Object value;
  final Widget child;

  static const _duration = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: KeyedSubtree(key: ValueKey(value), child: child),
    );
  }
}
