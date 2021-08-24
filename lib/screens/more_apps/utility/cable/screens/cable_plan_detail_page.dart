import 'package:Slydo/screens/more_apps/utility/cable/model/CablePlan.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';

class CablePlanDetail extends StatefulWidget {
  final Map<String, dynamic> arguments;
  CablePlanDetail({this.arguments});
  @override
  _CablePlanDetailState createState() => _CablePlanDetailState();
}

class _CablePlanDetailState extends State<CablePlanDetail> {
  CablePlan plan;

  @override
  void initState() {
    plan = widget.arguments["plan"];
    plan.features.add("CSI");
    plan.features.add("Sony Movies");
    plan.features.add("Cartoon Network");
    plan.features.add("Disney Junior");
    plan.features.add("Showmax");
    plan.features.add("53 Audio channels");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 16,
            ),
            Text(
              plan.name,
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w700, color: blackFont),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "₦",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: navyBlue,
                      fontFamily: "roberto"),
                ),
                Text(
                  plan.price.replaceAll("₦", ""),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: navyBlue),
                ),
              ],
            ),
            SizedBox(
              height: 36,
            ),
            Card(
              elevation: 0,
              color: lightGrey,
              margin: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: lightGrey,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 36),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: lightGrey, width: 0.2)),
                child: Container(
                  child: getPlanFeatures(plan: plan),
                ),
              ),
            ),
            SizedBox(
              height: 36,
            ),
            getSubscribeBtn()
          ],
        ),
      ),
    );
  }

  Widget getSubscribeBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CurvedButton(
        onPressed: () {
          Navigator.pop(context, plan);
        },
        backgroundColor: navyBlue,
        text: "Subscribe",
        textColor: Colors.white,
      ),
    );
  }

  Widget getPlanFeatures({CablePlan plan}) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: getColumnChildren(plan: plan));
  }

  List<Widget> getColumnChildren({CablePlan plan}) {
    List<Widget> items = [];

    for (int i = 0; i < plan.features.length; i++) {
      items.add(
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.check_rounded,
                size: 24,
                color: naturalGreen,
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                plan.features[i],
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: blackFont),
              )
            ],
          ),
        ),
      );
    }

    return items;
  }

  Widget appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      centerTitle: false,
      title: Text(
        "",
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
    );
  }
}
