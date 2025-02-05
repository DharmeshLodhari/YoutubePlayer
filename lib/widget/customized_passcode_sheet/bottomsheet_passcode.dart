import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/customized_passcode_sheet/passcode_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomSheetPassCode {
  BuildContext context;
  GestureTapCallback isValidCallback;
  GestureTapCallback? cancelCallBack;
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  late UserBloc userBloc;

  BottomSheetPassCode(
      {required this.context,
      required this.isValidCallback,
      this.cancelCallBack}) {
    userBloc = Provider.of<UserBloc>(context, listen: false);

    showModalBottomSheet(
        elevation: 2,
        backgroundColor: Colors.white,
        // ignore: prefer_const_constructors
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.hardEdge,
        context: context,
        builder: (context) => SizedBox(
              height: 375,
              child: CustomizedPassCodeScreen(
                title: Text(
                  AppLocalization.of(context)!.enterPassCode,
                  style: TextStyle(
                    color: blackFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                passwordEnteredCallback: _onPassCodeEntered,
                cancelButton: Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height > 600 ? 0 : 16,
                      right: MediaQuery.of(context).size.width / 6 - 34,
                      bottom:
                          MediaQuery.of(context).size.height > 600 ? 25 : 8),
                  child: Text(
                    AppLocalization.of(context)!.cancel,
                    style: TextStyle(
                      color: HexColor("#8D92A3"),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                deleteButton: Container(
                    padding: EdgeInsets.only(
                        right: (MediaQuery.of(context).size.width / 6) - 24,
                        bottom: 25),
                    child: Icon(
                      Icons.backspace,
                      color: HexColor("#8D92A3"),
                      size: 18,
                    )),
                shouldTriggerVerification: _verificationNotifier.stream,
                passwordDigits: 6,
                isValidCallback: isValidCallback,
                cancelCallback: cancelCallBack,
              ),
            ));
  }

  void _onPassCodeEntered(String enteredPassCode) {
    _verificationNotifier.add(userBloc.user.isValidPassword(enteredPassCode));
  }
}
