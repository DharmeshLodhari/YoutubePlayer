import 'package:PayBay/data/state_notifier.dart';
import 'package:PayBay/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          title: Text(
            userBloc.user.fullName,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          subtitle: Text(userBloc.user.userName),
          leading: Image.network(
            userBloc.user.avatar,
            height: 45,
            width: 45,
            colorBlendMode: BlendMode.darken,
            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.high,
          ),
          trailing: FlatButton(
            child: Icon(Icons.mode_edit, color: Colors.grey[400]),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

class SettingsList extends StatefulWidget {
  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  int _currentIndex = 3;
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Settings'),
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                SettingsTile(),
                SizedBox(height: 20),
                ButtonTheme(
                  minWidth: double.infinity,
                  child: MaterialButton(
                    onPressed: () async {
                      await _auth.logOut();
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/", (r) => false);
                    },
                    textColor: Colors.black,
                    color: Colors.white,
                    height: 50,
                    child: Text("Log In"),
                  ),
                ),
              ],
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
  }
}
