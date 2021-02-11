import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';

class MessageSoundPlayer {
  String message;
  UserBloc userBloc;

  String messageIncomingSound = "assets/sounds/message_incoming.mp3";
  String messageOutgoingSound = "assets/sounds/message_delivered.mp3";

  MessageSoundPlayer({@required this.message, @required this.userBloc});

  void playSound() {
    String sound = determineSoundType();
    if (sound != null) {
      debugPrint("sound :- $sound");
      AssetsAudioPlayer.playAndForget(Audio(sound), respectSilentMode: true);
    }
  }

  String determineSoundType() {
    Map<String, dynamic> messageData = jsonDecode(message);

    if (messageData["type"] == "chatroom_message") {
      if (messageData["author"] == userBloc.user.userName) {
        debugPrint("messageData['delivered']  ${messageData["delivered"]} ");
        if (messageData["delivered"] == true) {
          return messageOutgoingSound;
        }
        return null;
      } else {
        return messageIncomingSound;
      }
    }

    return null;
  }
}
