import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NoItemInList extends StatelessWidget {
  String msg = "";
  bool isResult;

  NoItemInList({@required this.msg, this.isResult = true});

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   child: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         Image.asset(
    //           "assets/images/noTransactions.png",
    //           colorBlendMode: BlendMode.color,
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: Text(
    //             msg,
    //             style: TextStyle(
    //                 color: Colors.black,
    //                 fontSize: 18,
    //                 fontWeight: FontWeight.w600),
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    // );

    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: SizedBox(
              height: 2,
            )),
            Image.asset(
              isResult
                  ? "assets/images/no_result_found_1.png"
                  : "assets/images/no_result_found_2.png",
              colorBlendMode: BlendMode.color,
              height: 150,
              width: 150,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              msg,
              style: TextStyle(
                  color: blackFont, fontSize: 16, fontWeight: FontWeight.bold),
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
