import 'package:Slydo/utils/date_time_and_money_converter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

import 'colors.dart';

export 'colors.dart';
export 'common.dart';

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

Widget imageErrorWidget(BuildContext context, String url, dynamic error) =>
    CachedNetworkImage(
        imageUrl:
            "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high);

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

String formatTime(String date) {
  DateTime dateTime = DateTime.parse(date).toLocal();

  String time = DateFormat("hh:mm a").format(dateTime);

  return time;
}

String formatDate(DateTime dateTime) {
  String date =
      "${dateTime.day} ${monthName[dateTime.month - 1]}, ${dateTime.year}";

  return date;
}

String formatDateInTwoDigit(DateTime dateTime) {
  String date =
      "${dateTime.day.toString().padLeft(2, '0')} ${monthName[dateTime.month - 1]}, ${dateTime.year}";

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

String dateToString(DateTime date) {
  var formatter = new DateFormat('yyyy-MM-dd');
  var formatted = formatter.format(date);
  return formatted;
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

List<String> errorImageList = [
  "https://slydo-assets.s3.amazonaws.com/media/customer/avatar/me_uAxOKxt.jpeg",
  "https://slydo-assets.s3.amazonaws.com/media/customer/avatar/me_DN78oka.jpeg",
  "https://slydo-assets.s3.amazonaws.com/media/customer/avatar/me.jpeg"
];

String checkImageInErrorList(String url) {
  errorImageList.forEach((element) {
    if (element == url) {
      return "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png";
    }
  });
  return url;
}

void apiErrorHandler({String error, BuildContext context, int duration = 1}) {
  Toast.show("$error", context,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      duration: duration);
}

int moneyInputNormalizer(String amount) {
  double value = double.parse(amount) * 100;
  // Format the money into integer as server store money in integer
  return value.toInt();
}

String moneyDisplayNormalizer(int amount) {
  // Format the money into double as server returns money in integer
  // amount = 1050500;

  if (amount.toString().length >= 3) {
    int amountLength = amount.toString().length;

    int getLastTwoDigit =
        int.parse(amount.toString().substring(amountLength - 2, amountLength));

    if (getLastTwoDigit > 0) {
      return moneyConverter(
          double.parse((amount / 100).toString()).toStringAsFixed(2),
          isNotCompact: true);
    } else {
      return moneyConverter(
          double.parse((amount / 100).toString()).toStringAsFixed(2),
          isNotCompact: true);
    }
  } else {
    return moneyConverter(
        double.parse((amount / 100).toString()).toStringAsFixed(2),
        isNotCompact: true);
  }
}

String getSecureUrl({String url}) {
  String secureUrl;
  if (!url.startsWith("https://")) {
    url = url.replaceFirst("http", "https");
  }
  secureUrl = url;
  return secureUrl;
}
