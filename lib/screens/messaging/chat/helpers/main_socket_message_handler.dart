import 'dart:async';
import 'dart:convert';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/socket_provider.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/messaging/chat/helpers/chat_group_action_manager.dart';
import 'package:Slydo/screens/messaging/chat/helpers/chat_message_handler.dart';
import 'package:Slydo/screens/messaging/chat/helpers/chat_message_synchronizer.dart';
import 'package:Slydo/screens/messaging/chat/helpers/chat_shake_detection.dart';
import 'package:Slydo/screens/messaging/chat/helpers/chat_user_manager.dart';
import 'package:Slydo/screens/messaging/chat/helpers/db_socket_message_handler.dart';
import 'package:Slydo/screens/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/messaging/chat/models/main_socket_message_model.dart';
import 'package:Slydo/screens/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/messaging/chat/models/models_for_db/SocketQueueChatMessage.dart';
import 'package:Slydo/screens/messaging/message_auth.dart';
import 'package:Slydo/screens/payment_and_banking/models/transactions.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/screens/user_profile/user_auth.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/fcm_push_notification.dart';
import 'package:Slydo/services/secure_storage.dart';
import 'package:Slydo/utils/cache_manager.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/dialog.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'message_sound_player.dart';

/// For Handling the Messages which are coming From the socket
class MainSocketMessageHandler {
  final String? message;

  static final List<String?> _nudgingUsers = [];

  static final List<String?> _audioPlayers = [];

  static final List<String> _hashedNudgingMessages = [];

  static Timer? _nudgeAlertTimer;
  static Duration nudgeAlertDuration = const Duration(seconds: 10);

  bool isFCMMessage = false;

  MainSocketMessageHandler({this.message, this.isFCMMessage = false}) {
    if (message != null) {
      handleMessageAccordingToType();
    }
  }

  ///Handle message according to message type
  void handleMessageAccordingToType() async {
    final Map<String, dynamic> messageData = jsonDecode(message!);

    final MainSocketProvider mainSocketProvider =
        Provider.of<MainSocketProvider>(myGlobals.navigationKey.currentContext!,
            listen: false);

    mainSocketProvider.removeFromTheQueue(message: message!);

    final String? messageType = messageData["type"];

    switch (messageType) {
      case "chatroom_message":
        if (messageData.containsKey("conversation") ||
            messageData.containsKey("conversation_id")) {
          final MainSocketProvider mainSocketProvider =
              Provider.of<MainSocketProvider>(
                  myGlobals.navigationKey.currentContext!,
                  listen: false);

          final String? conversationId =
              (messageData.containsKey("conversation")
                  ? messageData["conversation"]
                  : messageData["conversation_id"]);

          /// Converting message Data into MODEL
          // {"created_at": "2021-05-07 10:05:26.332872Z", "check_id": "337e4aa6-039d-4c13-b438-34905cbcb3b3", "author": "brijesh.sakariya", "text": "10", "kind": "text", "meta_data": {}, "read_by_author": true, "read_by_recipient": false, "delivered": true, "type": "chatroom_message", "conversation_id": "9ae68069-b342-4e04-b568-602bde6fe901"}
          final ChatMessage chatMessage = ChatMessage.fromJson(messageData);

          /// checking if the recipient is in the current chat screen then we will not update message count
          if (mainSocketProvider.currentConversationId != conversationId) {
            await saveAndUpdateUserMessageCount(messageData: messageData);
          }

          /// update message in the local message db
          await ChatMessageHandler()
              .updateChatMessage(chatMessage: chatMessage);

          /// Send Acknowledgement of the message
          await sendAcknowledgementOfMessageWithCheckingAuthor(
              chatMessage: chatMessage);

          /// update ConnectionList order by last receive time
          await updateConnectionListOrder(
              conversationId: conversationId, messageData: messageData);

          ///delete message from ChatTextMessage table in db if message came back from socket

          final String? chatMessageKind = messageData['kind'];

          ChatMessageSynchronizer().setStreamTrue();

          switch (chatMessageKind) {
            case "text":
              DBSocketMessageHandler().deleteSocketQueueChatMessage(
                  message: SocketQueueChatMessage.fromJson(messageData));
              break;
            case "user_location":
              DBSocketMessageHandler().deleteSocketQueueChatMessage(
                  message: SocketQueueChatMessage.fromJson(messageData));
              break;
            case "gif_image":
              DBSocketMessageHandler().deleteSocketQueueChatMessage(
                  message: SocketQueueChatMessage.fromJson(messageData));
              break;

            case "envelope":
              break;

            case "payment-request":
              break;

            case "transaction":
              break;
            case "audio":
              break;
            case "video":
              break;
            case "image":
              break;
            case "file":
              break;

            default:
              debugPrint(
                  "UNKNOWN==> KIND:- ${messageData['kind']}  message:- $messageData");
          }
        } else {
          debugPrint("UNKNOWN==> chatroom_message $messageData");
        }
        break;

      case "read_by_recipient":
        ChatMessageHandler().updateReadByRecipientChatMessage(
            checkId: messageData["check_id"],
            conversationId: messageData["conversation_id"]);
        break;

      case "delete_message":
        ChatMessageHandler().deleteChatMessage(
            checkId: messageData["check_id"],
            conversationId: messageData["conversation_id"]);
        break;

      case "edit_message":
        ChatMessageHandler().updateEditedChatMessage(
            checkId: messageData["check_id"],
            conversationId: messageData["conversation_id"],
            wasEdited: messageData['was_edited'],
            text: messageData['text']);
        break;

      case "nudge_user":
        showNudgeAlertToUser(messageData: messageData);
        break;

      case "stop_nudging":
        stopNudgeAlertToUser(messageData: messageData);
        break;

      case "conversation_created":
        addChatConversation(messageData: messageData);
        break;

      case "group_conversation_admin_actions":
        final UserBloc user = Provider.of<UserBloc>(
            MyGlobals().navigationKey.currentContext!,
            listen: false);

        if (messageData['meta_data']['author'] != user.user.userName) {
          ChatGroupActionManager(message: messageData);
        }

        break;

      case "conversation_actions":
        handleConversationActions(messageData: messageData);
        break;

      case "acknowledge_message":
        handleAcknowledgementMessage(messageData: messageData);
        break;

      case "user_typing_message":
        break;

      case "pong":
        break;

      case "user_recording_audio_message":
        break;

      case "logout_user":
        logoutUser();
        break;

      default:
        debugPrint("UNHANDLED MESSAGE GOT IN SOCKET:-  $messageData");
    }
  }

