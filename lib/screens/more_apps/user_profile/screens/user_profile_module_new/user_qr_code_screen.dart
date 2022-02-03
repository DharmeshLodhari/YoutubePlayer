import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/global_key.dart';
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

import '../../user_auth.dart';

// ignore: must_be_immutable
class UserQRCodeScreen extends StatefulWidget {
  CustomerProfile? user;
  UserQRCodeScreen({
    required this.user,
  });

  @override
  _UserQRCodeScreenState createState() => _UserQRCodeScreenState();
}

class _UserQRCodeScreenState extends State<UserQRCodeScreen> {
  late UserBloc userBloc;

  bool isLoading = true;
  bool isInContactList = false;
  bool isInRequestList = false;
  bool profileValue = false;
  final auth = AuthService();
  int counter = 0;

  late BankAccountBloc bankAccountBloc;

  int? accountBalance = 0;

  @override
  void initState() {
    super.initState();
  }

  void checkCurrentUserIsInContact() async {
    if (userBloc.user.userName != widget.user!.userName) {
      UserAuth()
          .checkInContactList(widget.user!.userName, userBloc.user.userName)
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
    if (userBloc.user.userName != widget.user!.userName) {
      UserAuth()
        ..checkInRequest(widget.user!.userName).then((value) {
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

  @override
  Widget build(BuildContext context) {
    bankAccountBloc = Provider.of<BankAccountBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    if (counter == 0) {
      checkCurrentUserState();
      counter++;
    }
    return WillPopScope(
      onWillPop: () async {
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
                imageUrl: widget.user!.avatar!,
                fit: BoxFit.fill,
                errorWidget: imageErrorWidget,
              ),
            ),
          ),
          title: Text(widget.user!.displayName()!),
          subtitle: Text(widget.user!.userName!),
          trailing: getTrailing()),
    );
  }

  Widget? getTrailing() {
    if (userBloc.user.userName == widget.user!.userName) {
      return null;
    }
    return IconButton(
      icon: Icon(
        Icons.message,
        color: blackFont,
      ),
      onPressed: () {
        UserAuth()
            .fetchCustomerProfile(widget.user!.userName)
            .then((fetchedUser) {
          Navigator.of(context).pushNamed('/compose_message', arguments: {
            'recipient': fetchedUser.userName,
            'subject': "",
          });
        });
      },
    );
  }

  Widget displayUserInfo() {
    return CustomBoxShadow(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.zero,
        shadowColor: boxShadowTwo,
        borderOnForeground: true,
        child: Column(
          children: <Widget>[
            Container(
                padding:
                    EdgeInsets.only(right: 40, left: 40, top: 40, bottom: 10),
                child: CachedNetworkImage(
                  imageUrl: widget.user!.qrCode!,
                  colorBlendMode: BlendMode.darken,
                  errorWidget: imageErrorWidget,
                  fit: BoxFit.fitWidth,
                  filterQuality: FilterQuality.high,
                  placeholder: (context, url) => CircularLoadingIndicator(),
                )),
            SizedBox(
              height: 8,
            ),
            userBloc.user.userName != widget.user!.userName
                ? Divider(
                    color: dividerColor,
                    height: 0,
                    thickness: 1,
                  )
                : Container(),
            userBloc.user.userName != widget.user!.userName
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
                                showToast(
                                    message: "${widget.user!.displayName()} " +
                                        AppLocalization.of(context)!.isBlocked);
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
                                    AppLocalization.of(context)!.blockUser,
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
    if (userBloc.user.userName == widget.user!.userName) {
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
          userBloc.user.type!,
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
          onTap: contactPrimaryActionCall() as void Function()?,
          child: contactPrimaryAction()),
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
        UserAuth().removeFromContactList(widget.user!).then((value) {
          if (value) {
            showToast(
                message:
                    "Connection Remove From Your Connection List Successfully .");
            checkCurrentUserState();
          } else {
            showToast(
                message:
                    "Connection is Removed From Your Connection List Unsuccessfully .");
          }
        });
      };
    } else if (isInRequestList) {
      return () {
        UserAuth().rejectContactRequest(widget.user!).then((value) {
          if (value) {
            showToast(message: "Connection request Canceled");
          } else {
            showToast(message: "Connection request Canceled unsuccessfully");
          }
          checkCurrentUserState();
        });
      };
    }

    return () {
      UserAuth().makeContactRequest(widget.user!).then((value) {
        if (value) {
          showToast(message: "Connection Request Sent !!");
        } else {
          checkCurrentUserIsInContact();
          showToast(message: "Request Not Sent.. ");
        }
        checkCurrentUserState();
      });
    };
  }

  Widget displayPaymentButtons() {
    if (userBloc.user.userName == widget.user!.userName) {
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
          UserAuth()
              .fetchCustomerProfile(widget.user!.userName)
              .then((fetchedUser) {
            CustomerProfileBloc customerProfileBloc =
                Provider.of<CustomerProfileBloc>(
                    myGlobals.navigationKey.currentContext!,
                    listen: false);
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
          UserAuth()
              .fetchCustomerProfile(widget.user!.userName)
              .then((fetchedUser) {
            CustomerProfileBloc customerProfileBloc =
                Provider.of<CustomerProfileBloc>(
                    myGlobals.navigationKey.currentContext!,
                    listen: false);
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
              showToast(
                  message: AppLocalization.of(context)!
                      .internetConnectionNotAvailable);
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
                : CircularLoadingIndicator(),
          ),
        ),
      ),
    );
  }

  Widget displayUserProfileUpgradeOptions() {
    if (userBloc.user.userName == widget.user!.userName) {
      return userBloc.user.type == "User"
          ? CurvedButton(
              backgroundColor: navyBlue,
              onPressed: upgradeAccount,
              text: "Upgrade Profile",
              textColor: Colors.white,
            )
          : Container();
    }
    return Container();
  }

  void upgradeAccount() async {
    await getAccountBalance();
    if (accountBalance! > 0) {
      Navigator.pushNamed(context, "/upgrade-user-profile");
    } else {
      showToast(message: "Insufficient funds!!");
    }
  }

  Future<void> getAccountBalance() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Center(child: CircularLoadingIndicator()));

    await PaymentAndBankingAuth().getAccountBalance().then((value) {
      var data = value!;
      var spendableBalance = data["spendable_balance"];
      debugPrint("DATA:- $value");
      accountBalance = spendableBalance;
      Navigator.of(context).pop();
      if (mounted) setState(() {});
    });
  }
}
