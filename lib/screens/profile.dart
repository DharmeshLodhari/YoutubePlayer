import 'package:PayBay/screens/commons.dart';
import 'package:flutter/material.dart';


class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Center(child: Text("Home")),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: 600,
            color: Colors.white,
            padding: EdgeInsets.all(30),
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
                          Container(
                            padding: EdgeInsets.all(40),
                            child: Image.network('https://cdn.britannica.com/s:700x500/17/155017-050-9AC96FC8/Example-QR-code.jpg',
                              colorBlendMode: BlendMode.darken,
                              fit: BoxFit.fitWidth,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                  ButtonBar(
                    children: <Widget>[

                      FlatButton(onPressed: (){},
                          child: Text('Ngozi Obi', style: TextStyle(color: Colors.black, fontSize: 14))
                      ),

                      FlatButton.icon(onPressed: (){},
                          icon: Icon(Icons.settings, color: Colors.black),
                          label: Text('Copy Url', style: TextStyle(color: Colors.black, fontSize: 14))),
                    ],
                  ),
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
                      child: Text("Make a Payment"),
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
