/*
 * rflutter_alert
 * Created by Ratel
 * https://ratel.com.tr
 *
 * Copyright (c) 2018 Ratel, LLC. All rights reserved.
 * See LICENSE for distribution and usage details.
 */
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';

/// Used for defining alert buttons.
///
/// [child] and [onPressed] parameters are required.
class DialogButtonStateFul extends StatefulWidget {
  final Color? backgroundColor;
  final Function onPressed;
  final Color? textColor;
  final String? text;

  /// DialogButton constructor
  DialogButtonStateFul({
    Key? key,
    this.backgroundColor,
    this.text,
    this.textColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<DialogButtonStateFul> createState() => _DialogButtonStateFulState();
}

class _DialogButtonStateFulState extends State<DialogButtonStateFul> {
  bool isLoading = false;

  /// Creates alert buttons based on constructor params
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: Material(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(7))),
        color: widget.backgroundColor,
        child: InkWell(
          onTap: isLoading
              ? null
              : () async {
                  isLoading = true;
                  setState(() {});
                  await widget.onPressed();
                  isLoading = false;
                  setState(() {});
                },
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularLoadingIndicator(
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.text!,
                    style: TextStyle(
                        color: widget.textColor,
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