  Future<void> sendAcknowledgementOfMessageWithCheckingAuthor(
      {required ChatMessage chatMessage}) async {
    String? currentUserName;

    UserBloc userBloc;

    try {
      userBloc = Provider.of<UserBloc>(myGlobals.navigationKey.currentContext!,
          listen: false);
      currentUserName = userBloc.user.userName;
    } catch (error) {
      final User? user = await DatabaseHelper().getUser();
      if (user == null) return;
      currentUserName = user.userName;
    }

    if (currentUserName != chatMessage.author) {
      /// send acknowledgement to server through API that this message is received
      await sendAcknowledgementOfMessageThroughHttp(
              conversationId: chatMessage.conversationId,
              checkId: chatMessage.checkId)
          .catchError((error) {
        /// send acknowledgement to server through WEBSocket that this message is received
        sendAcknowledgementOfMessageThroughSocket(
            conversationId: chatMessage.conversationId,
            checkId: chatMessage.checkId);
      });
    }
  }

  ///  For Sending the message acknowledgement to server that user has received this message
  Future<void> sendAcknowledgementOfMessageWithOutCheckingAuthor(
      {String? checkId, String? conversationId}) async {
    /// send acknowledgement to server through API that this message is received
    await sendAcknowledgementOfMessageThroughHttp(
            conversationId: conversationId, checkId: checkId)
        .catchError((error) {
      /// send acknowledgement to server through WEBSocket that this message is received
      sendAcknowledgementOfMessageThroughSocket(
          conversationId: conversationId, checkId: checkId);
    });
  }

  void addChatConversation({required Map<String, dynamic> messageData}) {
    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(
            MyGlobals().navigationKey.currentContext!,
            listen: false);

    Map<String, dynamic>? json;

    if (messageData['meta_data'] is String) {
      json = jsonDecode(messageData['meta_data']);
    } else {
      json = messageData['meta_data'];
    }

    final ChatConversation chatConversation = ChatConversation.fromJson(json!);
    connectionListBloc.addConnectionUser(chatConversation: chatConversation);
  }

