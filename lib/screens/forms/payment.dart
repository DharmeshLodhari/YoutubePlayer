import 'package:PayBay/data/state_notifier.dart';
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
  final _formKey = GlobalKey<FormState>();
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final PayeeBloc payeeBloc = Provider.of<PayeeBloc>(context);
    final UserBloc userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Center(child: Text("Send a Payment")),
          backgroundColor: Colors.green),
      body: SingleChildScrollView(
        child: Container(
          height: 600,
          color: Colors.white,
          padding: EdgeInsets.all(40),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 10),
                  Center(
                    child: Card(
                      semanticContainer: true,
                      elevation: 4.0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          ListTile(
                            title: Text(
                              payeeBloc.payee.fullName,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            subtitle: Text(payeeBloc.payee.userName),
                            leading: Image.network(
                              payeeBloc.payee.avatar,
                              colorBlendMode: BlendMode.darken,
                              fit: BoxFit.fitWidth,
                              filterQuality: FilterQuality.high,
                            ),
                            trailing: Image.network(
                              payeeBloc.payee.qrCode,
                              colorBlendMode: BlendMode.darken,
                              fit: BoxFit.fitWidth,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: TextFormField(
                              autofocus: true,
                              obscureText: false,
                              //keyboardType: TextInputType.number,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                  prefixText: '#',
                                  prefixStyle: TextStyle(
                                      color: Colors.green,
                                      backgroundColor: Colors.grey[400],
                                      fontSize: 20,
                                      letterSpacing: 5),
                                  //labelText: "Enter Amount",
                                  hintText: "Enter Amount",
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: Colors.green,
                                          style: BorderStyle.solid))),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.all(20.0),
                              child: TextFormField(
                                autofocus: false,
                                decoration: InputDecoration(
                                    labelText: "Reference",
                                    hintText: "Reference",
                                    labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.green,
                                            style: BorderStyle.solid))),
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ButtonTheme(
                    //elevation: 4,
                    //color: Colors.green,
                    minWidth: double.infinity,
                    child: MaterialButton(
                      elevation: 4.0,
                      onPressed: () {
                        Navigator.of(context).pushNamed('/transactions');
                      },
                      textColor: Colors.white,
                      color: Colors.green,
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
              color: Colors.grey[400],
            ),
            title: Text('Home',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group, color: Colors.grey[400]),
            title: Text('Accounts',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: Colors.grey[400]),
            title: Text('Transactions',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.grey[400]),
            title: Text('Settings',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
        ],
      ),
    );
    //
  }
}
