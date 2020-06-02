import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
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

  bool isLoading = true;
  bool isInContactList = false;
  bool isInRequestList = false;
  final auth = AuthService();
  int counter = 0;

  void checkCurrentUserIsInContact() async {
    if (_userBloc.user.userName != user.userName) {
      _auth
          .checkInContactList(user.userName, _userBloc.user.userName)
          .then((value) {
        if (mounted) {
          setState(() {
            if (value) {
              isInContactList = true;
              debugPrint("is In Contact : $isInContactList");
            }
          });
        }
      });
    }
  }

  void checkCurrentUserIsInRequestList() async {
    if (_userBloc.user.userName != user.userName) {
      _auth
        ..checkInRequest(user.userName).then((value) {
          if (mounted) {
            setState(() {
              if (value) {
                isInRequestList = true;
                debugPrint("is In Request List : $isInRequestList");
              }
            });
          }
        });
    }
  }

  void checkCurrentUserState() {
    if (mounted) {
      setState(() {
        isInRequestList = false;
        isInContactList = false;
      });
    }
    checkCurrentUserIsInContact();
    checkCurrentUserIsInRequestList();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldUserInfoKey =
      new GlobalKey<ScaffoldState>();

  final _auth = AuthService();
  CustomerProfileBloc customerProfileBloc;
  @override
  Widget build(BuildContext context) {
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    _userBloc = Provider.of<UserBloc>(context);
    if (counter == 0) {
      checkCurrentUserState();
      counter++;
    }
    return WillPopScope(
      onWillPop: () async {
        customerProfileBloc.customer = null;
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
//                displayUserNameAndContect(),
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
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
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
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      elevation: 4.0,
      child: Column(
        children: <Widget>[
          ListTile(
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
          Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
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
          SizedBox(
            height: 8,
          ),
          _userBloc.user.userName != user.userName
              ? Divider(
                  color: darkBlue(),
                  height: 0,
                )
              : Container(),
          _userBloc.user.userName != user.userName
              ? Container(
                  height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                          child: isLoading
                              ? CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                )
                              : contactActionButtons()),
                      Container(
                        width: 0.5,
                        height: double.infinity,
                        color: darkBlue(),
                      ),
                      Expanded(
                        child: Container(
                          height: double.infinity,
                          child: InkWell(
                            onTap: () {
                              Toast.show(
                                  "${user.fullName} " +
                                      AppLocalization.of(context).isBlocked,
                                  context,
                                  gravity: Toast.CENTER,
                                  duration: Toast.LENGTH_LONG,
                                  backgroundColor: darkBlue(),
                                  textColor: Colors.white);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Stack(
                                  children: <Widget>[
                                    Icon(
                                      Icons.group,
                                      color: Colors.black,
                                    ),
                                    Icon(
                                      Icons.block,
                                      color: Colors.red,
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  AppLocalization.of(context).blockUser,
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget contactActionButtons() {
    return Container(
      height: double.infinity,
      child: InkWell(
          onTap: contactPrimaryActionCall(), child: contactPrimaryAction()),
    );
  }

  Widget contactPrimaryAction() {
    if (isInContactList) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.remove_circle, color: Colors.red),
          SizedBox(
            width: 8,
          ),
          Text(
            "Remove Contact",
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
      );
    } else if (isInRequestList) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.close, color: Colors.red),
          SizedBox(
            width: 8,
          ),
          Text(
            "Cancel Request",
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.group_add, color: Colors.black),
        SizedBox(
          width: 8,
        ),
        Text(
          AppLocalization.of(context).addContact,
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    );
  }

  Function contactPrimaryActionCall() {
    if (isInContactList) {
      return () {
        _auth.removeFromContactList(user).then((value) {
          if (value) {
            Toast.show(
                "Contact Remove From Your Contact List Successfully .", context,
                gravity: Toast.CENTER,
                duration: Toast.LENGTH_LONG,
                backgroundColor: darkBlue());
            checkCurrentUserState();
          } else {
            Toast.show(
                "Contact is Removed From Your Contact List Unsuccessfully .",
                context,
                gravity: Toast.CENTER,
                duration: Toast.LENGTH_LONG,
                backgroundColor: darkBlue());
          }
        });
      };
    } else if (isInRequestList) {
      return () {
        _auth.rejectContactRequest(user).then((value) {
          if (value) {
            Toast.show("Contact request Canceled", context,
                gravity: Toast.CENTER,
                duration: Toast.LENGTH_LONG,
                backgroundColor: darkBlue());
          } else {
            Toast.show("Contact request Canceled unsuccessfully", context,
                gravity: Toast.CENTER,
                duration: Toast.LENGTH_LONG,
                backgroundColor: darkBlue());
          }
          checkCurrentUserState();
        });
      };
    }
    return () {
      _auth.makeContactRequest(user).then((value) {
        if (value) {
          Toast.show(AppLocalization.of(context).contactRequestSent, context,
              gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG,
              backgroundColor: darkBlue());
        } else {
          checkCurrentUserIsInContact();
          Toast.show("Request Not Sent.. ", context,
              gravity: Toast.CENTER,
              duration: Toast.LENGTH_LONG,
              backgroundColor: darkBlue());
        }
        checkCurrentUserState();
      });
    };
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
