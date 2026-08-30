import 'package:flutter/material.dart';

/// Cross-fades [child] whenever [value] changes, sliding the outgoing
/// content away and the incoming content in from the opposite edge along
/// [direction] (+1 = advancing, so the new content arrives from the right
/// and the old exits left; -1 = the reverse). Used to carry the product
/// page's title and description in lockstep with the pizza carousel's own
/// slide whenever the shopper switches pizzas.
class SlideCrossFade extends StatelessWidget {
  const SlideCrossFade({super.key, required this.value, required this.direction, required this.child});

  /// Unique per piece of content — changing this triggers the transition.
  final Object value;
  final int direction;
  final Widget child;

  static const _duration = Duration(milliseconds: 320);
  static const _travel = 0.2;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (transitionChild, animation) {
        final isIncoming = (transitionChild.key! as ValueKey<Object>).value == value;
        final dx = (isIncoming ? direction : -direction) * _travel;
        return SlideTransition(
          position: Tween<Offset>(begin: Offset(dx, 0), end: Offset.zero).animate(animation),
          child: FadeTransition(opacity: animation, child: transitionChild),
        );
      },
      child: KeyedSubtree(key: ValueKey(value), child: child),
    );
  }
}
