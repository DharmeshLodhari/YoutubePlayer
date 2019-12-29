import 'dart:convert';

import 'package:PayBay/models/user.dart';
import 'package:PayBay/screens/commons.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SendPayment extends StatefulWidget {
  @override
  _SendPaymentState createState() => _SendPaymentState();
}

class _SendPaymentState extends State<SendPayment> {
  Future<Payee> _getPayee() async {
    final String payeeURL =
        "https://api.mockaroo.com/api/3bbfbdf0?count=1&key=b81ba250";
    var response = await http.get(payeeURL);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      Payee _payee = Payee(
          uuid: jsonData['uuid'],
          url: jsonData['url'],
          fullName: jsonData['fullName'],
          userName: jsonData['userName'],
          avatar: jsonData['avatar'],
          qrCode:
              'https://cdn.britannica.com/s:700x500/17/155017-050-9AC96FC8/Example-QR-code.jpg');
      return _payee;
    } else {
      throw "Can't get https.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(child: Text("Send a Payment")),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder(
        future: _getPayee(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Container(
              child: Text('missing'),
            );
          } else {
            return Center(
              child: SingleChildScrollView(
                child: Container(
                  height: 600,
                  color: Colors.white,
                  padding: EdgeInsets.all(40),
                  child: Center(
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
                                    snapshot.data.fullName,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  subtitle: Text(snapshot.data.userName),
                                  leading: Image.network(
                                    snapshot.data.avatar,
                                    colorBlendMode: BlendMode.darken,
                                    fit: BoxFit.fitWidth,
                                    filterQuality: FilterQuality.high,
                                  ),
                                  trailing: Image.network(
                                    snapshot.data.qrCode,
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
                                  child: TextField(
                                    autofocus: false,
                                    obscureText: false,
                                    keyboardType: TextInputType.number,
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
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4)),
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.green,
                                                style: BorderStyle.solid))),
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: TextField(
                                      autofocus: false,
                                      obscureText: false,
                                      //keyboardType: TextInputType.phone,
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
            );
          }
        },
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
