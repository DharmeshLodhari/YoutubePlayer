import 'package:Slydo/utils/colors.dart';
import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';

const int _kFlex = 1;
const Color _kBackgroundColor = Colors.white;
const bool _kAutoClose = true;

// ignore: must_be_immutable
class SlideActionButton extends StatelessWidget {
  Color? backgroundColor;
  Color? iconColor;
  final int flex;
  final Color? foregroundColor;
  final bool autoClose;
  final SlidableActionCallback? onPressed;
  final IconData? icon;
  final double spacing;
  final String? label;
  final BorderRadius borderRadius;
  final EdgeInsets? padding;

  SlideActionButton({
    Key? key,
    this.icon,
    this.iconColor,
    this.flex = _kFlex,
    this.backgroundColor,
    this.foregroundColor,
    this.autoClose = _kAutoClose,
    this.onPressed,
    this.spacing = 4,
    this.label,
    this.borderRadius = BorderRadius.zero,
    this.padding,
  })  : assert(flex > 0),
        assert(icon != null || label != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    iconColor ??= Colors.white;

    return CustomSlidableAction(
      borderRadius: borderRadius,
      padding: padding,
      onPressed: onPressed,
      autoClose: autoClose,
      backgroundColor: backgroundColor ?? white,
      foregroundColor: foregroundColor,
      flex: flex,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
          const SizedBox(
            height: 6,
          ),
          Flexible(
            child: Text(
              label!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: iconColor,
                fontFamily: "Inter",
              ),
            ),
          ),
        ],
      ),
    );
    // return InkWell(
    //   child: Card(
    //     color: backgroundColor,
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: <Widget>[
    //         Icon(
    //           icon,
    //           size: 16,
    //           color: iconColor,
    //         ),
    //         const SizedBox(
    //           height: 6,
    //         ),
    //         Text(
    //           title!,
    //           textAlign: TextAlign.center,
    //           style: TextStyle(
    //             fontSize: 12,
    //             fontWeight: FontWeight.w600,
    //             color: iconColor,
    //             fontFamily: "Inter",
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    //   onTap: () {
    //     slideController!.close();
    //     onTap!();
    //   },
    // );
  }
}
