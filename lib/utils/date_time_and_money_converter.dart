import 'package:Slydo/utils/money_formatter/flutter_money_formatter.dart';
import 'package:intl/intl.dart';

/// for graph date rendering

int weekNumber(DateTime date) {
  final int dayOfYear = int.parse(DateFormat("D").format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}

DateTime getStartingOfWeek(DateTime date) {
  return date.subtract(Duration(days: date.weekday));
}

DateTime getEndingOfWeek(DateTime date) {
  final DateTime startingOfWeek = getStartingOfWeek(date);
  return startingOfWeek.add(const Duration(days: 6));
}

String moneyConverter(String amount, {bool isNotCompact = false}) {
  final amt = double.parse(amount.toString());
  final FlutterMoneyFormatter fmf =
      FlutterMoneyFormatter(amount: amt, settings: MoneyFormatterSettings());

  if (isNotCompact) return fmf.output.nonSymbol.toString();
  return fmf.output.compactNonSymbol;
}

int? convertStringToMillisecondsSinceEpoch(String? dateTime) {
  if (dateTime != null) {
    DateTime date = DateTime.parse(dateTime);
    if (!date.isUtc) {
      date = date.toUtc();
    }
    return date.millisecondsSinceEpoch;
  }
  return null;
}

String convertMillisecondsSinceEpochToString(int millisecondsSinceEpoch) {
  final DateTime date =
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch).toUtc();
  return date.toIso8601String();
}

String convertTimestampToDateTime(String timestamp) {
  // Parse the timestamp string into a DateTime object
  final DateTime dateTime = DateTime.parse(timestamp);

  // Create a DateFormat instance to format the date and time
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd | HH:mm:ss');

  // Format the DateTime object to the desired format
  final String formattedDateTime = dateFormat.format(dateTime);

  return formattedDateTime;
}
