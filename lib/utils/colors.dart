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
Color navyBlueLight = HexColor("#BEC2F4");
Color naturalGreen = HexColor("#46CE7C");
Color whiteBackground = HexColor("#F9F8F8");
Color blackFont = HexColor("#030F36");
Color darkGrey = HexColor("#75818F");
Color lightGrey = HexColor("#FBFBFF");
Color iconBtnGrey = HexColor("#F8F9FF");
Color greyBorderColor = HexColor("#DDE1E7");
Color dividerColor = HexColor("#EBEDFC");
Color mateRad = HexColor("#F35B46");
Color eyeGrey = HexColor("#A5ADB6");
Color starYellow = HexColor("#FFAB00");
Color graphWitheBackground = HexColor("#F3F3F3");

Color boxShadow = Color.fromARGB(51, 50, 55, 140);
