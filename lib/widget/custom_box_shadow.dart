import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomBoxShadow extends StatelessWidget {
  Widget child;
  double offsetRight;
  double offsetBottom;
  Color? color;
  double blurRadius;
  double borderRadius;

  CustomBoxShadow({
    required this.child,
    this.blurRadius = 7.0,
    this.borderRadius = 12,
    this.offsetBottom = 6.0,
    this.offsetRight = 2.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: color != null ? color! : boxShadowTwo.withOpacity(0.04),
            blurRadius: blurRadius, // soften the shadow
            spreadRadius: 0.0, //extend the shadow
            offset: Offset(
              offsetRight, // Move to right 2.0  horizontally
              offsetBottom, // Move to bottom 6.0 Vertically
            ),
          )
        ],
      ),
      child: child,
    );
  }
}
