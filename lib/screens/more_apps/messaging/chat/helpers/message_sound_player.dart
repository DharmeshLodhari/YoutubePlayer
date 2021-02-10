import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';

class MessageSoundPlayer {
  String message;
  UserBloc userBloc;

  String textIncomingSound = "assets/sounds/whatsapp_incoming.mp3";
  String textOutgoingSound = "assets/sounds/whatsapp_web.mp3";
  String audioIncomingSound = "assets/sounds/whatsapp_incoming.mp3";
  String audioOutgoingSound = "assets/sounds/whatsapp_web.mp3";
  String videoIncomingSound = "assets/sounds/whatsapp_incoming.mp3";
  String videoOutgoingSound = "assets/sounds/whatsapp_web.mp3";
  String imageIncomingSound = "assets/sounds/whatsapp_incoming.mp3";
  String imageOutgoingSound = "assets/sounds/whatsapp_web.mp3";
  String paymentRequestIncomingSound = "assets/sounds/whatsapp_incoming.mp3";
  String paymentRequestOutgoingSound = "assets/sounds/whatsapp_web.mp3";
  String transactionIncomingSound = "assets/sounds/whatsapp_incoming.mp3";
  String transactionOutgoingSound = "assets/sounds/whatsapp_web.mp3";

  MessageSoundPlayer({@required this.message, @required this.userBloc});

  void playSound() {
    String sound = determineSoundType();
    if (sound != null) {
      AssetsAudioPlayer.playAndForget(Audio(sound), respectSilentMode: true);
    }
  }

  String determineSoundType() {
    Map<String, dynamic> messageData = jsonDecode(message);

    if (messageData["type"] == "chatroom_message") {
      if (messageData["kind"] == "text") {
        if (messageData["author"] == userBloc.user.userName) {
          return textOutgoingSound;
        } else {
          return textIncomingSound;
        }
      } else if (messageData["kind"] == "image") {
        if (messageData["author"] == userBloc.user.userName) {
          return imageOutgoingSound;
        } else {
          return imageIncomingSound;
        }
      } else if (messageData["kind"] == "audio") {
        if (messageData["author"] == userBloc.user.userName) {
          return audioOutgoingSound;
        } else {
          return audioIncomingSound;
        }
      } else if (messageData["kind"] == "video") {
        if (messageData["author"] == userBloc.user.userName) {
          return videoOutgoingSound;
        } else {
          return videoIncomingSound;
        }
      } else if (messageData["kind"] == "payment-request") {
        if (messageData["author"] == userBloc.user.userName) {
          return paymentRequestOutgoingSound;
        } else {
          return paymentRequestIncomingSound;
        }
      } else if (messageData["kind"] == "transaction") {
        if (messageData["author"] == userBloc.user.userName) {
          return transactionOutgoingSound;
        } else {
          return transactionIncomingSound;
        }
      }
    }

    return null;
  }
}
