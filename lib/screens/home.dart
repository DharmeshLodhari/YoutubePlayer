import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/colors.dart';
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
  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      key: _scaffoldHomeKey,
      resizeToAvoidBottomInset: true,
      backgroundColor: lightBlue(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: darkBlue(),
        title: Center(child: Text(AppLocalization.of(context).home)),
        actions: <Widget>[
          displayQRCodeButton(),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          color: lightBlue(),
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 30),
                displayUserInfo(userBloc),
                SizedBox(height: 30),
                displayPaymentButtons()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget displayUserInfo(userBloc) {
    return Center(
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        elevation: 4.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: ClipOval(
                child: Container(
                  height: 45,
                  width: 45,
                  child: CachedNetworkImage(
                    imageUrl: userBloc.user.avatar,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              title: Text(
                userBloc.user.fullName,
                maxLines: 1,
              ),
              subtitle: Text(
                userBloc.user.userName,
                maxLines: 1,
              ),
            ),
            Container(
                height: 250,
                width: 250,
                child: CachedNetworkImage(
                  width: double.infinity,
                  height: double.infinity,
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
            SizedBox(
              height: 20,
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
                          AppLocalization.of(context)
                              .internetConnectionNotAvailable,
                          context,
                          gravity: Toast.BOTTOM,
                          backgroundColor: darkBlue());
                    }
                  });
                },
                textColor: Colors.white,
                color: darkBlue(),
                height: 50,
                child: Text(AppLocalization.of(context).request),
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
                          AppLocalization.of(context)
                              .internetConnectionNotAvailable,
                          context,
                          gravity: Toast.BOTTOM,
                          backgroundColor: darkBlue());
                    }
                  });
                },
                textColor: Colors.white,
                color: darkBlue(),
                height: 50,
                child: Text(AppLocalization.of(context)
                    .send), // change this to make payment request button to
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
