import 'package:Slydo/screens/super_store/super_store_home.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ignore: must_be_immutable
class NoOrderInList extends StatelessWidget {
  String msg = "";
  String? title = "";
  bool isResult;

  NoOrderInList(
      {super.key, required this.msg, this.isResult = true, this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/no_order.svg',
            colorBlendMode: BlendMode.color,
            height: 100,
            width: 100,
          ),
          const SizedBox(
            height: 20,
          ),
          if (title != null || title == '') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: blackFont,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackFont,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: "Inter",
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          CurvedButton(
            backgroundColor: navyBlue,
            width: 170,
            height: 37,
            onPressed: () {
              NavigationUtil.push(context, screen: const SuperStoreHome());
            },
            text: "Browse Product",
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
