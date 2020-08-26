import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomizedTextFormField extends StatelessWidget {
  Function validator;
  TextEditingController controller;
  TextInputType type;
  bool obscureText;
  String labelText;
  Color labelColor;
  int maxLength;

  CustomizedTextFormField({
    this.validator,
    this.controller,
    this.type = TextInputType.text,
    this.obscureText = false,
    this.labelText = "Label",
    this.labelColor,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          labelText,
          style: TextStyle(
              color: labelColor != null ? labelColor : darkGrey, fontSize: 14),
        ),
        SizedBox(
          height: 6,
        ),
        TextFormField(
          cursorColor: Colors.black87,
          style: TextStyle(
              fontSize: 16, color: blackFont, fontWeight: FontWeight.w600),
          buildCounter: (BuildContext context,
                  {int currentLength, int maxLength, bool isFocused}) =>
              null,
          decoration: InputDecoration(
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
                color: greyBorderColor,
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
          validator: validator,
          controller: controller,
          keyboardType: type,
          obscureText: obscureText,
          maxLength: maxLength,
        ),
      ],
    );
  }
}
