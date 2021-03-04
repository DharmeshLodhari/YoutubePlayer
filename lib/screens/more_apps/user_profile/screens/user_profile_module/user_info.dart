import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/UserAbout.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/CustomBoxShadow.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../user_auth.dart';

// ignore: must_be_immutable
class UserInfo extends StatefulWidget {
  CustomerProfile user;

  UserInfo({@required this.user});

  @override
  _UserInfoState createState() => _UserInfoState(user: user);
}

class _UserInfoState extends State<UserInfo> {
  CustomerProfile user;
  UserBloc userBloc;

  _UserInfoState({this.user});

  bool isLoading = true;
  bool isInContactList = false;
  bool isInRequestList = false;
  bool profileValue = false;
  final auth = AuthService();
  int counter = 0;
  UserAbout userAbout;
  bool isAboutLoading = false;

  @override
  void initState() {
    fetchUserAboutDetail();
    super.initState();
  }

  void fetchUserAboutDetail() {
    isAboutLoading = true;
    if (mounted) setState(() {});
    UserAuth().fetchUserAboutInfo(userName: user.userName).then((value) {
      userAbout = value;
      isAboutLoading = false;
      if (mounted) setState(() {});
    });
  }

  void checkCurrentUserIsInContact() async {
    if (userBloc.user.userName != user.userName) {
      UserAuth()
          .checkInContactList(user.userName, userBloc.user.userName)
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
    if (userBloc.user.userName != user.userName) {
      UserAuth()
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

  CustomerProfileBloc customerProfileBloc;

  @override
  Widget build(BuildContext context) {
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
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
        backgroundColor: lightGrey,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                displayUserInfo(),
                SizedBox(height: 30),
                // displayPaymentButtons(),
                displayUserProfileUpgradeOptions(),
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
                errorWidget: imageErrorWidget,
              ),
            ),
          ),
          title: Text(user.fullName),
          subtitle: Text(user.userName),
          trailing: getTrailing()),
    );
  }

  Widget getTrailing() {
    if (userBloc.user.userName == user.userName) {
      return null;
    }
    return IconButton(
      icon: Icon(
        Icons.message,
        color: darkBlue(),
      ),
      onPressed: () {
        UserAuth().fetchCustomerProfile(user.userName).then((fetchedUser) {
          Navigator.of(context).pushNamed('/compose_message', arguments: {
            'recipient': fetchedUser.userName,
            'subject': "",
          });
        });
      },
    );
  }

  Widget displayUserInfo() {
    Color borderColor = getUserTypeColor(user: user);

    return CustomBoxShadow(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        shadowColor: boxShadowTwo,
        borderOnForeground: true,
        child: Column(
          children: <Widget>[
            // ListTile(
            //   leading: Container(
            //     height: 48,
            //     width: 48,
            //     decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(
            //           25,
            //         ),
            //         border: Border.all(color: borderColor, width: 2)),
            //     child: ClipOval(
            //       child: CachedNetworkImage(
            //         imageUrl: user.avatar,
            //         fit: BoxFit.fill,
            //         errorWidget: imageErrorWidget,
            //       ),
            //     ),
            //   ),
            //   title: Text(
            //     user.fullName,
            //     style: TextStyle(
            //       fontSize: 16,
            //       fontWeight: FontWeight.bold,
            //       color: blackFont,
            //     ),
            //     maxLines: 1,
            //     softWrap: false,
            //     overflow: TextOverflow.fade,
            //   ),
            //   subtitle: Text(
            //     user.userName,
            //     style: TextStyle(
            //       fontSize: 14,
            //       color: darkGrey,
            //     ),
            //     maxLines: 1,
            //     softWrap: false,
            //     overflow: TextOverflow.fade,
            //   ),
            // ),
            // Divider(
            //   color: dividerColor,
            //   height: 0,
            //   thickness: 1,
            // ),
            GestureDetector(
              child: Container(
                  padding:
                      EdgeInsets.only(right: 40, left: 40, top: 40, bottom: 10),
                  child: CachedNetworkImage(
                    imageUrl: user.qrCode,
                    colorBlendMode: BlendMode.darken,
                    errorWidget: imageErrorWidget,
                    fit: BoxFit.fitWidth,
                    filterQuality: FilterQuality.high,
                    placeholder: (context, url) => CircularLoadingIndicator(),
                  )),
              onTap: () {
                // Navigator.of(context).pushNamed("/profile-new");
                Navigator.pushNamed(context, '/profile-new',
                    arguments: {"searchedUserName": user.userName});
              },
            ),
            SizedBox(
              height: 8,
            ),
            userBloc.user.userName != user.userName
                ? Divider(
                    color: dividerColor,
                    height: 0,
                    thickness: 1,
                  )
                : Container(),
            userBloc.user.userName != user.userName
                ? Container(
                    height: 45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                            child: isLoading
                                ? CircularLoadingIndicator()
                                : contactActionButtons()),
                        Container(
                          width: 1,
                          height: double.infinity,
                          color: dividerColor,
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
                                  RoundedBackgroundIcon(
                                    height: 28,
                                    width: 28,
                                    icon: Icon(
                                      SlydoAppIcon.block,
                                      color: mateRed,
                                      size: 14,
                                    ),
                                    backgroundColor: mateRed.withOpacity(0.1),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    AppLocalization.of(context).blockUser,
                                    style:
                                        TextStyle(color: mateRed, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: displayUserType(),
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget displayUserType() {
    if (userBloc.user.userName == user.userName) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: userBloc.user.type != "User"
                ? userBloc.user.type != "Business"
                    ? starYellow
                    : naturalGreen
                : navyBlue),
        child: Text(
          userBloc.user.type,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }
    return Container();
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
          SizedBox(
            width: 8,
          ),
          RoundedBackgroundIcon(
            height: 28,
            width: 28,
            icon: Icon(
              SlydoAppIcon.remove_connection,
              color: blackFont,
              size: 14,
            ),
            backgroundColor: blackFont.withOpacity(0.1),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              "Remove Connection",
              style: TextStyle(
                color: blackFont,
                fontSize: 14,
              ),
            ),
          ),
        ],
      );
    } else if (isInRequestList) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 8,
          ),
          RoundedBackgroundIcon(
            height: 28,
            width: 28,
            icon: Icon(
              SlydoAppIcon.cancel_connection_request,
              color: mateRed,
              size: 14,
            ),
            backgroundColor: mateRed.withOpacity(0.1),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              "Cancel Request",
              style: TextStyle(color: mateRed, fontSize: 14),
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 8,
        ),
        RoundedBackgroundIcon(
          height: 28,
          width: 28,
          icon: Icon(
            SlydoAppIcon.send_connection_request,
            color: naturalGreen,
            size: 14,
          ),
          backgroundColor: naturalGreen.withOpacity(0.1),
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
          child: Text(
            "Add Connection",
            style: TextStyle(color: naturalGreen, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Function contactPrimaryActionCall() {
    if (isInContactList) {
      return () {
        UserAuth().removeFromContactList(user).then((value) {
          if (value) {
            Toast.show(
                "Connection Remove From Your Connection List Successfully .",
                context,
                gravity: Toast.CENTER,
                duration: Toast.LENGTH_LONG,
                backgroundColor: darkBlue());
            checkCurrentUserState();
          } else {
            Toast.show(
                "Connection is Removed From Your Connection List Unsuccessfully .",
                context,
                gravity: Toast.CENTER,
                duration: Toast.LENGTH_LONG,
                backgroundColor: darkBlue());
          }
        });
      };
    } else if (isInRequestList) {
      return () {
        UserAuth().rejectContactRequest(user).then((value) {
          if (value) {
            Toast.show("Connection request Canceled", context,
                gravity: Toast.CENTER,
                duration: Toast.LENGTH_LONG,
                backgroundColor: darkBlue());
          } else {
            Toast.show("Connection request Canceled unsuccessfully", context,
                gravity: Toast.CENTER,
                duration: Toast.LENGTH_LONG,
                backgroundColor: darkBlue());
          }
          checkCurrentUserState();
        });
      };
    }

    return () {
      UserAuth().makeContactRequest(user).then((value) {
        if (value) {
          Toast.show("Connection Request Sent !!", context,
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
    if (userBloc.user.userName == user.userName) {
      return Container();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: Color.fromARGB(51, 50, 55, 140),
      margin: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: dividerColor, width: 0.5)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
        onTap: () async {
          UserAuth().fetchCustomerProfile(user.userName).then((fetchedUser) {
            customerProfileBloc.customer = fetchedUser;
            Navigator.of(context).pushNamed('/request-payment',
                arguments: <String, bool>{
                  'isFromProfile': false,
                  'isRequest': true
                });
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
          UserAuth().fetchCustomerProfile(user.userName).then((fetchedUser) {
            customerProfileBloc.customer = fetchedUser;
            Navigator.of(context).pushNamed('/send-payment',
                arguments: <String, bool>{'isFromProfile': false});
          });
        },
      ),
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
            errorWidget: imageErrorWidget,
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

  Widget displayUserProfileUpgradeOptions() {
    if (userBloc.user.userName == user.userName) {
      return userBloc.user.type == "User"
          ? CurvedButton(
              backgroundColor: navyBlue,
              onPressed: () {
                Navigator.pushNamed(context, "/upgrade-user-profile");
              },
              text: "Upgrade Profile",
              textColor: Colors.white,
            )
          : Container();
    }
    return Container();
  }
}
