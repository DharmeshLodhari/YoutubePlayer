import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class UserInfo extends StatefulWidget {
  CustomerProfile user;
  UserInfo({@required this.user});
  @override
  _UserInfoState createState() => _UserInfoState(user: user);
}

class _UserInfoState extends State<UserInfo> {
  CustomerProfile user;
  UserBloc _userBloc;
  _UserInfoState({this.user});

  final GlobalKey<ScaffoldState> _scaffoldUserInfoKey =
      new GlobalKey<ScaffoldState>();

  final _auth = AuthService();
  CustomerProfileBloc customerProfileBloc;
  @override
  Widget build(BuildContext context) {
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    _userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        key: _scaffoldUserInfoKey,
        resizeToAvoidBottomInset: true,
        backgroundColor: lightBlue(),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            color: lightBlue(),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                displayUserNameAndContect(),
                SizedBox(height: 10),
                displayUserInfo(),
                SizedBox(height: 30),
                displayPaymentButtons()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget displayUserNameAndContect() {
    return Card(
      child: ListTile(
          leading: ClipOval(
            child: Container(
              height: 45,
              width: 45,
              child: CachedNetworkImage(
                imageUrl: user.avatar,
                fit: BoxFit.fill,
              ),
            ),
          ),
          title: Text(user.fullName),
          subtitle: Text(user.userName),
          trailing: getTrailing()),
    );
  }

  Widget getTrailing() {
    if (_userBloc.user.userName == user.userName) {
      return null;
    }
    return IconButton(
      icon: Icon(
        Icons.message,
        color: darkBlue(),
      ),
      onPressed: () {
        _auth.fetchCustomerProfile(user.userName).then((fetchedUser) {
          Navigator.of(context).pushNamed('/compose_message', arguments: {
            'recipient': fetchedUser.userName,
            'subject': "",
          });
        });
      },
    );
  }

  Widget displayUserInfo() {
    return Card(
      elevation: 4.0,
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: CachedNetworkImage(
                imageUrl: user.qrCode,
                colorBlendMode: BlendMode.darken,
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.high,
                placeholder: (context, url) => CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  backgroundColor: lightBlue(),
                ),
              )),
          ButtonBar(
            mainAxisSize: MainAxisSize.max,
            alignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FlatButton(
                  onPressed: () {},
                  child: Text(user.fullName,
                      style: TextStyle(color: Colors.black, fontSize: 14))),
              FlatButton.icon(
                  onPressed: () {
                    Clipboard.setData(new ClipboardData(
                        text: baseUrl + "/api/v1/customer/" + user.userName));
                    Toast.show(AppLocalization.of(context).copied, context,
                        gravity: Toast.CENTER,
                        duration: Toast.LENGTH_LONG,
                        backgroundColor: darkBlue());
                  },
                  icon: Icon(Icons.content_copy, color: Colors.black),
                  label: Text(AppLocalization.of(context).copyUrl,
                      style: TextStyle(color: Colors.black, fontSize: 14))),
            ],
          ),
        ],
      ),
    );
  }

  Widget displayPaymentButtons() {
    if (_userBloc.user.userName == user.userName) {
      return Container();
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
            child: ButtonTheme(
              //elevation: 4,
              child: MaterialButton(
                elevation: 4.0,
                onPressed: () async {
                  _auth.fetchCustomerProfile(user.userName).then((fetchedUser) {
                    customerProfileBloc.customer = fetchedUser;
                    Navigator.of(context).pushNamed('/request-payment',
                        arguments: <String, bool>{
                          'isFromProfile': false,
                          'isRequest': true
                        });
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
                  _auth.fetchCustomerProfile(user.userName).then((fetchedUser) {
                    customerProfileBloc.customer = fetchedUser;
                    Navigator.of(context).pushNamed('/send-payment',
                        arguments: <String, bool>{'isFromProfile': false});
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

  Widget displayUserAvatar(userBloc) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
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
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: lightBlue(),
                  ),
          ),
        ),
      ),
    );
  }
}
