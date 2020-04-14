import 'package:Slydo/screens/colors.dart';
import 'package:flutter/material.dart';

class ConfirmDelete extends StatelessWidget {
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, false);
        return false;
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        content: Text('Are you sure want to delete this item ?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            )),
        actions: <Widget>[
          FlatButton(
              child: const Text('Yes'),
              color: darkBlue(),
              onPressed: () {
                Navigator.pop(context, true);
              }),
          FlatButton(
            child: const Text('Cancel'),
            color: darkBlue(),
            onPressed: () {
              Navigator.pop(context, false);
            },
          )
        ],
      ),
    );
  }
}
