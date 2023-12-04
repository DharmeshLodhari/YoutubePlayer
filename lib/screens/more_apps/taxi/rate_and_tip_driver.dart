import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RateAndTipDriver extends StatefulWidget {
  @override
  _RateAndTipDriverState createState() => _RateAndTipDriverState();
}

class _RateAndTipDriverState extends State<RateAndTipDriver> {
  @override
  void initState() {
    super.initState();
  }

  int rating = 4;

  int selectedTip = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
          Icons.close,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        "Rate & Tip driver",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 100,
          ),
          getRatingUI(),
          SizedBox(
            height: 40,
          ),
          getTipUI(),
          Expanded(
            child: SizedBox(
              height: 30,
            ),
          ),
          getDriverActions(),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget getRatingUI() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () {
                  rating = 1;
                  if (mounted) setState(() {});
                },
                child: Icon(
                  SlydoAppIcon.star,
                  size: 38,
                  color: rating >= 1 ? navyBlue : dividerColor,
                )),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: () {
                  rating = 2;
                  if (mounted) setState(() {});
                },
                child: Icon(
                  SlydoAppIcon.star,
                  size: 38,
                  color: rating >= 2 ? navyBlue : dividerColor,
                )),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: () {
                  rating = 3;
                  if (mounted) setState(() {});
                },
                child: Icon(
                  SlydoAppIcon.star,
                  size: 38,
                  color: rating >= 3 ? navyBlue : dividerColor,
                )),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: () {
                  rating = 4;
                  if (mounted) setState(() {});
                },
                child: Icon(
                  SlydoAppIcon.star,
                  size: 38,
                  color: rating >= 4 ? navyBlue : dividerColor,
                )),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: () {
                  rating = 5;
                  if (mounted) setState(() {});
                },
                child: Icon(
                  SlydoAppIcon.star,
                  size: 38,
                  color: rating >= 5 ? navyBlue : dividerColor,
                )),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          "Excellent",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        )
      ],
    );
  }

  Widget getTipUI() {
    UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: CachedNetworkImage(
            imageUrl: userBloc.user.avatar!,
            height: 80,
            width: 80,
            fit: BoxFit.fill,
          ),
        ),
        SizedBox(
          height: 40,
        ),
        Text(
          "Add a tip?",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
        ),
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                selectedTip = 1;
                if (mounted) setState(() {});
              },
              child: Card(
                elevation: 4,
                color: selectedTip == 1 ? navyBlue : Colors.white,
                shadowColor: dividerColor,
                borderOnForeground: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        "₦",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: selectedTip == 1 ? Colors.white : blackFont,
                            fontFamily: "Inter"),
                      ),
                      Text(
                        "50",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: selectedTip == 1 ? Colors.white : blackFont,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                selectedTip = 2;
                if (mounted) setState(() {});
              },
              child: Card(
                elevation: 4,
                color: selectedTip == 2 ? navyBlue : Colors.white,
                shadowColor: dividerColor,
                borderOnForeground: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        "₦",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: selectedTip == 2 ? Colors.white : blackFont,
                            fontFamily: "Inter"),
                      ),
                      Text(
                        "100",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: selectedTip == 2 ? Colors.white : blackFont,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                selectedTip = 3;
                if (mounted) setState(() {});
              },
              child: Card(
                elevation: 4,
                color: selectedTip == 3 ? navyBlue : Colors.white,
                shadowColor: dividerColor,
                borderOnForeground: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        "₦",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: selectedTip == 3 ? Colors.white : blackFont,
                            fontFamily: "Inter"),
                      ),
                      Text(
                        "150",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: selectedTip == 3 ? Colors.white : blackFont,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                selectedTip = 4;
                if (mounted) setState(() {});
              },
              child: Card(
                elevation: 4,
                color: selectedTip == 4 ? navyBlue : Colors.white,
                shadowColor: dividerColor,
                borderOnForeground: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        "₦",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: selectedTip == 4 ? Colors.white : blackFont,
                            fontFamily: "Inter"),
                      ),
                      Text(
                        "200",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: selectedTip == 4 ? Colors.white : blackFont,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 30,
        ),
        Text(
          "Tipping is welcome, but not required.\nThe amount is always up to you.",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400, color: darkGrey),
        ),
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
    return CurvedButton(
      borderRadius: 10,
      backgroundColor: navyBlue,
      onPressed: () {
        Navigator.of(context).pushNamed("/payment-options");
      },
      textColor: Colors.white,
      text: "Pay",
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
