import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:intl/intl.dart';

/// for graph date rendering

int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}

DateTime getStartingOfWeek(DateTime date) {
  return date.subtract(new Duration(days: date.weekday));
}

DateTime getEndingOfWeek(DateTime date) {
  DateTime startingOfWeek = getStartingOfWeek(date);
  return startingOfWeek.add(new Duration(days: 6));
}

String moneyConverter(var amount) {
  var amt = double.parse(amount.toString());
  FlutterMoneyFormatter fmf = FlutterMoneyFormatter(amount: amt);
  return fmf.output.compactNonSymbol;
}
