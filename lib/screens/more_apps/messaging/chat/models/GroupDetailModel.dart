import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/Participant.dart';

class GroupDetailModel {
  List<String> adminUsers;
  String avatar;
  List<String> blockedParticipants;
  String conversationId;
  String fullName;
  bool isGroupConversation;
  String createdAt;
  List<String> mutedParticipants;
  List<Participant> participants;
  String type;
  String username;
  String owner;
  String description;

  GroupDetailModel(
      {this.adminUsers = const [],
      this.avatar,
      this.blockedParticipants = const [],
      this.conversationId,
      this.fullName,
      this.isGroupConversation,
      this.mutedParticipants = const [],
      this.participants = const [],
      this.type,
      this.createdAt,
      this.username,
      this.owner,
      this.description});

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) {
    return GroupDetailModel(
        adminUsers: json['admin_users'] != null
            ? new List<String>.from(json['admin_users'])
            : [],
        avatar: json['avatar'],
        blockedParticipants: json['blocked_participants'] != null
            ? new List<String>.from(json['blocked_participants'])
            : [],
        conversationId: json['conversation_id'],
        fullName: json['full_name'],
        createdAt: json['created_at'],
        isGroupConversation: json['is_group_conversation'],
        mutedParticipants: json['muted_participants'] != null
            ? new List<String>.from(json['muted_participants'])
            : [],
        participants: json['participants'] != null
            ? (json['participants'] as List)
                .map((i) => Participant.fromJson(i))
                .toList()
            : [],
        type: json['type'],
        username: json['username'],
        owner: json['owner'],
        description: json['description'] ?? "");
  }

  factory GroupDetailModel.fromChatConversation(
      ChatConversation chatConversation) {
    return GroupDetailModel(
        adminUsers: chatConversation.adminUsers,
        avatar: chatConversation.avatar,
        blockedParticipants: chatConversation.blockedParticipants,
        conversationId: chatConversation.conversationId,
        fullName: chatConversation.fullName,
        isGroupConversation: chatConversation.isGroupConversation,
        mutedParticipants: chatConversation.mutedParticipants,
        participants: [],
        createdAt: chatConversation.createdAt,
        type: chatConversation.type,
        username: chatConversation.userName,
        owner: chatConversation.owner,
        description: chatConversation.description);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['conversation_id'] = this.conversationId;
    data['full_name'] = this.fullName;
    data['is_group_conversation'] = this.isGroupConversation;
    data['type'] = this.type;
    data['username'] = this.username;
    data['owner'] = this.owner;
    data['description'] = this.description;
    data['created_at'] = this.createdAt;
    if (this.adminUsers != null) {
      data['admin_users'] = this.adminUsers;
    }
    if (this.blockedParticipants != null) {
      data['blocked_participants'] = this.blockedParticipants;
    }
    if (this.mutedParticipants != null) {
      data['muted_participants'] = this.mutedParticipants;
    }
    if (this.participants != null) {
      data['participants'] = this.participants.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
