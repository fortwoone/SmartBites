import 'package:flutter/material.dart';
import '../../utils/color_constants.dart';

class RecipeBackground extends StatelessWidget {
  const RecipeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: primaryPeach.withOpacity(1.0),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 80,
          left: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: primaryPeach.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
