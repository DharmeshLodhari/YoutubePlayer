import 'dart:async';
import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/chat_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/connection_list_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/main_socket_message_handler.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessagePagination.dart';
import 'package:Slydo/screens/more_apps/messaging/message_auth.dart';
import 'package:Slydo/utils/date_time_and_money_converter.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

/// This helper will sync messages from the server to the local db
class ChatMessageSynchronizer {
  static final ChatMessageSynchronizer _chatMessageSynchronizer =
      ChatMessageSynchronizer._internal();

  ChatMessageSynchronizer._internal();

  final StreamController<bool> _chatMessageCountStream =
      StreamController<bool>.broadcast();

  Stream<bool> get getChatMessageCountStream => _chatMessageCountStream.stream;

  final StreamController<bool> _chatMessageStream =
      StreamController<bool>.broadcast();

  Stream<bool> get getChatMessageStream => _chatMessageStream.stream;

  final StreamController<bool?> _chatMessageFetchingStream =
      BehaviorSubject<bool?>();

  Stream<bool?> get getChatMessageFetchingStream =>
      _chatMessageFetchingStream.stream;

  void updateFetchStream({bool? isFetching}) {
    _chatMessageFetchingStream.sink.add(isFetching);
  }

  factory ChatMessageSynchronizer() {
    return _chatMessageSynchronizer;
  }

  static String? _next = "";
  static String? _previous = "";

  static String? _nextMissedMessages = "";
  static String? _previousMissedMessages = "";

  void setStreamFalse() {
    _chatMessageStream.sink.add(false);
  }

  void setStreamTrue() {
    debugPrint("Stream called !!!");
    _chatMessageStream.sink.add(true);
  }

  Future<void> getMessages(
      {required ChatConversation chatConversation, bool? isFirstTime}) async {
    debugPrint("Fetching previous messages !!");

    final ChatMessagePagination chatMessagePagination =
        await ChatMessageHandler().getChatMessagePagination(
            conversationId: chatConversation.conversationId);

    _next = chatMessagePagination.next;
    _previous = chatMessagePagination.previous;

    if (_next != null) {
      debugPrint(
          "recipient conversationID:- ${chatConversation.conversationId}  ${chatConversation.fullName}");

      final Map<String, dynamic>? result = await MessageAuth()
          .getChatMessages(_next, _previous,
              conversionId: chatConversation.conversationId)
          .catchError((error) {
        debugPrint("ERROR:- $error");
      });

      if (result == null) return;

      final List<String> tempList = result['results'];

      final List<ChatMessage> insertedMessages =
          await ChatMessageHandler().saveChatMessages(messages: tempList);

      chatMessagePagination.count = result['count'];
      chatMessagePagination.next = result['next'];
      chatMessagePagination.previous = result['previous'];

      /// For sending acknowledgement for new Messages
      sendAcknowledgementForNewMessages(messages: insertedMessages);

      if (isFirstTime!) {
        await ChatMessageHandler().saveChatMessagePagination(
            chatMessagePagination: chatMessagePagination);
      } else {
        await ChatMessageHandler().updateChatMessagePagination(
            chatMessagePagination: chatMessagePagination);
      }
    }

    if (isFirstTime! && chatMessagePagination.next != null) {
      await getMessages(chatConversation: chatConversation, isFirstTime: false);
    } else {
      return;
    }
    return;
  }

  void sendAcknowledgementForNewMessages(
      {required List<ChatMessage> messages}) async {
    final UserBloc userBloc = Provider.of<UserBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);

    final List<String?> acknowledgedMessageIds = [];
    for (int i = 0; i < messages.length; i++) {
      if (userBloc.user.userName != messages[i].author &&
          !messages[i].delivered!) {
        acknowledgedMessageIds.add(messages[i].messageId);
        await MainSocketMessageHandler()
            .saveAndUpdateUserMessageCount(messageData: messages[i].toJson());

        final int? time =
            convertStringToMillisecondsSinceEpoch(messages[i].createdAt);

        final String? conversationId = messages[i].conversationId;

        await ConnectionListManager()
            .updateLastMessageTime(conversationId: conversationId, time: time);

        _chatMessageCountStream.sink.add(true);
      }
    }

