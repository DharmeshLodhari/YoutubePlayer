import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatTextMessage.dart';
import 'package:flutter/material.dart';

class DBSocketMessageHandler {
  DatabaseHelper _db = DatabaseHelper();

  void saveMessageToDb({ChatTextMessage message}) {
    _db.saveChatTextMessage(message: message);
    getChatTextMessage();
  }

  void getChatTextMessage() async {
    await _db.getChatTextMessages().then((value) {
      debugPrint(" length ${value.length}");
      value.forEach((element) {
        debugPrint(
            " ===> ${element.checkId} ${element.kind} ${element.message}");
      });
    });
  }

  void deleteChatTextMessage({ChatTextMessage message}) {
    debugPrint("<===> ${message.checkId} ${message.kind} ${message.message}");
  }
}
