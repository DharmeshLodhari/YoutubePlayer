import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomizedDropDownField extends StatefulWidget {
  Widget child;
  String title;
  Color? titleColor;
  double? borderWidth;
  double? fontSize;
  double? height;
  FontWeight? fontWeight;

  CustomizedDropDownField(
      {super.key,
      required this.child,
      required this.title,
      this.titleColor,
      this.borderWidth,
      this.fontSize = 16,
      this.height = 10,
      this.fontWeight});

  @override
  State<CustomizedDropDownField> createState() =>
      _CustomizedDropDownFieldState();
}

class _CustomizedDropDownFieldState extends State<CustomizedDropDownField> {
  @override
  Widget build(BuildContext context) {
    widget.titleColor ??= darkGrey;
    widget.fontWeight ??= FontWeight.normal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.title == '')
          const SizedBox.shrink()
        else
          Text(
            widget.title,
            style: TextStyle(
              color: widget.titleColor,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              fontFamily: "Inter",
            ),
          ),
        SizedBox(
          height: widget.height,
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
          margin: const EdgeInsets.all(0),
          borderOnForeground: true,
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(alignedDropdown: true, child: widget.child),
          ),
        ),
      ],
    );
  }
}
