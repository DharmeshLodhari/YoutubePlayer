//TODO: allow user to type recevierName like we do in payment request
//TODO: allow user to input body
//TODO: allow user to click send button
//TODO: inputs {recipient, subject, body, submitButton }

import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class ComposeMessage extends StatefulWidget {
  @override
  _ComposeMessageState createState() => _ComposeMessageState();
}

class _ComposeMessageState extends State<ComposeMessage> {
  TextEditingController _recipientController = TextEditingController();
  FocusNode _recipientFocus = FocusNode();

  http.Response response;
  bool isValidPayee = false;
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  CustomerProfile _payee;
  UserBloc userBloc;
  CustomerProfileBloc customerProfileBloc;
  String subject = "";
  String message = "";
  String errorMessage = "";
  String recipient;

  @override
  void initState() {
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
    if (customerProfileBloc.customer.userName != null) {
      setState(() {
        _payee = customerProfileBloc.customer;
        recipient = _payee.userName;
        _recipientController.text = recipient;
      });
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
            actions: <Widget>[sendMessage()],
            automaticallyImplyLeading: Platform.isAndroid ? false : true,
            title: Center(child: Text("Compose Message")),
            backgroundColor: darkBlue()),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    getDisplayCard(),
                    SizedBox(height: 10),
                    getRecipientField(),
                    SizedBox(height: 10),
                    getSubjectField(),
                    SizedBox(height: 10),
                    getContentField(),
                    SizedBox(height: 10),
                    Text(
                      errorMessage,
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
//                    SizedBox(height: 10),
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

  Widget sendMessage() {
    return IconButton(
      icon: Icon(Icons.send),
      onPressed: () {
        if (_payee != null) {
          if (recipient == _payee.userName) {
            if (!isValidPayee) {
              setState(() {
                errorMessage = "Invalid recipient";
              });
            }
            if (_formKey.currentState.validate()) {
              FocusScope.of(context).unfocus();

              Navigator.pop(context);
              try {
                var data = {
                  "from_customer": userBloc.user.userName,
                  "to_customer": recipient,
                  "message": message
                };
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
        } else {
          var msg = "Please Fill Details";
          Toast.show(msg, context,
              gravity: Toast.CENTER,
              backgroundColor: darkBlue(),
              textColor: Colors.white);
        }
      },
    );
  }

  Widget showBackArrow() {
    if (Platform.isAndroid) {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          Navigator.pop(context);
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
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
      enabled: true,
      focusNode: _recipientFocus,
      cursorColor: darkBlue(),
      validator: (value) {
        if (value != _payee.userName) {
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
          if (_payee != null) {
            recipient = _payee.userName;
          } else {
            recipient = val.toLowerCase();
          }
        });
      },
    );
  }

  Widget getSubjectField() {
    return TextFormField(
      enabled: true,
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.subject),
        fillColor: Colors.white,
        filled: true,
        hintText: "Subject",
        labelStyle: TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
          borderSide: BorderSide(
            width: 1,
            color: Colors.white,
            style: BorderStyle.solid,
          ),
        ),
      ),
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
          subject = val;
        });
      },
    );
  }

  Widget getContentField() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      maxLines: 15,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
          isDense: true,
          fillColor: Colors.white,
          filled: true,
          hintText: "Type your message here....",
          labelStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1, color: Colors.white, style: BorderStyle.solid))),
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
          message = val;
        });
      },
    );
  }
}
