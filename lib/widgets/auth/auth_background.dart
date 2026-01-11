import 'package:flutter/material.dart';
import '../../utils/color_constants.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});
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
              color: AppColors.primary.withAlpha(255),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(13),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
