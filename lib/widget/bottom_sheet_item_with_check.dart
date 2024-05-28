import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

class BottomSheetItemWithCheck extends StatelessWidget {
  final Function? onTap;
  final IconData? icon;
  final String? title;
  bool? isLast;
  final bool? isChecked;

  BottomSheetItemWithCheck(
      {this.onTap, this.icon, this.title, this.isLast = false, this.isChecked});

  @override
  Widget build(BuildContext context) {
    return bottomSheetItemWithCheck(
        isChecked: isChecked!,
        title: title!,
        icon: icon,
        isLast: isLast!,
        onTap: onTap);
  }

  Widget bottomSheetItemWithCheck(
      {Function? onTap,
      IconData? icon,
      required String title,
      bool isLast = false,
      required bool isChecked}) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            RoundedBackgroundIcon(
              icon: Icon(
                icon,
                size: 14,
              ),
              backgroundColor: lightGrey,
              width: 32,
              height: 32,
            ),
            const SizedBox(
              width: 16,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: blackFont),
            ),
            flexibleSpace(),
            if (isChecked)
              Icon(
                SlydoAppIcon.checked,
                color: navyBlue,
                size: 14,
              )
            else
              Container()
          ],
        ),
      ),
    );
  }
}
