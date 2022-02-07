import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/utils/date_time_and_money_converter.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'colors.dart';

export 'colors.dart';
export 'common.dart';

// this function will build image frame by frame and load image from opacity 0 to 1 use this function in every image
Widget imageFrameBuilder(BuildContext context, Widget child, int? frame,
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

Widget imageErrorForUserWidget(
        BuildContext context, String url, dynamic error) =>
    Image.network(
      defaultImage,
      colorBlendMode: BlendMode.darken,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
    );

Widget imageErrorWidget(BuildContext context, String url, dynamic error) =>
    Container(
      color: darkGrey.withOpacity(0.50),
      child: Image.asset(
        defaultProductAndServiceImage,
        width: double.infinity,
        height: double.infinity,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );

Widget wallpaperErrorWidget(BuildContext context, String url, dynamic error) =>
    Image.asset(
      defaultWallPaper,
      width: double.infinity,
      height: double.infinity,
      colorBlendMode: BlendMode.darken,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );

Widget productAndServiceErrorWidget(
        BuildContext context, String url, dynamic error) =>
    Container(
      color: darkGrey.withOpacity(0.50),
      child: Image.asset(
        defaultProductAndServiceImage,
        width: double.infinity,
        height: double.infinity,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );

Widget productAndServiceBigErrorWidget(
        BuildContext context, String url, dynamic error) =>
    Container(
      color: darkGrey.withOpacity(0.50),
      child: Image.asset(
        defaultProductAndServiceImage,
        width: double.infinity,
        height: double.infinity,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      ),
    );

Widget customThemeBuilder(BuildContext context, Widget? child) {
  return Theme(
    data: ThemeData.light().copyWith(
      primaryColor: navyBlue,
      buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
      colorScheme:
          ColorScheme.light(primary: navyBlue).copyWith(secondary: navyBlue),
    ),
    child: child!,
  );
}

BoxDecoration decorateBox(
    {Color? borderColor, double borderRadius = 10, Color? shadowColor}) {
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

void androidBottomSheet(
    {required BuildContext context, required Widget child}) {
  showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          color: Colors.white,
          margin: EdgeInsets.zero,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: child,
          ),
        );
      });
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
List dayName = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];

String getDayName({required int day}) {
  return dayName[day - 1];
}

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

String formatDurationInSeconds({Duration? duration}) {
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
  String? name;
  String? value;

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

void apiErrorHandler({String? error, BuildContext? context, int duration = 1}) {
  Fluttertoast.showToast(
    msg: "$error",
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black,
    textColor: Colors.white,
  );
}

int moneyInputNormalizer(String amount) {
  double value = double.parse(amount) * 100;
  // Format the money into integer as server store money in integer
  return value.toInt();
}

String moneyDisplayNormalizer(int? amount) {
  // Format the money into double as server returns money in integer
  // amount = 1050500;

  if (amount.toString().length >= 3) {
    int amountLength = amount.toString().length;

    int getLastTwoDigit =
        int.parse(amount.toString().substring(amountLength - 2, amountLength));

    if (getLastTwoDigit > 0) {
      return moneyConverter(
          double.parse((amount! / 100).toString()).toStringAsFixed(2),
          isNotCompact: true);
    } else {
      return moneyConverter(
          double.parse((amount! / 100).toString()).toStringAsFixed(2),
          isNotCompact: true);
    }
  } else {
    return moneyConverter(
        double.parse((amount! / 100).toString()).toStringAsFixed(2),
        isNotCompact: true);
  }
}

String moneyNormalizer(int? amount) {
  // Format the money into double as server returns money in integer
  // amount = 1050500;

  return (amount! / 100).toString();
}

int moneyDisplayNormalizerForGraph(int? amount) {
  // Format the money into double as server returns money in integer
  // amount = 1050500;

  int formattedAmount = (double.parse(amount.toString()) / 100).truncate();
  return formattedAmount;
}

String getSecureUrl({required String url}) {
  String secureUrl;
  if (!url.startsWith("https://")) {
    url = url.replaceFirst("http", "https");
  }
  secureUrl = url;
  return secureUrl;
}

/// For Storing notification image
Future<String> saveImage(BuildContext context, Image image) {
  final completer = Completer<String>();

  image.image
      .resolve(ImageConfiguration())
      .addListener(ImageStreamListener((imageInfo, _) async {
    ByteData? byteData =
        await imageInfo.image.toByteData(format: ImageByteFormat.png);
    if (byteData == null) return Future.error("ERROR while saving image");
    final pngBytes = byteData.buffer.asUint8List();

    final fileName = pngBytes.hashCode;
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(pngBytes);

    completer.complete(filePath);
  }));

  return completer.future;
}

///generate hash of the message
String generateHashedMessage(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

Future<double> getAccountBalance() async {
  Map<String, dynamic>? data =
      await PaymentAndBankingAuth().getAccountBalance();
  if (data == null) return 0.0;

  int spendableBalance = data["spendable_balance"];

  double accountBalanceConverted = spendableBalance / 100;
  debugPrint("ACCOUNT BALANCE:- $accountBalanceConverted");

  return accountBalanceConverted;
}

const String defaultImage =
    "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png";

const String defaultWallPaper = "assets/images/home_screen_background.png";

const String defaultProductAndServiceImage =
    "assets/images/default_image/product_and_service.png";

void showToast({String? message}) {
  Fluttertoast.showToast(
    msg: "$message",
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black,
    textColor: Colors.white,
  );
}

String? checkSlydoName(String name) {
  String? result;

  if (name.isNotEmpty && name != "") {
    List<String> listOfWords = name.split(" ").toList();
    for (int i = 0; i < listOfWords.length; i++) {
      if (listOfWords[i].toLowerCase() == "slydo") {
        result = "You can not use slydo in name.";
        break;
      }
    }
  }
  debugPrint("ERROR:- $result");

  return result;
}

String getFormattedAccountNumber({String accountNumber = "0000000000"}) {
  return '******' +
      accountNumber.substring(
          accountNumber.length - 5, accountNumber.length - 1);
}

double formatRating(double rating) {
  return double.parse(rating.toStringAsFixed(1));
}
