import 'dart:io';

import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef Widget? BuildCounterWidget(
    int? currentLength, int? maxLength, bool? isFocused);

// ignore: must_be_immutable
class CustomizedTextFormField extends StatefulWidget {
  TextInputAction? textInputAction;
  Function(String? value)? onFieldSubmitted;
  bool hasLabel;
  bool hasBorder;
  TextStyle? textStyle;
  BuildCounterWidget? buildCounterWidget;
  bool isNumberOnlyInput;
  Function? validator;
  Function? onChanged;
  Function? onTap;
  TextEditingController? controller;
  List<TextInputFormatter>? inputFormatters;
  TextInputType keyboardType;
  bool obscureText;
  bool isPassword;
  bool isReadOnly;
  bool? enabled;
  bool isAmount;
  String labelText;
  String? hintText;
  Color? labelColor;
  int? maxLength;
  int? maxLines;
  FocusNode? focusNode;
  TextCapitalization textCapitalization;

  CustomizedTextFormField(
      {this.hasBorder = true,
      this.hasLabel = true,
      this.textInputAction,
      this.validator,
      this.onChanged,
      this.textStyle,
      this.onTap,
      this.onFieldSubmitted,
      this.controller,
      this.buildCounterWidget,
      this.isNumberOnlyInput = false,
      this.keyboardType = TextInputType.text,
      this.obscureText = false,
      this.isPassword = false,
      this.isReadOnly = false,
      this.isAmount = false,
      this.labelText = "",
      this.hintText = "",
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
            widget.hasLabel
                ? Text(
                    widget.labelText,
                    style: TextStyle(
                        color: widget.labelColor != null
                            ? widget.labelColor
                            : darkGrey,
                        fontSize: 14),
                  )
                : SizedBox.shrink(),
            widget.hasLabel
                ? SizedBox(
                    height: 6,
                  )
                : SizedBox.shrink(),
            widget.isPassword
                ? Text(
                    "${widget.controller!.text.toString().length}/6",
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
          onFieldSubmitted: widget.onFieldSubmitted,
          textInputAction: widget.textInputAction,
          readOnly: widget.isReadOnly,
          style: widget.textStyle ??
              TextStyle(
                  fontSize: widget.isPassword ? 20 : 16,
                  color: blackFont,
                  fontWeight: FontWeight.w600,
                  letterSpacing: widget.isPassword ? 2 : 0),
          buildCounter: (BuildContext context,
                  {int? currentLength, int? maxLength, bool? isFocused}) =>
              widget.buildCounterWidget != null
                  ? widget.buildCounterWidget!(
                      currentLength, maxLength, isFocused)
                  : null,
          cursorWidth: 1.5,
          enabled: widget.enabled,
          textCapitalization: widget.textCapitalization,
          cursorColor: navyBlue,
          decoration: InputDecoration(
            hintText: widget.hintText != null ? widget.hintText : null,
            hintStyle: TextStyle(
              color: darkGrey.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
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
            border: widget.hasBorder ? null : InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            enabledBorder: widget.hasBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: greyBorderColor,
                      width: 1.0,
                    ),
                  )
                : null,
            disabledBorder: widget.hasBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: greyBorderColor,
                      width: 1.0,
                    ),
                  )
                : null,
            focusedBorder: widget.hasBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: navyBlue,
                      width: 1.0,
                    ),
                  )
                : null,
            errorBorder: widget.hasBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: greyBorderColor,
                      width: 1.0,
                    ),
                  )
                : null,
            focusedErrorBorder: widget.hasBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: greyBorderColor,
                      width: 1.0,
                    ),
                  )
                : null,
          ),
          inputFormatters:
              widget.inputFormatters != null ? widget.inputFormatters : [],
          validator: (value) {
            if (widget.validator != null) {
              return widget.validator!(value!);
            }
            return null;
          },
          controller: widget.controller,
          keyboardType: getKeyBoardType(widget.keyboardType),
          obscureText: widget.obscureText,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          focusNode: widget.focusNode != null ? widget.focusNode : null,
          onChanged: (val) {
            if (widget.onChanged != null) widget.onChanged!(val);
            setState(() {});
          },
          onTap: () {
            if (widget.onTap != null) widget.onTap!();
            setState(() {});
          },
        ),
      ],
    );
  }

  TextInputType getKeyBoardType(TextInputType textInputType) {
    if (textInputType == TextInputType.number) {
      return Platform.isIOS
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number;
    }
    return textInputType;
  }
}
