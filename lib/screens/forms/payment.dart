import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
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
  TextEditingController _passwordController;
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

  @override
  Widget build(BuildContext context) {
    isFromProfile =
        widget.arguments != null ? widget.arguments['isFromProfile'] : false;
    _passwordController = TextEditingController();
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
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                _payee = null;
                Navigator.pop(context);
              },
            ),
            automaticallyImplyLeading: false,
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

  Widget getDisplayCard() {
    if (!isFromProfile) {
      if (customerProfileBloc.customer.userName != null) {
        setState(() {
          _payee = customerProfileBloc.customer;
          recipient = _payee.userName;
        });
      }
    }
    var avatarImage;
    var qrCodeImage;
    if (_payee != null) {
      avatarImage = Image.network(
        _payee.avatar,
        colorBlendMode: BlendMode.darken,
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high,
      );
      qrCodeImage = Image.network(
        _payee.qrCode,
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
      initialValue: isFromProfile ? "" : _payee.userName,
      cursorColor: darkBlue(),
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
      //),
    );
  }

  Widget getReferenceField() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
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

  Widget passwordPopUp() {
    return Container(
      color: lightBlue(),
      width: MediaQuery.of(context).size.width - 10,
      height: MediaQuery.of(context).size.height -  80,
      padding: EdgeInsets.all(20),
      child: AlertDialog(
        backgroundColor: lightBlue(),
        elevation: 0.0,
        title: Text(
          "Enter Your Password",
          style: TextStyle(color: Colors.white),
        ),
        content: TextFormField(
          autovalidate: true,
          autofocus: false,
          obscureText: true,
          controller: _passwordController,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
              hintText: "Password",
              fillColor: Colors.white,
              filled: true,
              border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
        ),
        actions: <Widget>[
          MaterialButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if (_passwordController.text != "") {
                _passwordFromPopUp = _passwordController.text;
                Navigator.pop(context);

                //use _passwordFromPopUp variable to pass in request

                Map data = {
                  "from_customer": userBloc.user.userName,
                  "to_customer": recipient,
                  "currency": "NGN",
                  "amount": amount.toString(),
                  "category": "Shopping",
                  "notes": reference,
                  "description": reference
                };

                showDialog(
                    context: context, builder: (context) => LoadingIndicator());

                http.Response response;
                _auth.makePayment(data).then((value) {
                  response = value;
                  if (response.statusCode == 200) {
                    Navigator.of(context).pushNamed('/transactions');
                  } else {
                    setState(() {
                      errorMessage = "An error has occured please try again";
                    });
                  }
                });
              } else {
                Toast.show("Password Should not Be Empty !!", context,
                    gravity: Toast.TOP,
                    backgroundColor: darkBlue(),
                    textColor: Colors.white);
              }
            },
            color: darkBlue(),
          ),
          MaterialButton(
            color: darkBlue(),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }


  Widget getSubmitButton() {
    return ButtonTheme(
      minWidth: double.infinity,
      child: MaterialButton(
        elevation: 4.0,
        onPressed: () async {
          if (!isValidPayee) {
            setState(() {
              errorMessage = "Invalid recipient";
            });
          }

          if (isValidPayee && _formKey.currentState.validate()) {
            //password popup starts

            await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => passwordPopUp());
          }
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("Send Payment"),
      ),
    );
  }
}
