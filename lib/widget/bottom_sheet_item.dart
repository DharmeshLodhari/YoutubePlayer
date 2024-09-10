import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget bottomSheetItem(
    {Function? onTap,
    Widget? icon,
    IconData? iconData,
    String? profileIcon,
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
            getIcons(iconData, iconSize, profileIcon, icon),
            SizedBox(width: icon != null ? 28 : 16),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16, color: blackFont, fontWeight: FontWeight.w600),
            ),
            extraWidget ?? const SizedBox.shrink(),
          ],
        ),
      ),
    ),
  );
}

Widget getIcons(
    IconData? iconData, double iconSize, String? profileIcon, Widget? icon) {
  if (iconData != null) {
    return RoundedBackgroundIcon(
      icon: Icon(
        iconData,
        size: iconSize,
        color: blackFont,
      ),
      backgroundColor: lightGrey,
      width: 30,
      height: 30,
    );
  } else if (profileIcon != null) {
    return SvgPicture.asset(
      height: 30,
      width: 30,
      profileIcon.toSVG(),
    );
  } else {
    return Padding(
      padding: const EdgeInsets.only(left: 7.4),
      child: RoundedBackgroundIcon(
        icon: icon,
        backgroundColor: lightGrey,
        width: 12,
        height: 12,
      ),
    );
  }
}
