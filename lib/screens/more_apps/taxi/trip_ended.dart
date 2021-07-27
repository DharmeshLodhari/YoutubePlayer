import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';

class TripEnded extends StatefulWidget {
  @override
  _TripEndedState createState() => _TripEndedState();
}

class _TripEndedState extends State<TripEnded> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(),
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
          Icons.menu_rounded,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {},
      ),
      title: Text(
        "",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return Column(
      children: [
        SizedBox(
          height: 80,
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 3,
              shadowColor: dividerColor.withAlpha(125),
              color: Colors.white,
              borderOnForeground: true,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 60,
                    ),
                    getDriverInfo(),
                    SizedBox(
                      height: 10,
                    ),
                    getRideInfo(),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              top: -20,
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: 0,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: naturalGreen,
                  child: Container(
                      height: 60,
                      width: 60,
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      )),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 40,
        ),
        getDriverActions(),
      ],
    );
  }

  Widget getDriverInfo() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        "Your trip has ended",
        style: TextStyle(
            color: blackFont, fontSize: 22, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget getDriverActions() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: CurvedButton(
        borderRadius: 10,
        backgroundColor: navyBlue,
        onPressed: () {},
        textColor: Colors.white,
        text: "Ok",
      ),
    );
  }

  Widget getRideInfo() {
    return Card(
      elevation: 3,
      borderOnForeground: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: dividerColor.withAlpha(125),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  "11:24",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: blackFont),
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  "11:38",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: blackFont),
                ),
              ],
            ),
            SizedBox(
              width: 12,
            ),
            Image.asset(
              "assets/images/taxi/route.png",
              height: 80,
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "1 Bola Dada Avenue, Victoria Island, Lagos",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: blackFont),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Tafawa Balewa Square, Lagos Island, Lagos",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: blackFont),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
