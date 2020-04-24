import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/transactions.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  bool isRemember = false;
  final _formKey = GlobalKey<FormState>( );
  final _auth = AuthService( );
  String phoneNumber = '';
  String password = '';

  //for remember user
  bool isChecked = false;
  String phoneNumberFromPref;
  String passwordFromPref;
  TextEditingController phoneNumberController;
  TextEditingController passwordController;
  SharedPreferences _sharedPreferences;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging( );

  // creating a instance of the databaseHelper
  DatabaseHelper _db = DatabaseHelper( );

  @override
  void initState() {
    getSharedPreference( );
    phoneNumberController = TextEditingController( );
    passwordController = TextEditingController( );
    super.initState( );
  }

  Future<void> getSharedPreference() async {
    _sharedPreferences = await SharedPreferences.getInstance( );

    if (_sharedPreferences != null) {
      setState( () {
        isChecked = _sharedPreferences.getBool( 'isChecked' ) ?? false;
      } );
      isRemember = isChecked;

      if (isChecked) {
        phoneNumberFromPref = _sharedPreferences.getString( 'username' ) ?? "";
        passwordFromPref = _sharedPreferences.getString( 'password' ) ?? "";

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
    return WillPopScope(
      onWillPop: () {
        if (FocusScope
            .of( context )
            .hasFocus) {
          FocusScope.of( context ).unfocus( );
        }

        return Future.value( true );
      },
      child: Scaffold(
          backgroundColor: lightBlue( ),
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text( 'Login' ),
            backgroundColor: darkBlue( ),
            elevation: 0.0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric( vertical: 20.0, horizontal: 40.0 ),
            scrollDirection: Axis.vertical,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  displayImage( ),
                  phoneNumberField( ),
                  SizedBox( height: 20.0 ),
                  passwordField( ),
                  SizedBox( height: 20.0 ),
                  rememberLogin( ),
                  SizedBox( height: 15 ),
                  forgotPasswordButton( ),
                  SizedBox( height: 20 ),
                  submitButton( context ),
                ],
              ),
            ),
          ) ),
    );
  }

  Widget displayImage() {
    return Container(
      margin: EdgeInsets.all( 20.0 ),
      padding: EdgeInsets.fromLTRB( 10.0, 0.0, 10, 0 ),
      alignment: Alignment.topCenter,
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Image.asset(
        'assets/images/icon2.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget phoneNumberField() {
    return TextFormField(
      controller: phoneNumberController,
      cursorColor: darkBlue( ),
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          prefixIcon: Icon(
              Platform.isAndroid ? Icons.phone_android : Icons.phone_iphone ),
          fillColor: Colors.white,
          filled: true,
          hintText: "Phone Number",
          labelStyle: TextStyle(
            color: darkBlue( ),
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all( Radius.circular( 4 ) ),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid ) ) ),
      validator: (val) {
        if (val.isNotEmpty && val.length == 13) {
          return null;
        }
        return "Invalid phone number";
      },
      onChanged: (val) {
        setState( () {
          phoneNumber = val.trim( );
        } );
      },
    );
  }

  Widget passwordField() {
    return TextFormField(
      controller: passwordController,
      autofocus: false,
      obscureText: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          prefixIcon: Icon( Icons.lock ),
          fillColor: Colors.white,
          filled: true,
          hintText: "Password",
          labelStyle: TextStyle(
            color: darkBlue( ),
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all( Radius.circular( 4 ) ),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid ) ) ),
      validator: (val) => val.length < 4 ? "Enter a valid Password." : null,
      onChanged: (val) {
        setState( () {
          password = val.trim( );
        } );
      },
    );
  }

  Widget submitButton(context) {
    return ButtonTheme(
      minWidth: double.infinity,
      child: MaterialButton(
        onPressed: login,
        textColor: Colors.white,
        color: darkBlue( ),
        height: 50,
        child: Text( "LOGIN" ),
      ),
    );
  }

  Widget rememberLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Checkbox(
          onChanged: (value) {
            setState( () {
              if (value == true) {
                isChecked = true;
                isRemember = true;
              } else {
                isChecked = false;
                isRemember = false;
              }
            } );
          },
          activeColor: Colors.white,
          value: isChecked,
          checkColor: darkBlue( ),
        ),
        Expanded(
          child: Text(
            "Remember Me",
            style: TextStyle( color: Colors.white ),
          ),
        )
      ],
    );
  }

  Widget logo() {
    return Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: Image.asset( 'assets/images/android-chrome-192x192.png' ),
      ),
    );
  }

  void isRememberChecked() async {
    bool isLoggedOut = await _sharedPreferences.setBool( 'isLoggedOut', false );
    if (isRemember) {
      await _sharedPreferences.clear( );
      bool isCheckedSet =
      await _sharedPreferences.setBool( 'isChecked', isChecked );
      bool usernameSet =
      await _sharedPreferences.setString( 'username', phoneNumber );
      bool passwordSet =
      await _sharedPreferences.setString( 'password', password );

      if (!isCheckedSet || !isLoggedOut || !usernameSet || !passwordSet) {
        Toast.show( "User Not Saved !!!", context );
      }
    } else {
      bool isSuccessFullyStored =
      await _sharedPreferences.setBool( 'isChecked', isChecked );
      if (!isSuccessFullyStored) {
        Toast.show( "User Not Saved !!!", context );
      }
    }
  }

  void login() async {
    final UserBloc userBloc = Provider.of<UserBloc>( context, listen: false );
    final BankAccountBloc bankAccountBloc =
    Provider.of<BankAccountBloc>( context, listen: false );
    if (_formKey.currentState.validate( )) {
      showDialog( context: context, builder: (context) => LoadingIndicator( ) );

      var _user;
      BankAccount _bankAccount;

      _auth.authenticate( phoneNumber, password ).then( (value) {
        _user = value;

        if (_user.fullName != null) {
          //method call for storing user info into shared preference
          isRememberChecked( );
          userBloc.user = _user;

          //setting up notification
          setupNotification( );

          // Get user's bank account if user is logged in
          if (_user != null) {
            _auth.getBankAccounts( ).then( (accounts) {
              try {
                _bankAccount = accounts[0];
                if (_bankAccount != null) {
                  bankAccountBloc.bankAccount = _bankAccount;
                }
              } catch (e) {
                debugPrint( e );
              }
            } );
          }

          if (_user.isVerified == true) {
            Navigator.of( context )
                .pushNamed( '/dashboard', arguments: {'dashboardIndex': 0} );
          } else {
            Navigator.of( context ).popAndPushNamed( '/add-document' );
          }
        } else {
          Navigator.pop( context );
          Toast.show( "User is Not Registerd !!", context,
              gravity: Toast.CENTER,
              backgroundColor: darkBlue( ),
              textColor: Colors.white );
        }
      } );
    }
  }

  Widget forgotPasswordButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of( context ).pushNamed( '/forgot-password' );
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          "Forgot Password?",
          style: TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  // ignore: missing_return
  void onSelectNotification(String payload) {
    // example of notification response
    // {body: abiola.rasheed.2 sent you a message,
    // title: You've Got Mail, vibrate: [200,100,200,100,200,100,400],
    // icon: null, badge: null, sound: null, link: null, tag: null, dir: auto,
    // actions: /detail_message/40892023-fa43-4652-b3eb-fd584f6530e9}

    debugPrint( "payload : $payload" );
    if (payload == "/request-payment") {
      Navigator.of( context ).pushNamed( '/dashboard', arguments: {
        'dashboardIndex': 1,
      } );
    } else if (payload == "/transaction") {
      Navigator.of( context ).pushNamed( '/dashboard', arguments: {
        'dashboardIndex': 2,
      } );
    } else if (payload.length > 15 &&
        payload.substring( 0, 16 ) == "/detail_message/") {
      //this variable will fetch the id of message from the response
      String idOfMessage = payload.replaceAll( "/detail_message/", "" );
      Navigator.of( context ).pushNamed( '/detail_message', arguments: {
        'id': idOfMessage,
      } );
    }
  }

  void _navigateToItemDetail(Map<String, dynamic> notification) async {
    debugPrint( "naviagate function is callled" );
    onSelectNotification( notification['actions'] );
  }

  void authenticateUser(Map<String, dynamic> navigate) async {
    SharedPreferences _sharedPreferences =
    await SharedPreferences.getInstance( );
    final UserBloc userBloc = Provider.of<UserBloc>( context, listen: false );
    final BankAccountBloc bankAccountBloc = Provider.of(
        context, listen: false );
    final _auth = AuthService( );

    var phoneNumberFromPref = _sharedPreferences.getString( 'username' ) ?? "";
    var passwordFromPref = _sharedPreferences.getString( 'password' ) ?? "";

    if (phoneNumberFromPref != "" && passwordFromPref != "") {
      var _user;
      var _bankAccount;
      _auth.authenticate( phoneNumberFromPref, passwordFromPref ).then( (
          value) {
        _user = value;

        if (_user.fullName != null) {
          userBloc.user = _user;

          if (_user != null) {
            _auth.getBankAccounts( ).then( (accounts) {
              try {
                _bankAccount = accounts[0];
                if (_bankAccount != null) {
                  bankAccountBloc.bankAccount = _bankAccount;
                  if (_user.isVerified == true) {
                    Navigator.of( context ).pushNamed( navigate['route'],
                        arguments: navigate['arguments'] );
                  } else {
                    Navigator.of( context ).popAndPushNamed( '/add-document' );
                  }
                }
              } catch (e) {}
            } );
          }
        } else {
          Navigator.of( context ).pushNamed( "/index" );
        }
      } );
    } else {
      Navigator.of( context ).pushNamed( "/index" );
    }
  }

  void setupNotification() async {
    var data = await getDeviceInfo( );
    _firebaseMessaging.getToken( ).then( (String token) async {
      data["token"] = token;

      // this piece of code convert Map<dynamic,dynamic> data to Map<String,String> tempData
      // so we can store that data into database
      Map<String, dynamic> tempData = new Map<String, dynamic>( );
      tempData['firebaseToken'] = data['token'];
      tempData['type'] = data['type'];
      tempData['mode'] = data['mode'];
      tempData['deviceId'] = data['device_id'];
      tempData['deviceName'] = data['device_name'];

      // delete device info to database
      await _db.deleteDevice( );

      // save device info to database
      await _db.saveDevice( tempData );

      // register device with the backend
      await _auth.registerDevice( data );
    } );

    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(
          const IosNotificationSettings(
              sound: true, badge: true, alert: true ) );
    }

    _firebaseMessaging.configure(
      // onMessage will be called when App is running and also app is in foreground
      onMessage: (Map<String, dynamic> message) async {
        debugPrint( "onMessage: $message" );
        // creating notification from server payload
        var notification = getAndroidNotification( message );

        debugPrint( "Notification From onMessage:  $notification" );

        // show the notification in the dialog
        showCuperDialog<String>(
          context: context,
          notification: notification,
          child: CupertinoDessertDialog(
            title: Text( notification['title'].toString( ) ),
            content: Text( notification['body'].toString( ) ),
          ),
        );
      },

      // onLaunch will be called when App is not running
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint( "onLaunch: $message" );
        // creating notification from server payload
        var notification = getAndroidNotification( message );

        debugPrint( "Notification From onLaunch:  $notification" );

        //navigate to the particular screen
        _navigateToItemDetail( notification );
      },
      // onResume will be called when App is running and it is in background
      onResume: (Map<String, dynamic> message) async {
        debugPrint( "onResume: $message" );
        // creating notification from server payload
        var notification = getAndroidNotification( message );

        debugPrint( "Notification From OnResume:  $notification" );

        //navigate to the particular screen
        _navigateToItemDetail( notification );
      },
    );
  }

  void showCuperDialog<T>(
      {BuildContext context, Map<String, dynamic> notification, Widget child}) {
    showCupertinoDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then( (T value) {
      if (value != null) {
        if (value == "Navigate") {
          _navigateToItemDetail( notification );
        }
      }
    } );
  }

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
    debugPrint( "notification from android getnotification $notification" );
    return notification;
  }
}

class CupertinoDessertDialog extends StatelessWidget {
  const CupertinoDessertDialog({Key key, this.title, this.content})
      : super(key: key);

  final Widget title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: title,
      content: content,
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text('Navigate to the page'),
          onPressed: () {
            Navigator.pop(context, 'Navigate');
          },
        ),
        CupertinoDialogAction(
          child: const Text('Cancel'),
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
        ),
      ],
    );
  }
}
