import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SendPayment extends StatefulWidget {
  // Declare a field that holds the userData.
  @override
  _SendPaymentState createState() => _SendPaymentState();
}

class _SendPaymentState extends State<SendPayment> {
  int _currentIndex = 2;
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  CustomerProfile _payee;
  UserBloc userBloc;

  bool isValidPayee = false;
  int amount;
  String reference = "";
  String errorMessage = "";
  String recipient;

  @override
  Widget build(BuildContext context) {
    userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      backgroundColor: lightBlue(),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
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

// TODO: Find a better way to do this without duplication
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          String path = _currentIndex.toString();

          switch (path) {
            case '0':
              return Navigator.of(context).pushNamed('/profile');
            case '1':
              return Navigator.of(context).pushNamed('/accounts');
            case '2':
              return Navigator.of(context).pushNamed('/transactions');
            case '3':
              return Navigator.of(context).pushNamed('/settings');
            default:
              // If there is no such named route in the switch statement, e.g. /third
              return Navigator.of(context).pushNamed('/profile');
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.white,
            ),
            title: Text('Home',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group, color: Colors.white),
            title: Text('Accounts',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          BottomNavigationBarItem(
            backgroundColor: lightBlue(),
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            title: Text('Transactions',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.white),
            title: Text('Settings',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
    //
  }

  Widget getDisplayCard() {
    return _payee == null
        ? Text("")
        : Card(
            semanticContainer: true,
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              SizedBox(height: 20),
              ListTile(
                title: Text(
                  _payee.fullName,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                subtitle: Text(_payee.userName),
                leading: Image.network(
                  _payee.avatar,
                  colorBlendMode: BlendMode.darken,
                  fit: BoxFit.fitWidth,
                  filterQuality: FilterQuality.high,
                ),
                trailing: Image.network(
                  _payee.qrCode,
                  colorBlendMode: BlendMode.darken,
                  fit: BoxFit.fitWidth,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ]),
          );
  }

  Widget getRecipientField() {
    return TextFormField(
      cursorColor: darkBlue(),
      autofocus: false,
      obscureText: false,
      decoration: InputDecoration(
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
          _payee = null;
          recipient = val;
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
          prefixText: '#',
          prefixStyle: TextStyle(
              color: darkBlue(),
              backgroundColor: Colors.white,
              fontSize: 20,
              letterSpacing: 5),
          //labelText: "Enter Amount",
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
          if (!isValidPayee) {
            setState(() {
              errorMessage = "Invalid recipient";
            });
          }

          if (isValidPayee && _formKey.currentState.validate()) {
            Map data = {
              "from_customer": userBloc.user.userName,
              "to_customer": recipient,
              "currency": "NGN",
              "amount": amount.toString(),
              "category": "Shopping",
              "notes": reference,
              "description": reference
            };
            http.Response response = await _auth.makePayment(data);
            if (response.statusCode == 200) {
              Navigator.of(context).pushNamed('/transactions');
            } else {
              setState(() {
                errorMessage = "An error has occured please try again";
              });
            }
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
