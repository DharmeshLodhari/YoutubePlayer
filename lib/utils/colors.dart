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

Color white = HexColor("#FFFFFF");
Color navyBlue = HexColor("#3F61DB");
Color navyBlueLight = HexColor("#BEC2F4");
Color naturalGreen = HexColor("#46CE7C");
Color naturalGreenLight = HexColor("#E9FFF2");
Color brownLight = HexColor("#FFEFE0");
Color whiteBackground = HexColor("#F9F8F8");
Color blackFont = HexColor("#030F36");
Color black = HexColor("#000000");
Color lightPink = HexColor("#FFE6E2");
Color deepPink = HexColor("#FD7D75");
Color darkGrey = HexColor("#75818F");
Color richPink = HexColor("#F07097");
Color richPurple = HexColor("#9B51E0");
Color lightGrey = HexColor("#FBFBFF");
Color chatBackgroundColor = HexColor("#F4F5F6");
Color iconBtnGrey = HexColor("#F8F9FF");
Color greyBorderColor = HexColor("#DDE1E7");
Color greyTagColor = HexColor("#e8ebef");
Color dividerColor = HexColor("#EBEDFC");
Color mateRed = HexColor("#F35B46");
Color mateRedLight = HexColor("#FFECEA");
Color redBtn = HexColor("#FE5151");
Color eyeGrey = HexColor("#A5ADB6");
Color starYellow = HexColor("#FFAB00");
Color starYellowDark = HexColor("#FFA500");
Color graphWitheBackground = HexColor("#F3F3F3");
Color selectedListItemBackgroundBlue = HexColor("#F8F9FF");
Color yarnBlack = HexColor("#151515");
Color transparent = Colors.transparent;

Color greyDarkBackground = HexColor("#F0F2F5");
Color greyBackground = HexColor("#F1F3F4");
Color greySecondaryYarn = HexColor("#D9D9D9");
Color darkGreyYarn = HexColor("#808080");
Color lightGreyYarn = HexColor("#E5E5E5");
Color verifyBlue = HexColor("#4aadf4");
Color verifyGreen = HexColor("#46CE7C");
Color red = HexColor("#FF3F3F");
Color deepBlue = HexColor("#4060DB");
Color orange = HexColor("#F08770");
Color darkRed = HexColor("#33FF0000");

Color boxShadow = Color.fromARGB(51, 50, 55, 140);
Color boxShadowTwo = HexColor("#32378C").withOpacity(0.07);
