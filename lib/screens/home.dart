import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../widget/exit_alert_dialog.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldState>();
    final UserBloc userBloc = Provider.of<UserBloc>(context);

    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (context) => ExitAlertDialog(),
        );
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkBlue(),
          title: Center(child: Text("Home")),
          leading: displayUserAvatar(userBloc),
          actions: <Widget>[
            displayQRCodeButton(),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              color: lightBlue(),
              padding: EdgeInsets.all(30),
              child: Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 10),
                    displayUserInfo(key, userBloc),
                    SizedBox(height: 30),
                    displayPaymentButtons()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget displayUserInfo(key, userBloc) {
    return Center(
      child: Card(
        semanticContainer: true,
        elevation: 4.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(40),
                child: CachedNetworkImage(
                  imageUrl: userBloc.user.qrCode,
                  colorBlendMode: BlendMode.darken,
                  fit: BoxFit.fitWidth,
                  filterQuality: FilterQuality.high,
                  placeholder: (context, url) => CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                )),
            ButtonBar(
              mainAxisSize: MainAxisSize.max,
              alignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                    onPressed: () {},
                    child: Text(userBloc.user.fullName,
                        style: TextStyle(color: Colors.black, fontSize: 14))),
                FlatButton.icon(
                    onPressed: () {
                      Clipboard.setData(new ClipboardData(
                          text: baseUrl +
                              "/api/v1/customer/" +
                              userBloc.user.userName));
                      Toast.show("Copied!", context,
                          gravity: Toast.CENTER,
                          duration: Toast.LENGTH_LONG,
                          backgroundColor: darkBlue());
                    },
                    icon: Icon(Icons.content_copy, color: Colors.black),
                    label: Text('Copy Url',
                        style: TextStyle(color: Colors.black, fontSize: 14))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget displayPaymentButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
            child: ButtonTheme(
              //elevation: 4,
              child: MaterialButton(
                elevation: 4.0,
                onPressed: () {
                  Connectivity().checkConnectivity().then((value) {
                    var connectionResult = value;
                    if (connectionResult == ConnectivityResult.wifi ||
                        connectionResult == ConnectivityResult.mobile) {
                      Navigator.of(context).pushNamed('/request-payment',
                          arguments: <String, bool>{
                            'isFromProfile': true,
                            'isRequest': true
                          });
                    } else {
                      Toast.show(
                          "Internet Connection is not available", context,
                          gravity: Toast.BOTTOM, backgroundColor: darkBlue());
                    }
                  });
                },
                textColor: Colors.white,
                color: darkBlue(),
                height: 50,
                child: Text("Request"),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 0.0, 8.0),
            child: ButtonTheme(
              //elevation: 4,

              child: MaterialButton(
                elevation: 4.0,
                onPressed: () {
                  Connectivity().checkConnectivity().then((value) {
                    var connectionResult = value;
                    if (connectionResult == ConnectivityResult.wifi ||
                        connectionResult == ConnectivityResult.mobile) {
                      Navigator.of(context).pushNamed('/send-payment',
                          arguments: <String, bool>{'isFromProfile': true});
                    } else {
                      Toast.show(
                          "Internet Connection is not available", context,
                          gravity: Toast.BOTTOM, backgroundColor: darkBlue());
                    }
                  });
                },
                textColor: Colors.white,
                color: darkBlue(),
                height: 50,
                child: Text(
                    "Send"), // change this to make payment request button to
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget displayQRCodeButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: InkWell(
        onTap: () {
          Connectivity().checkConnectivity().then((value) {
            var connectionResult = value;
            if (connectionResult == ConnectivityResult.wifi ||
                connectionResult == ConnectivityResult.mobile) {
              Navigator.of(context)
                  .pushNamed('/scan-qr', arguments: {'isRequest': false});
            } else {
              Toast.show("Internet Connection is not available", context,
                  gravity: Toast.BOTTOM, backgroundColor: darkBlue());
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

  Widget displayUserAvatar(userBloc) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: userBloc.user.avatar,
          height: 40,
          width: 40,
          colorBlendMode: BlendMode.darken,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          placeholder: (context, url) => userBloc.user.avatar == ""
              ? Icon(Icons.person)
              : CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
        ),
      ),
    );
  }
}
