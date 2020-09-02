import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:provider/provider.dart';

class PassCodePopup {
  BuildContext context;
  GestureTapCallback isValidCallback;
  GestureTapCallback cancelCallBack;
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  UserBloc userBloc;

  PassCodePopup(
      {@required this.context,
      @required this.isValidCallback,
      this.cancelCallBack}) {
    userBloc = Provider.of<UserBloc>(context, listen: false);

    showDialog(
        context: context,
        builder: (context) => Column(
              children: <Widget>[
                Expanded(
                  child: PasscodeScreen(
                    title: Text(
                      AppLocalization.of(context).enterPassCode,
                      style: TextStyle(color: Colors.white),
                    ),
                    passwordEnteredCallback: _onPassCodeEntered,
                    cancelButton: Container(
                      padding: EdgeInsets.all(0),
                      child: Text(
                        AppLocalization.of(context).cancel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    deleteButton: Container(
                      padding: EdgeInsets.all(0),
                      child: Text(
                        AppLocalization.of(context).delete,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    shouldTriggerVerification: _verificationNotifier.stream,
                    passwordDigits: 6,
                    isValidCallback: isValidCallback,
                    cancelCallback: cancelCallBack,
                    keyboardUIConfig:
                        KeyboardUIConfig(keyboardRowMargin: EdgeInsets.all(8)),
                  ),
                ),
              ],
            ));
  }

  _onPassCodeEntered(String enteredPassCode) {
    bool isValid = userBloc.user.password == enteredPassCode;
    _verificationNotifier.add(isValid);
  }
}
