import 'dart:async';
import 'dart:convert';

import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_shake_detection.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/MainSocketMessageModel.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';

import 'message_sound_player.dart';

class MainSocketMessageHandler {
  final String message;

  static List<String> _nudgingUsers = [];

  static List<String> _audioPlayers = [];

  static List<String> _hashedNudgingMessages = [];

  static Timer _nudgeAlertTimer;
  // static Duration nudgeAlertDuration = Duration(seconds: 15);
  static Duration nudgeAlertDuration = Duration(seconds: 10);

  MainSocketMessageHandler({this.message}) {
    if (message != null) {
      handleMessageAccordingToType();
    }
  }

  ///generate hash of the message
  String generateHashedMessage(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  ///Handle message according to message type
  void handleMessageAccordingToType() {
    Map<String, dynamic> messageData = jsonDecode(message);

    if (messageData["type"] == "chatroom_message") {
      /// checking if the recipient is in the current chat screen then we will not update message count
      if (messageData.containsKey("conversation") ||
          messageData.containsKey("conversation_id")) {
        MainSocketProvider mainSocketProvider = Provider.of<MainSocketProvider>(
            myGlobals.scaffoldKey.currentContext,
            listen: false);
        if (mainSocketProvider.currentConversationId !=
            (messageData.containsKey("conversation")
                ? messageData["conversation"]
                : messageData.containsKey("conversation_id"))) {
          saveAndUpdateUserMessageCount(messageData: messageData);
        }
      }
    } else if (messageData["type"] == "nudge_user") {
      showNudgeAlertToUser(messageData: messageData);
    } else if (messageData["type"] == "stop_nudging") {
      stopNudgeAlertToUser(messageData: messageData);
    }
  }

  void saveAndUpdateUserMessageCount({Map<String, dynamic> messageData}) {
    MainSocketMessageModel messageModel =
        MainSocketMessageModel.fromJson(jsonDecode(message));

    String hashedMessage = generateHashedMessage(message);
    debugPrint("Message>>>>> $message");

    ChatUserManager().addUser(
        conversationId:
            messageData["conversation"] ?? messageData["conversation_id"]);

    ChatUserManager().updateChatUserMessageCount(
        conversationId: messageModel.conversation,
        hashedMessage: hashedMessage);
  }

  void showNudgeAlertToUser({Map<String, dynamic> messageData}) async {
    String hashTheMessage = generateHashedMessage(message);

    /// if This message is already in the list we will return
    if (_hashedNudgingMessages.contains(hashTheMessage)) {
      return;
    }
    _hashedNudgingMessages.add(hashTheMessage);

    ///{check_id: ae13214e-de96-49e5-95b3-5642fadbeb5c,
    /// conversation_id: 3fe1e3b6-5802-4ade-b4f3-8f21d7b8ebd7,
    /// author: black,
    /// recipient: abiola.rasheed.2,
    /// created_at: 2021-02-12 09:06:36.417618Z,
    /// type: nudge_user,
    /// username: black}

    UserBloc userBloc = Provider.of<UserBloc>(
        myGlobals.scaffoldKey.currentContext,
        listen: false);

    /// if current user is not author of the nudge then we play nudge sound
    if (userBloc.user.userName != messageData["author"]) {
      MainSocketProvider mainSocketProvider = Provider.of<MainSocketProvider>(
          myGlobals.scaffoldKey.currentContext,
          listen: false);

      /// if user is on the chat screen of the user who is nudging then we will not play sound
      if (mainSocketProvider.currentConversationId !=
          messageData["conversation_id"]) {
        debugPrint("author ${messageData["author"]}");

        /// if nudge alert is Already open then we will not open second nudge alert
        debugPrint(
            "nudgingUsers.contains(messageData['author'])  ${_nudgingUsers.contains(messageData["author"])}");
        if (!_nudgingUsers.contains(messageData["author"])) {
          CustomerProfile customerProfile =
              await UserAuth().fetchContactProfile(messageData["author"]);

          if (customerProfile == null) {
            return;
          }

          _nudgingUsers.add(messageData["author"]);
          String audioPlayerId =
              MessageSoundPlayer(message: message).playSound();
          _audioPlayers.add(audioPlayerId);

          if (_nudgeAlertTimer?.isActive ?? false) {
            _nudgeAlertTimer.cancel();
          }

          /// dispose the audio player if user not press anything
          _nudgeAlertTimer = Timer(nudgeAlertDuration, () {
            _nudgingUsers.remove(messageData["author"]);

            Navigator.of(myGlobals.scaffoldKey.currentContext).pop();

            /// dispose the audio player
            AssetsAudioPlayer.withId(audioPlayerId)?.dispose();
          });

          bool result = await showDialogBoxWithImageForNudge(
            context: myGlobals.scaffoldKey.currentContext,
            iconBgColor: mateRed,
            iconColor: Colors.white,
            iconTwoBgColor: navyBlue,
            iconTwoColor: Colors.white,
            firstActionPrimary: false,
            title: "${customerProfile.fullName}",
            description: "${customerProfile.userName} is nudging you",
            image: customerProfile.avatar,
            actionOneIcon: SlydoAppIcon.remove,
            actionTwoIcon: SlydoAppIcon.text_message,
          );

          _nudgingUsers.remove(messageData["author"]);

          /// dispose the audio player
          AssetsAudioPlayer.withId(audioPlayerId)?.dispose();

          /// stop timer when get any action from the user
          if (_nudgeAlertTimer?.isActive ?? false) {
            _nudgeAlertTimer.cancel();
          }

          if (result != null) {
            debugPrint("result>>>>> $result");
            if (result) {
              /// send Nudge acknowledgement to author that recipient have accepted that nudge and online now
              sendNudgeAcknowledgement(
                  currentUser: userBloc,
                  author: customerProfile,
                  type: "Accepted");

              Navigator.of(myGlobals.scaffoldKey.currentContext)
                  .popUntil(ModalRoute.withName('/dashboard'));

              Navigator.pushNamed(
                  myGlobals.scaffoldKey.currentContext, '/chat-screen',
                  arguments: {"searchedUser": customerProfile});
            } else {
              debugPrint("else executed");

              /// send Nudge acknowledgement to author that recipient have canceled that nudge and he is busy
              sendNudgeAcknowledgement(
                  currentUser: userBloc,
                  author: customerProfile,
                  type: "Canceled");
            }
          }
        }
      }
    }
  }

  void sendNudgeAcknowledgement(
      {CustomerProfile author, UserBloc currentUser, String type}) {
    Map<String, dynamic> data = {
      "check_id": Uuid().v4(),
      "conversation_id": author.conversationId,
      "author": currentUser.user.userName,
      "recipient": author.userName,
      "created_at": DateTime.now().toUtc().toString(),
      "acknowledgement_type": type,
      "type": "stop_nudging",
    };
    sendDataToSocket(data);
  }

  Future<bool> sendDataToSocket(Map<String, dynamic> data) async {
    MainSocketProvider mainSocketProvider = Provider.of<MainSocketProvider>(
        myGlobals.scaffoldKey.currentContext,
        listen: false);

    await mainSocketProvider.add(data);

    return true;
  }

  void stopNudgeAlertToUser({Map<String, dynamic> messageData}) {
    String hashTheMessage = generateHashedMessage(message);

    debugPrint("Message dat c>>>>> $messageData");

    /// if This message is already in the list we will return
    if (_hashedNudgingMessages.contains(hashTheMessage)) {
      return;
    }
    _hashedNudgingMessages.add(hashTheMessage);

    UserBloc userBloc = Provider.of<UserBloc>(
        myGlobals.scaffoldKey.currentContext,
        listen: false);

    /// if current user is not author of the nudge then we play nudge sound
    if (userBloc.user.userName != messageData["author"]) {
      /// if nudge alert is Already open then we will not open second nudge alert
      debugPrint(
          "nudgingUsers.contains(messageData['author'])  ${_nudgingUsers.contains(messageData["author"])}");

      debugPrint(
          "nudgingUsers.contains(messageData['recipient'])  ${_nudgingUsers.contains(messageData["recipient"])}");
      if (_nudgingUsers.contains(messageData["author"])) {
        _nudgingUsers.remove(messageData["author"]);

        Navigator.of(myGlobals.scaffoldKey.currentContext).pop();

        /// dispose the audio player
        AssetsAudioPlayer.withId(messageData["author"])?.dispose();
      } else if (messageData.containsKey("acknowledgement_type")) {
        ChatShakeDetection chatShakeDetection = Provider.of<ChatShakeDetection>(
            myGlobals.scaffoldKey.currentContext,
            listen: false);
        chatShakeDetection.stopAlertDialog();

        Toast.show(
            "${messageData["author"]} has ${messageData["acknowledgement_type"]} your Nudge !!",
            myGlobals.scaffoldKey.currentContext,
            textColor: Colors.white,
            duration: 3);
      }
    }
  }

  void dispose() {
    _audioPlayers.forEach((element) {
      AssetsAudioPlayer.withId(element)?.dispose();
    });

    _audioPlayers.clear();
    _nudgingUsers.clear();
    _hashedNudgingMessages.clear();
  }
}
