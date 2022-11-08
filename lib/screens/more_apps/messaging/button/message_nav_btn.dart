import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/slydo_app_icon_new_icons.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class MessageNavBtn extends StatefulWidget {
  const MessageNavBtn({Key? key}) : super(key: key);

  @override
  State<MessageNavBtn> createState() => _MessageNavBtnState();
}

class _MessageNavBtnState extends State<MessageNavBtn> {
  int count = 0;

  @override
  void initState() {
    super.initState();
    fetchMessageCount();
  }

  void fetchMessageCount() async {
    try {
      count = await MessageAuth().getUnreadMessageCount();
      if (mounted) setState(() {});
    } catch (error) {
      count = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Badge(
        badgeColor: naturalGreen,
        animationType: BadgeAnimationType.slide,
        badgeContent: getUnReadCount(count),
        padding: count == 0
            ? EdgeInsets.all(0)
            : EdgeInsets.only(
                left: count.toString().length == 1 ? 6 : 8,
                right: 6,
                top: 4,
                bottom: 4),
        position:
            BadgePosition(end: count.toString().length == 1 ? -5 : -10, top: 0),
        child: Icon(
          SlydoAppIconNew.inbox,
          size: 16,
          color: HexColor("#151515"),
        ),
      ),
      onTap: () {
        Navigator.of(context).pushNamed(Routes.MESSAGE_LIST);
      },
      backgroundColor: lightGrey.withOpacity(0.1),
      enableMargin: true,
    );
  }

  Widget? getUnReadCount(int count) {
    if (count == 0) {
      return null;
    }
    return Text(
      count.toString(),
      style: TextStyle(
          fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}