  void handleConversationActions({required Map<String, dynamic> messageData}) {
    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(
            MyGlobals().navigationKey.currentContext!,
            listen: false);

    Map<String, dynamic>? metaData;

    if (messageData['meta_data'] is String) {
      metaData = jsonDecode(messageData['meta_data']);
    } else {
      metaData = messageData['meta_data'];
    }

    if (!messageData.containsKey("meta_data")) {
      metaData = messageData;
    }
    final String? action = metaData!['action'];

    switch (action) {
      case "delete_conversation":
        connectionListBloc.deleteChatConversation(
            conversationId: metaData['conversation_id']);
        DBSocketMessageHandler().deleteSocketQueueForSpecificConversation(
            conversationId: metaData['conversation_id']);
        break;

      default:
        debugPrint(
            "UNHANDLED MESSAGE ACTION FOUNT:- $action MESSAGE:- $messageData");
    }
  }

  void handleAcknowledgementMessage(
      {required Map<String, dynamic> messageData}) async {
    await ChatMessageHandler().updateDeliverStatusOfChatMessage(
        checkId: messageData['check_id'],
        conversationId:
            messageData['conversation_id'] ?? messageData['conversation']);
  }

  Future<void> saveAndUpdateUserMessageCount(
      {required Map<String, dynamic> messageData}) async {
    // debugPrint("MESSAGE DATA:- $messageData");

    final ChatMessage chatMessage = ChatMessage.fromJson(messageData);

    final UserBloc userBloc = Provider.of<UserBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);

