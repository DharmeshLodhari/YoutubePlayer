import 'package:PayBay/models/user.dart';
import 'package:flutter/material.dart';


class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _currentIndex = 0;

  User _user = User(
    uuid: '16a33e14-36a0-4d9f-9efe-14ca1b0121bc',
    url: 'http://paybay.com/api/v1/customer/abiola.rasheed',
    phoneNumber: '+353877478230',
    fullName: 'Abiola Rasheed',
    userName: 'abiola.rasheed',
    avatar: 'https://randomuser.me/api/portraits/men/83.jpg',
    qrCode: 'https://cdn.britannica.com/s:700x500/17/155017-050-9AC96FC8/Example-QR-code.jpg');

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
                            child: Image.network(
                              _user.qrCode,
                              colorBlendMode: BlendMode.darken,
                              fit: BoxFit.fitWidth,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                  ButtonBar(
                    children: <Widget>[

                      FlatButton(onPressed: (){},
                          child: Text(_user.fullName, style: TextStyle(color: Colors.black, fontSize: 14))
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
                      onPressed: () {
                        Navigator.of(context).pushNamed('/send-payment');
                      },
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
            icon: Icon(Icons.home,
              color: Colors.grey[400],),
            title: Text('Home', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group,
                color: Colors.grey[400]),
            title: Text('Accounts', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart,
                color: Colors.grey[400]
            ),
            title: Text('Transactions', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,
                color: Colors.grey[400]
            ),
            title: Text('Settings', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ),
        ],
      ),


    );
  }
}
