import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/user.dart';
import 'package:Slydo/screens/colors.dart';
import 'package:Slydo/screens/dashboard.dart';
import 'package:Slydo/screens/tiles/settings_tiles.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SettingsList extends StatefulWidget {
  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  final _auth = AuthService();
  Dashboard dashboard = Dashboard();

  void _pickImage() async {
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);
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
        try {
          _auth.updateCustomerAvatar(file);
          User _user = await _auth.getUser();
          _auth.authenticate(_user.phoneNumber, _user.password);
          userBloc.user = _user;
        } catch (err) {
          print('Caught error: $err');
        }
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
      ),
    );
  }
}
