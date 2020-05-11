import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:provider/provider.dart';

class PasscodePopup {
  BuildContext context;
  GestureTapCallback isValidCallback;
  GestureTapCallback cancelCallBack;
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  UserBloc userBloc;

  PasscodePopup(
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
                    passwordEnteredCallback: _onPasscodeEntered,
                    cancelButton: FlatButton(
                      child: Text(
                        AppLocalization.of(context).cancel,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    deleteButton: FlatButton(
                      child: Text(
                        AppLocalization.of(context).delete,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    shouldTriggerVerification: _verificationNotifier.stream,
                    passwordDigits: 4,
                    isValidCallback: isValidCallback,
                    cancelCallback: cancelCallBack,
                    keyboardUIConfig:
                        KeyboardUIConfig(deleteButtonMargin: EdgeInsets.all(8)),
                  ),
                ),
              ],
            ));
  }

  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = userBloc.user.password == enteredPasscode;
    _verificationNotifier.add(isValid);
  }
}
