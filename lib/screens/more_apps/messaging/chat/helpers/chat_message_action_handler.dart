import 'dart:convert';

import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatMessageAction.dart';
import 'package:flutter/material.dart';

class GetChatMessageActions {
  String _message;

  GetChatMessageActions();

  /// this function will return ChatMessageActions which contains all the action
  /// which available for that kind of message
  ChatMessageAction getActions({@required String message}) {
    _message = message;

    ChatMessageAction chatMessageAction = ChatMessageAction(message: _message);

    Map<String, dynamic> messageData = jsonDecode(_message);

    String messageType = messageData["kind"];

    switch (messageType) {
      case "text":
        chatMessageAction = _getTextMessageActions(message: _message);
        return chatMessageAction;
        break;

      case "image":
        chatMessageAction = _getImageActions(message: _message);
        return chatMessageAction;
        break;

      case "video":
        chatMessageAction = _getVideoActions(message: _message);
        return chatMessageAction;
        break;

      case "audio":
        chatMessageAction = _getAudioActions(message: _message);
        return chatMessageAction;
        break;

      case "transaction":
        chatMessageAction = _getTransactionActions(message: _message);
        return chatMessageAction;
        break;

      case "payment-request":
        chatMessageAction = _getPaymentRequestActions(message: _message);
        return chatMessageAction;
        break;

      case "product":
        chatMessageAction = _getProductActions(message: _message);
        return chatMessageAction;
        break;

      case "service":
        chatMessageAction = _getServiceActions(message: _message);
        return chatMessageAction;
        break;

      case "user-profile":
        chatMessageAction = _getUserProfileActions(message: _message);
        return chatMessageAction;

      default:
        debugPrint("Unknown Message Kind: $messageType Message:- $_message");
        return chatMessageAction;
    }
  }

  ChatMessageAction _getTextMessageActions({@required String message}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    chatMessageAction.isDeletable = true;
    chatMessageAction.isEditable = true;
    chatMessageAction.isCopyable = true;
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getImageActions({@required String message}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    chatMessageAction.isDeletable = true;
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getVideoActions({@required String message}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    chatMessageAction.isDeletable = true;
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getAudioActions({@required String message}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    chatMessageAction.isDeletable = true;
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getPaymentRequestActions({@required String message}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getTransactionActions({@required String message}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getProductActions({@required String message}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    chatMessageAction.isDeletable = true;
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getServiceActions({@required String message}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    chatMessageAction.isDeletable = true;
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }

  ChatMessageAction _getUserProfileActions({@required String message}) {
    ChatMessageAction chatMessageAction = ChatMessageAction(message: message);

    chatMessageAction.isDeletable = true;
    chatMessageAction.isReplyable = true;

    return chatMessageAction;
  }
}
