import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CurvedButton extends StatelessWidget {
  String text = "Button";
  Color backgroundColor = navyBlue;
  Color textColor = Colors.white;
  Function onPressed = () {};

  CurvedButton({
    this.text,
    this.textColor,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 42,
      child: FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(7))),
        child: Text(
          text,
          style: TextStyle(
              color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        color: backgroundColor,
        onPressed: onPressed,
      ),
    );
  }
}

// ignore: must_be_immutable
class OutlineCurvedButton extends StatelessWidget {
  String text = "Button";
  Color backgroundColor = Colors.transparent;
  Color textColor = navyBlue;
  Function onPressed = () {};

  OutlineCurvedButton({
    this.text,
    this.textColor,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 42,
      child: FlatButton(
        shape: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(color: textColor)),
        child: Text(
          text,
          style: TextStyle(
              color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        color: backgroundColor,
        onPressed: onPressed,
      ),
    );
  }
}
