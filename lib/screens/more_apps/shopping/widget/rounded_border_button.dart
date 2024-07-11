import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';

class RoundedBorderButton extends StatelessWidget {
  String title;
  Function onTap;
  Color? color;
  bool isLoading;

  RoundedBorderButton(
      {super.key,
      required this.title,
      required this.onTap,
      this.color,
      this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      height: 33,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      color: color ?? navyBlue,
      onPressed: onTap as void Function()?,
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
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: white,
                fontSize: 11,
                fontFamily: "Inter",
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
