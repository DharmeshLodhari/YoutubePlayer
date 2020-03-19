import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/location_service.dart';
import 'package:Slydo/widget/passcodePopup.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class SendPayment extends StatefulWidget {
  var arguments;

  SendPayment({this.arguments});

  // Declare a field that holds the userData.
  @override
  _SendPaymentState createState() => _SendPaymentState();
}

class _SendPaymentState extends State<SendPayment> {
  TextEditingController _recipientController = TextEditingController();
  FocusNode _recipientFocus = FocusNode();
  TextEditingController _passwordController;
  http.Response response;
  String _passwordFromPopUp = "";

  var currencyImage = Image.asset(
    'assets/images/naira.png',
    scale: 1.5,
  );
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  CustomerProfile _payee;
  UserBloc userBloc;
  CustomerProfileBloc customerProfileBloc;

  bool isFromProfile = false;
  bool isValidPayee = false;
  int amount;
  String reference = "";
  String errorMessage = "";
  String recipient;
  final locationService = LocationService();

  @override
  void initState() {
    isFromProfile =
        widget.arguments != null ? widget.arguments['isFromProfile'] : false;
    _passwordController = TextEditingController();

    _recipientFocus
      ..addListener(() {
        if (!_recipientFocus.hasFocus) {
          setState(() {
            _recipientController.text = _recipientController.text.toLowerCase();
          });
        }
      });

    super.initState();
  }

  initializeDisplayCard() {
    if (!isFromProfile) {
      if (customerProfileBloc.customer.userName != null) {
        setState(() {
          _payee = customerProfileBloc.customer;
          recipient = _payee.userName;
          _recipientController.text = recipient;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        _payee = null;
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            leading: showBackArrow(),
            automaticallyImplyLeading: Platform.isAndroid ? false : true,
            title: Center(child: Text("Send a Payment")),
            backgroundColor: darkBlue()),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    getDisplayCard(),
                    SizedBox(height: 10),
                    getRecipientField(),
                    SizedBox(height: 10),
                    displayAmountField(),
                    SizedBox(height: 10),
                    getReferenceField(),
                    SizedBox(height: 10),
                    Text(
                      errorMessage,
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    getSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    //
  }

  Widget showBackArrow() {
    if (Platform.isAndroid) {
      return Text("");
    } else {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          _payee = null;
          Navigator.pop(context);
        },
      );
    }
  }

  Widget getDisplayCard() {
    initializeDisplayCard();
    var avatarImage;
    var qrCodeImage;
    if (_payee != null) {
      avatarImage = CachedNetworkImage(
        imageUrl: _payee.avatar,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
      );
      qrCodeImage = CachedNetworkImage(
        imageUrl: _payee.qrCode,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
      );
    }

    return _payee == null
        ? Container()
        : Card(
            semanticContainer: true,
            child: ListTile(
              dense: true,
              title: Text(
                _payee.fullName,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              subtitle: Text(_payee.userName),
              leading: avatarImage,
              trailing: qrCodeImage,
            ),
          );
  }

  Widget getRecipientField() {
    return TextFormField(
      controller: _recipientController,
      enabled: isFromProfile,
      focusNode: _recipientFocus,
//      initialValue: isFromProfile ? "" : _payee.userName,
      cursorColor: darkBlue(),
      validator: (value) {
        if (!isFromProfile && value != _payee.userName) {
          return "Enter Valid Recipient";
        }
        return null;
      },
      //
      autofocus: false,
      obscureText: false,

      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person),
        fillColor: Colors.white,
        filled: true,
        hintText: "Recipient",
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(
                width: 1, color: Colors.white, style: BorderStyle.solid)),
      ),

      onChanged: (val) {
        setState(() {
          if (!isFromProfile && _payee != null) {
            recipient = _payee.userName;
          } else {
            recipient = val.toLowerCase();
          }
        });
      },
    );
  }

