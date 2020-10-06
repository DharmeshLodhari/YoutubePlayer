import 'package:flutter/material.dart';

import 'colors.dart';

export 'colors.dart';

// this function will build image frame by frame and load image from opacity 0 to 1 use this function in every image
Widget imageFrameBuilder(BuildContext context, Widget child, int frame,
    bool wasSynchronouslyLoaded) {
  if (wasSynchronouslyLoaded) {
    return child;
  }
  return AnimatedOpacity(
    child: child,
    opacity: frame == null ? 0 : 1,
    duration: Duration(milliseconds: 100),
    curve: Curves.easeOut,
  );
}

Widget customThemeBuilder(BuildContext context, Widget child) {
  return Theme(
    data: ThemeData.light().copyWith(
      primaryColor: navyBlue,
      accentColor: navyBlue,
      colorScheme: ColorScheme.light(primary: navyBlue),
      buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
    ),
    child: child,
  );
}

// for having expanded space
Widget flexibleSpace({int flex = 1}) {
  return Expanded(
    flex: flex,
    child: SizedBox(
      height: 10,
      width: 10,
    ),
  );
}

List monthName = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

String formatDate(DateTime dateTime) {
  String date =
      "${dateTime.day} ${monthName[dateTime.month]}, ${dateTime.year}";

  return date;
}
