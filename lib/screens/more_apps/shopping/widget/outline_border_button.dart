import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

class OutlineBorderButton extends StatelessWidget {
  String title;
  Function onTap;

  OutlineBorderButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 33,
      elevation: 0,
      shape: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
          borderSide: BorderSide(color: navyBlue)),
      color: white,
      onPressed: onTap as void Function()?,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: navyBlue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: "Inter",
        ),
      ),
    );
  }
}
