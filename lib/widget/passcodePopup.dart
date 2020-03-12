import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
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
        builder: (context) => PasscodeScreen(
              title: "Enter Passcode",
              passwordEnteredCallback: _onPasscodeEntered,
              cancelLocalizedText: 'Cancel',
              deleteLocalizedText: 'delete',
              shouldTriggerVerification: _verificationNotifier.stream,
              passwordDigits: 4,
              isValidCallback: isValidCallback,
              cancelCallback: cancelCallBack,
              keyboardUIConfig:
                  KeyboardUIConfig(deleteButtonMargin: EdgeInsets.all(8)),
            ));
  }

  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = userBloc.user.password == enteredPasscode;
    _verificationNotifier.add(isValid);
  }
}
