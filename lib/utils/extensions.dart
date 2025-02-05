import 'package:Slydo/data/currency.dart';
import 'package:intl/intl.dart';

extension FORMAT on String {
  String toPNG() {
    return 'assets/images/$this.png';
  }

  String toSVG() {
    return 'assets/images/$this.svg';
  }

  String toJPG() {
    return 'assets/images/$this.jpg';
  }
}

extension FormateDate on DateTime {
  /// pass any date format you want in String result like DD/MM/YYYY
  String? toDateFormatString({required String dateFormat}) {
    final DateFormat df = DateFormat(dateFormat);

    return df.format(this).toString();
  }
}

extension CurrencyFormat on String {
  String toCurrencyNameAndSymbol() {
    return "$this (${worldCurrencies[this]})";
  }
}
