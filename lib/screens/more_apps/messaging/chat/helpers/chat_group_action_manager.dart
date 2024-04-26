import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/group_detail_model.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/participant_model.dart';
import 'package:Slydo/utils/global_key.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// {meta_data:
/// {action: add_admin_user,
/// users: [null],
/// conversation_id: 75ed0e26-c837-407a-bf8e-6d2f1b35a8e0,
/// author: brijesh.sakariya},
/// type: group_conversation_admin_actions}

/// This Class is responsible for performing Group Operations Like Make Admin
/// Block User, Mute participant
class ChatGroupActionManager {
  Map<String, dynamic>? message;

  ChatGroupActionManager({this.message}) {
    handleMessageAction();
  }

  //perform action according to action type
  void handleMessageAction() {
    final String? action = message!['meta_data']['action'];

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

  /// Adding the admin user to Group
  void addAdminUser() {
    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(
            MyGlobals().navigationKey.currentContext!,
            listen: false);

    ChatConversation? chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message!['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      final List users = message!['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      final String user = users.first.toString();

      if (!chatConversation.adminUsers.contains(user)) {
        chatConversation.adminUsers.add(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
  }

  /// Removing the admin user to Group
  void removeAdminUser() {
    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(
            MyGlobals().navigationKey.currentContext!,
            listen: false);

    ChatConversation? chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message!['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      final List users = message!['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      final String user = users.first.toString();

      if (chatConversation.adminUsers.contains(user)) {
        chatConversation.adminUsers.remove(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
  }

  /// Mute the participant in Group
  void muteParticipant() {
    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(
            MyGlobals().navigationKey.currentContext!,
            listen: false);

    ChatConversation? chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message!['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      final List users = message!['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      final String user = users.first.toString();

      if (!chatConversation.mutedParticipants.contains(user)) {
        chatConversation.mutedParticipants.add(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
  }

  /// UnMute the participant in Group
  void unMuteParticipant() {
    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(
            MyGlobals().navigationKey.currentContext!,
            listen: false);

    ChatConversation? chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message!['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      final List users = message!['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      final String user = users.first.toString();

      if (chatConversation.mutedParticipants.contains(user)) {
        chatConversation.mutedParticipants.remove(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
  }

  /// Block the participant in Group
  void blockParticipant() {
    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(
            MyGlobals().navigationKey.currentContext!,
            listen: false);

    ChatConversation? chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message!['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      final List users = message!['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      final String user = users.first.toString();

      if (!chatConversation.blockedParticipants.contains(user)) {
        chatConversation.blockedParticipants.add(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
  }

  /// unblock the participant in Group
  void unblockParticipant() {
    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(
            MyGlobals().navigationKey.currentContext!,
            listen: false);

    ChatConversation? chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message!['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      final List users = message!['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      final String user = users.first.toString();

      if (chatConversation.blockedParticipants.contains(user)) {
        chatConversation.blockedParticipants.remove(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
  }

  /// add the participant in Group
  void addParticipant() {
    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(
            MyGlobals().navigationKey.currentContext!,
            listen: false);

    ChatConversation? chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message!['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }

    final List users = message!['meta_data']['users'];
    if (users.isEmpty) return;
    if (users.first == null || users.first == {}) return;
    final Participant user = Participant.fromJson(users.first);

    if (chatConversation != null) {
      if (!chatConversation.participants.contains(user)) {
        chatConversation.participants.add(user.userName);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }
    }
    final UserBloc userBloc = Provider.of<UserBloc>(
        MyGlobals().navigationKey.currentContext!,
        listen: false);

    if (userBloc.user.userName == user.userName) {
      final ChatConversation chatConversation =
          ChatConversation.fromJson(users.first['conversation']);
      connectionListBloc.addConnectionUser(chatConversation: chatConversation);
    }
  }

  /// remove the participant in Group
  void removeParticipant() {
    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(
            MyGlobals().navigationKey.currentContext!,
            listen: false);

    ChatConversation? chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message!['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      debugPrint("chatConversation:- ${chatConversation.toJson()}");
      final List users = message!['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      final String user = users.first.toString();

      if (chatConversation.participants.contains(user)) {
        chatConversation.participants.remove(user);

        if (chatConversation.mutedParticipants.contains(user)) {
          chatConversation.mutedParticipants.remove(user);
        }

        if (chatConversation.blockedParticipants.contains(user)) {
          chatConversation.blockedParticipants.remove(user);
        }

        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }

      final UserBloc userBloc = Provider.of<UserBloc>(
          MyGlobals().navigationKey.currentContext!,
          listen: false);
      if (userBloc.user.userName == user) {
        connectionListBloc.deleteChatConversation(
            conversationId: chatConversation.conversationId);
      }
    }
  }

  /// exit from the Group
  void exitConversation() {
    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(
            MyGlobals().navigationKey.currentContext!,
            listen: false);

    ChatConversation? chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message!['meta_data']['conversation_id'] ==
          connectionListBloc.connectionUsers[i].conversationId) {
        chatConversation = connectionListBloc.connectionUsers[i];
        break;
      }
    }
    if (chatConversation != null) {
      final List users = message!['meta_data']['users'];
      if (users.isEmpty) return;
      if (users.first == null || users.first == "") return;
      final String user = users.first.toString();

      if (chatConversation.participants.contains(user)) {
        chatConversation.participants.remove(user);
        connectionListBloc.updateChatConversation(
            chatConversation: chatConversation);
      }

      final UserBloc userBloc = Provider.of<UserBloc>(
          MyGlobals().navigationKey.currentContext!,
          listen: false);
      if (userBloc.user.userName == user) {
        connectionListBloc.deleteChatConversation(
            conversationId: chatConversation.conversationId);
      }
    }
  }

  /// delete the group
  void deleteGroup() {
    final ConnectionListBloc connectionListBloc =
        Provider.of<ConnectionListBloc>(
            MyGlobals().navigationKey.currentContext!,
            listen: false);

    ChatConversation? chatConversation;
    for (int i = 0; i < connectionListBloc.connectionUsers.length; i++) {
      if (message!['meta_data']['conversation_id'] ==
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
  Map<String, dynamic>? message;
  bool isChatConversation = false;
  bool isGroupDetailModel = false;
  ChatConversation? chatConversationToUpdate;
  GroupDetailModel? groupDetailModelToUpdate;

  ChatGroupActionManagerForLiveConversation({this.message});
  //perform action according to action type
  dynamic handleMessageAction(
      {ChatConversation? chatConversation,
      GroupDetailModel? groupDetailModel}) {
    final String? action = message!['meta_data']['action'];

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

      case "remove_admin_user":
        return removeAdminUser();

      case "mute_participant":
        return muteParticipant();

      case "unmute_participant":
        return unMuteParticipant();

      case "block_participants":
        return blockParticipant();

      case "unblock_participants":
        return unBlockParticipant();

      case "add_user":
        return addParticipant();

      case "remove_user":
        return removeParticipant();

      case "exit_group":
        return exitGroup();

      default:
        debugPrint("UNKNOWN ACTION TYPE==> $action MESSAGE: $message");
        return null;
    }
  }

  dynamic addAdminUser() {
    final List users = message!['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    final String user = users.first.toString();

    if (isChatConversation) {
      if (!chatConversationToUpdate!.adminUsers.contains(user)) {
        chatConversationToUpdate!.adminUsers.add(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      if (!groupDetailModelToUpdate!.adminUsers.contains(user)) {
        groupDetailModelToUpdate!.adminUsers.add(user);
        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic removeAdminUser() {
    final List users = message!['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    final String user = users.first.toString();

    if (isChatConversation) {
      if (chatConversationToUpdate!.adminUsers.contains(user)) {
        chatConversationToUpdate!.adminUsers.remove(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      if (groupDetailModelToUpdate!.adminUsers.contains(user)) {
        groupDetailModelToUpdate!.adminUsers.remove(user);
        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic muteParticipant() {
    final List users = message!['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    final String user = users.first.toString();

    if (isChatConversation) {
      if (!chatConversationToUpdate!.mutedParticipants.contains(user)) {
        chatConversationToUpdate!.mutedParticipants.add(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      if (!groupDetailModelToUpdate!.mutedParticipants.contains(user)) {
        groupDetailModelToUpdate!.mutedParticipants.add(user);
        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic unMuteParticipant() {
    final List users = message!['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    final String user = users.first.toString();

    if (isChatConversation) {
      if (chatConversationToUpdate!.mutedParticipants.contains(user)) {
        chatConversationToUpdate!.mutedParticipants.remove(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      if (groupDetailModelToUpdate!.mutedParticipants.contains(user)) {
        groupDetailModelToUpdate!.mutedParticipants.remove(user);
        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic blockParticipant() {
    final List users = message!['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    final String user = users.first.toString();

    if (isChatConversation) {
      if (!chatConversationToUpdate!.blockedParticipants.contains(user)) {
        chatConversationToUpdate!.blockedParticipants.add(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      if (!groupDetailModelToUpdate!.blockedParticipants.contains(user)) {
        groupDetailModelToUpdate!.blockedParticipants.add(user);
        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic unBlockParticipant() {
    final List users = message!['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    final String user = users.first.toString();

    if (isChatConversation) {
      if (chatConversationToUpdate!.blockedParticipants.contains(user)) {
        chatConversationToUpdate!.blockedParticipants.remove(user);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      if (groupDetailModelToUpdate!.blockedParticipants.contains(user)) {
        groupDetailModelToUpdate!.blockedParticipants.remove(user);
        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic addParticipant() {
    final List users = message!['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == {}) return null;
    final Participant participant = Participant.fromJson(users.first);

    if (isChatConversation) {
      if (!chatConversationToUpdate!.participants
          .contains(participant.userName)) {
        chatConversationToUpdate!.participants.add(participant.userName);
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      if (!groupDetailModelToUpdate!.participants
          .contains(participant.userName)) {
        groupDetailModelToUpdate!.participants.add(participant);
        return groupDetailModelToUpdate;
      }
    }

    return null;
  }

  dynamic removeParticipant() {
    final List users = message!['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    final String user = users.first.toString();

    if (isChatConversation) {
      if (chatConversationToUpdate!.participants.contains(user)) {
        chatConversationToUpdate!.participants.remove(user);

        if (chatConversationToUpdate!.mutedParticipants.contains(user)) {
          chatConversationToUpdate!.mutedParticipants.remove(user);
        }

        if (chatConversationToUpdate!.blockedParticipants.contains(user)) {
          chatConversationToUpdate!.blockedParticipants.remove(user);
        }
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      Participant? participant;
      for (int i = 0; i < groupDetailModelToUpdate!.participants.length; i++) {
        if (groupDetailModelToUpdate!.participants[i].userName == user) {
          participant = groupDetailModelToUpdate!.participants[i];
          break;
        }
      }

      if (participant != null) {
        groupDetailModelToUpdate!.participants.remove(participant);

        if (groupDetailModelToUpdate!.mutedParticipants.contains(user)) {
          groupDetailModelToUpdate!.mutedParticipants.remove(user);
        }

        if (groupDetailModelToUpdate!.blockedParticipants.contains(user)) {
          groupDetailModelToUpdate!.blockedParticipants.remove(user);
        }

        return groupDetailModelToUpdate;
      }
    }
    return null;
  }

  dynamic exitGroup() {
    final List users = message!['meta_data']['users'];
    if (users.isEmpty) return null;
    if (users.first == null || users.first == "") return null;
    final String user = users.first.toString();

    if (isChatConversation) {
      if (chatConversationToUpdate!.participants.contains(user)) {
        chatConversationToUpdate!.participants.remove(user);

        if (chatConversationToUpdate!.mutedParticipants.contains(user)) {
          chatConversationToUpdate!.mutedParticipants.remove(user);
        }

        if (chatConversationToUpdate!.blockedParticipants.contains(user)) {
          chatConversationToUpdate!.blockedParticipants.remove(user);
        }
        return chatConversationToUpdate;
      }
    }

    if (isGroupDetailModel) {
      Participant? participant;
      for (int i = 0; i < groupDetailModelToUpdate!.participants.length; i++) {
        if (groupDetailModelToUpdate!.participants[i].userName == user) {
          participant = groupDetailModelToUpdate!.participants[i];
          break;
        }
      }

      if (participant != null) {
        groupDetailModelToUpdate!.participants.remove(participant);

        if (groupDetailModelToUpdate!.mutedParticipants.contains(user)) {
          groupDetailModelToUpdate!.mutedParticipants.remove(user);
        }

        if (groupDetailModelToUpdate!.blockedParticipants.contains(user)) {
          groupDetailModelToUpdate!.blockedParticipants.remove(user);
        }

        return groupDetailModelToUpdate;
      }
    }
    return null;
  }
}
