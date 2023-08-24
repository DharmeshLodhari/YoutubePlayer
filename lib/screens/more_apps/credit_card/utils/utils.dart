
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../utils/colors.dart';

String formatAsDollar(double amount) {
  final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  return currencyFormat.format(amount);
}

String formatAsNaira(double amount) {
  final currencyFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦');
  return currencyFormat.format(amount);
}

String convertCurrency(double value, double inputValue) {
  double finalOutput = value * inputValue;

  return formatCurrency(finalOutput);
}

String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(locale: 'en_US', symbol: '');
  return formatter.format(amount);
}

String insertSpacesInCardNumber(String cardNumber) {
  final List<String> chunks = [];
  for (int i = 0; i < cardNumber.length; i += 4) {
    chunks.add(cardNumber.substring(i, i + 4));
  }
  return chunks.join(' ');
}

Widget blurredText(String text, bool shouldBlur, double fontSize) {
  return BackdropFilter(
    filter: shouldBlur ? ImageFilter.blur(sigmaX: 0, sigmaY: 0) : ImageFilter.blur(sigmaX: 5, sigmaY: 5),
    child: Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: shouldBlur ? white : Colors.transparent,
      ),
    ),
  );
}