import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomizedTextFormField extends StatefulWidget {
  Function validator;
  Function onChange;
  TextEditingController controller;
  TextInputType type;
  bool obscureText;
  bool isPassword;
  bool isReadOnly;
  String labelText;
  Color labelColor;
  int maxLength;

  CustomizedTextFormField({
    this.validator,
    this.onChange,
    this.controller,
    this.type = TextInputType.text,
    this.obscureText = false,
    this.isPassword = false,
    this.isReadOnly = false,
    this.labelText = "Label",
    this.labelColor,
    this.maxLength,
  });

  @override
  _CustomizedTextFormFieldState createState() =>
      _CustomizedTextFormFieldState();
}

class _CustomizedTextFormFieldState extends State<CustomizedTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              widget.labelText,
              style: TextStyle(
                  color:
                      widget.labelColor != null ? widget.labelColor : darkGrey,
                  fontSize: 14),
            ),
            SizedBox(
              height: 6,
            ),
            widget.isPassword
                ? Text(
                    "${widget.controller.text.toString().length}/6",
                    style: TextStyle(
                      color: widget.labelColor != null
                          ? widget.labelColor
                          : darkGrey,
                      fontSize: 14,
                    ),
                  )
                : Container(),
          ],
        ),
        SizedBox(
          height: 6,
        ),
        TextFormField(
          readOnly: widget.isReadOnly,
          style: TextStyle(
              fontSize: widget.isPassword ? 20 : 16,
              color: blackFont,
              fontWeight: FontWeight.w600,
              letterSpacing: widget.isPassword ? 2 : 0),
          buildCounter: (BuildContext context,
                  {int currentLength, int maxLength, bool isFocused}) =>
              null,
          cursorWidth: 1.5,
          cursorColor: navyBlue,
          decoration: InputDecoration(
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      Icons.remove_red_eye,
                      color: widget.obscureText ? darkGrey : navyBlue,
                    ),
                    onPressed: () {
                      widget.obscureText = !widget.obscureText;
                      setState(() {});
                    },
                  )
                : null,
            prefix: Padding(
              padding: EdgeInsets.only(left: 16),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: greyBorderColor,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: navyBlue,
                width: 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: greyBorderColor,
                width: 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: greyBorderColor,
                width: 1.0,
              ),
            ),
          ),
          validator: widget.validator,
          controller: widget.controller,
          keyboardType: widget.type,
          obscureText: widget.obscureText,
          maxLength: widget.maxLength,
          onChanged: (val) {
            if (widget.onChange != null) widget.onChange(val);
            setState(() {});
          },
        ),
      ],
    );
  }
}
