import 'package:Slydo/screens/more_apps/utility/tiles/utility_payment_tile.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

class UtilityHistory extends StatefulWidget {
  @override
  _UtilityHistoryState createState() => _UtilityHistoryState();
}

class _UtilityHistoryState extends State<UtilityHistory> {
  List<Map<String, dynamic>> utilityPayment = [
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Processing"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Complete"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Pending"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Processing"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Canceled"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Paused"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Processing"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Complete"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Pending"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Processing"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Canceled"
    },
    {
      "name": "DStv Subscription",
      "image": "assets/images/utility/dstv.png",
      "time": "18/08/2020 • 6:54 AM",
      "amount": "₦34.00",
      "status": "Paused"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: foregroundScreen(),
    );
  }

  Widget foregroundScreen() {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 8),
      child: getUtilityPaymentHistory(),
    );
  }

  Widget getUtilityPaymentHistory() {
    return ListView.builder(
      itemBuilder: (context, index) =>
          getUtilityPaymentTile(item: utilityPayment[index]),
      itemCount: utilityPayment.length,
    );
  }

  Widget getUtilityPaymentTile({Map<String, dynamic>? item}) {
    return UtilityPaymentTile(payment: item);
  }

  Widget appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      centerTitle: false,
      title: Text(
        "Utility History",
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: blackFont),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: [
        // utilityHistoryBtn(),
        // SizedBox(
        //   width: 16,
        // )
      ],
    );
  }

  Widget utilityHistoryBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.utility_history,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        // Navigator.of(context)
        //     .pushNamed('/scan-qr', arguments: {"isRequest": true});
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }
}
