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

BoxDecoration decorateBox(
    {Color borderColor, double borderRadius = 10, Color shadowColor}) {
  if (shadowColor == null) shadowColor = boxShadowTwo;
  return BoxDecoration(
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: shadowColor,
        offset: Offset(0.0, 0.0),
        blurRadius: 20.0,
      ),
    ],
    color: Colors.white,
    borderRadius: BorderRadius.all(
      Radius.circular(borderRadius),
    ),
    border: new Border.all(
        color: borderColor != null ? borderColor : lightGrey,
        width: 1.0,
        style: BorderStyle.solid),
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

String formatDateInDigit(DateTime dateTime) {
  String date = "${dateTime.day}/${dateTime.month}/${dateTime.year}";

  return date;
}

String formatDurationInSeconds({Duration duration}) {
  String formattedDuration = "";
  if (int.parse(duration.toString().substring(0, 1)) > 0) {
    formattedDuration = duration.toString().substring(0, 7);
  } else {
    formattedDuration = duration.toString().substring(2, 7);
  }

  return formattedDuration;
}

String durationToString(Duration duration) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes =
      twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour));
  String twoDigitSeconds =
      twoDigits(duration.inSeconds.remainder(Duration.secondsPerMinute));
  return "$twoDigitMinutes:$twoDigitSeconds";
}

class PaymentDuration {
  String name;
  String value;

  PaymentDuration({this.name, this.value});
}

List<PaymentDuration> paymentDurations = [
  PaymentDuration(name: "Daily (7 days)", value: "daily"),
  PaymentDuration(name: "Business day only (5 days)", value: "weekday_only"),
  PaymentDuration(name: "Weekly", value: "weekly"),
  PaymentDuration(name: "Monthly", value: "monthly"),
  PaymentDuration(name: "Yearly", value: "yearly"),
];
