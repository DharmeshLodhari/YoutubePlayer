import 'dart:async';
import 'dart:convert';

import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/main_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessagePagination.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:flutter/cupertino.dart';

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

  static String _nextMissedMessages = "";
  static String _previousMissedMessages = "";

  void setStreamFalse() {
    _chatMessageStream.sink.add(false);
  }

  void setStreamTrue() {
    debugPrint("Stream called !!!");
    _chatMessageStream.sink.add(true);
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

  Future<void> syncMessages({bool fetchFresh = false}) async {
    if (fetchFresh) {
      _nextMissedMessages = "";
      _previousMissedMessages = "";
    }

    // MyGlobals myGlobals = MyGlobals();
    // BuildContext context = myGlobals.navigationKey.currentContext;
    //
    // ConnectionListBloc connectionListBloc =
    //     Provider.of<ConnectionListBloc>(context, listen: false);
    //
    // List<Map<String, dynamic>> dataToBeSent = [];
    //
    // for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
    //   List<ChatMessage> lastFewMessages = await ChatMessageHandler()
    //       .getLimitedChatMessages(
    //           conversationId:
    //               connectionListBloc.connectionUsers[i].conversationId,
    //           limit: 20);
    //
    //   List<String> checkIds = [];
    //   if (lastFewMessages != null) {
    //     if (lastFewMessages.isNotEmpty) {
    //       lastFewMessages.forEach((element) {
    //         if (element.checkId != null && element.checkId != "") {
    //           checkIds.add(element.checkId);
    //         }
    //       });
    //     }
    //   }
    //
    //   dataToBeSent.add({
    //     "conversation_id": connectionListBloc.connectionUsers[i].conversationId,
    //     "check_ids": checkIds
    //   });
    // }

    Map<String, dynamic> resultData = await MessageAuth()
        .fetchMissedMessages(
            next: _nextMissedMessages, previous: _previousMissedMessages)
        .catchError((error) {
      debugPrint("ERROR:- While calling Message Synchronizer $error");
    });

    if (resultData == null) return;

    List<ChatMessage> messageList = List<ChatMessage>();

    List missedMessages = resultData['results'];
    _nextMissedMessages = resultData['next'];
    _previousMissedMessages = resultData['previous'];

    if (missedMessages == null) return;

    if (missedMessages.isEmpty) return;

    missedMessages.forEach((element) {
      ChatMessage chatMessage = ChatMessage.fromJson(jsonDecode(element));
      debugPrint("<==== ${chatMessage.text}   <===== ${chatMessage.createdAt}");
      messageList.add(chatMessage);
    });

    if (messageList.isNotEmpty) {
      // await ChatMessageHandler()
      //     .insertMissedChatMessages(messages: messageList);

      _chatMessageStream.sink.add(true);
      for (int i = 0; i < messageList.length; i++) {
        int result = await ChatMessageHandler()
            .insertMissedChatMessage(chatMessage: messageList[i]);

        if (result == 1) {
          await MainSocketMessageHandler().saveAndUpdateUserMessageCount(
              messageData: messageList[i].toJson());
          _chatMessageCountStream.sink.add(true);
        }
      }

      List<String> acknowledgedMessageIds = [];
      for (int i = 0; i < messageList.length; i++) {
        acknowledgedMessageIds.add(messageList[i].messageId);
      }

      await MessageAuth()
          .acknowledgeMessagesToServer(dataToBeSent: acknowledgedMessageIds)
          .catchError((error) {
        debugPrint("Error:- $error");
      });
    }

    if (_nextMissedMessages != "") {
      await syncMessages();
    }

    return Future.value();
  }

  void dispose() {
    _chatMessageCountStream.close();
    _chatMessageStream.close();
  }
}
