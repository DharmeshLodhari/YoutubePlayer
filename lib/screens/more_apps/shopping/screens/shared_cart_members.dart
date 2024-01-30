import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/send_payment.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SharedCartMembers extends StatefulWidget {
  @override
  State<SharedCartMembers> createState() => _SharedCartMembersState();
}

class _SharedCartMembersState extends State<SharedCartMembers> {
  SlidableController? _slideController;
  void handleSlideAnimationChanged(Animation<double>? slideAnimation) {}

  void handleSlideIsOpenChanged(bool? isOpen) {}
  @override
  void initState() {
    _slideController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );
    super.initState();
  }

  Widget scanQRCodeBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.SCAN_QR, arguments: {'isRequest': false});
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Text(
          "My Birthday Hangout",
          style: TextStyle(
              color: blackFont, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          scanQRCodeBtn(),
          const SizedBox(
            width: 16,
          ),
        ],
        backgroundColor: white,
        elevation: 0.0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            child: Slidable(
              key: Key('uu'),
              controller: _slideController,
              direction: Axis.horizontal,
              actionPane: SlidableBehindActionPane(),
              actionExtentRatio: 0.25,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                shadowColor: boxShadowTwo,
                elevation: 0,
                child: InkWell(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SendPayment())),
                  child: Container(
                    decoration: decorateBox(),
                    child: ListTile(
                      dense: true,
                      title: userNameWithVerifiedIcon(
                        name: 'rose',
                        isVerified: false,
                        verifiedIconColor: verifyGreen,
                      ),
                      subtitle: Text("text"),
                      leading:
                          GestureDetector(onTap: () {}, child: Text("ooo")),
                      trailing: Text("ll"),
                    ),
                  ),
                ),
              ),
              actions: [
                SlideActionButton(
                  backgroundColor: mateRed,
                  icon: SlydoAppIcon.leave,
                  onTap: () {
                    // exitTheGroupAlert(chatConversation, index);
                  },
                  title: "Exit",
                  slideController: _slideController,
                )
              ],
              secondaryActions: [
                SlideActionButton(
                  backgroundColor: mateRed,
                  icon: SlydoAppIcon.block,
                  onTap: () {
                    // blockUserAlert(customerProfile);
                  },
                  title: AppLocalization.of(context)!.block,
                  slideController: _slideController,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
