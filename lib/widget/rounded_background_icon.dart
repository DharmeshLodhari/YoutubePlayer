import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RoundedBackgroundIcon extends StatelessWidget {
  Color? backgroundColor;
  Widget? icon;
  Widget? image;
  double height;
  double width;
  Function? onTap;
  bool enableMargin;
  double borderRadius;

  RoundedBackgroundIcon(
      {this.backgroundColor,
      this.icon,
      this.image,
      this.height = 34,
      this.width = 34,
      this.borderRadius = 10,
      this.onTap,
      this.enableMargin = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: InkWell(
        child: Card(
          color: backgroundColor,
          elevation: 0,
          margin: enableMargin
              ? EdgeInsets.symmetric(vertical: 10)
              : EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: image ?? icon,
        ),
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
      ),
    );
  }
}
