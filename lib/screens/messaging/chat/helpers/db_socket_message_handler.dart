import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/screens/messaging/chat/models/models_for_db/SocketQueueChatMessage.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:provider/provider.dart';

/// For performing the db operation related to socket queue messages
class DBSocketMessageHandler {
  final DatabaseHelper _db = DatabaseHelper();

  void saveMessageToDb({required SocketQueueChatMessage message}) async {
    await _db.saveSocketQueueChatMessage(message: message);
    final List<SocketQueueChatMessage> socketQueueChatMessage =
        await getSocketQueueChatMessage();
    // debugPrint(
    //     "Length of Pending Messages 1 :- ${socketQueueChatMessage.length}");
  }

  Future<List<SocketQueueChatMessage>> getSocketQueueChatMessage() async {
    return await _db.getSocketQueueChatMessages();
  }

  void deleteSocketQueueChatMessage(
      {required SocketQueueChatMessage message}) async {
    await _db.deleteSocketQueueChatMessage(message: message);

    final List<SocketQueueChatMessage> socketQueueChatMessage =
        await getSocketQueueChatMessage();
    // debugPrint(
    //     "Length of Pending Messages 2 :- ${socketQueueChatMessage.length}");
  }

  void deleteSocketQueueForSpecificConversation(
      {String? conversationId}) async {
    final MainSocketProvider mainSocketProvider =
        Provider.of<MainSocketProvider>(myGlobals.navigationKey.currentContext!,
            listen: false);
    mainSocketProvider.deleteQueueMessagesForSpecificConversation(
        conversationId: conversationId);
    await _db.deleteSocketQueueForSpecificConversation(
        conversationId: conversationId);
  }

  Future<int> clearSocketQueueChatMessage() async {
    return await _db.clearSocketQueueChatMessage();
  }
}
