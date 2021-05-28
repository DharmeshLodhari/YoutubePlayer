import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/GroupDetailModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/Participant.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// {meta_data:
/// {action: add_admin_user,
/// users: [null],
/// conversation_id: 75ed0e26-c837-407a-bf8e-6d2f1b35a8e0,
/// author: brijesh.sakariya},
/// type: group_conversation_admin_actions}

class ChatGroupActionManager {
  Map<String, dynamic> message;

  ChatGroupActionManager({this.message}) {
    handleMessageAction();
  }

  //perform action according to action type
  void handleMessageAction() {
    String action = message['meta_data']['action'];

    switch (action) {
      case "add_admin_user":
        addAdminUser();
        break;

      case "remove_admin_user":
        removeAdminUser();
        break;

      case "mute_participant":
        muteParticipant();
        break;

      case "unmute_participant":
        unMuteParticipant();
        break;

      case "block_participants":
        blockParticipant();
        break;

      case "unblock_participants":
        unblockParticipant();
        break;

      case "add_user":
        addParticipant();
        break;

      case "remove_user":
        removeParticipant();
        break;

      case "exit_group":
        exitConversation();
        break;

      case "delete_group":
        deleteGroup();
        break;

      default:
        debugPrint("UNKNOWN ACTION TYPE==> $action MESSAGE: $message");
    }
  }

  void addAdminUser() {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        MyGlobals().navigationKey.currentContext,
        listen: false);

