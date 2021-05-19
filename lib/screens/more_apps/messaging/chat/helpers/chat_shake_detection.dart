import 'dart:async';
import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shake/shake.dart';
import 'package:sizer/sizer.dart';
import 'package:uuid/uuid.dart';

class ChatShakeDetection extends ChangeNotifier {
  /// variables for shaking detection and nudge
  ShakeDetector _detector;
  bool _showShakingAlert = false;
  Timer _nudgeAlertTimer;
  Duration _nudgeAlertDuration = Duration(seconds: 11);
  ChatConversation _recipientUser;
  UserBloc _userBloc;

  void setupShakeDetector({@required ChatConversation recipientUser}) {
    debugPrint("Setting up shake detection for ${recipientUser.userName}");
    _recipientUser = recipientUser;
    _userBloc = Provider.of<UserBloc>(myGlobals.scaffoldKey.currentContext,
        listen: false);
    _detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        // debugPrint("Shake Detected:- ${detector.mShakeCount}");
        if (_detector.mShakeCount == 5) {
          ///send Nudge to Recipient
          _nudgeRecipient();
        }
      },
      shakeSlopTimeMS: Platform.isIOS ? 500 : 150,
      shakeCountResetTime: 1000,
      shakeThresholdGravity: Platform.isIOS ? 2 : 1.5,
    );
  }

  void stopAlertDialog() {
    if (_showShakingAlert == true) {
      Navigator.of(myGlobals.scaffoldKey.currentContext).pop();
      _showShakingAlert = false;
      notifyListeners();
      _resetShakeDetector();
    }
  }

  void _resetShakeDetector() {
    _detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        // debugPrint("Shake Detected:- ${detector.mShakeCount}");
        if (_detector.mShakeCount == 5) {
          ///send Nudge to Recipient
          _nudgeRecipient();
        }
      },
      shakeSlopTimeMS: Platform.isIOS ? 500 : 150,
      shakeCountResetTime: 1000,
      shakeThresholdGravity: Platform.isIOS ? 2 : 1.5,
    );
  }

  /// To stop shake detection when user left chat
  void stopShakeDetector() {
    if (_recipientUser != null) {
      debugPrint("Stopping shake detection for ${_recipientUser.userName}");

      /// if nudge timer is already in action we stop it
      if (_nudgeAlertTimer?.isActive ?? false) {
        _nudgeAlertTimer.cancel();
      }

      _detector?.stopListening();

      _recipientUser = null;
    } else {
      /// if nudge timer is already in action we stop it
      if (_nudgeAlertTimer?.isActive ?? false) {
        _nudgeAlertTimer.cancel();
      }

      _detector?.stopListening();

      _recipientUser = null;
    }
  }

  void showShakingDialog() async {
    // debugPrint("showShake $_showShakingAlert");
    if (_showShakingAlert) {
      _showShakingAlert = false;
      notifyListeners();
    } else {
      _showShakingAlert = true;
      // debugPrint("showShake $_showShakingAlert");
      _detector.stopListening();
      notifyListeners();

      /// if nudge timer is already in action we stop it
      if (_nudgeAlertTimer?.isActive ?? false) {
        _nudgeAlertTimer.cancel();
      }

      _nudgeAlertTimer = Timer(_nudgeAlertDuration, () {
        Navigator.of(myGlobals.scaffoldKey.currentContext).pop();
        _showShakingAlert = false;
        notifyListeners();
        _resetShakeDetector();
      });

      await Future.delayed(Duration(milliseconds: 1500));

      String result = await showDialog<String>(
          context: myGlobals.scaffoldKey.currentContext,
          barrierColor: Colors.black38,
          builder: (context) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.0.w),
                          height: 30.0.h,
                          width: double.infinity,
                          color: Colors.white,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 8.0,
                                ),
                              ),
                              CircularLoadingIndicator(),
                              Expanded(
                                child: SizedBox(
                                  height: 8.0,
                                ),
                              ),
                              Text("Nudging...",
                                  style: TextStyle(
                                    inherit: false,
                                    fontSize: 18.0,
                                    color: blackFont,
                                    fontWeight: FontWeight.w500,
                                  )),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 8.0,
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  color: mateRed,
                                  child: IconButton(
                                    icon: Icon(
                                      SlydoAppIcon.remove,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop("STOP");
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 8.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ));

      if (_nudgeAlertTimer?.isActive ?? false) {
        _nudgeAlertTimer.cancel();
      }
      // debugPrint("result $result");
      if (result != null) {
        if (result == "STOP") {
          _stopNudge();
          _showShakingAlert = false;
          _resetShakeDetector();
        }
      }
    }
  }

  void _nudgeRecipient() {
    if (_recipientUser == null) return null;

    Map<String, dynamic> data = {
      "check_id": Uuid().v4(),
      "conversation_id": _recipientUser.conversationId,
      "author": _userBloc.user.userName,
      "author_avatar": _userBloc.user.avatar,
      "recipient": _recipientUser.userName,
      "created_at": DateTime.now().toUtc().toString(),
      "type": "nudge_user",
    };
    sendDataToSocket(data);
  }

  void _stopNudge() {
    if (_recipientUser == null) return null;

    Map<String, dynamic> data = {
      "check_id": Uuid().v4(),
      "conversation_id": _recipientUser.conversationId,
      "author": _userBloc.user.userName,
      "author_avatar": _userBloc.user.avatar,
      "recipient": _recipientUser.userName,
      "created_at": DateTime.now().toUtc().toString(),
      "type": "stop_nudging",
    };
    sendDataToSocket(data);
  }
}
