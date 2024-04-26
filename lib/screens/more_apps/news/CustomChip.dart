import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomChip extends StatelessWidget {
  String text;
  final Color? color;
  final Color? textColor;
  final EdgeInsets? padding;

  CustomChip(
      {super.key, this.text = "", this.padding, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: color ?? HexColor("#F7F7F9"),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor ?? darkGrey,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
