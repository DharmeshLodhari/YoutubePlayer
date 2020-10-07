import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

import 'CustomBoxShadow.dart';

// ignore: must_be_immutable
class UserDashboardItemTile extends StatelessWidget {
  String title;
  IconData icon;
  Color iconColor;
  Function onTap;

  UserDashboardItemTile({
    @required this.title,
    @required this.icon,
    @required this.iconColor,
    @required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: CustomBoxShadow(
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 3,
          shadowColor: boxShadowTwo,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                flexibleSpace(flex: 3),
                Card(
                  elevation: 0,
                  color: iconColor.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
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
      ),
      onTap: onTap,
    );
  }
}
