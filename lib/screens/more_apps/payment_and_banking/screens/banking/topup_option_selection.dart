import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TopUpOptionSelection extends StatefulWidget {
  @override
  _TopUpOptionSelectionState createState() => _TopUpOptionSelectionState();
}

class _TopUpOptionSelectionState extends State<TopUpOptionSelection> {
  final GlobalKey<ScaffoldState> _scaffoldTopUpOptionSelectionKey =
      new GlobalKey<ScaffoldState>();

  @protected
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldTopUpOptionSelectionKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }

  Widget scaffoldBody() {
    return Column(
      children: [
        Expanded(
            child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getChatSettingTitle(),
                SizedBox(
                  height: 8,
                ),
                getSettingTile(
                    title: "Credit Card",
                    icon: Icons.credit_card,
                    iconColor: naturalGreen,
                    onTap: () async {
                      Navigator.of(context).pushNamed('/card-payment-page');
                    }),
                getSettingTile(
                    title: "Virtual Account",
                    icon: Icons.account_balance_wallet,
                    iconColor: HexColor("#3F61DB"),
                    onTap: () async {
                      Navigator.of(context)
                          .pushNamed('/add-money-to-slydo-one');
                    }),
                getSettingTile(
                    title: "Bank Account",
                    icon: Icons.account_balance,
                    iconColor: HexColor("#F35B46"),
                    onTap: () async {}),
              ],
            ),
          ),
        )),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget getChatSettingTitle() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "How would you like to pay?",
        style: TextStyle(
            fontWeight: FontWeight.w500, fontSize: 14, color: darkGrey),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(
        "Top up",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget getSettingTile(
      {String title = "",
      Function()? onTap,
      IconData? icon,
      Color? iconColor}) {
    if (iconColor == null) {
      iconColor = navyBlue;
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shadowColor: boxShadowTwo,
      elevation: 6,
      child: Container(
        decoration: decorateBox(),
        padding: EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          leading: RoundedBackgroundIcon(
            height: 50,
            width: 50,
            icon: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            backgroundColor: iconColor.withOpacity(0.08),
            borderRadius: 20,
            onTap: onTap,
          ),
          title: Text(
            title,
            maxLines: 1,
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right_outlined,
            color: Color(0XFF1A399D),
          ),
          onTap: () {
            if (onTap != null) {
              onTap();
            }
          },
        ),
      ),
    );
  }
}
