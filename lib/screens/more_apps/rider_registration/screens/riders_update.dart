import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RidersUpdate extends StatefulWidget {
  const RidersUpdate({super.key});

  @override
  State<RidersUpdate> createState() => _RidersUpdateState();
}

class _RidersUpdateState extends State<RidersUpdate> {
  late UserBloc userBloc;
  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
        },
        child: Scaffold(
          backgroundColor: white,
          appBar: _buildAppBar() as PreferredSizeWidget?,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16,
      title: Text(
        'Rider\'s Update',
        style: TextStyle(
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.of(context).popUntil(ModalRoute.withName("/dashboard"));
        },
      ),
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userBloc.user.rider?.isStatusApproved() == true)
              Text(
                'Welcome, ${userBloc.user.nickName}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: blackFont,
                  fontFamily: "Inter",
                ),
                textAlign: TextAlign.center,
              ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (userBloc.user.rider?.isStatusApproved() == true)
                    Image.asset(
                      'assets/images/rider_status_approve.png',
                      fit: BoxFit.fill,
                    )
                  else
                    Image.asset(
                      'assets/images/rider_status_pending.png',
                      fit: BoxFit.fill,
                    ),
                  Text(
                    userBloc.user.rider?.isStatusApproved() == true
                        ? 'Your account has been verified to be a slydo rider, you can now start accepting request for delivery in service hub.'
                        : 'You can visit one of our outlet for credentials verification.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: black,
                      fontFamily: "Inter",
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (userBloc.user.rider?.isStatusApproved() == true) _buildButton(),
            const SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    return CurvedButton(
      onPressed: () {
        Navigator.of(context)
            .popAndPushNamed(Routes.SUPER_HUB, arguments: {'page': 1});
      },
      backgroundColor: navyBlue,
      textColor: white,
      text: 'View delivery jobs',
    );
  }
}
