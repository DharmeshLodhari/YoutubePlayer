import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

Widget bottomSheetItem(
    {Function? onTap,
    Widget? icon,
    IconData? iconData,
    required String title,
    bool isLast = false,
    Widget? extraWidget,
    double iconSize = 14}) {
  return InkWell(
    onTap: onTap as void Function()?,
    child: SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            iconData != null
                ? RoundedBackgroundIcon(
                    icon: Icon(
                      iconData,
                      size: iconSize,
                      color: blackFont,
                    ),
                    backgroundColor: lightGrey,
                    width: 32,
                    height: 32,
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 7.4),
                    child: RoundedBackgroundIcon(
                      icon: icon,
                      backgroundColor: lightGrey,
                      width: 12,
                      height: 12,
                    ),
                  ),
            SizedBox(width: icon != null ? 28 : 16),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: blackFont, fontWeight: FontWeight.w600),
            ),
            extraWidget ?? const SizedBox.shrink(),
          ],
        ),
      ),
    ),
  );
}
