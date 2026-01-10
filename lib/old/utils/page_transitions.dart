import 'package:flutter/material.dart';

class SlideAndFadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final AxisDirection direction;

  SlideAndFadePageRoute({
    required this.page,
    this.direction = AxisDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
              reverseCurve: Curves.easeInQuart,
            );

            final secondaryCurvedAnimation = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInQuart,
            );
            Offset slideBegin;
            switch (direction) {
              case AxisDirection.right:
                slideBegin = const Offset(0.3, 0.0);
                break;
              case AxisDirection.left:
                slideBegin = const Offset(-0.3, 0.0);
                break;
              case AxisDirection.up:
                slideBegin = const Offset(0.0, -0.3);
                break;
              case AxisDirection.down:
                slideBegin = const Offset(0.0, 0.3);
                break;
            }

            return SlideTransition(
              position: Tween<Offset>(
                begin: slideBegin,
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(curvedAnimation),
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: 1.0,
                    end: 0.7,
                  ).animate(secondaryCurvedAnimation),
                  child: child,
                ),
              ),
            );
          },
        );
}

