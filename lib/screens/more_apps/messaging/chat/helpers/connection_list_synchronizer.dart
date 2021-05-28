import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/helpers/connection_list_manager.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/user_profile/user_auth.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ConnectionSynchronizer {
  static final ConnectionSynchronizer _connectionSynchronizer =
      ConnectionSynchronizer._internal();

  ConnectionSynchronizer._internal();

  factory ConnectionSynchronizer() {
    return _connectionSynchronizer;
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

  void update() async {
    ChatConversation chatConversation =
        await ConnectionListManager().getLastChatConversation();

    if (chatConversation == null) return;

    debugPrint("ChatConversation:- ${chatConversation.toJson()}");

    await UserAuth().fetchMissedContact(
        conversationId: chatConversation.conversationId,
        createdAt: chatConversation.createdAt);
  }
}
