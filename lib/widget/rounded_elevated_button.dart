import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ignore: must_be_immutable
class RoundedElevatedButton extends StatelessWidget {
  String svgImg;

  RoundedElevatedButton({
    this.svgImg = "",
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      elevation: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 30,
          height: 30,
          color: white,
          child: Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: SvgPicture.asset(
                svgImg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
