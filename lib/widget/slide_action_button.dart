import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';

// ignore: must_be_immutable
class SlideActionButton extends StatelessWidget {
  Function? onTap;
  IconData? icon;
  String? title;
  Color? backgroundColor;
  Color? iconColor;
  SlidableController? slideController;

  SlideActionButton(
      {this.backgroundColor,
      this.onTap,
      this.icon,
      this.iconColor,
      this.slideController,
      this.title});

  @override
  Widget build(BuildContext context) {
    if (iconColor == null) {
      iconColor = Colors.white;
    }

    return Container(
      child: InkWell(
        child: Card(
          color: backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: iconColor,
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor),
              )
            ],
          ),
        ),
        onTap: () {
          slideController!.activeState!.close();
          onTap!();
        },
      ),
    );
  }
}
