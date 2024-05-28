import 'package:Slydo/screens/more_apps/utility/cable/model/CablePlan.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/material.dart';

class CablePlanPaymentDetail extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  CablePlanPaymentDetail({this.arguments});
  @override
  _CablePlanPaymentDetailState createState() => _CablePlanPaymentDetailState();
}

class _CablePlanPaymentDetailState extends State<CablePlanPaymentDetail> {
  Map<String, dynamic> provider = {
    "image": "assets/images/utility/dstv.png",
    "name": "DStv Subscription"
  };

  CablePlan? plan;

  @override
  void initState() {
    plan = widget.arguments!["plan"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popAndPushNamed("/utility-history");
        return false;
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: appBar() as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.of(context).popAndPushNamed("/utility-history");
        },
      ),
      title: Text(
        "Cable",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return SingleChildScrollView(
      child: ticketWithImage(),
    );
  }

  Widget ticketWithImage() {
    return Container(
      child: Stack(
        children: [
          Image.asset(
            "assets/images/utility/cable_payment_background.png",
          ),
          Container(
            height: 470,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                providerInfo(),
                const SizedBox(
                  height: 15,
                ),
                MySeparator(color: dividerColor),
                const SizedBox(
                  height: 20,
                ),
                Expanded(child: paymentInfo()),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget providerInfo() {
    return Row(
      children: [
        Image.asset(
          provider['image'],
          fit: BoxFit.fill,
          height: 80,
          width: 80,
        ),
        const SizedBox(
          width: 8,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider['name'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              plan!.name!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ],
    );
  }

  Widget paymentInfo() {
    return Column(children: [
      getAmountTile(),
      const Expanded(
          child: SizedBox(
        height: 10,
      )),
      getDateAndTime(),
      const Expanded(
          child: SizedBox(
        height: 10,
      )),
      getStatus(),
      const Expanded(
          child: SizedBox(
        height: 10,
      )),
      getDescription()
    ]);
  }

  Widget getAmountTile() {
    return ListTile(
      leading: RoundedBackgroundIcon(
        height: 32,
        width: 32,
        icon: Icon(
          SlydoAppIcon.naira,
          size: 14,
          color: blackFont,
        ),
        backgroundColor: iconBtnGrey,
      ),
      title: Text(
        "Amount",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, color: blackFont),
      ),
      subtitle: Text(
        plan!.price!,
        style: TextStyle(
            fontFamily: "roborto",
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: blackFont),
      ),
    );
  }

  Widget getDateAndTime() {
    return ListTile(
      leading: RoundedBackgroundIcon(
        height: 32,
        width: 32,
        icon: Icon(
          SlydoAppIcon.clock,
          size: 14,
          color: blackFont,
        ),
        backgroundColor: iconBtnGrey,
      ),
      title: Text(
        "Date & Time",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, color: blackFont),
      ),
      subtitle: Text(
        "8AM, 14 June 2021",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: blackFont),
      ),
    );
  }

  Widget getStatus() {
    return ListTile(
      leading: RoundedBackgroundIcon(
        height: 32,
        width: 32,
        icon: Icon(
          SlydoAppIcon.subscription_status,
          size: 14,
          color: blackFont,
        ),
        backgroundColor: iconBtnGrey,
      ),
      title: Text(
        "Status",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, color: blackFont),
      ),
      subtitle: Container(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: navyBlue.withOpacity(0.1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                "Complete",
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: navyBlue),
              ),
            ),
            Expanded(
                child: Container(
              width: 1,
            ))
          ],
        ),
      ),
    );
  }

  Widget getDescription() {
    return ListTile(
      leading: RoundedBackgroundIcon(
        height: 32,
        width: 32,
        icon: Icon(
          SlydoAppIcon.note,
          size: 14,
          color: blackFont,
        ),
        backgroundColor: iconBtnGrey,
      ),
      title: Text(
        "Note",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w400, color: blackFont),
      ),
      subtitle: Text(
        "Description bla bla bla...",
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: blackFont),
      ),
    );
  }
}

class MySeparator extends StatelessWidget {
  final double height;
  final Color color;

  const MySeparator({this.height = 1.5, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 4.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
