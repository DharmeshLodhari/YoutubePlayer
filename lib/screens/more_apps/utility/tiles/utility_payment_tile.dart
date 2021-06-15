import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

import '../../../../utils/colors.dart';

class UtilityPaymentTile extends StatelessWidget {
  final Map<String, dynamic> payment;

  UtilityPaymentTile({this.payment});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shadowColor: boxShadowTwo,
      elevation: 0,
      child: Container(
        decoration: decorateBox(),
        child: Row(
          children: [
            getLeading(),
            SizedBox(
              width: 4,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getTitle(),
                SizedBox(
                  height: 4,
                ),
                getDateTime(),
                SizedBox(
                  height: 8,
                ),
              ],
            ),
            Expanded(
                child: SizedBox(
              width: 1,
            )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  payment['amount'],
                  style: TextStyle(
                      fontFamily: "Roboto",
                      color: blackFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                SizedBox(
                  height: 8,
                ),
                getPaymentStatus(),
              ],
            ),
            SizedBox(
              width: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget getLeading() {
    return Image.asset(
      payment['image'],
      height: 80,
      width: 80,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.high,
    );
  }

  Widget getPaymentStatus() {
    Color color = getStatusColor(payment['status']);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(
        payment['status'],
        style:
            TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  Color getStatusColor(String status) {
    if (status == "Processing") {
      return naturalGreen;
    } else if (status == "Complete") {
      return navyBlue;
    } else if (status == "Pending") {
      return starYellow;
    } else if (status == "Canceled") {
      return mateRed;
    } else if (status == "Paused") {
      return darkGrey;
    } else {
      return navyBlue;
    }
  }

  Widget getTitle() {
    return Text(
      payment['name'],
      style: TextStyle(
        color: blackFont,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget getDateTime() {
    return Text(
      payment['time'],
      softWrap: false,
      overflow: TextOverflow.visible,
      style: TextStyle(color: darkGrey, fontSize: 10),
    );
  }
}
