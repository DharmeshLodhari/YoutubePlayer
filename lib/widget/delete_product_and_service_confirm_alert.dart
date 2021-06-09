import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
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
        content:
            Text(AppLocalization.of(context).areYouSureWantToDeleteThisItem,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                )),
        actions: <Widget>[
          FlatButton(
              child: Text(AppLocalization.of(context).yes),
              color: blackFont,
              onPressed: () {
                Navigator.pop(context, true);
              }),
          FlatButton(
            child: Text(AppLocalization.of(context).cancel),
            color: blackFont,
            onPressed: () {
              Navigator.pop(context, false);
            },
          )
        ],
      ),
    );
  }
}
