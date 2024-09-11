import 'package:Slydo/screens/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/messaging/chat/models/participant_model.dart';

class GroupDetailModel {
  List<String?> adminUsers;
  String? avatar;
  String? banner;
  List<String?> blockedParticipants;
  String? conversationId;
  String? fullName;
  bool? isGroupConversation;
  String? createdAt;
  List<String?> mutedParticipants;
  List<Participant> participants;
  String? type;
  String? conversationType;
  String? username;
  String? owner;
  String? description;
  bool? isVerified;

  bool? isPublicGroup;
  int? ageRestriction;
  int? groupSubscriptionFees;
  int? maxAllowedUser;
  String? groupSubscriptionCurrency;

  GroupDetailModel(
      {this.adminUsers = const [],
      this.avatar,
      this.banner,
      this.blockedParticipants = const [],
      this.conversationId,
      this.fullName,
      this.isGroupConversation,
      this.mutedParticipants = const [],
      this.participants = const [],
      this.type,
      this.conversationType,
      this.createdAt,
      this.username,
      this.owner,
      this.isVerified = false,
      this.description,
      this.isPublicGroup = false,
      this.groupSubscriptionCurrency,
      this.maxAllowedUser,
      this.groupSubscriptionFees,
      this.ageRestriction});

  factory GroupDetailModel.fromJson(Map<String, dynamic> json) {
    return GroupDetailModel(
      adminUsers: json['admin_users'] != null
          ? List<String>.from(json['admin_users'])
          : [],
      avatar: json['avatar'],
      banner: json['banner'],
      blockedParticipants: json['blocked_participants'] != null
          ? List<String>.from(json['blocked_participants'])
          : [],
      conversationId: json['conversation_id'],
      fullName: json['full_name'],
      createdAt: json['created_at'],
      isGroupConversation: json['is_group_conversation'],
      mutedParticipants: json['muted_participants'] != null
          ? List<String>.from(json['muted_participants'])
          : [],
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((i) => Participant.fromJson(i))
              .toList()
          : [],
      type: json['type'],
      conversationType: json['conversation_type'],
      username: json['username'],
      owner: json['owner'],
      isVerified: json['is_verified'],
      description: json['description'] ?? "",
      isPublicGroup: json["is_public_group"],
      ageRestriction: json["age_restriction"],
      groupSubscriptionFees: json["group_subscription_fee"],
      maxAllowedUser: json["group_max_allowed_users"],
      groupSubscriptionCurrency: json["group_subscription_currency"],
    );
  }

  factory GroupDetailModel.fromChatConversation(
      ChatConversation chatConversation) {
    return GroupDetailModel(
        adminUsers: chatConversation.adminUsers,
        avatar: chatConversation.avatar,
        banner: chatConversation.banner,
        blockedParticipants: chatConversation.blockedParticipants,
        conversationId: chatConversation.conversationId,
        fullName: chatConversation.fullName,
        isGroupConversation: chatConversation.isGroupConversation,
        mutedParticipants: chatConversation.mutedParticipants,
        participants: [],
        createdAt: chatConversation.createdAt,
        type: chatConversation.type,
        conversationType: chatConversation.conversationType,
        username: chatConversation.userName,
        owner: chatConversation.owner,
        isVerified: chatConversation.isVerified,
        description: chatConversation.description);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['avatar'] = avatar;
    data['banner'] = banner;
    data['conversation_id'] = conversationId;
    data['full_name'] = fullName;
    data['is_group_conversation'] = isGroupConversation;
    data['type'] = type;
    data['conversation_type'] = conversationType;
    data['username'] = username;
    data['owner'] = owner;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['admin_users'] = adminUsers;
    data['blocked_participants'] = blockedParticipants;
    data['muted_participants'] = mutedParticipants;
    data['is_verified'] = isVerified;
    data['participants'] = participants.map((v) => v.toJson()).toList();
    return data;
  }
}
