import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../locator.dart';
import '../services/app_config_bloc.dart';

// ignore: must_be_immutable
class CurvedButton extends StatelessWidget {
  double? width;
  String? text;
  Color? backgroundColor;
  Color? textColor;
  Function onPressed;
  double height;
  double borderRadius;
  bool isLoading;
  bool isPaymentBtn;

  CurvedButton(
      {this.text,
      this.width,
      this.textColor,
      this.backgroundColor,
      required this.onPressed,
      this.height = 42,
      this.isPaymentBtn = false,
      this.borderRadius = 7,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (backgroundColor == null) {
      backgroundColor = navyBlue;
    }
    if (textColor == null) {
      textColor = Colors.white;
    }
    if (text == null) {
      text = "Button";
    }
    return Container(
      width: width ?? 100.w,
      height: height,
      child: MaterialButton(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
        child: isLoading
            ? Center(
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularLoadingIndicator(
                    color: Colors.white,
                  ),
                ),
              )
            : Text(
                text!,
                style: TextStyle(
                    color: textColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600),
              ),
        color: backgroundColor,
        onPressed: () {
          onBtnPressed();
        },
        disabledColor: darkGrey.withOpacity(0.5),
      ),
    );
  }

  onBtnPressed() {
    if (isPaymentBtn) {
      if (getIt<AppConfigurationBloc>().appConfigurationModel?.enablePayment ==
          false) {
        showToast(message: 'Payment Coming soon');
        return;
      } else {
        onPressed();
        return;
      }
    } else {
      onPressed();
    }
  }
}

// ignore: must_be_immutable
class OutlineCurvedButton extends StatelessWidget {
  String? text = "Button";
  Color? backgroundColor = Colors.transparent;
  Color? textColor = navyBlue;
  Function? onPressed = () {};

  OutlineCurvedButton({
    this.text,
    this.textColor,
    this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 42,
      child: MaterialButton(
        shape: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            borderSide: BorderSide(color: textColor!)),
        child: Text(
          text!,
          style: TextStyle(
              color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        color: backgroundColor,
        onPressed: onPressed as void Function()?,
      ),
    );
  }
}