    ChatConversation chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      List users = message['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      String user = users.first.toString();

      if (!chatConversation.adminUsers.contains(user)) {
        chatConversation.adminUsers.add(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
  }

  void removeAdminUser() {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        MyGlobals().navigationKey.currentContext,
        listen: false);

    ChatConversation chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      List users = message['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      String user = users.first.toString();

      if (chatConversation.adminUsers.contains(user)) {
        chatConversation.adminUsers.remove(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
  }

  void muteParticipant() {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        MyGlobals().navigationKey.currentContext,
        listen: false);

    ChatConversation chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      List users = message['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      String user = users.first.toString();

      if (!chatConversation.mutedParticipants.contains(user)) {
        chatConversation.mutedParticipants.add(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
  }

  void unMuteParticipant() {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        MyGlobals().navigationKey.currentContext,
        listen: false);

    ChatConversation chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      List users = message['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      String user = users.first.toString();

      if (chatConversation.mutedParticipants.contains(user)) {
        chatConversation.mutedParticipants.remove(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
  }

  void blockParticipant() {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        MyGlobals().navigationKey.currentContext,
        listen: false);

    ChatConversation chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      List users = message['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      String user = users.first.toString();

      if (!chatConversation.blockedParticipants.contains(user)) {
        chatConversation.blockedParticipants.add(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
  }

  void unblockParticipant() {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        MyGlobals().navigationKey.currentContext,
        listen: false);

    ChatConversation chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      List users = message['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      String user = users.first.toString();

      if (chatConversation.blockedParticipants.contains(user)) {
        chatConversation.blockedParticipants.remove(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
  }

  void addParticipant() {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        MyGlobals().navigationKey.currentContext,
        listen: false);

    ChatConversation chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }

    List users = message['meta_data']['users'];
    if (users.isEmpty) return;
    if (users.first == null || users.first == {}) return;
    Participant user = Participant.fromJson(users.first);

    if (chatConversation != null) {
      if (!chatConversation.participants.contains(user)) {
        chatConversation.participants.add(user.userName);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
    UserBloc userBloc = Provider.of<UserBloc>(
        MyGlobals().navigationKey.currentContext,
        listen: false);

    if (userBloc.user.userName == user.userName) {
      ChatConversation chatConversation =
          ChatConversation.fromJson(users.first['conversation']);
      connectionListBloc.addConnectionUser(chatConversation: chatConversation);
    }
  }

  void removeParticipant() {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        MyGlobals().navigationKey.currentContext,
        listen: false);

    ChatConversation chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      List users = message['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      String user = users.first.toString();

      if (chatConversation.participants.contains(user)) {
        chatConversation.participants.remove(user);

        if (chatConversation.mutedParticipants.contains(user))
          chatConversation.mutedParticipants.remove(user);

        if (chatConversation.blockedParticipants.contains(user))
          chatConversation.blockedParticipants.remove(user);

        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }

      UserBloc userBloc = Provider.of<UserBloc>(
          MyGlobals().navigationKey.currentContext,
          listen: false);
      if (userBloc.user.userName == user) {
        connectionListBloc.deleteChatConversation(
            conversationId: chatConversation.conversationId);
      }
    }
  }

  void exitConversation() {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        MyGlobals().navigationKey.currentContext,
        listen: false);

    ChatConversation chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      List users = message['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      String user = users.first.toString();

      if (chatConversation.participants.contains(user)) {
        chatConversation.participants.remove(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }

      UserBloc userBloc = Provider.of<UserBloc>(
          MyGlobals().navigationKey.currentContext,
          listen: false);
      if (userBloc.user.userName == user) {
        connectionListBloc.deleteChatConversation(
            conversationId: chatConversation.conversationId);
      }
    }
  }

  void deleteGroup() {
    ConnectionListBloc connectionListBloc = Provider.of<ConnectionListBloc>(
        MyGlobals().navigationKey.currentContext,
        listen: false);

    ChatConversation chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      connectionListBloc.deleteChatConversation(
          conversationId: chatConversation.conversationId);
    }
  }
}

class ChatGroupActionManagerForLiveConversation {
  Map<String, dynamic> message;
  bool isChatConversation = false;
  bool isGroupDetailModel = false;
  ChatConversation chatConversationToUpdate;
  GroupDetailModel groupDetailModelToUpdate;

  ChatGroupActionManagerForLiveConversation({this.message});
  //perform action according to action type
  dynamic handleMessageAction(
      {ChatConversation chatConversation, GroupDetailModel groupDetailModel}) {
    String action = message['meta_data']['action'];

    if (chatConversation != null) {
      isChatConversation = true;
      chatConversationToUpdate = chatConversation;
    }
    if (groupDetailModel != null) {
      isGroupDetailModel = true;
      groupDetailModelToUpdate = groupDetailModel;
    }

    switch (action) {
      case "add_admin_user":
        return addAdminUser();
        break;

      case "remove_admin_user":
        return removeAdminUser();
        break;

      case "mute_participant":
        return muteParticipant();
        break;

      case "unmute_participant":
        return unMuteParticipant();
        break;

      case "block_participants":
        return blockParticipant();
        break;

      case "unblock_participants":
        return unBlockParticipant();
        break;

      case "add_user":
        return addParticipant();
        break;

      case "remove_user":
        return removeParticipant();
        break;

      case "exit_group":
        return exitGroup();
        break;

      default:
        debugPrint("UNKNOWN ACTION TYPE==> $action MESSAGE: $message");
        return null;
    }
  }

  dynamic addAdminUser() {
    List users = message['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    String user = users.first.toString();

    if (isChatConversation) {
      if (!chatConversationToUpdate.adminUsers.contains(user)) {
        chatConversationToUpdate.adminUsers.add(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      if (!groupDetailModelToUpdate.adminUsers.contains(user)) {
        groupDetailModelToUpdate.adminUsers.add(user);
        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic removeAdminUser() {
    List users = message['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    String user = users.first.toString();

    if (isChatConversation) {
      if (chatConversationToUpdate.adminUsers.contains(user)) {
        chatConversationToUpdate.adminUsers.remove(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      if (groupDetailModelToUpdate.adminUsers.contains(user)) {
        groupDetailModelToUpdate.adminUsers.remove(user);
        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic muteParticipant() {
    List users = message['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    String user = users.first.toString();

    if (isChatConversation) {
      if (!chatConversationToUpdate.mutedParticipants.contains(user)) {
        chatConversationToUpdate.mutedParticipants.add(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      if (!groupDetailModelToUpdate.mutedParticipants.contains(user)) {
        groupDetailModelToUpdate.mutedParticipants.add(user);
        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic unMuteParticipant() {
    List users = message['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    String user = users.first.toString();

    if (isChatConversation) {
      if (chatConversationToUpdate.mutedParticipants.contains(user)) {
        chatConversationToUpdate.mutedParticipants.remove(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      if (groupDetailModelToUpdate.mutedParticipants.contains(user)) {
        groupDetailModelToUpdate.mutedParticipants.remove(user);
        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic blockParticipant() {
    List users = message['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    String user = users.first.toString();

    if (isChatConversation) {
      if (!chatConversationToUpdate.blockedParticipants.contains(user)) {
        chatConversationToUpdate.blockedParticipants.add(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      if (!groupDetailModelToUpdate.blockedParticipants.contains(user)) {
        groupDetailModelToUpdate.blockedParticipants.add(user);
        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic unBlockParticipant() {
    List users = message['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    String user = users.first.toString();

    if (isChatConversation) {
      if (chatConversationToUpdate.blockedParticipants.contains(user)) {
        chatConversationToUpdate.blockedParticipants.remove(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      if (groupDetailModelToUpdate.blockedParticipants.contains(user)) {
        groupDetailModelToUpdate.blockedParticipants.remove(user);
        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic addParticipant() {
    List users = message['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == {}) return null;
    Participant participant = Participant.fromJson(users.first);

    if (participant != null) {
      if (isChatConversation) {
        if (!chatConversationToUpdate.participants
            .contains(participant.userName)) {
          chatConversationToUpdate.participants.add(participant.userName);
          return chatConversationToUpdate;
        }
      }

      if (isGroupDetailModel) {
        if (!groupDetailModelToUpdate.participants
            .contains(participant.userName)) {
          groupDetailModelToUpdate.participants.add(participant);
          return groupDetailModelToUpdate;
        }
      }
    }

    return null;
  }

  dynamic removeParticipant() {
    List users = message['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    String user = users.first.toString();

    if (isChatConversation) {
      if (chatConversationToUpdate.participants.contains(user)) {
        chatConversationToUpdate.participants.remove(user);

        if (chatConversationToUpdate.mutedParticipants.contains(user))
          chatConversationToUpdate.mutedParticipants.remove(user);

        if (chatConversationToUpdate.blockedParticipants.contains(user))
          chatConversationToUpdate.blockedParticipants.remove(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      Participant participant;
      for (int i = 0; i < groupDetailModelToUpdate.participants.length; i++) {
        if (groupDetailModelToUpdate.participants[i].userName == user) {
          participant = groupDetailModelToUpdate.participants[i];
          break;
        }
      }

      if (participant != null) {
        groupDetailModelToUpdate.participants.remove(participant);

        if (groupDetailModelToUpdate.mutedParticipants.contains(user))
          groupDetailModelToUpdate.mutedParticipants.remove(user);

        if (groupDetailModelToUpdate.blockedParticipants.contains(user))
          groupDetailModelToUpdate.blockedParticipants.remove(user);

        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic exitGroup() {
    List users = message['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    String user = users.first.toString();

    if (isChatConversation) {
      if (chatConversationToUpdate.participants.contains(user)) {
        chatConversationToUpdate.participants.remove(user);

        if (chatConversationToUpdate.mutedParticipants.contains(user))
          chatConversationToUpdate.mutedParticipants.remove(user);

        if (chatConversationToUpdate.blockedParticipants.contains(user))
          chatConversationToUpdate.blockedParticipants.remove(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      Participant participant;
      for (int i = 0; i < groupDetailModelToUpdate.participants.length; i++) {
        if (groupDetailModelToUpdate.participants[i].userName == user) {
          participant = groupDetailModelToUpdate.participants[i];
          break;
        }
      }

      if (participant != null) {
        groupDetailModelToUpdate.participants.remove(participant);

        if (groupDetailModelToUpdate.mutedParticipants.contains(user))
          groupDetailModelToUpdate.mutedParticipants.remove(user);

        if (groupDetailModelToUpdate.blockedParticipants.contains(user))
          groupDetailModelToUpdate.blockedParticipants.remove(user);

        return groupDetailModelToUpdate;
      }
    }
    return null;
  }
}
