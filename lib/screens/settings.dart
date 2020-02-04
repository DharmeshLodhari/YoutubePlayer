import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/dashboard.dart';
import 'package:Slydo/screens/tiles/settings_tiles.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingsList extends StatefulWidget {
  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  int _currentIndex = 3;
  final _auth = AuthService();
  Dashboard dashboard = Dashboard();

  void _pickImage() async {
    final imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Select the image source"),
              actions: <Widget>[
                MaterialButton(
                  child: Text("Camera"),
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                ),
                MaterialButton(
                  child: Text("Gallery"),
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                )
              ],
            ));

    if (imageSource != null) {
      final file = await ImagePicker.pickImage(source: imageSource);
      if (file != null) {
        _auth.updateCustomerAvatar(file);
      }
    }
  }

  Widget logOutButton() {
    return ButtonTheme(
      minWidth: double.infinity,
      child: MaterialButton(
        onPressed: () async {
          await _auth.logOut();
          Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
        },
        textColor: Colors.white,
        color: darkBlue(),
        height: 50,
        child: Text("Logout"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/dashboard');
        return false;
      },
      child: Scaffold(
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkBlue(),
          title: Text('Settings'),
        ),
        body: Center(
          child: Container(
            color: lightBlue(),
            padding: EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  SettingsTile(pickImage: _pickImage),
                  SizedBox(height: 20),
                  logOutButton(),
                ],
              ),
            ),
          ),
        ),

// TODO: Find a better way to do this without duplication
//      bottomNavigationBar: BottomNavigationBar(
//        elevation: 0.0,
//        currentIndex: _currentIndex,
//        onTap: (index) {
//          setState(() {
//            _currentIndex = index;
//          });
//
//          String path = _currentIndex.toString();
//
//          switch (path) {
//            case '0':
//              return Navigator.of(context).pushNamed('/profile');
//            case '1':
//              return Navigator.of(context).pushNamed('/accounts');
//            case '2':
//              return Navigator.of(context).pushNamed('/transactions');
//            case '3':
//              return Navigator.of(context).pushNamed('/settings');
//            default:
//              // If there is no such named route in the switch statement, e.g. /third
//              return Navigator.of(context).pushNamed('/profile');
//          }
//        },
//        items: [
//          BottomNavigationBarItem(
//            icon: Icon(
//              Icons.home,
//              color: Colors.white,
//            ),
//            title: Text('Home',
//                style: TextStyle(color: Colors.white, fontSize: 12)),
//          ),
//          BottomNavigationBarItem(
//            icon: Icon(Icons.group, color: Colors.white),
//            title: Text('Accounts',
//                style: TextStyle(color: Colors.white, fontSize: 12)),
//          ),
//          BottomNavigationBarItem(
//            icon: Icon(Icons.shopping_cart, color: Colors.white),
//            title: Text('Transactions',
//                style: TextStyle(color: Colors.white, fontSize: 12)),
//          ),
//          BottomNavigationBarItem(
//            backgroundColor: lightBlue(),
//            icon: Icon(Icons.settings, color: Colors.white),
//            title: Text('Settings',
//                style: TextStyle(color: Colors.white, fontSize: 12)),
//          ),
//        ],
//      ),
      ),
    );
  }
}
