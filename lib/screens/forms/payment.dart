

//user image
// user full_name
// user qr code
// number input for money
// text input for  reference
// payment button


import 'package:PayBay/screens/commons.dart';
import 'package:flutter/material.dart';


class SendPayment extends StatefulWidget {
  @override
  _SendPaymentState createState() => _SendPaymentState();
}

class _SendPaymentState extends State<SendPayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(child: Text("Send a Payment")),
        backgroundColor: Colors.green,
      ),
      body: Center(
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
                           title: Text("Abiola Rasheed",
                           style: TextStyle(
                               color: Colors.black,
                               fontWeight: FontWeight.bold,
                               fontSize: 15
                           ),
                           ),
                           subtitle: Text("abiola.rasheed"),
                           leading: Image.network('https://avatars3.githubusercontent.com/u/2910568?s=460&v=4',
                             colorBlendMode: BlendMode.darken,
                             fit: BoxFit.fitWidth,
                             filterQuality: FilterQuality.high,
                           ),
                           trailing: Image.network('https://cdn.britannica.com/s:700x500/17/155017-050-9AC96FC8/Example-QR-code.jpg',
                             colorBlendMode: BlendMode.darken,
                             fit: BoxFit.fitWidth,
                             filterQuality: FilterQuality.high,
                           ),
                         ),


                          SizedBox(
                            height: 20,
                          ),

                          Padding(padding: EdgeInsets.all(20.0),
                            child: TextField(
                              autofocus: false,
                              obscureText: false,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  prefixText: '#',
                                  prefixStyle: TextStyle(color: Colors.green,
                                      backgroundColor: Colors.grey[400],
                                      fontSize: 20, letterSpacing: 5),
                                  //labelText: "Enter Amount",
                                  hintText: "Enter Amount",
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                      borderSide: BorderSide(
                                          width: 1,
                                          color: Colors.green,
                                          style: BorderStyle.solid))),
                            ),
                          ),

                          Padding(padding: EdgeInsets.all(20.0),
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
                                      borderRadius: BorderRadius.all(Radius.circular(4)),
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
                      onPressed: () => {},
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


      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
