import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UtilityDashboardItemTile extends StatelessWidget {
  String title;
  IconData icon;
  Color iconColor;
  Function onTap;
  double height;

  UtilityDashboardItemTile(
      {required this.title,
      required this.icon,
      required this.iconColor,
      required this.onTap,
      this.height = 100});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        height: height,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              flexibleSpace(flex: 3),
              RoundedBackgroundIcon(
                height: 50,
                width: 50,
                icon: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
                backgroundColor: iconColor.withOpacity(0.08),
                borderRadius: 20,
                onTap: onTap,
              ),
              flexibleSpace(),
              Text(
                title,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
              flexibleSpace(flex: 3),
            ],
          ),
        ),
      ),
      onTap: onTap as void Function()?,
    );
  }
}
