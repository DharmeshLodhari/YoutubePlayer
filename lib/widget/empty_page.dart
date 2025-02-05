import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ignore: must_be_immutable
class EmptyPage extends StatelessWidget {
  String msg = "";
  String? title = "";
  bool isResult;

  EmptyPage({super.key, required this.msg, this.isResult = true, this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        SvgPicture.asset(
          'assets/images/no_item.svg',
          colorBlendMode: BlendMode.color,
          height: 150,
          width: 150,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: blackFont,
              fontSize: 12,
              fontFamily: "Inter",
            ),
          ),
        ),
      ],
    );
  }
}
