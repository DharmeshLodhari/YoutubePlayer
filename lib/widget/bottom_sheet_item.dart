import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

Widget bottomSheetItem(
    {Function? onTap,
    IconData? icon,
    required String title,
    bool isLast = false,
    double iconSize = 14}) {
  return InkWell(
    child: Container(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            RoundedBackgroundIcon(
              icon: Icon(
                icon,
                size: iconSize,
              ),
              backgroundColor: lightGrey,
              width: 32,
              height: 32,
            ),
            SizedBox(
              width: 16,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: blackFont),
            )
          ],
        ),
      ),
    ),
    onTap: onTap as void Function()?,
  );
}