    if (acknowledgedMessageIds.isNotEmpty) {
      final Map<String, dynamic>? acknowledgedMessages = await MessageAuth()
          .acknowledgeMessagesToServer(dataToBeSent: acknowledgedMessageIds)
          .catchError((error) {
        debugPrint("Error:- $error");
      });

      debugPrint("==> $acknowledgedMessages");
    }
  }

  Future<void> syncMessages({bool fetchFresh = false}) async {
    if (fetchFresh) {
      _nextMissedMessages = "";
      _previousMissedMessages = "";
    }

    final Map<String, dynamic>? resultData = await MessageAuth()
        .fetchMissedMessages(
            next: _nextMissedMessages, previous: _previousMissedMessages)
        .catchError((error) {
      debugPrint("ERROR:- While calling Message Synchronizer $error");
    });

    if (resultData == null) return;

    final List<ChatMessage> messageList = [];

    final List? missedMessages = resultData['results'];
    _nextMissedMessages = resultData['next'];
    _previousMissedMessages = resultData['previous'];

    if (missedMessages == null) return;

    if (missedMessages.isEmpty) return;

    for (var element in missedMessages) {
      final ChatMessage chatMessage = ChatMessage.fromJson(jsonDecode(element));
      debugPrint("<==== ${chatMessage.text}   <===== ${chatMessage.createdAt}");
      messageList.add(chatMessage);
    }

    if (messageList.isNotEmpty) {
      for (int i = 0; i < messageList.length; i++) {
        final int result = await ChatMessageHandler()
            .insertMissedChatMessage(chatMessage: messageList[i]);

        if (result == 1) {
          await MainSocketMessageHandler().saveAndUpdateUserMessageCount(
              messageData: messageList[i].toJson());

          final int? time =
              convertStringToMillisecondsSinceEpoch(messageList[i].createdAt);

          final String? conversationId = messageList[i].conversationId;

          await ConnectionListManager().updateLastMessageTime(
              conversationId: conversationId, time: time);

          _chatMessageCountStream.sink.add(true);
        }
      }

      final ConnectionListBloc connectionListBloc =
          Provider.of<ConnectionListBloc>(
              myGlobals.navigationKey.currentContext!,
              listen: false);
      await connectionListBloc.getConnectionsCount();

      _chatMessageStream.sink.add(true);

      final List<String?> acknowledgedMessageIds = [];
      for (int i = 0; i < messageList.length; i++) {
        acknowledgedMessageIds.add(messageList[i].messageId);
      }

      final Map<String, dynamic>? acknowledgedMessages = await MessageAuth()
          .acknowledgeMessagesToServer(dataToBeSent: acknowledgedMessageIds)
          .catchError((error) {
        debugPrint("Error:- $error");
      });

      debugPrint("==> $acknowledgedMessages");
    }

    if (_nextMissedMessages != "") {
      await syncMessages();
    }

    return Future.value();
  }

  void handleAcknowledgementMessage(
      {required Map<String, dynamic> messageData}) async {
    /// {check_id: e0c64c88-262d-4428-8634-031762897556,
    /// conversation_id: 09700559-3aa6-4d71-bd4b-748322e49fdb,
    /// username: black, delivered: true, type: acknowledge_message}
    final UserBloc userBloc = Provider.of<UserBloc>(
        MyGlobals().navigationKey.currentContext!,
        listen: false);

    if (userBloc.user.userName != messageData["username"]) {
      await ChatMessageHandler().updateDeliverStatusOfChatMessage(
          checkId: messageData['check_id'],
          conversationId:
              messageData['conversation_id'] ?? messageData['conversation']);
    }
  }

  void dispose() {
    _chatMessageCountStream.close();
    _chatMessageStream.close();
    _chatMessageFetchingStream.close();
  }
}
