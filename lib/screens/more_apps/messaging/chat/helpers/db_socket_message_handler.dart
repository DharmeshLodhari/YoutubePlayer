import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatTextMessage.dart';
import 'package:Slydo/utils/common.dart';

class DBSocketMessageHandler {
  DatabaseHelper _db = DatabaseHelper();

  void saveMessageToDb({ChatTextMessage message}) async {
    _db.saveChatTextMessage(message: message);
    await getChatTextMessage();
  }

  void sendPendingQueueMessages() async {
    List<ChatTextMessage> pendingMessages = await getChatTextMessage();

    pendingMessages.forEach((element) {
      sendDataToSocket(element.toJson(isForSendingToSocket: true));
    });
  }

  Future<List<ChatTextMessage>> getChatTextMessage() async {
    return await _db.getChatTextMessages();
  }

  void deleteChatTextMessage({ChatTextMessage message}) {
    sendPendingQueueMessages();
    // _db.deleteChatTextMessage(message: message);
  }

  void clearChatTextMessage() {
    _db.clearChatTextMessage();
    getChatTextMessage();
  }
}
