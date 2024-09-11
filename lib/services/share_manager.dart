import 'dart:async';
import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/messaging/chat/helpers/chat_message_handler.dart';
import 'package:Slydo/screens/messaging/chat/helpers/db_socket_message_handler.dart';
import 'package:Slydo/screens/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/messaging/chat/models/models_for_db/SocketQueueChatMessage.dart';
import 'package:Slydo/screens/messaging/chat/share_in_chat/ShareInChat.dart';
import 'package:Slydo/screens/messaging/chat/utils.dart';
import 'package:Slydo/screens/messaging/message_auth.dart';
import 'package:Slydo/services/route_provider.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:uuid/uuid.dart';

class ShareManager {
  StreamSubscription? _intentDataStreamSubscription;

  static final ShareManager _shareManager = ShareManager._internal();

  factory ShareManager() {
    return _shareManager;
  }

  ShareManager._internal();

  List<SharedMediaFile>? _sharedFiles;
  String? _sharedText;
  Timer? _timerForSharingDataListen;
  final Duration _refreshDurationInterval = const Duration(seconds: 1);

  void initializeShareManager() {
    _initializeMediaStream();
    // _initializeTextStream();
  }

  void _initializeMediaStream() {
    disposeSharedValue();
    // For sharing images coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.instance
        .getMediaStream()
        .listen((List<SharedMediaFile> value) {
      // debugPrint("ReceiveSharedMedia1:${value.map((f) => f.path).join(",")}");
      _sharedFiles = value;
      if (_sharedFiles != null && _sharedFiles!.isNotEmpty) {
        initializeNavigationTimer();
      }
    }, onError: (err) {
      debugPrint("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> value) {
      // debugPrint("ReceiveSharedMedia2:${value.map((f) => f.path).join(",")}");
      _sharedFiles = value;
      if (_sharedFiles != null && _sharedFiles!.isNotEmpty) {
        initializeNavigationTimer();
      }
    });
  }

  // void _initializeTextStream() {
  //   disposeSharedValue();
  //   // For sharing or opening urls/text coming from outside the app while the app is in the memory
  //   _intentDataStreamSubscription =
  //       ReceiveSharingIntent.instance.getTextStream().listen((String value) {
  //     debugPrint("ReceiveSharedText1: $value");
  //     _sharedText = value;
  //     if (_sharedText != null && _sharedText != "" && _sharedText != "null") {
  //       initializeNavigationTimer();
  //     }
  //   }, onError: (err) {
  //     debugPrint("getLinkStream error: $err");
  //   });
  //
  //   // For sharing or opening urls/text coming from outside the app while the app is closed
  //   ReceiveSharingIntent.getInitialText().then((String? value) {
  //     debugPrint("ReceiveSharedText2: $value");
  //     _sharedText = value;
  //     if (_sharedText != null && _sharedText != "" && _sharedText != "null") {
  //       initializeNavigationTimer();
  //     }
  //   });
  // }

  void disposeShareManager() {
    _intentDataStreamSubscription?.cancel();
    disposeSharedValue();
  }

  void disposeSharedValue() {
    _sharedText = null;
    _sharedFiles = null;
  }

  void initializeNavigationTimer() {
    if (_timerForSharingDataListen?.isActive ?? false) {
      _timerForSharingDataListen?.cancel();
    }

    _timerForSharingDataListen =
        Timer.periodic(_refreshDurationInterval, (time) {
      try {
        if (myGlobals.navigationKey.currentContext != null) {
          _timerForSharingDataListen!.cancel();
          // debugPrint("<====== Opening user list ======>");
          final RouteProvider routeProvider = Provider.of<RouteProvider>(
              myGlobals.navigationKey.currentContext!,
              listen: false);

          if (routeProvider.routes.contains("/dashboard") ||
              routeProvider.routes.last == "/dashboard") {
            openPopup();
          }
        }
      } catch (e) {
        debugPrint("ShareContextException===>$e");
      }
    });
  }

  void openPopup() async {
    if (_sharedText != null && _sharedText != "" && _sharedText != "null") {
      // debugPrint("ShareContext===> Text ===> $_sharedText");
      final String text = _sharedText!.trim();
      _timerForSharingDataListen!.cancel();
      disposeSharedValue();
      final List<ChatConversation?> selectedUser = await ShareInChat()
          .selectShareCustomer(myGlobals.navigationKey.currentContext!);

      for (int i = 0; i < selectedUser.length; i++) {
        await sendTextMessage(text, selectedUser[i]!);
      }
    } else if (_sharedFiles != null && _sharedFiles!.isNotEmpty) {
      // debugPrint("ShareContext===> Media ===> $_sharedFiles");
      final List<SharedMediaFile> files = [];
      files.addAll(_sharedFiles!);
      _timerForSharingDataListen!.cancel();
      disposeSharedValue();
      final List<ChatConversation?> selectedUser = await ShareInChat()
          .selectShareCustomer(myGlobals.navigationKey.currentContext!);

      for (int i = 0; i < selectedUser.length; i++) {
        for (int j = 0; j < files.length; j++) {
          await sendMediaMessage(selectedUser[i], files[j]);
        }
      }
    }
  }

  Future<void> sendMediaMessage(ChatConversation? chatConversation,
      SharedMediaFile sharedMediaFile) async {
    final UserBloc userBloc = Provider.of<UserBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);

    final File file = File(sharedMediaFile.path);

    final String? mediaType = getFileKind(sharedMediaFile);

    if (mediaType == null) return;

    final Map<String, dynamic> data = {};
    data['text'] = "";
    data['check_id'] = const Uuid().v4();
    data['kind'] = mediaType;
    data['read_by_author'] = true;
    data['created_at'] = DateTime.now().toUtc().toString();
    data['type'] = "chatroom_message";
    data['conversation'] = chatConversation!.conversationId;
    data['author'] = userBloc.user.userName;

    debugPrint("ShareContentMediaData====>/ $data");

    File? poster;
    if (mediaType == "video") {
      final String? posterPath = await getVideoThumbnail(file);

      if (posterPath == null) return;
      poster = File(posterPath);
    }

    await MessageAuth()
        .sendSocketMessage(data, file, poster: poster)
        .then((value) {
      // debugPrint("ShareContext====> MessageAuth");
    }).catchError((error) {
      debugPrint("ShareContext====> ${Future.error(error)}");
    });
  }

