import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NoItemInList extends StatelessWidget {
  String msg = "";
  bool isResult;

  NoItemInList({required this.msg, this.isResult = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: SizedBox(
              height: 2,
            )),
            Expanded(
              flex: 2,
              child: Image.asset(
                isResult
                    ? "assets/images/no_result_found_1.png"
                    : "assets/images/no_result_found_2.png",
                colorBlendMode: BlendMode.color,
                height: 150,
                width: 150,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: blackFont,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
                child: SizedBox(
              height: 2,
            ))
          ],
        ),
      ),
    );
  }
}
