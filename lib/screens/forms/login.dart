import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  bool isRemember = false;
  final _loginFormKey = GlobalKey<FormState>();
  final _auth = AuthService();
  String phoneNumber = '';
  String password = '';

  //for remember user
  bool isChecked = false;
  String phoneNumberFromPref;
  String passwordFromPref;
  TextEditingController phoneNumberController;
  TextEditingController passwordController;
  SharedPreferences _sharedPreferences;
  BasketBloc basketBloc;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // creating a instance of the databaseHelper
  DatabaseHelper _db = DatabaseHelper();

  final FocusNode _pinPutFocusNode = FocusNode();

  @override
  void initState() {
    getSharedPreference();
    phoneNumberController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  Future<void> getSharedPreference() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    if (_sharedPreferences != null) {
      if (mounted) {
        setState(() {
          isChecked = _sharedPreferences.getBool('isChecked') ?? false;
        });
      }
      isRemember = isChecked;

      if (isChecked) {
        phoneNumberFromPref = _sharedPreferences.getString('username') ?? "";
        passwordFromPref = _sharedPreferences.getString('password') ?? "";

        //setting fetched userdata into screen
        phoneNumberController.text = phoneNumberFromPref;
        passwordController.text = passwordFromPref;
        phoneNumber = phoneNumberFromPref;
        password = passwordFromPref;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    return WillPopScope(
      onWillPop: () {
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus();
        }
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: whiteBackground,
        appBar: AppBar(
          backgroundColor: whiteBackground,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: navyBlue,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            height: MediaQuery.of(context).size.height -
                (AppBar().preferredSize.height +
                    MediaQuery.of(context).padding.top),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Expanded(
                  flex: 7,
                  child: Form(
                    key: _loginFormKey,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          appIcon(),
                          flexibleSpace(flex: 1),
                          loginTitle(),
                          flexibleSpace(flex: 4),
                          phoneNumberField(),
                          flexibleSpace(flex: 1),
                          passwordPinFiled(),
                          flexibleSpace(flex: 1),
                          rememberMeAndForgotPasswordField(),
                          flexibleSpace(flex: 4),
                          loginBtnField(),
                          flexibleSpace(flex: 2),
                        ],
                      ),
                    ),
                  ),
                ),
                flexibleSpace(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget appIcon() {
    return Container(
      child: Image.asset(
        "assets/images/app_logo_navyBlue.png",
        height: MediaQuery.of(context).size.height / 16,
        frameBuilder: imageFrameBuilder,
      ),
    );
  }

  Widget loginTitle() {
    return Container(
      child: Row(
        children: <Widget>[
          Text(
            "Log in to ",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
          ),
          Text(
            "Slydo",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w700, color: navyBlue),
          ),
        ],
      ),
    );
  }

  Widget phoneNumberField() {
    return CustomizedTextFormField(
      labelColor: darkGrey,
      labelText: "Phone number",
      type: TextInputType.phone,
      controller: phoneNumberController,
      validator: (val) {
        if (val.isNotEmpty && val.length == 13) {
          return null;
        }
        return AppLocalization.of(context).invalidPhoneNumber;
      },
    );
  }

  Widget passwordPinFiled() {
    BoxDecoration pinPutDecoration = BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: greyBorderColor));
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Password",
            style: TextStyle(fontSize: 14, color: darkGrey),
          ),
          SizedBox(
            height: 6.0,
          ),
          PinPut(
            eachFieldWidth: 45,
            eachFieldHeight: 45,
            obscureText: '•',
            validator: (val) => val.length < 4
                ? AppLocalization.of(context).invalidPassword
                : null,
            fieldsCount: 6,
            focusNode: _pinPutFocusNode,
            controller: passwordController,
            submittedFieldDecoration: pinPutDecoration,
            selectedFieldDecoration: pinPutDecoration,
            followingFieldDecoration: pinPutDecoration,
            pinAnimationType: PinAnimationType.scale,
            textStyle: TextStyle(color: blackFont, fontSize: 35),
          ),
        ],
      ),
    );
  }

  Widget rememberMeAndForgotPasswordField() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          rememberMeField(),
          forgotPasswordField(),
        ],
      ),
    );
  }

  Widget rememberMeField() {
    return Row(
      children: <Widget>[
        ClipRRect(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          child: SizedBox(
            width: Checkbox.width - 1.5,
            height: Checkbox.width - 1.5,
            child: Container(
              decoration: new BoxDecoration(
                border: Border.all(
                  color: greyBorderColor,
                  width: 1,
                ),
                borderRadius: new BorderRadius.circular(5),
              ),
              child: Theme(
                data: ThemeData(
                  unselectedWidgetColor: Colors.transparent,
                ),
                child: Checkbox(
                  value: isChecked,
                  onChanged: (value) {
                    if (mounted) {
                      if (value == true) {
                        isChecked = true;
                        isRemember = true;
                      } else {
                        isChecked = false;
                        isRemember = false;
                      }
                      setState(() {});
                    }
                  },
                  activeColor: navyBlue,
                  checkColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 12,
        ),
        Text(
          AppLocalization.of(context).rememberMe,
          style: TextStyle(color: blackFont, fontSize: 14),
        ),
      ],
    );
  }

  Widget forgotPasswordField() {
    return Container(
        child: GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/forgot-password');
      },
      child: Text(
        AppLocalization.of(context).forgotPassword,
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: navyBlue),
      ),
    ));
  }

  Widget loginBtnField() {
    return CurvedButton(
      backgroundColor: navyBlue,
      textColor: Colors.white,
      text: "Log in",
      onPressed: login,
    );
  }

  void login() async {
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    final BankAccountBloc bankAccountBloc =
        Provider.of<BankAccountBloc>(context, listen: false);
    if (_loginFormKey.currentState.validate()) {
      showDialog(context: context, builder: (context) => LoadingIndicator());

      var _user;
      BankAccount _bankAccount;
      phoneNumber = phoneNumberController.text.trim();
      password = passwordController.text.trim();

      _auth.authenticate(phoneNumber, password).then((value) {
        _user = value;

        if (_user.fullName != null) {
          //method call for storing user info into shared preference
          isRememberChecked();
          userBloc.user = _user;

          //setting up notification
          setupNotification();

          // Get user's bank account if user is logged in
          if (_user != null) {
            _auth.getBankAccounts().then((accounts) {
              try {
                _bankAccount = accounts[0];
                if (_bankAccount != null) {
                  bankAccountBloc.bankAccount = _bankAccount;
                }
              } catch (e) {
                debugPrint(e.toString());
              }
            });
          }

//          if (_user.isVerified == true) {
          //to initializeShoppingCart
          initializeShoppingCart();
          Navigator.of(context).pushNamedAndRemoveUntil(
            "/dashboard",
            (Route<dynamic> route) => false,
          );
//          } else {
//            Navigator.of(context).popAndPushNamed('/bvn-verification');
//          }
        } else {
          Navigator.pop(context);
          Toast.show(AppLocalization.of(context).userIsNotRegistered, context,
              gravity: Toast.CENTER,
              backgroundColor: darkBlue(),
              textColor: Colors.white);
        }
      });
    }
  }

  void isRememberChecked() async {
    bool isLoggedOut = await _sharedPreferences.setBool('isLoggedOut', false);
    if (isRemember) {
      await _sharedPreferences.clear();
      bool isCheckedSet =
          await _sharedPreferences.setBool('isChecked', isChecked);
      bool usernameSet =
          await _sharedPreferences.setString('username', phoneNumber);
      bool passwordSet =
          await _sharedPreferences.setString('password', password);

      if (!isCheckedSet || !isLoggedOut || !usernameSet || !passwordSet) {
        Toast.show(AppLocalization.of(context).userIsNotSaved, context);
      }
    } else {
      bool isSuccessFullyStored =
          await _sharedPreferences.setBool('isChecked', isChecked);
      if (!isSuccessFullyStored) {
        Toast.show(AppLocalization.of(context).userIsNotSaved, context);
      }
    }
  }

  void initializeShoppingCart() async {
    debugPrint("initializeShoppingCart called");
    List items = await _auth.getShoppingCart();
    items.forEach((element) {
      String type = element is Product ? "product" : "service";
      basketBloc.addItemToCart(item: element, type: type);
    });
  }

  // ignore: missing_return
  void onSelectNotification(String payload) {
    // example of notification response
    // {body: abiola.rasheed.2 sent you a message,
    // title: You've Got Mail, vibrate: [200,100,200,100,200,100,400],
    // icon: null, badge: null, sound: null, link: null, tag: null, dir: auto,
    // actions: /detail_message/40892023-fa43-4652-b3eb-fd584f6530e9}

    debugPrint("payload : $payload");
    if (payload == "/request-payment") {
      Navigator.of(context).pushNamedAndRemoveUntil(
        "/dashboard",
        (Route<dynamic> route) => false,
        arguments: {"dashboardIndex": 1},
      );
    } else if (payload == "/transaction") {
      Navigator.of(context).pushNamed('/transactions');
    } else if (payload.length > 15 &&
        payload.substring(0, 16) == "/detail_message/") {
      //this variable will fetch the id of message from the response
      String idOfMessage = payload.replaceAll("/detail_message/", "");
      Navigator.of(context).pushNamed('/detail_message', arguments: {
        'id': idOfMessage,
      });
    }
  }

  void _navigateToItemDetail(Map<String, dynamic> notification) async {
    debugPrint("naviagate function is callled");
    onSelectNotification(notification['actions']);
  }

  void authenticateUser(Map<String, dynamic> navigate) async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
    final BankAccountBloc bankAccountBloc = Provider.of(context, listen: false);
    final _auth = AuthService();

    var phoneNumberFromPref = _sharedPreferences.getString('username') ?? "";
    var passwordFromPref = _sharedPreferences.getString('password') ?? "";

    if (phoneNumberFromPref != "" && passwordFromPref != "") {
      var _user;
      var _bankAccount;
      _auth.authenticate(phoneNumberFromPref, passwordFromPref).then((value) {
        _user = value;

        if (_user.fullName != null) {
          userBloc.user = _user;

          if (_user != null) {
            _auth.getBankAccounts().then((accounts) {
              try {
                _bankAccount = accounts[0];
                if (_bankAccount != null) {
                  bankAccountBloc.bankAccount = _bankAccount;
                  if (_user.isVerified == true) {
                    Navigator.of(context).pushNamed(navigate['route'],
                        arguments: navigate['arguments']);
                  } else {
                    Navigator.of(context).popAndPushNamed('/add-document');
                  }
                }
              } catch (e) {}
            });
          }
        } else {
          Navigator.of(context).pushNamed("/index");
        }
      });
    } else {
      Navigator.of(context).pushNamed("/index");
    }
  }

  void setupNotification() async {
    var data = await getDeviceInfo();
    _firebaseMessaging.getToken().then((String token) async {
      data["token"] = token;

      // this piece of code convert Map<dynamic,dynamic> data to Map<String,String> tempData
      // so we can store that data into database
      Map<String, dynamic> tempData = new Map<String, dynamic>();
      tempData['firebaseToken'] = data['token'];
      tempData['type'] = data['type'];
      tempData['mode'] = data['mode'];
      tempData['deviceId'] = data['device_id'];
      tempData['deviceName'] = data['device_name'];

      // delete device info to database
      await _db.deleteDevice();

      // save device info to database
      await _db.saveDevice(tempData);

      // register device with the backend
      await _auth.registerDevice(data);
    });

    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(sound: true, badge: true, alert: true));

      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        debugPrint("Settings registered: $settings");
      });
      _firebaseMessaging.getToken().then((String token) {
        debugPrint("firebase IOS token : $token");
      });
    }

    _firebaseMessaging.configure(
      // onMessage will be called when App is running and also app is in foreground
      onMessage: (Map<String, dynamic> message) async {
        debugPrint("onMessage: $message");
        // creating notification from server payload
        var notification = Platform.isAndroid
            ? getAndroidNotification(message)
            : getIosNotification(message);

        debugPrint("Notification From onMessage:  $notification");

        // show the notification in the dialog
        bool result = await showDialogBoxWithImage(
          context: context,
          title: notification['title'],
          description: notification['body'],
          image: notification['image'],
          actionOne: AppLocalization.of(context).navigate,
          actionTwo: AppLocalization.of(context).cancel,
        );
        if (result) {
          _navigateToItemDetail(notification);
        } else {
          Navigator.pop(context);
        }
      },

      // onLaunch will be called when App is not running
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint("onLaunch: $message");
        // creating notification from server payload
        var notification = Platform.isAndroid
            ? getAndroidNotification(message)
            : getIosNotification(message);

        debugPrint("Notification From onLaunch:  $notification");

        //navigate to the particular screen
        _navigateToItemDetail(notification);
      },
      // onResume will be called when App is running and it is in background
      onResume: (Map<String, dynamic> message) async {
        debugPrint("onResume: $message");
        // creating notification from server payload
        var notification = Platform.isAndroid
            ? getAndroidNotification(message)
            : getIosNotification(message);

        debugPrint("Notification From OnResume:  $notification");

        //navigate to the particular screen
        _navigateToItemDetail(notification);
      },
    );
  }

