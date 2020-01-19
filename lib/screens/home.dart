import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Slydo'),
        backgroundColor: Colors.green,
        elevation: 0.0,
      ),
      body: Center(
        child: Container(
          color: Colors.green,
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: 20),
                Container(
                  child: Image.asset(
                    'assets/images/index.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'An easy way to accept \n and receive payments.',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                SizedBox(height: 20),
                ButtonTheme(
                  minWidth: double.infinity,
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/login');
                    },
                    textColor: Colors.black,
                    color: Colors.white,
                    height: 50,
                    child: Text("Log In"),
                  ),
                ),
                SizedBox(height: 20),
                ButtonTheme(
                  minWidth: double.infinity,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.white, width: 2.0)),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/register');
                    },
                    textColor: Colors.white,
                    color: Colors.green,
                    height: 50,
                    child: Text("Register"),
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
