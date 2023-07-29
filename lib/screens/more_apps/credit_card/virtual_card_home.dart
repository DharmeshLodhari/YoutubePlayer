import 'dart:async';
import 'dart:convert';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/tiles/transaction.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/extensions.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/customized_popup_menu.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:Slydo/widget/slide_action_button.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../../routes/route_constants.dart';
import '../../../../../utils/navigation_util.dart';
import '../payment_and_banking/payment_and_banking_auth.dart';


class VirtualCardHome extends StatefulWidget {
  @override
  _VirtualCardHomeState createState() => _VirtualCardHomeState();
}

class _VirtualCardHomeState extends State<VirtualCardHome> {
  final GlobalKey<ScaffoldState> _scaffoldPaymentListKey =
  GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerPaymentListKey =
  GlobalKey<ScaffoldMessengerState>();

  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  bool isFirstTime = true;
  late UserBloc userBloc;
  bool isAPILoading = false;

  @protected
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return ScaffoldMessenger(
      key: _scaffoldMessengerPaymentListKey,
      child: Scaffold(
        key: _scaffoldPaymentListKey,
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: appBar() as PreferredSizeWidget?,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: creditCard()),
            Expanded(child: _buildOtherView()),
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
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
        'Virtual Card',
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        addBtn(),
        const SizedBox(width: 12),
        settingBtn(),
        const SizedBox(width: 12.0),
      ],
    );
  }

  Widget addBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.add,
        size: 16,
        color: blackFont,
      ),
      onTap: () async {
        // Navigator.of(context).pushNamed(Routes.REQUEST_PAYMENT,
        //     arguments: <String, bool>{
        //       'isRequest': true,
        //       'isFromProfile': true
        //     });
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget settingBtn() {
    return SizedBox(
      height: 36,
      width: 36,
      child: InkWell(
        child: Card(
          elevation: 0,
          // color: blackFont,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            SlydoAppIcon.settings,
            size: 16,
            color: blackFont,
          ),
        ),
        onTap: () {
          // hideBalance();
          // Navigator.of(context).pushNamed(Routes.GENERAL_SETTING);
        },
      ),
    );
  }

  Widget creditCard() {
    return Card(
      elevation: 0,
      color: navyBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Left side with text
          Container(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dollar Card Balance",
                  style: TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  'N'+"5000",
                  style: TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  "4521 5678 9101 1121",
                  style: TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Text(
                      "Yusuf Adefolahan",
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      "13/24",
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      "235",
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          //Right side with text
          Expanded(
            child: Container(
              child: Stack(
                children: [
                  SvgPicture.asset(
                    "arrow_card".toSVG(),
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Row(
                      children: [
                        const Text(
                          'Slydo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        SvgPicture.asset(
                          "slydo".toSVG(),
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 5.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherView() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left: 40.0, right: 40.0),
              child: RichText(
                text: TextSpan(
                  text: 'Get a ',
                  style: TextStyle(
                    color: black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'virtual card ',
                      style: TextStyle(
                        color: navyBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: 'and start paying in dollars online securely !',
                      style: TextStyle(
                        color: black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ListTile(
              leading: SvgPicture.asset(
                "apple_pay".toSVG(),
                fit: BoxFit.cover,
              ),
              title: const Text(
                'Purchase easily in-store',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                  'Set up subscription and pay with your virtual card details'),
            ),
            const SizedBox(height: 10.0),
            ListTile(
              leading: SvgPicture.asset(
                "travel".toSVG(),
                fit: BoxFit.cover,
              ),
              title: const Text(
                'A safer way to pay',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                  'Use a virtual card when you dont trust a company with your details'),
            ),


          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();

    super.dispose();
  }
}