  String? getFileKind(SharedMediaFile file) {
    if (file.type == SharedMediaType.image) {
      return "image";
    } else if (file.type == SharedMediaType.video) {
      return "video";
    }
    return null;
  }

  Future<void> sendTextMessage(
      String message, ChatConversation chatConversation) async {
    final UserBloc userBloc = Provider.of<UserBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);

    final Map<String, dynamic> data = {
      "check_id": const Uuid().v4(),
      "conversation_id": chatConversation.conversationId,
      "author": userBloc.user.userName,
      "author_full_name": userBloc.user.fullName,
      "author_avatar": userBloc.user.avatar,
      "message": message,
      "kind": "text",
      "read_by_author": true,
      "read_by_recipient": false,
      "delivered": false,
      "created_at": DateTime.now().toUtc().toIso8601String(),
      "type": "chatroom_message",
    };

    // debugPrint("ShareContentTextData====> $data");

    // debugPrint(
    //     "recipientUser = $chatConversation  recipientUser.conversationId = ${chatConversation.conversationId}");
    if (chatConversation != null && chatConversation.conversationId != null) {
      DBSocketMessageHandler()
          .saveMessageToDb(message: SocketQueueChatMessage.fromJson(data));

      final ChatMessage chatMessage = convertToChatMessage(data);

      await ChatMessageHandler().addChatMessage(chatMessage: chatMessage);

      updateConnectionList(
          messageData: data, conversationId: chatConversation.conversationId);
      await sendDataToSocket(data);
    } else {
      showToast(message: "Please check your connection !!");
    }
  }

  void updateConnectionList(
      {required Map<String, dynamic> messageData, String? conversationId}) {
    if (messageData.containsKey("created_at")) {
      final DateTime dateTime =
          DateTime.parse(messageData["created_at"]).toLocal();
      final int time = dateTime.millisecondsSinceEpoch;

      // debugPrint("Last message Time => $time");

      final ConnectionListBloc connectionListBloc =
          Provider.of<ConnectionListBloc>(myGlobals.scaffoldKey.currentContext!,
              listen: false);
      connectionListBloc.updateLastMessageTime(
          conversationId: conversationId, time: time);
    }
  }

  ChatMessage convertToChatMessage(Map<String, dynamic> data) {
    final Map<String, dynamic> newData = {};
    newData["check_id"] = data["check_id"];
    newData["conversation"] = data["conversation_id"];
    newData["author"] = data["author"];
    newData["author_full_name"] = data["author_full_name"];
    newData["author_avatar"] = data["author_avatar"];
    newData["text"] = data["message"];
    newData["kind"] = data["kind"];
    newData["read_by_author"] = data["read_by_author"];
    newData["read_by_recipient"] = data["read_by_recipient"];
    newData["delivered"] = data["delivered"];
    newData["created_at"] = data["created_at"];
    newData["updated_at"] = data["updated_at"];
    newData["type"] = data["type"];
    newData["was_edited"] = false;
    newData["deleted_for_recipient"] = false;
    newData["deleted_for_author"] = false;
    newData["meta_data"] = {};
    newData["replied_to"] = data["replied_to"] ?? {};

    return ChatMessage.fromJson(newData);
  }
}
