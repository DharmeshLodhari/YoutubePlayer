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

Color navyBlue = HexColor("#3F61DB");
Color navyBlueLight = HexColor("#BEC2F4");
Color naturalGreen = HexColor("#46CE7C");
Color naturalGreenLight = HexColor("#E9FFF2");
Color whiteBackground = HexColor("#F9F8F8");
Color blackFont = HexColor("#030F36");
Color darkGrey = HexColor("#75818F");
Color richPink = HexColor("#F07097");
Color richPurple = HexColor("#9B51E0");
Color lightGrey = HexColor("#FBFBFF");
Color chatBackgroundColor = HexColor("#F4F5F6");
Color iconBtnGrey = HexColor("#F8F9FF");
Color greyBorderColor = HexColor("#DDE1E7");
Color dividerColor = HexColor("#EBEDFC");
Color mateRed = HexColor("#F35B46");
Color mateRedLight = HexColor("#FFECEA");
Color eyeGrey = HexColor("#A5ADB6");
Color starYellow = HexColor("#FFAB00");
Color graphWitheBackground = HexColor("#F3F3F3");
Color selectedListItemBackgroundBlue = HexColor("#F8F9FF");

Color boxShadow = Color.fromARGB(51, 50, 55, 140);
Color boxShadowTwo = HexColor("#32378C").withOpacity(0.07);
