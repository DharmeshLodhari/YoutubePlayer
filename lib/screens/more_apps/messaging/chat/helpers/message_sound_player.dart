import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class MessageSoundPlayer {
  String message;

  String messageIncomingSound = "assets/sounds/message_incoming.mp3";
  String messageOutgoingSound = "assets/sounds/message_delivered.mp3";
  String nudgeUserSound = "assets/sounds/ping.mp3";

  MessageSoundPlayer({@required this.message});

  // ignore: missing_return
  String playSound() {
    Map<String, dynamic> messageData = jsonDecode(message);
    String sound = determineSoundType(messageData: messageData);
    if (sound != null) {
      // debugPrint("sound :- $sound");

      if (messageData["type"] == "chatroom_message") {
        AssetsAudioPlayer.playAndForget(Audio(sound), respectSilentMode: true);
      } else if (messageData["type"] == "nudge_user") {
        AssetsAudioPlayer _audioPlayer =
            AssetsAudioPlayer.withId(messageData["check_id"]);

        _audioPlayer.open(Audio(sound),
            autoStart: true,
            respectSilentMode: true,
            loopMode: LoopMode.single);
        return messageData["check_id"];
      }
    }
  }

  String determineSoundType({Map<String, dynamic> messageData}) {
    if (messageData["type"] == "chatroom_message") {
      UserBloc userBloc = Provider.of<UserBloc>(
          myGlobals.scaffoldKey.currentContext,
          listen: false);

      if (messageData["author"] == userBloc.user.userName) {
        if (messageData["delivered"] == true) {
          return messageOutgoingSound;
        }
        return null;
      } else {
        return messageIncomingSound;
      }
    } else if (messageData["type"] == "nudge_user") {
      return nudgeUserSound;
    }

    return null;
  }
}
