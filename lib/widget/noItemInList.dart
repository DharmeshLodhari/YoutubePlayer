import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NoItemInList extends StatelessWidget {
  String msg = "";

  NoItemInList({@required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/images/noTransactions.png",
              colorBlendMode: BlendMode.color,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                msg,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    );
  }
}