//  I/flutter ( 9569): onMessage: {notification: {title: Payment Received, body: Received NGN5}, data: {actions: /transaction, dir: auto, image: https://slydo-assets.s3.amazonaws.com/media/customer/avatar/77d91cd9345d4f50bb88d29c412eb0f7.jpg, vibrate: [200,100,200,100,200,100,400]}}
//  I/flutter ( 9569): notification from android getnotification {body: Received NGN5, title: Payment Received, vibrate: [200,100,200,100,200,100,400], icon: null, badge: null, sound: null, link: null, tag: null, dir: auto, actions: /transaction, image: https://slydo-assets.s3.amazonaws.com/media/customer/avatar/77d91cd9345d4f50bb88d29c412eb0f7.jpg}
//  I/flutter ( 9569): Notification From onMessage:  {body: Received NGN5, title: Payment Received, vibrate: [200,100,200,100,200,100,400], icon: null, badge: null, sound: null, link: null, tag: null, dir: auto, actions: /transaction, image: https://slydo-assets.s3.amazonaws.com/media/customer/avatar/77d91cd9345d4f50bb88d29c412eb0f7.jpg}

  Map<String, dynamic> getAndroidNotification(Map<String, dynamic> message) {
    Map<String, dynamic> notification = {};
    notification["body"] = message['notification']['body'];
    notification["title"] = message['notification']['title'];
    notification["vibrate"] = message['data']['vibrate'];
    notification["icon"] = message['data']['icon'];
    notification["badge"] = message['data']['badge'];
    notification["sound"] = message['data']['sound'];
    notification["link"] = message['data']['link'];
    notification["tag"] = message['data']['tag'];
    notification["dir"] = message['data']['dir'];
    notification["actions"] = message['data']['actions'];
    notification['image'] = message['data']['image'];
    debugPrint("notification from android getnotification $notification");
    return notification;
  }

  Map<String, dynamic> getIosNotification(Map<String, dynamic> message) {
    Map<String, dynamic> notification = {};
    notification["body"] = message['notification']['body'];
    notification["title"] = message['notification']['title'];
    notification["vibrate"] = message['vibrate'];
    notification["icon"] = message['notification']['icon'];
    notification["tag"] = message['notification']['tag'];
    notification["dir"] = message['dir'];
    notification["actions"] = message['actions'];
    notification['image'] = message['image'];
    debugPrint("notification from IOS getnotification $notification");
    return notification;
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
