import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RoundedBackgroundIcon extends StatelessWidget {
  Key? key;
  Color? backgroundColor;
  Widget? icon;
  Widget? image;
  double height;
  double width;
  Function? onTap;
  bool enableMargin;
  double borderRadius;
  double margin;

  RoundedBackgroundIcon({
    this.key,
    this.backgroundColor,
    this.icon,
    this.image,
    this.height = 34,
    this.width = 34,
    this.borderRadius = 10,
    this.onTap,
    this.enableMargin = false,
    this.margin = 10,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: SizedBox(
        height: height,
        width: width,
        child: Card(
          color: backgroundColor,
          elevation: 0,
          margin: enableMargin
              ? EdgeInsets.symmetric(vertical: margin)
              : EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: image ?? icon,
        ),
      ),
    );
  }
}
