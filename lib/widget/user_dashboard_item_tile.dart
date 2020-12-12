import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

import 'CustomBoxShadow.dart';

// ignore: must_be_immutable
class UserDashboardItemTile extends StatelessWidget {
  String title;
  IconData icon;
  Color iconColor;
  Function onTap;
  double height;
  bool isLocked;

  UserDashboardItemTile(
      {@required this.title,
      @required this.icon,
      @required this.iconColor,
      @required this.onTap,
      this.isLocked = false,
      this.height = 100});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: CustomBoxShadow(
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 3,
          shadowColor: boxShadowTwo,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: lightGrey, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            height: height,
            child: Stack(
              children: [
                Center(
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
                isLocked
                    ? Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(
                          Icons.lock_outline_rounded,
                          color: blackFont,
                          size: 14,
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}