  Widget displayAmountField() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      keyboardType: TextInputType.number,
      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          prefixIcon: currencyImage,
          hintText: "Enter Amount",
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      validator: (val) {
        if (val.isNotEmpty) {
          try {
            int.parse(val);
            return null;
          } catch (e) {}
        }
        return "Invalid amount";
      },
      onTap: () async {
        if (recipient != null) {
          var customerProfile = await _auth.fetchCustomerProfile(recipient);
          setState(() {
            _payee = customerProfile;
            isValidPayee = _payee.userName != userBloc.user.userName;
          });
        }
      },
      onChanged: (val) {
        setState(() {
          amount = int.parse(val);
        });
      },
    );
  }

  Widget getReferenceField() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.note),
          fillColor: Colors.white,
          filled: true,
          hintText: "Reference",
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
      onChanged: (val) {
        setState(() {
          reference = val;
        });
      },
    );
  }

  Widget getSubmitButton() {
    return ButtonTheme(
      minWidth: double.infinity,
      child: MaterialButton(
        elevation: 4.0,
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("Send Payment"),
        onPressed: () async {
          if (recipient == _payee.userName) {
            if (!isValidPayee) {
              setState(() {
                errorMessage = "Invalid recipient";
              });
            }

            if (isValidPayee && _formKey.currentState.validate()) {
              FocusScope.of(context).unfocus();
              // Todo: Add a try block here and stop user from continuing if they deny location permission
              var userLocation;
              try {
                userLocation = await locationService.getLocation();
                var data = {
                  "from_customer": userBloc.user.userName,
                  "to_customer": recipient,
                  "currency": "NGN",
                  "amount": amount.toString(),
                  "category": "Shopping",
                  "notes": reference,
                  "description": reference,
                  "latitude": userLocation.latitude,
                  "longitude": userLocation.longitude,
                };

                PasscodePopup(
                    context: context,
                    isValidCallback: () {
                      showDialog(
                          context: context,
                          builder: (context) =>
                              Center(child: CircularProgressIndicator()));
                      _auth.makePayment(data).then((value) {
                        response = value;
                        if (response.statusCode == 200) {
                          Navigator.of(context).pushNamed('/dashboard',
                              arguments: {'dashboardIndex': 2});
                        } else if (response.statusCode == 500) {
                          Navigator.pop(context);
                          setState(() {
                            errorMessage =
                                "Server Error please try after some time !";
                            Toast.show(errorMessage, context,
                                gravity: Toast.TOP,
                                backgroundColor: darkBlue(),
                                textColor: Colors.white);
                          });
                        } else {
                          Navigator.pop(context);
                          setState(() {
                            errorMessage = "Something went wrong  !!";
                            Toast.show(errorMessage, context,
                                gravity: Toast.TOP,
                                backgroundColor: darkBlue(),
                                textColor: Colors.white);
                          });
                        }
                      });
                    },
                    cancelCallBack: () {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Wrong Password !!"),
                      ));
                    });

//                Navigator.of(context)
//                    .pushNamed('/resultPasswordPopup')
//                    .then((result) {
//                  if ("true" == result) {
//                    _auth.makePayment(data).then((value) {
//                      response = value;
//                      if (response.statusCode == 200) {
//                        Navigator.of(context).pushNamed('/dashboard',
//                            arguments: {'dashboardIndex': 2});
//                      } else if (response.statusCode == 500) {
//                        setState(() {
//                          errorMessage =
//                              "Server Error please try after some time !";
//                          Toast.show(errorMessage, context,
//                              gravity: Toast.TOP,
//                              backgroundColor: darkBlue(),
//                              textColor: Colors.white);
//                        });
//                      } else {
//                        setState(() {
//                          errorMessage = "Something went wrong  !!";
//                          Toast.show(errorMessage, context,
//                              gravity: Toast.TOP,
//                              backgroundColor: darkBlue(),
//                              textColor: Colors.white);
//                        });
//                      }
//                    });
//                  } else {
//                    Scaffold.of(context).showSnackBar(SnackBar(
//                      content: Text("Wrong Password !!"),
//                    ));
//                  }
//                });
              } catch (e) {
                print(e);
                Toast.show(e, context,
                    gravity: Toast.BOTTOM, backgroundColor: darkBlue());
              }
            }
          } else {
            var msg = "Invalid recipient";
            Toast.show(msg, context,
                gravity: Toast.CENTER,
                backgroundColor: darkBlue(),
                textColor: Colors.white);
          }
        },
      ),
    );
  }
}
