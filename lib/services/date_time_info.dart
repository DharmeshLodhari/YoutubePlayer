import 'package:intl/intl.dart';

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
