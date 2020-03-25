import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/location_service.dart';
import 'package:Slydo/widget/passcodePopup.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class RequestPayment extends StatefulWidget {
  var arguments;
  RequestPayment({this.arguments});

  // Declare a field that holds the userData.
  @override
  _RequestPaymentState createState() =>
      _RequestPaymentState(arguments: arguments);
}

class _RequestPaymentState extends State<RequestPayment> {
  TextEditingController _recipientController = TextEditingController();
  FocusNode _recipientFocus = FocusNode();

  var arguments;
  _RequestPaymentState({this.arguments});

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
    isFromProfile = arguments != null
        ? arguments['isFromProfile'] != null
            ? arguments['isFromProfile']
            : false
        : false;

    /* adding listener on recipientFocus when user unFocus
    From Recipient Field then value of that field should be in lowerCase */
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

  void initializeDisplayCard() {
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
            actions: <Widget>[
              displayQRCodeButton(),
            ],
            leading: showBackArrow(),
            automaticallyImplyLeading: Platform.isAndroid ? false : true,
            title: Center(child: Text("Request Payment")),
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

  Widget displayQRCodeButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed('/scan-qr', arguments: {"isRequest": true});
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
//      initialValue: isFromProfile ? null : _payee.userName,
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
                  width: 1, color: Colors.white, style: BorderStyle.solid))),

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
          prefixIcon: Container(
            width: 20,
            child: Center(
              child: Text(
                worldCurrencies[userBloc.user.currency],
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600]),
              ),
            ),
          ),
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
        onPressed: () async {
          FocusScope.of(context).unfocus();

          if (!isValidPayee) {
            setState(() {
              errorMessage = "Invalid recipient";
              return;
            });
          }

          if (recipient == _payee.userName) {
            if (!isValidPayee) {
              setState(() {
                errorMessage = "Invalid recipient";
                return;
              });
            }

            if (isValidPayee && _formKey.currentState.validate()) {
              // Todo: Add a try block here and stop user from continuing if they deny location permission

              var userLocation;
              try {
                userLocation = await locationService.getLocation();

                var data = {
                  "from_customer": userBloc.user.userName,
                  "to_customer": recipient,
                  "currency": userBloc.user.currency,
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
                      _auth.createPaymentRequests(data).then((value) {
                        if (value) {
                          Navigator.of(context).pushNamed('/dashboard',
                              arguments: {'dashboardIndex': 1});
                        } else if (!value) {
                          Navigator.pop(context);
                          Toast.show("Request Not Send ", context,
                              gravity: Toast.TOP,
                              backgroundColor: darkBlue(),
                              textColor: Colors.white);
                        } else {
                          Navigator.pop(context);
                          setState(() {
                            errorMessage = "Wrong Password !!";
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
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("Request Payment"),
      ),
    );
  }
}
