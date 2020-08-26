import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

HexColor lightBlue() {
  return HexColor('#0099df');
}

HexColor darkBlue() {
  return HexColor('#0d1b46');
}

Color navyBlue = HexColor("#3F61DB");
Color whiteBackground = HexColor("#F9F8F8");
Color blackFont = HexColor("#030F36");
Color darkGrey = HexColor("#75818F");
Color greyBorderColor = HexColor("#DDE1E7");
