import 'package:flutter/material.dart';

class BankAccountTile extends StatelessWidget {

  // Pass account object into this constructor
  //BankAccountTile({ this.account });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
            title: Text("GTBank Nigeria Ltd",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15
              ),
            ),
            subtitle: Text("******8989"),
            leading: Image.network(
              'https://store-images.s-microsoft.com/image/apps.18247.9007199266509880.c1dffb67-bdcd-4c95-af2a-5eb59d7cc14a.333f1c59-150f-4b46-bbdf-dd81a1ab9b80?mode=scale&q=90&h=300&w=300',
              height: 45,
              width: 45,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.high,
            ),
            trailing: FlatButton(
              child: Icon(Icons.settings, color: Colors.grey[400]),
              onPressed: () {

              },
            ),
        ),
      ),
    );
  }
}