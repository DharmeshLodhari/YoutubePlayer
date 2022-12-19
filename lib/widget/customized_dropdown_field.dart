import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomizedDropDownField extends StatefulWidget {
  Widget child;
  String title;
  Color? titleColor;
  double? borderWidth;
  FontWeight? fontWeight;

  CustomizedDropDownField(
      {required this.child,
      required this.title,
      this.titleColor,
      this.borderWidth,
      this.fontWeight});

  @override
  _CustomizedDropDownFieldState createState() =>
      _CustomizedDropDownFieldState();
}

class _CustomizedDropDownFieldState extends State<CustomizedDropDownField> {
  @override
  Widget build(BuildContext context) {
    if (widget.titleColor == null) {
      widget.titleColor = darkGrey;
    }
    if (widget.fontWeight == null) {
      widget.fontWeight = FontWeight.normal;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.title,
          style: TextStyle(
              color: widget.titleColor,
              fontSize: 14,
              fontWeight: widget.fontWeight),
        ),
        SizedBox(
          height: 6,
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                  color: greyBorderColor,
                  width:
                      widget.borderWidth != null ? widget.borderWidth! : 1.0)),
          margin: EdgeInsets.all(0),
          borderOnForeground: true,
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(alignedDropdown: true, child: widget.child),
          ),
        ),
      ],
    );
  }
}
