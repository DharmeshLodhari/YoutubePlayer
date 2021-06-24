import 'dart:async';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/main_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessagePagination.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ChatMessageSynchronizer {
  static final ChatMessageSynchronizer _chatMessageSynchronizer =
      ChatMessageSynchronizer._internal();

  ChatMessageSynchronizer._internal();

  StreamController<bool> _chatMessageCountStream =
      StreamController<bool>.broadcast();

  Stream<bool> get getChatMessageCountStream => _chatMessageCountStream.stream;

  StreamController<bool> _chatMessageStream =
      StreamController<bool>.broadcast();

  Stream<bool> get getChatMessageStream => _chatMessageStream.stream;

  factory ChatMessageSynchronizer() {
    return _chatMessageSynchronizer;
  }

  static String _next = "";
  static String _previous = "";

  void setStreamFalse() {
    _chatMessageStream.sink.add(false);
  }

  Future<void> getMessages(
      {ChatConversation chatConversation, bool isFirstTime}) async {
    debugPrint("Fetching previous messages !!");

    ChatMessagePagination chatMessagePagination = await ChatMessageHandler()
        .getChatMessagePagination(
            conversationId: chatConversation.conversationId);

    _next = chatMessagePagination.next;
    _previous = chatMessagePagination.previous;

    if (_next != null) {
      debugPrint(
          "recipient conversationID:- ${chatConversation.conversationId}  ${chatConversation.fullName}");

      Map<String, dynamic> result = await MessageAuth()
          .getChatMessages(_next, _previous,
              conversionId: chatConversation.conversationId)
          .catchError((error) {
        debugPrint("ERROR:- $error");
      });

      if (result == null) return;

      List<String> tempList = result['results'];

      await ChatMessageHandler().saveChatMessages(messages: tempList);

      chatMessagePagination.count = result['count'];
      chatMessagePagination.next = result['next'];
      chatMessagePagination.previous = result['previous'];

      if (isFirstTime) {
        await ChatMessageHandler().saveChatMessagePagination(
            chatMessagePagination: chatMessagePagination);
      } else {
        await ChatMessageHandler().updateChatMessagePagination(
            chatMessagePagination: chatMessagePagination);
      }
    }

    if (isFirstTime && chatMessagePagination.next != null) {
      await getMessages(chatConversation: chatConversation, isFirstTime: false);
    } else {
      return;
    }
    return;
  }

  Future<void> update() async {
    List<ChatMessage> chatMessages =
        await ChatMessageHandler().getLastChatMessage();

    if (chatMessages == null || chatMessages.isEmpty) return;

    // chatMessages.forEach((element) {
    //   debugPrint("Message:- ${element.text}  createdAt:- ${element.createdAt}");
    // });

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
          debugPrint(
              "<==== ${chatMessage.text}   <===== ${chatMessage.createdAt}");
          messageList.add(chatMessage);
        });
      });
    }

    if (messageList.isNotEmpty) {
      await ChatMessageHandler().insertMissedChatMessage(messages: messageList);

      _chatMessageStream.sink.add(true);

      messageList.forEach((message) async {
        await MainSocketMessageHandler()
            .saveAndUpdateUserMessageCount(messageData: message.toJson());
        _chatMessageCountStream.sink.add(true);
      });
    }

    return Future.value();
  }

  void dispose() {
    _chatMessageCountStream.close();
    _chatMessageStream.close();
  }
}
