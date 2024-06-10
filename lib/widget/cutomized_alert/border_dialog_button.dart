/*
 * rflutter_alert
 * Created by Ratel
 * https://ratel.com.tr
 * 
 * Copyright (c) 2018 Ratel, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:flutter/material.dart';

/// Used for defining alert buttons.
///
/// [child] and [onPressed] parameters are required.
class BorderDialogButton extends StatelessWidget {
  final Color? backgroundColor;
  final Function onPressed;
  final Color? textColor;
  final bool outlineBorder;
  final String? text;

  /// DialogButton constructor
  const BorderDialogButton({
    super.key,
    this.backgroundColor,
    this.text,
    this.textColor,
    this.outlineBorder = false,
    required this.onPressed,
  });

  /// Creates alert buttons based on constructor params
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: Material(
        shape: outlineBorder
            ? OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                borderSide: BorderSide(color: textColor!))
            : const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(7))),
        color: backgroundColor,
        child: InkWell(
          onTap: onPressed as void Function()?,
          child: Center(
            child: Text(
              text!,
              style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Inter"),
            ),
          ),
        ),
      ),
    );
  }
}
