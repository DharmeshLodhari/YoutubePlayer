import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/main_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ChatMessageSynchronizer {
  static final ChatMessageSynchronizer _chatMessageSynchronizer =
      ChatMessageSynchronizer._internal();

  ChatMessageSynchronizer._internal();

  final _chatMessageCountStream = StreamController<bool>.broadcast();

  Stream<bool> get getChatMessageCountStream => _chatMessageCountStream.stream;

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

  Future<void> update() async {
    List<ChatMessage> chatMessages =
        await ChatMessageHandler().getLastChatMessage();

    MyGlobals myGlobals = MyGlobals();
    BuildContext context = myGlobals.navigationKey.currentContext;

    ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(context, listen: false);

    List<ChatMessage> newConnections = List<ChatMessage>();

    connectionListBloc.connectionUsers.forEach((chatConversation) {
      ChatMessage chatMessage;
      chatMessages.forEach((message) {
        if (message.conversationId == chatConversation.conversationId) {
          chatMessage = message;
        }
      });

      if (chatMessage == null) {
        newConnections.add(ChatMessage(
            text: chatConversation.fullName,
            conversationId: chatConversation.conversationId,
            createdAt: chatConversation.createdAt,
            checkId: null));
      }
    });

    chatMessages.addAll(newConnections);

    newConnections.forEach((element) {
      debugPrint("New Conversation ${element.toJson()}");
    });

    debugPrint(
        "Messages after adding new Conversation:- ${chatMessages.length}");

    if (chatMessages == null) return;

    Map<String, dynamic> resultData = await MessageAuth()
        .fetchMissedMessages(chatMessages: chatMessages)
        .catchError((error) {
      debugPrint("ERROR:- While calling Message Synchronizer $error");
    });

    if (resultData == null) return;
    List connectionList = resultData['results'];

    List<ChatMessage> messageList = List<ChatMessage>();
    if (connectionList.isNotEmpty) {
      connectionList.forEach((element) {
        String conversationId = element.keys.first;

        List messages = element[conversationId];

        messages.forEach((message) {
          ChatMessage chatMessage = ChatMessage.fromJson(message);
          messageList.add(chatMessage);
        });
      });
    }

    if (messageList.isNotEmpty) {
      await ChatMessageHandler().insertMissedChatMessage(messages: messageList);

      messageList.forEach((message) async {
        await MainSocketMessageHandler()
            .saveAndUpdateUserMessageCount(messageData: message.toJson());
        _chatMessageCountStream.sink.add(true);
      });
    }

    return Future.value();
  }
}
