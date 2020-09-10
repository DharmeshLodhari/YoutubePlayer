import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class CustomizedTextFormField extends StatefulWidget {
  Function validator;
  Function onChanged;
  Function onTap;
  TextEditingController controller;
  List<TextInputFormatter> inputFormatters;
  TextInputType type;
  bool obscureText;
  bool isPassword;
  bool isReadOnly;
  bool enabled;
  bool isAmount;
  String labelText;
  Color labelColor;
  int maxLength;
  int maxLines;
  FocusNode focusNode;
  TextCapitalization textCapitalization;

  CustomizedTextFormField(
      {this.validator,
      this.onChanged,
      this.onTap,
      this.controller,
      this.type = TextInputType.text,
      this.obscureText = false,
      this.isPassword = false,
      this.isReadOnly = false,
      this.isAmount = false,
      this.labelText = "Label",
      this.labelColor,
      this.maxLength,
      this.maxLines = 1,
      this.focusNode,
      this.enabled = true,
      this.textCapitalization = TextCapitalization.none,
      this.inputFormatters});

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
          enabled: widget.enabled,
          textCapitalization: widget.textCapitalization,
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
              padding: EdgeInsets.only(left: widget.isAmount ? 8 : 16),
            ),
            prefixIcon: widget.isAmount
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 12),
                        child: Icon(
                          SlydoAppIcon.naira,
                          color: blackFont,
                          size: 12,
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: dividerColor,
                      ),
                    ],
                  )
                : null,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: greyBorderColor,
                width: 1.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
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
          inputFormatters:
              widget.inputFormatters != null ? widget.inputFormatters : [],
          validator: widget.validator,
          controller: widget.controller,
          keyboardType: widget.type,
          obscureText: widget.obscureText,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          focusNode: widget.focusNode != null ? widget.focusNode : null,
          onChanged: (val) {
            if (widget.onChanged != null) widget.onChanged(val);
            setState(() {});
          },
          onTap: () {
            if (widget.onTap != null) widget.onTap();
            setState(() {});
          },
        ),
      ],
    );
  }
}
