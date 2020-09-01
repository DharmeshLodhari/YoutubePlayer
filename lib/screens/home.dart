import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldHomeKey =
      new GlobalKey<ScaffoldState>();
  UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
//    return Scaffold(
//      key: _scaffoldHomeKey,
//      resizeToAvoidBottomInset: true,
//      backgroundColor: lightBlue(),
//      appBar: AppBar(
//        automaticallyImplyLeading: false,
//        backgroundColor: darkBlue(),
//        title: Center(child: Text(AppLocalization.of(context).home)),
//        actions: <Widget>[
//          displayQRCodeButton(),
//        ],
//      ),
//      body: SingleChildScrollView(
//        scrollDirection: Axis.vertical,
//        child: Container(
//          color: lightBlue(),
//          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//          child: Center(
//            child: Column(
//              children: <Widget>[
//                SizedBox(height: 30),
//                displayUserInfo(userBloc),
//                SizedBox(height: 30),
//                displayPaymentButtons(),
//              ],
//            ),
//          ),
//        ),
//      ),
//    );
    return Scaffold(
      key: _scaffoldHomeKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: whiteBackground,
      body: Container(
        height: MediaQuery.of(context).size.height -
            (AppBar().preferredSize.height),
        width: MediaQuery.of(context).size.width,
        color: whiteBackground,
        child: Stack(
          children: <Widget>[
            backgroundScreen(),
            foregroundScreen(),
          ],
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
      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 9,
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
      elevation: 0,
      titleSpacing: 0,
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
          width: 10.0,
        ),
        messageBtn(),
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
            SlydoAppIcon.message,
            size: 16,
          ),
        ),
        onTap: () {
          Navigator.of(context).pushNamed('/message-list');
        },
      ),
    );
  }

  Widget displayUserInfo() {
    return Card(
      shadowColor: Color.fromARGB(51, 50, 55, 140),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      elevation: 4.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4.0),
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
          ),
          Divider(
            thickness: 1,
            color: dividerColor,
            height: 1,
          ),
          Container(
              padding: EdgeInsets.symmetric(vertical: 32, horizontal: 32),
              child: CachedNetworkImage(
//                height: MediaQuery.of(context).size.width / 1.5,
                width: MediaQuery.of(context).size.width / 1.7,
                imageUrl: userBloc.user.qrCode,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: lightBlue(),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget displayPaymentButtons() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Color.fromARGB(51, 50, 55, 140),
      margin: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          Navigator.of(context).pushNamed('/request-payment',
              arguments: <String, bool>{
                'isFromProfile': true,
                'isRequest': true
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

//  Widget displayPaymentButtons() {
//    return Row(
//      children: <Widget>[
//        Expanded(
//          child: Padding(
//            padding: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
//            child: ButtonTheme(
//              //elevation: 4,
//              child: MaterialButton(
//                elevation: 4.0,
//                onPressed: () {
//                  Connectivity().checkConnectivity().then((value) {
//                    var connectionResult = value;
//                    if (connectionResult == ConnectivityResult.wifi ||
//                        connectionResult == ConnectivityResult.mobile) {
//                      Navigator.of(context).pushNamed('/request-payment',
//                          arguments: <String, bool>{
//                            'isFromProfile': true,
//                            'isRequest': true
//                          });
//                    } else {
//                      Toast.show(
//                          AppLocalization.of(context)
//                              .internetConnectionNotAvailable,
//                          context,
//                          gravity: Toast.BOTTOM,
//                          backgroundColor: darkBlue());
//                    }
//                  });
//                },
//                textColor: Colors.white,
//                color: darkBlue(),
//                height: 50,
//                child: Text(AppLocalization.of(context).request),
//              ),
//            ),
//          ),
//        ),
//        Expanded(
//          child: Padding(
//            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
//            child: ButtonTheme(
//              //elevation: 4,
//
//              child: MaterialButton(
//                elevation: 4.0,
//                onPressed: () {
//                  Connectivity().checkConnectivity().then((value) {
//                    var connectionResult = value;
//                    if (connectionResult == ConnectivityResult.wifi ||
//                        connectionResult == ConnectivityResult.mobile) {
//                      Navigator.of(context).pushNamed('/send-payment',
//                          arguments: <String, bool>{'isFromProfile': true});
//                    } else {
//                      Toast.show(
//                          AppLocalization.of(context)
//                              .internetConnectionNotAvailable,
//                          context,
//                          gravity: Toast.BOTTOM,
//                          backgroundColor: darkBlue());
//                    }
//                  });
//                },
//                textColor: Colors.white,
//                color: darkBlue(),
//                height: 50,
//                child: Text(AppLocalization.of(context)
//                    .send), // change this to make payment request button to
//              ),
//            ),
//          ),
//        ),
//      ],
//    );
//  }

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
