import 'package:Slydo/data/state_notifier.dart';
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
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  int _currentIndex = 2;

  int amount;
  String reference = "";
  String errorMessage = "";
  int recipient;

  @override
  Widget build(BuildContext context) {
    final PayeeBloc payeeBloc = Provider.of<PayeeBloc>(context);
    final UserBloc userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Center(child: Text("Send a Payment")),
          backgroundColor: darkBlue()),
      body: SingleChildScrollView(
        child: Container(
          color: lightBlue(),
          padding: EdgeInsets.all(40),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  Center(
//                    child: Card(
//                      semanticContainer: true,
//                      elevation: 4.0,
//                      child: Column(
//                        mainAxisSize: MainAxisSize.min,
//                        children: <Widget>[
//                          SizedBox(
//                            height: 10,
//                          ),
//                          ListTile(
//                            title: Text(
//                              payeeBloc.payee.fullName,
//                              style: TextStyle(
//                                  color: Colors.black,
//                                  fontWeight: FontWeight.bold,
//                                  fontSize: 15),
//                            ),
//                            subtitle: Text(payeeBloc.payee.userName),
//                            leading: Image.network(
//                              payeeBloc.payee.avatar,
//                              colorBlendMode: BlendMode.darken,
//                              fit: BoxFit.fitWidth,
//                              filterQuality: FilterQuality.high,
//                            ),
//                            trailing: Image.network(
//                              payeeBloc.payee.qrCode,
//                              colorBlendMode: BlendMode.darken,
//                              fit: BoxFit.fitWidth,
//                              filterQuality: FilterQuality.high,
//                            ),
//                          ),
//                          SizedBox(
//                            height: 10,
//                          ),
//                          customerField(),
//                          SizedBox(
//                            height: 10,
//                          ),
//                          Padding(
//                            padding: EdgeInsets.all(20.0),
//                            child: TextFormField(
//                              autofocus: true,
//                              obscureText: false,
//                              keyboardType: TextInputType.number,
//                              inputFormatters: [
//                                WhitelistingTextInputFormatter.digitsOnly
//                              ],
//                              decoration: InputDecoration(
//                                  prefixText: '#',
//                                  prefixStyle: TextStyle(
//                                      color: darkBlue(),
//                                      backgroundColor: Colors.white,
//                                      fontSize: 20,
//                                      letterSpacing: 5),
//                                  //labelText: "Enter Amount",
//                                  hintText: "Enter Amount",
//                                  labelStyle: TextStyle(
//                                    color: Colors.black,
//                                    fontSize: 16,
//                                  ),
//                                  border: OutlineInputBorder(
//                                      borderRadius:
//                                          BorderRadius.all(Radius.circular(4)),
//                                      borderSide: BorderSide(
//                                          width: 1,
//                                          color: darkBlue(),
//                                          style: BorderStyle.solid))),
//                              validator: (val) {
//                                if (val.isNotEmpty) {
//                                  try {
//                                    int.parse(val);
//                                    return null;
//                                  } catch (e) {}
//                                }
//                                return "Invalid amount";
//                              },
//                              onChanged: (val) {
//                                setState(() {
//                                  amount = int.parse(val);
//                                });
//                              },
//                            ),
//                          ),
//                          Padding(
//                              padding: EdgeInsets.all(20.0),
//                              child: TextFormField(
//                                autofocus: false,
//                                decoration: InputDecoration(
//                                    labelText: "Reference",
//                                    hintText: "Reference",
//                                    labelStyle: TextStyle(
//                                      color: Colors.black,
//                                      fontSize: 16,
//                                    ),
//                                    border: OutlineInputBorder(
//                                        borderRadius: BorderRadius.all(
//                                            Radius.circular(4)),
//                                        borderSide: BorderSide(
//                                            width: 1,
//                                            color: darkBlue(),
//                                            style: BorderStyle.solid))),
//                                onChanged: (val) {
//                                  setState(() {
//                                    reference = val;
//                                  });
//                                },
//                              )),
//                        ],
//                      ),
//                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 10),
                  ButtonTheme(
                    //elevation: 4,
                    //color: darkBlue(),
                    minWidth: double.infinity,
                    child: MaterialButton(
                      elevation: 4.0,
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          Map data = {
                            "from_customer": userBloc.user.userName,
                            "to_customer": recipient,
                            "currency": "NGN",
                            "amount": amount.toString(),
                            "category": "Shopping",
                            "notes": reference,
                            "description": reference
                          };
                          http.Response response =
                              await _auth.makePayment(data);
                          if (response.statusCode == 200) {
                            Navigator.of(context).pushNamed('/transactions');
                          } else {
                            setState(() {
                              errorMessage =
                                  "An error has occured please try again";
                            });
                          }
                        }
                      },
                      textColor: Colors.white,
                      color: darkBlue(),
                      height: 50,
                      child: Text("Send Payment"),
                    ),
                  )
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

  Widget customerField() {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: TextFormField(
          autofocus: false,
          decoration: InputDecoration(
              labelText: "Recipient",
              hintText: "Recipient",
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(
                      width: 1, color: darkBlue(), style: BorderStyle.solid))),
          onChanged: (val) {
            setState(() {
              recipient = int.parse(val);
            });
          },
        ));
  }
}
