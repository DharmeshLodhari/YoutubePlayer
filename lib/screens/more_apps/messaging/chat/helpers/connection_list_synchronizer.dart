import 'dart:developer';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/connection_list_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

/// For synchronizing the the user's connection list From server to db
class ConnectionSynchronizer {
  static final ConnectionSynchronizer _connectionSynchronizer =
      ConnectionSynchronizer._internal();

  ConnectionSynchronizer._internal();

  factory ConnectionSynchronizer() {
    return _connectionSynchronizer;
  }

  static String? _next = "";
  static String? _previous = "";

  Future<void> fetch({bool isRefresh = false}) async {
    log("CHAT SYNCHRONIZER FETCH");
    if (isRefresh) {
      _next = "";
      _previous = "";
    }

    final MyGlobals myGlobals = MyGlobals();
    final BuildContext context = myGlobals.navigationKey.currentContext!;

    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(context, listen: false);
    if (_next != null) {
      final Map<String, dynamic>? result =
          await UserAuth().contacts(_next, _previous).catchError((error) {
        debugPrint("ERROR:- $error");
      });

      if (result == null) return;
      _next = result['next'];
      _previous = result['previous'];

      final List tempList = result['results'];

      final List<ChatConversation> users = [];

      tempList
          .forEach((element) => users.add(ChatConversation.fromJson(element)));

      debugPrint('USERS ::: $users');

      await connectionListBloc.setConnectionUsers(users: users);

      if (_next != null) {
        await fetch();
      }
      return Future.value();
    }
  }

  Future<void> update() async {
    log("CHAT SYNCHRONIZER UPDATE");
    final ChatConversation? chatConversation = await ConnectionListManager()
        .getLastChatConversation()
        .catchError((error) {
      debugPrint("ERROR:- While calling Contact Synchronizer $error");
    });

    if (chatConversation == null) return;

    debugPrint(
        "Last ChatConversation:- ${chatConversation.fullName}  ${chatConversation.userName} ");

    ///[{"id":"18d67b2b-c79f-4b8c-978c-2d12cdc4f780","owner":"brijesh.sakariya","group_name":"test beta three","description":"Beta three","banner":"https://slydo-assets.s3.amazonaws.com/media/image_cropper_1622353806759.jpg","participants":["abiola.rasheed.2","black","brijesh.sakariya","pankaj.sakariya"],"blocked_participants":null,"muted_participants":null,"admin_users":["brijesh.sakariya"],"is_group_conversation":true,"updated_at":"2021-05-30T06:51:11.016495+01:00","created_at":"2021-05-30T06:50:16.061634+01:00"},{"id":"14fd3371-9358-4067-b19c-f309123cbed1","owner":"brijesh.sakariya","group_name":"Test Group Beta","description":"Hello Test Group","banner":"https://slydo-assets.s3.amazonaws.com/media/image_cropper_1622353494477.jpg","participants":["abiola.rasheed.2","black","brijesh.sakariya","pankaj.sakariya"],"blocked_participants":null,"muted_participants":null,"admin_users":["brijesh.sakariya"],"is_group_conversation":true,"updated_at":"2021-05-30T06:45:19.697305+01:00","created_at":"2
    final List? chatConversations = await UserAuth().fetchMissedContact(
        conversationId: chatConversation.conversationId,
        createdAt: chatConversation.createdAt!);

    if (chatConversations == null) return;

    final List<ChatConversation> chatConversationToBeAdded = [];
    chatConversations.forEach((element) {
      chatConversationToBeAdded.add(ChatConversation.fromJson(element));
    });

    if (chatConversations.isNotEmpty) {
      await ConnectionListManager()
          .saveMissedConnectionsToDB(connections: chatConversationToBeAdded);
    }
    return Future.value();
  }
}
