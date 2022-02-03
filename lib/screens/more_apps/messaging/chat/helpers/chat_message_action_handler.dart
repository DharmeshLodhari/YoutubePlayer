import 'dart:convert';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatMessageAction.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/Envelope.dart';
import 'package:flutter/material.dart';

/// This Helper is Responsible for getting the chat Message Actions like
/// Reply Message,
/// Delete Message,
/// Edit Message
/// which is available for that particular type of messsage
class GetChatMessageActions {
  String? _message;
  UserBloc? _userBloc;

  GetChatMessageActions();

  /// this function will return ChatMessageActions which contains all the action
  /// which available for that kind of message
  ChatMessageAction getActions({required String message, UserBloc? userBloc}) {
    _message = message;
    _userBloc = userBloc;

    ChatMessageAction chatMessageAction = ChatMessageAction(message: _message);

    Map<String, dynamic> messageData = jsonDecode(_message!);

    String? messageType = messageData["kind"];

    bool isAuthorPerformingAction =
        _userBloc!.user.userName == messageData["author"];

    switch (messageType) {
      case "text":
        chatMessageAction = _getTextMessageActions(
            message: _message,
            isAuthorPerformingAction: isAuthorPerformingAction);
        return chatMessageAction;

      case "image":
        chatMessageAction = _getImageActions(
            message: _message,
            isAuthorPerformingAction: isAuthorPerformingAction);
        return chatMessageAction;

      case "video":
        chatMessageAction = _getVideoActions(
            message: _message,
            isAuthorPerformingAction: isAuthorPerformingAction);
        return chatMessageAction;

      case "audio":
        chatMessageAction = _getAudioActions(
            message: _message,
            isAuthorPerformingAction: isAuthorPerformingAction);
        return chatMessageAction;

      case "transaction":
        chatMessageAction = _getTransactionActions(
            message: _message,
            isAuthorPerformingAction: isAuthorPerformingAction);
        return chatMessageAction;

      case "payment-request":
        chatMessageAction = _getPaymentRequestActions(
            message: _message,
            isAuthorPerformingAction: isAuthorPerformingAction);
        return chatMessageAction;

      case "product":
        chatMessageAction = _getProductActions(
            message: _message,
            isAuthorPerformingAction: isAuthorPerformingAction);
        return chatMessageAction;

      case "service":
        chatMessageAction = _getServiceActions(
            message: _message,
            isAuthorPerformingAction: isAuthorPerformingAction);
        return chatMessageAction;

      case "user-profile":
        chatMessageAction = _getUserProfileActions(
            message: _message,
            isAuthorPerformingAction: isAuthorPerformingAction);
        return chatMessageAction;

      case "user_location":
        chatMessageAction = _getUserLocationActions(
            message: _message,
            isAuthorPerformingAction: isAuthorPerformingAction);
        return chatMessageAction;

      case "gif_image":
        chatMessageAction = _getGIFImageActions(
            message: _message,
            isAuthorPerformingAction: isAuthorPerformingAction);
        return chatMessageAction;

      case "envelope":
        chatMessageAction = _getEnvelopeActions(
            message: _message!,
            isAuthorPerformingAction: isAuthorPerformingAction);
        return chatMessageAction;

      default:
        debugPrint("Unknown Message Kind 2: $messageType Message:- $_message");
        return chatMessageAction;
    }
  }

  ChatMessageAction _getTextMessageActions(
      {required String? message, required bool isAuthorPerformingAction}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    if (isAuthorPerformingAction) {
      chatMessageAction.isDeletable = true;
      chatMessageAction.isEditable = true;
    }

    chatMessageAction.isCopyable = true;
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getImageActions(
      {required String? message, required bool isAuthorPerformingAction}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    if (isAuthorPerformingAction) {
      chatMessageAction.isDeletable = true;
    }

    chatMessageAction.isCopyable = true;
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getVideoActions(
      {required String? message, required bool isAuthorPerformingAction}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    if (isAuthorPerformingAction) {
      chatMessageAction.isDeletable = true;
    }
    chatMessageAction.isCopyable = true;
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getAudioActions(
      {required String? message, required bool isAuthorPerformingAction}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    if (isAuthorPerformingAction) {
      chatMessageAction.isDeletable = true;
    }
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getPaymentRequestActions(
      {required String? message, bool? isAuthorPerformingAction}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getTransactionActions(
      {required String? message, bool? isAuthorPerformingAction}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getProductActions(
      {required String? message, required bool isAuthorPerformingAction}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    if (isAuthorPerformingAction) {
      chatMessageAction.isDeletable = true;
    }
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getServiceActions(
      {required String? message, required bool isAuthorPerformingAction}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    if (isAuthorPerformingAction) {
      chatMessageAction.isDeletable = true;
    }
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getUserProfileActions(
      {required String? message, required bool isAuthorPerformingAction}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    if (isAuthorPerformingAction) {
      chatMessageAction.isDeletable = true;
    }
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getUserLocationActions(
      {required String? message, required bool isAuthorPerformingAction}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    if (isAuthorPerformingAction) {
      chatMessageAction.isDeletable = true;
    }
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getGIFImageActions(
      {required String? message, required bool isAuthorPerformingAction}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    if (isAuthorPerformingAction) {
      chatMessageAction.isDeletable = true;
    }
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getEnvelopeActions(
      {required String message, required bool isAuthorPerformingAction}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    Map<String, dynamic> messageData = jsonDecode(message);

    Map<String, dynamic>? data;

    if (messageData['meta_data'] is String) {
      data = jsonDecode(messageData['meta_data']);
    } else if (messageData['meta_data'] is Map) {
      data = messageData['meta_data'];
    }

    Envelope envelope = Envelope.fromJson(data!);

    if (isAuthorPerformingAction) {
      if (!envelope.isOpen) {
        chatMessageAction.isDeletable = true;
      }
    }
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }
}
