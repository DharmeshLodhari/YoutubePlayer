import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomChip extends StatelessWidget {
  String text;

  CustomChip({this.text = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: HexColor("#F7F7F9"),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: darkGrey, fontSize: 14, fontWeight: FontWeight.w400),
      ),
    );
  }
}
