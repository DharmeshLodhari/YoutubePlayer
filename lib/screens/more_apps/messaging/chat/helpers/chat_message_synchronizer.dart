import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ChatMessageSynchronizer {
  static final ChatMessageSynchronizer _chatMessageSynchronizer =
      ChatMessageSynchronizer._internal();

  ChatMessageSynchronizer._internal();

  factory ChatMessageSynchronizer() {
    return _chatMessageSynchronizer;
  }

  static int _count = 0;
  static String _next = "";
  static String _previous = "";

  Future<void> fetch({bool isRefresh = false}) async {
    if (isRefresh) {
      _count = 0;
      _next = "";
      _previous = "";
    }

    MyGlobals myGlobals = MyGlobals();
    BuildContext context = myGlobals.navigationKey.currentContext;

    ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(context, listen: false);
    if (_next != null) {
      Map<String, dynamic> result = await UserAuth().contacts(_next, _previous);
      _count = result['count'];
      _next = result['next'];
      _previous = result['previous'];

      List tempList = result['results'];

      // debugPrint("List:- $tempList");

      List<ChatConversation> users = List<ChatConversation>();

      tempList
          .forEach((element) => users.add(ChatConversation.fromJson(element)));

      connectionListBloc.setConnectionUsers(users: users);

      if (_next != null) {
        fetch();
      }
      return Future.value();
    }
  }

  void update() async {
    UserBloc userBloc = Provider.of<UserBloc>(
        MyGlobals().navigationKey.currentContext,
        listen: false);
    String author = userBloc.user.userName;
    List<ChatMessage> chatMessages =
        await ChatMessageHandler().getLastChatMessage(author: author);

    if (chatMessages == null) return;

    // Map<String, dynamic> resultData =
    //     await MessageAuth().fetchMissedMessages(chatMessages: chatMessages);
    //
    // List connectionList = resultData['results'];
    //
    // List<ChatMessage> messageList = List<ChatMessage>();
    // if (connectionList.isNotEmpty) {
    //   connectionList.forEach((element) {
    //     String conversationId = element.keys.first;
    //
    //     List messages = element[conversationId];
    //
    //     messages.forEach((message) {
    //       ChatMessage chatMessage = ChatMessage.fromJson(message);
    //       messageList.add(chatMessage);
    //     });
    //   });
    // }
    //
    // if (messageList.isNotEmpty) {
    //   ChatMessageHandler().insertMissedChatMessage(messages: messageList);
    // }
  }
}
