import 'package:flutter/material.dart';

import '../../../utils/colors.dart';

Widget attachmentWidget({
  required Function onTap,
  required IconData iconData,
  required String title,
}) {
  return InkWell(
    onTap: () {
      onTap();
    },
    child: Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 18),
          const SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              color: navyBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
