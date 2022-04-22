import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/util.dart';
import 'LoadingIndicator.dart';

typedef Widget? BuildCounterWidget(
    int? currentLength, int? maxLength, bool? isFocused);

// ignore: must_be_immutable
class CustomizedTextFormField extends StatefulWidget {
  final Widget? suffixIcon;
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
  bool isAmountField;
  String labelText;
  String? hintText;
  Color? labelColor;
  int? maxLength;
  int? maxLines;
  FocusNode? focusNode;
  EdgeInsets contentPadding;
  bool showLabelOrPassword;
  TextCapitalization textCapitalization;

  Future<bool>? Function()? verifyInputFromServerFunc;
  bool? Function(String val)? verifyInputFromServerValidation;
  Function? extraFunctionWhenInputWasVerifiedFromServerSuccessfully;
  Function? extraFunctionWhenInputWasNotVerifiedFromServerSuccessfully;

  CustomizedTextFormField({
    this.verifyInputFromServerFunc,
    this.verifyInputFromServerValidation,
    this.extraFunctionWhenInputWasVerifiedFromServerSuccessfully,
    this.extraFunctionWhenInputWasNotVerifiedFromServerSuccessfully,
    this.suffixIcon,
    this.hasBorder = true,
    this.hasLabel = true,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.textStyle,
    this.onTap,
    this.onFieldSubmitted,
    this.controller,
    this.buildCounterWidget,
    this.showLabelOrPassword = true,
    this.isNumberOnlyInput = false,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.isPassword = false,
    this.isReadOnly = false,
    this.isAmountField = false,
    this.labelText = "",
    this.hintText = "",
    this.labelColor,
    this.maxLength,
    this.maxLines = 1,
    this.focusNode,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 10),
  });

  @override
  _CustomizedTextFormFieldState createState() =>
      _CustomizedTextFormFieldState();
}

class _CustomizedTextFormFieldState extends State<CustomizedTextFormField> {
  bool verifyingInput = false;
  bool? inputVerified;

  @override
  void initState() {
    super.initState();

    // if (widget.isAmountField) {
    //   widget.controller!.addListener(() {
    //
    //     widget.controller!.text =
    //         moneyDisplayNormalizer(int.parse(widget.controller!.text));
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        widget.showLabelOrPassword
            ? Row(
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
              )
            : SizedBox.shrink(),
        widget.hasLabel
            ? SizedBox(
                height: 6,
              )
            : SizedBox.shrink(),
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
            suffixIcon: _getSuffixIcon(),
            prefix: Padding(
              padding: EdgeInsets.only(left: widget.isAmountField ? 8 : 16),
            ),
            prefixIcon: widget.isAmountField
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
            contentPadding: widget.contentPadding,
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
            if (widget.verifyInputFromServerValidation != null) {
              if (widget.verifyInputFromServerValidation!(val) == true) {
                _verifyInputFromServer();
              }
            }

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
    TextInputType numberInputType = Platform.isIOS
        ? TextInputType.numberWithOptions(decimal: true)
        : TextInputType.number;
    if (widget.isAmountField == true) {
      return numberInputType;
    }

    if (textInputType == TextInputType.number) {
      return numberInputType;
    }
    return textInputType;
  }

  Future _verifyInputFromServer() async {
    setState(() => verifyingInput = true);

    bool? verifyInputFromServerFunc = await widget.verifyInputFromServerFunc!();
    if (verifyInputFromServerFunc == true) {
      setState(() {
        inputVerified = true;
        verifyingInput = false;
      });
      widget.extraFunctionWhenInputWasVerifiedFromServerSuccessfully!();
    } else {
      setState(() {
        inputVerified = false;
        verifyingInput = false;
      });
      widget.extraFunctionWhenInputWasNotVerifiedFromServerSuccessfully!();
    }
  }

  // widget.suffixIcon != null
  // ? widget.suffixIcon
  //     : widget.isPassword
  // ? IconButton(
  // icon: Icon(
  // Icons.remove_red_eye,
  // color: widget.obscureText ? darkGrey : navyBlue,
  // ),
  // onPressed: () {
  // widget.obscureText = !widget.obscureText;
  // setState(() {});
  // },
  // )
  //     : null,

  Widget? _getSuffixIcon() {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    } else if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          Icons.remove_red_eye,
          color: widget.obscureText ? darkGrey : navyBlue,
        ),
        onPressed: () {
          widget.obscureText = !widget.obscureText;
          setState(() {});
        },
      );
    } else if (verifyingInput) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: CircularLoadingIndicator(),
      );
    } else if (inputVerified != null) {
      if (inputVerified!) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: navyBlue,
            child: Icon(Icons.check, size: 20, color: Colors.white),
          ),
        );
      } else {
        return Icon(Icons.cancel, color: Colors.red);
      }
    } else {
      return SizedBox.shrink();
    }
  }
}
