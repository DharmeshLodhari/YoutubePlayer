import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:provider/provider.dart';

///For playing every kind of notification sound
class MessageSoundPlayer {
  String? message;

  String messageIncomingSound = "assets/sounds/message_incoming.mp3";
  String messageOutgoingSound = "assets/sounds/message_delivered.mp3";
  String nudgeUserSound = "assets/sounds/ping.mp3";

  MessageSoundPlayer({required this.message});

  // ignore: missing_return
  String? playSound() {
    Map<String, dynamic> messageData = jsonDecode(message!);
    String? sound = determineSoundType(messageData: messageData);
    if (sound != null) {
      if (messageData["type"] == "chatroom_message") {
        AssetsAudioPlayer.playAndForget(
          Audio(
            sound,
          ),
          respectSilentMode: true,
        );
      } else if (messageData["type"] == "nudge_user") {
        AssetsAudioPlayer _audioPlayer = AssetsAudioPlayer.withId(
          messageData["author"],
        );

        _audioPlayer.open(Audio(sound),
            autoStart: true,
            respectSilentMode: true,
            loopMode: LoopMode.single);
        return messageData["author"];
      }
    }
    return null;
  }

  String? determineSoundType({required Map<String, dynamic> messageData}) {
    if (messageData["type"] == "chatroom_message") {
      UserBloc userBloc = Provider.of<UserBloc>(
          myGlobals.scaffoldKey.currentContext!,
          listen: false);

      if (messageData["author"] == userBloc.user.userName) {
        if (messageData["delivered"] == true) {
          if (userBloc.chatMessageSettings.playOutgoingMessageSound!) {
            return messageOutgoingSound;
          }
          return null;
        }
        return null;
      } else {
        if (userBloc.chatMessageSettings.playIncomingMessageSound!) {
          return messageIncomingSound;
        }
        return null;
      }
    } else if (messageData["type"] == "nudge_user") {
      return nudgeUserSound;
    }

    return null;
  }
}
