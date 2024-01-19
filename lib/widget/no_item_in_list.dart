import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ignore: must_be_immutable
class NoItemInList extends StatelessWidget {
  String msg = "";
  String? title = "";
  bool isResult;

  NoItemInList({required this.msg, this.isResult = true, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Expanded(
              child: SizedBox(height: 1),
            ),
            Expanded(
              flex: 2,
              child: SvgPicture.asset(
                'assets/images/no_item.svg',
                colorBlendMode: BlendMode.color,
                height: 150,
                width: 150,
              ),
            ),

            if(title != null || title == '')...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],

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
            const Expanded(
                child: SizedBox(
              height: 2,
            )),
            const Expanded(
                child: SizedBox(
              height: 2,
            )),
          ],
        ),
      ),
    );
  }
}
