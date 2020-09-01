import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';

// ignore: must_be_immutable
class SlideActionButton extends StatelessWidget {
  Function onTap;
  IconData icon;
  String title;
  Color backgroundColor;
  SlidableController slideController;

  SlideActionButton(
      {this.backgroundColor,
      this.onTap,
      this.icon,
      this.slideController,
      this.title});

  @override
  Widget build(BuildContext context) {
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
                color: Colors.white,
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                title,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              )
            ],
          ),
        ),
        onTap: () {
          onTap();
          slideController.activeState.close();
        },
      ),
    );
  }
}
