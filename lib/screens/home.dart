import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'more_apps/user_profile/user_auth.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldHomeKey =
      new GlobalKey<ScaffoldState>();
  AuthService _auth = AuthService();
  UserBloc userBloc;

  MainSocketProvider socketProvider;

  bool hasMessage = true;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    socketProvider = Provider.of<MainSocketProvider>(context);

    return Scaffold(
      key: _scaffoldHomeKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height -
              (AppBar().preferredSize.height),
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              backgroundScreen(),
              Column(
                children: [
                  Expanded(child: foregroundScreen()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget backgroundScreen() {
    return Container(
      child: Image.asset(
        "assets/images/home_screen_background.png",
        frameBuilder: imageFrameBuilder,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget foregroundScreen() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            flex: MediaQuery.of(context).size.height > 600 ? 9 : 50,
            child: Column(
              children: <Widget>[
                flexibleSpace(),
                appBar(),
                flexibleSpace(flex: 3),
                displayUserInfo(),
                flexibleSpace(),
                displayPaymentButtons(),
              ],
            ),
          ),
          flexibleSpace()
        ],
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Good morning,",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Text(
            userBloc.user.fullName,
            style: TextStyle(
              fontSize: 14,
            ),
          )
        ],
      ),
      actions: <Widget>[
        scanQRBtn(),
        SizedBox(
          width: 8.0,
        ),
        chatBtn(),
        SizedBox(
          width: 8.0,
        ),
        messageBtn(),
        SizedBox(
          width: 4.0,
        ),
      ],
    );
  }

  Widget chatBtn() {
    return Stack(
      overflow: Overflow.visible,
      children: [
        Column(
          children: [
            Expanded(
              child: SizedBox(
                height: 34,
                width: 34,
                child: InkWell(
                  child: Card(
                    elevation: 0,
                    color: lightGrey.withOpacity(0.1),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      SlydoAppIcon.text_message,
                      size: 16,
                    ),
                  ),
                  onTap: () async {
                    var result = await Navigator.of(context)
                        .pushNamed('/friends-dashboard');
                    setState(() {});
                  },
                ),
              ),
            ),
          ],
        ),
        FutureBuilder(
            future: ChatUserManager().checkForChatMessagesCount(),
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == true) {
                  return Positioned(
                    top: 8,
                    right: -2,
                    child: ClipOval(
                      child: Container(
                        height: 8,
                        width: 8,
                        color: naturalGreen,
                      ),
                    ),
                  );
                }
                return Container();
              }
              return Container();
            })
      ],
    );
  }

  Widget scanQRBtn() {
    return SizedBox(
      height: 34,
      width: 34,
      child: InkWell(
        child: Card(
          elevation: 0,
          color: lightGrey.withOpacity(0.1),
          margin: EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            SlydoAppIcon.qr_code,
            size: 16,
          ),
        ),
        onTap: () {
          Navigator.of(context)
              .pushNamed('/scan-qr', arguments: {'isRequest': false});
        },
      ),
    );
  }

  Widget messageBtn() {
    return Stack(
      overflow: Overflow.visible,
      children: [
        Column(
          children: [
            Expanded(
              child: SizedBox(
                height: 34,
                width: 34,
                child: InkWell(
                  child: Card(
                    elevation: 0,
                    color: lightGrey.withOpacity(0.1),
                    margin: EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      SlydoAppIcon.message,
                      size: 16,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/message-list');
                  },
                ),
              ),
            ),
          ],
        ),
        StreamBuilder<dynamic>(
            stream: socketProvider.socketStream,
            initialData: null,
            builder: (context, snapshot) {
              if (snapshot?.error == false) {
                return Container();
              }
              if (snapshot.hasData) {
                return Container();
                // return Positioned(
                //   top: 8,
                //   right: -2,
                //   child: ClipOval(
                //     child: Container(
                //       height: 8,
                //       width: 8,
                //       color: naturalGreen,
                //     ),
                //   ),
                // );
              }
              return Container();
            })
      ],
    );
  }

  Widget displayUserInfo() {
    return GestureDetector(
      child: CustomBoxShadow(
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.zero,
          elevation: 0.0,
          child: Container(
            decoration: decorateBox(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  dense:
                      MediaQuery.of(context).size.height > 600 ? false : true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 4.0),
                  leading: ClipOval(
                    child: Container(
                      height: 48,
                      width: 48,
                      child: CachedNetworkImage(
                        imageUrl: userBloc.user.avatar,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  title: Text(
                    userBloc.user.fullName,
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  subtitle: Text(
                    userBloc.user.userName,
                    maxLines: 1,
                    style: TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    UserAuth()
                        .fetchCustomerProfile(userBloc.user.userName)
                        .then((user) {
                      Navigator.pushNamed(context, '/profile',
                          arguments: {"searchedUser": user});
                    });
                  },
                ),
                Divider(
                  thickness: 1,
                  color: dividerColor,
                  height: 1,
                ),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 32, horizontal: 32),
                    child: CachedNetworkImage(
                      height: MediaQuery.of(context).size.width / 1.7,
                      width: MediaQuery.of(context).size.width / 1.7,
                      imageUrl: userBloc.user.qrCode,
                      colorBlendMode: BlendMode.darken,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                      placeholder: (context, url) => Center(
                        child: CircularLoadingIndicator(),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
      onTap: () async {
        ChatUserManager().clearChatUsers();

        // showSwipeHintCard(context: context);
        // showHoldHintCard(context: context);
      },
    );
  }

  Widget displayPaymentButtons() {
    return CustomBoxShadow(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
        child: Container(
          decoration: decorateBox(),
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: MediaQuery.of(context).size.height > 600 ? 16 : 8,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: requestPaymentButton(),
                ),
              ),
              Container(
                width: 1.5,
                color: dividerColor,
                height: 50,
              ),
              Expanded(
                child: Container(
                  child: sendPaymentButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget requestPaymentButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: InkWell(
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 50,
              width: 50,
              child: Card(
                elevation: 0,
                color: navyBlue.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  SlydoAppIcon.receive,
                  size: 20,
                  color: navyBlue,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              "Request",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context)
              .pushNamed('/request-payment', arguments: <String, bool>{
            'isFromProfile': true,
          });
        },
      ),
    );
  }

  Widget sendPaymentButton() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.white,
        highlightColor: Colors.white,
      ),
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 50,
              width: 50,
              child: Card(
                elevation: 0,
                color: naturalGreen.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  SlydoAppIcon.send,
                  size: 20,
                  color: naturalGreen,
                ),
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Text(
              "Send",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).pushNamed('/send-payment',
              arguments: <String, bool>{'isFromProfile': true});
        },
      ),
    );
  }

  Widget displayQRCodeButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          Connectivity().checkConnectivity().then((value) {
            var connectionResult = value;
            if (connectionResult == ConnectivityResult.wifi ||
                connectionResult == ConnectivityResult.mobile) {
              Navigator.of(context)
                  .pushNamed('/scan-qr', arguments: {'isRequest': false});
            } else {
              Toast.show(
                  AppLocalization.of(context).internetConnectionNotAvailable,
                  context,
                  gravity: Toast.BOTTOM,
                  backgroundColor: darkBlue());
            }
          });
        },
        child: Image.asset(
          'assets/images/qr_code.png',
          height: 24.0,
          width: 24.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