    /// When any Message came we will check the author if the Author is
    /// current user then we will not update chat count
    if (chatMessage.author != userBloc.user.userName) {
      final MainSocketMessageModel messageModel =
          MainSocketMessageModel.fromJson(messageData);

      // {body: test, data: {"replied_to":null,"author":"japa","kind":"text","deleted_for_author":false,"check_id":"9a8878b3-793d-46a4-8a43-8c07f470fa91","read_by_recipient":false,"created_at":"2022-09-26T10:34:31.694323+01:00","delivered":false,"was_edited":false,"type":"chatroom_message",
      // "read_by_author":true,"updated_at":"2022-09-26T10:34:31.694292+01:00","meta_data":{},"to_customer_avatar":"","id":"938d70c6-6a79-4d2d-a460-044b1e42ec32","text":"test","deleted_for_recipient":false,
      // "conversation":"7d3ceb51-1f09-467d-a29e-b95256a06fc7","from_customer_avatar":"http:\/\/cdn.slydo.co.global.prod.fastly.net\/media\/customer\/avatar\/1519ace0-54d6-4589-a038-6d5b0dac2e3d.jpg"},
      // title: Slydo Notification, actions: /chat-screen/7d3ceb51-1f09-467d-a29e-b95256a06fc7,
      // image: http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/1519ace0-54d6-4589-a038-6d5b0dac2e3d.jpg}

      final String hashedMessage =
          generateHashedMessage(jsonEncode(messageModel.toHashedJson()));
      await ChatUserManager().addUser(
          conversationId:
              messageData["conversation"] ?? messageData["conversation_id"]);

      await ChatUserManager().updateChatUserMessageCount(
          conversationId: messageModel.conversation,
          hashedMessage: hashedMessage);
      return;
    }
  }

  void showNudgeAlertToUser({Map<String, dynamic>? messageData}) async {
    final String hashTheMessage = generateHashedMessage(message!);

    /// if This message is already in the list we will return
    if (_hashedNudgingMessages.contains(hashTheMessage)) {
      return;
    }
    _hashedNudgingMessages.add(hashTheMessage);

    ///{check_id: ae13214e-de96-49e5-95b3-5642fadbeb5c,
    /// conversation_id: 3fe1e3b6-5802-4ade-b4f3-8f21d7b8ebd7,
    /// author: black,
    /// recipient: abiola.rasheed.2,
    /// created_at: 2021-02-12 09:06:36.417618Z,
    /// type: nudge_user,
    /// username: black}

    final UserBloc userBloc = Provider.of<UserBloc>(
        myGlobals.scaffoldKey.currentContext!,
        listen: false);

    /// if current user is not author of the nudge then we play nudge sound
    if (userBloc.user.userName != messageData!["author"]) {
      final MainSocketProvider mainSocketProvider =
          Provider.of<MainSocketProvider>(myGlobals.scaffoldKey.currentContext!,
              listen: false);

      /// if user is on the chat screen of the user who is nudging then we will not play sound
      if (mainSocketProvider.currentConversationId !=
          messageData["conversation_id"]) {
        // debugPrint("author ${messageData["author"]}");

        /// if nudge alert is Already open then we will not open second nudge alert
        // debugPrint(
        //     "nudgingUsers.contains(messageData['author'])  ${_nudgingUsers.contains(messageData["author"])}");
        if (!_nudgingUsers.contains(messageData["author"])) {
          final ChatConversation chatConversation =
              await UserAuth().fetchContactProfile(messageData["author"]);

          _nudgingUsers.add(messageData["author"]);
          final String? audioPlayerId =
              MessageSoundPlayer(message: message).playSound();
          _audioPlayers.add(audioPlayerId);

          if (_nudgeAlertTimer?.isActive ?? false) {
            _nudgeAlertTimer!.cancel();
          }

          /// dispose the audio player if user not press anything
          _nudgeAlertTimer = Timer(nudgeAlertDuration, () {
            _nudgingUsers.remove(messageData["author"]);

            Navigator.of(myGlobals.scaffoldKey.currentContext!).pop();

            /// dispose the audio player
            AssetsAudioPlayer.withId(audioPlayerId).dispose();
          });

          final bool? result = await showDialogBoxWithImageForNudge(
            context: myGlobals.scaffoldKey.currentContext,
            iconBgColor: mateRed,
            iconColor: Colors.white,
            iconTwoBgColor: navyBlue,
            iconTwoColor: Colors.white,
            firstActionPrimary: false,
            title: "${chatConversation.fullName}",
            description: "${chatConversation.userName} is nudging you",
            image: chatConversation.avatar,
            actionOneIcon: SlydoAppIcon.remove,
            actionTwoIcon: SlydoAppIcon.text_message,
          );

          _nudgingUsers.remove(messageData["author"]);

          /// dispose the audio player
          AssetsAudioPlayer.withId(audioPlayerId).dispose();

          /// stop timer when get any action from the user
          if (_nudgeAlertTimer?.isActive ?? false) {
            _nudgeAlertTimer!.cancel();
          }

          if (result != null) {
            // debugPrint("result>>>>> $result");
            if (result) {
              /// send Nudge acknowledgement to author that recipient have accepted that nudge and online now
              sendNudgeAcknowledgement(
                  currentUser: userBloc,
                  author: chatConversation,
                  type: "Accepted");

              Navigator.of(myGlobals.scaffoldKey.currentContext!)
                  .popUntil(ModalRoute.withName('/dashboard'));

              Navigator.pushNamed(
                  myGlobals.scaffoldKey.currentContext!, '/chat-screen',
                  arguments: {"searchedUser": chatConversation});
            } else {
              // debugPrint("else executed");

              /// send Nudge acknowledgement to author that recipient have canceled that nudge and he is busy
              sendNudgeAcknowledgement(
                  currentUser: userBloc,
                  author: chatConversation,
                  type: "Canceled");
            }
          }
        }
      }
    } else {
      // debugPrint("=================== $messageData");

      final ChatShakeDetection chatShakeDetection =
          Provider.of<ChatShakeDetection>(myGlobals.scaffoldKey.currentContext!,
              listen: false);
      chatShakeDetection.showShakingDialog();
    }
  }

  void sendNudgeAcknowledgement(
      {required ChatConversation author,
      required UserBloc currentUser,
      String? type}) {
    final Map<String, dynamic> data = {
      "check_id": const Uuid().v4(),
      "conversation_id": author.conversationId,
      "author": currentUser.user.userName,
      "author_avatar": currentUser.user.avatar,
      "recipient": author.userName,
      "created_at": DateTime.now().toUtc().toString(),
      "acknowledgement_type": type,
      "type": "stop_nudging",
    };
    sendDataToSocket(data);
  }

  Future<bool> sendDataToSocket(Map<String, dynamic> data) async {
    final MainSocketProvider mainSocketProvider =
        Provider.of<MainSocketProvider>(myGlobals.scaffoldKey.currentContext!,
            listen: false);

    await mainSocketProvider.add(data);

    return true;
  }

  void stopNudgeAlertToUser({Map<String, dynamic>? messageData}) {
    final String hashTheMessage = generateHashedMessage(message!);

    // debugPrint("Message dat c>>>>> $messageData");

    /// if This message is already in the list we will return
    if (_hashedNudgingMessages.contains(hashTheMessage)) {
      return;
    }
    _hashedNudgingMessages.add(hashTheMessage);

    final UserBloc userBloc = Provider.of<UserBloc>(
        myGlobals.scaffoldKey.currentContext!,
        listen: false);

    /// if current user is not author of the nudge then we play nudge sound
    if (userBloc.user.userName != messageData!["author"]) {
      /// if nudge alert is Already open then we will not open second nudge alert
      // debugPrint(
      //     "nudgingUsers.contains(messageData['author'])  ${_nudgingUsers.contains(messageData["author"])}");
      //
      // debugPrint(
      //     "nudgingUsers.contains(messageData['recipient'])  ${_nudgingUsers.contains(messageData["recipient"])}");
      if (_nudgingUsers.contains(messageData["author"])) {
        _nudgingUsers.remove(messageData["author"]);

        Navigator.of(myGlobals.scaffoldKey.currentContext!).pop();

        /// dispose the audio player
        AssetsAudioPlayer.withId(messageData["author"]).dispose();
      } else if (messageData.containsKey("acknowledgement_type")) {
        final ChatShakeDetection chatShakeDetection =
            Provider.of<ChatShakeDetection>(
                myGlobals.scaffoldKey.currentContext!,
                listen: false);
        chatShakeDetection.stopAlertDialog();

        showToast(
            message:
                "${messageData["author"]} has ${messageData["acknowledgement_type"]} your Nudge !!");
      }
    }
  }

  void dispose() {
    for (var element in _audioPlayers) {
      AssetsAudioPlayer.withId(element).dispose();
    }

    _audioPlayers.clear();
    _nudgingUsers.clear();
    _hashedNudgingMessages.clear();
  }

  Future<void> updateConnectionListOrder(
      {String? conversationId,
      required Map<String, dynamic> messageData}) async {
    if (messageData.containsKey("created_at")) {
      final DateTime dateTime =
          DateTime.parse(messageData["created_at"]).toLocal();
      final int time = dateTime.millisecondsSinceEpoch;

      // debugPrint("Last message Time => $time");

      final ConnectionListBloc connectionListBloc =
          Provider.of<ConnectionListBloc>(myGlobals.scaffoldKey.currentContext!,
              listen: false);

      await connectionListBloc.updateLastMessageTime(
          conversationId: conversationId, time: time);
    }
  }

  void sendAcknowledgementOfMessageThroughSocket(
      {String? checkId, String? conversationId}) {
    final UserBloc userBloc = Provider.of<UserBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);

    final Map<String, dynamic> data = {
      "check_id": checkId,
      "type": "acknowledge_message",
      "conversation_id": conversationId,
      "username": userBloc.user.userName
    };

    sendDataToSocket(data);
  }

  Future<void> sendAcknowledgementOfMessageThroughHttp(
      {String? checkId, String? conversationId}) async {
    final Map<String, dynamic> data = {
      "check_id": checkId,
      "conversation_id": conversationId,
    };

    final List<Map<String, dynamic>> messages = [];
    messages.add(data);

    try {
      await MessageAuth().acknowledgeMessagesToServer(dataToBeSent: messages);
    } catch (e) {
      return Future.error("");
    }
  }

  Future<void> logoutUser() async {
    Navigator.of(myGlobals.navigationKey.currentContext!)
        .popUntil(ModalRoute.withName('/splash'));

    Navigator.of(myGlobals.navigationKey.currentContext!)
        .pushNamed(Routes.LOGIN, arguments: {"isLoginOut": true});

    showUserLogoutCard(context: myGlobals.navigationKey.currentContext!);

    final BackgroundFetchStopBloc backgroundFetchBloc =
        Provider.of<BackgroundFetchStopBloc>(
            myGlobals.navigationKey.currentContext!,
            listen: false);

    backgroundFetchBloc.isAllowed = false;

    emptyBasketCart();
    SharedPreferences _sharedPreferences;

    MainSocketMessageHandler().dispose();

    await AuthService().logOut();

    CacheManager().deleteCache(clearAll: true);
    final MainSocketProvider socketProvider = Provider.of<MainSocketProvider>(
        myGlobals.navigationKey.currentContext!,
        listen: false);
    await socketProvider.close();

    await PushNotificationService().logout();

    final BankAccountBloc bankAccountBloc = Provider.of<BankAccountBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);
    bankAccountBloc.bankAccount = BankAccount();

    final DashboardBloc dashboardBloc = Provider.of<DashboardBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);
    try {
      dashboardBloc.index = 0;
    } catch (e) {
      debugPrint("===>$e");
    }
    _sharedPreferences = await SharedPreferences.getInstance();
    _sharedPreferences.setBool('isLoggedOut', true);
    // await _sharedPreferences.clear();

    /// clearing all data when user is logout
    await SecureStorage().clear();
  }

  void emptyBasketCart() {
    final BasketBloc basketBloc = Provider.of<BasketBloc>(
        myGlobals.navigationKey.currentContext!,
        listen: false);
    basketBloc.items.clear();
    basketBloc.total = 0;
  }
}
