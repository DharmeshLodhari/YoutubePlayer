import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/state_notifier.dart';
import '../utils/util.dart';
import 'loading_indicator.dart';

typedef Widget? BuildCounterWidget(
    int? currentLength, int? maxLength, bool? isFocused);

// ignore: must_be_immutable
class CustomizedTextFormField extends StatefulWidget {
  final bool autoFocus;
  final String? helperText;
  final Widget? suffixIcon;
  TextInputAction? textInputAction;
  Function(String? value)? onFieldSubmitted;
  bool hasLabel;
  bool hasBorder;
  TextStyle? textStyle;
  // BuildCounterWidget? buildCounterWidget;
  final String? currencySymbol;
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
  double? fontSize;
  String? hintText;
  Color? labelColor;
  int? maxLength;
  int? maxLines;
  FontWeight? fontWeight;
  FocusNode? focusNode;
  EdgeInsets contentPadding;
  bool showLabelOrPassword;
  String? initialValue;
  TextCapitalization textCapitalization;

  Future<bool>? Function()? verifyInputFromServerFunc;
  bool? Function(String val)?
      whenToVerifyInputFromServer; //If this is true, verifyInputFromServerFunc will be executed
  Function? extraFunctionWhenInputWasVerifiedFromServerSuccessfully;
  Function? extraFunctionWhenInputWasNotVerifiedFromServer;
  double? borderWidth;

  CustomizedTextFormField({
    this.initialValue,
    this.autoFocus = false,
    this.helperText,
    this.verifyInputFromServerFunc,
    this.whenToVerifyInputFromServer,
    this.extraFunctionWhenInputWasVerifiedFromServerSuccessfully,
    this.extraFunctionWhenInputWasNotVerifiedFromServer,
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
    this.fontWeight = FontWeight.w500,
    // this.buildCounterWidget,
    this.currencySymbol,
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
    this.borderWidth,
    this.fontSize = 16,
  });

  @override
  _CustomizedTextFormFieldState createState() =>
      _CustomizedTextFormFieldState();
}

class _CustomizedTextFormFieldState extends State<CustomizedTextFormField> {
  bool? inputVerified;
  bool verifyingInput = false;
  bool? showSuffixIconWhenTryingToValidateInputFromServer;

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.showLabelOrPassword)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (widget.hasLabel)
                Text(
                  widget.labelText,
                  style: TextStyle(
                    color: widget.labelColor ?? darkGrey,
                    fontSize: widget.fontSize,
                    fontWeight: widget.fontWeight,
                    fontFamily: "Inter",
                  ),
                )
              else
                const SizedBox.shrink(),
              if (widget.hasLabel)
                const SizedBox(
                  height: 6,
                )
              else
                const SizedBox.shrink(),
              if (widget.isPassword)
                Text(
                  "${widget.controller!.text.toString().length}/6",
                  style: TextStyle(
                    color: widget.labelColor ?? darkGrey,
                    fontSize: 14,
                  ),
                )
              else
                Container(),
            ],
          )
        else
          const SizedBox.shrink(),
        if (widget.hasLabel)
          const SizedBox(
            height: 6,
          )
        else
          const SizedBox.shrink(),
        TextFormField(
          initialValue: widget.initialValue,
          autofocus: widget.autoFocus,
          onFieldSubmitted: widget.onFieldSubmitted,
          textInputAction: widget.textInputAction,
          readOnly: widget.isReadOnly,

          style: widget.textStyle ??
              TextStyle(
                  fontSize: widget.isPassword ? 20 : 16,
                  color: blackFont,
                  fontWeight: FontWeight.w600,
                  letterSpacing: widget.isPassword ? 2 : 0),
          // buildCounter: (BuildContext context,
          //         {int? currentLength, int? maxLength, bool? isFocused}) =>
          //     widget.buildCounterWidget != null
          //         ? widget.buildCounterWidget!(
          //             currentLength, maxLength, isFocused)
          //         : null,
          cursorWidth: 1.5,
          enabled: widget.enabled,
          textCapitalization: widget.textCapitalization,
          cursorColor: navyBlue,
          decoration: InputDecoration(
            helperText: widget.helperText,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: darkGrey.withOpacity(0.5),
              fontSize: 14,
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
                        padding: const EdgeInsets.only(left: 10, right: 12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: darkGrey.withOpacity(.12)),
                          child: Text(
                            widget.currencySymbol ??
                                worldCurrencies[userBloc.user.currency!]!,
                            style: TextStyle(
                              color: blackFont,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: "Inter",
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
            border: widget.hasBorder ? null : InputBorder.none,
            contentPadding: widget.contentPadding,
            enabledBorder: widget.hasBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: greyBorderColor,
                      width: widget.borderWidth != null
                          ? widget.borderWidth!
                          : 1.0,
                    ),
                  )
                : null,
            disabledBorder: widget.hasBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: greyBorderColor,
                      width: widget.borderWidth != null
                          ? widget.borderWidth!
                          : 1.0,
                    ),
                  )
                : null,
            focusedBorder: widget.hasBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: navyBlue,
                      width: widget.borderWidth != null
                          ? widget.borderWidth!
                          : 1.0,
                    ),
                  )
                : null,
            errorBorder: widget.hasBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: greyBorderColor,
                      width: widget.borderWidth != null
                          ? widget.borderWidth!
                          : 1.0,
                    ),
                  )
                : null,
            focusedErrorBorder: widget.hasBorder
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: greyBorderColor,
                      width: widget.borderWidth != null
                          ? widget.borderWidth!
                          : 1.0,
                    ),
                  )
                : null,
          ),
          inputFormatters: getInputFormatters(),
          validator: (value) {
            if (widget.validator != null) {
              if (widget.isAmountField == true) {
                return widget.validator!(value!.replaceAll(',', ''));
              } else {
                return widget.validator!(value!);
              }
            }
            return null;
          },
          controller: widget.controller,
          keyboardType: getKeyBoardType(widget.keyboardType),
          obscureText: widget.obscureText,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          focusNode: widget.focusNode,
          onChanged: (val) {
            if (widget.whenToVerifyInputFromServer != null) {
              if (widget.whenToVerifyInputFromServer!(val) == true) {
                showSuffixIconWhenTryingToValidateInputFromServer = true;
                _verifyInputFromServer();
              } else {
                showSuffixIconWhenTryingToValidateInputFromServer = false;
              }
            }

            if (widget.isAmountField == true) {
              if (widget.onChanged != null) {
                widget.onChanged!(val.replaceAll(',', ''));
              }
            } else {
              if (widget.onChanged != null) {
                widget.onChanged!(val);
              }
            }
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
    final TextInputType numberInputType = Platform.isIOS
        ? const TextInputType.numberWithOptions(decimal: true)
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

    final bool? verifyInputFromServerFunc =
        await widget.verifyInputFromServerFunc!();
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
      widget.extraFunctionWhenInputWasNotVerifiedFromServer!();
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
    if (showSuffixIconWhenTryingToValidateInputFromServer == false) {
      return const SizedBox.shrink();
    }
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
            child: const Icon(Icons.check, size: 20, color: Colors.white),
          ),
        );
      } else {
        return const Icon(Icons.cancel, color: Colors.red);
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  List<TextInputFormatter>? getInputFormatters() {
    if (widget.isAmountField) {
      return [CurrencyTextInputFormatter(symbol: '')];
    }
    if (widget.isNumberOnlyInput) {
      return [FilteringTextInputFormatter.digitsOnly];
    } else {
      return widget.inputFormatters;
    }
  }
}
