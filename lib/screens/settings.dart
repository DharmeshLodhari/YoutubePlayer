import 'package:flutter/material.dart';


class SettingsTile extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
            title: Text("Abiola Rasheed",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15
              ),
            ),
            subtitle: Text("abiola.rasheed"),
            leading: Image.network(
              'https://avatars3.githubusercontent.com/u/2910568?s=460&v=4',
              height: 45,
              width: 45,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.high,
            ),
            trailing: FlatButton(
              child: Icon(Icons.mode_edit, color: Colors.grey[400]),
              onPressed: () {

              },
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Settings'),
      ),
      body: Center(
        child: Container(
          color: Colors.grey,
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
                    onPressed: () => {},
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
    );
  }
}

