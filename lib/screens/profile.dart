import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../widget/exit_alert_dialog.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _currentIndex = 0;
  String _copy = "Copy Me";

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
                    //displayPaymentButton()
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
              child: Image.network(
                userBloc.user.qrCode,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.high,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  );
                },
              ),
            ),
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
                      key.currentState.showSnackBar(SnackBar(
                        content: new Text("Coped!"),
                      ));
                    },
                    icon: Icon(Icons.settings, color: Colors.black),
                    label: Text('Copy Url',
                        style: TextStyle(color: Colors.black, fontSize: 14))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget displayPaymentButton() {
    return ButtonTheme(
      //elevation: 4,
      minWidth: double.infinity,
      child: MaterialButton(
        elevation: 4.0,
        onPressed: () {
          Navigator.of(context).pushNamed('/send-payment',
              arguments: <String, bool>{'isFromProfile': true});
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text(
            "Make a Payment"), // change this to make payment request button to
      ),
    );
  }

  Widget displayQRCodeButton() {
    return IconButton(
      icon: Icon(Icons.camera),
      onPressed: () {
        Navigator.of(context).pushNamed('/scan-qr');
      },
    );
  }

  Widget displayUserAvatar(userBloc) {
    return CircleAvatar(
      radius: 10.00,
      foregroundColor: Colors.transparent,
      child: Image.network(
        userBloc.user.avatar,
        fit: BoxFit.fill,
      ),
    );
  }
}
