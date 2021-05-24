import 'dart:convert';

import 'package:Slydo/screens/more_apps/messaging/chat/models/GroupDetailModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/Participant.dart';

/// Model for user's connection list
class ChatConversation {
  List<String> adminUsers;
  String avatar;
  List<String> blockedParticipants;
  String conversationId;
  String description;
  String fullName;
  bool isGroupConversation;
  List<String> mutedParticipants;
  String owner;
  List<String> participants;
  String qrCode;
  String type;
  String userName;

  ChatConversation(
      {this.adminUsers = const [],
      this.avatar,
      this.blockedParticipants = const [],
      this.conversationId,
      this.description,
      this.fullName,
      this.isGroupConversation,
      this.mutedParticipants = const [],
      this.owner,
      this.participants = const [],
      this.qrCode,
      this.type,
      this.userName});

  /// Creating ChatConversation From Server Payload
  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      adminUsers: json['admin_users'] != null
          ? new List<String>.from(json['admin_users'])
          : [],
      avatar: json['avatar'],
      blockedParticipants: json['blocked_participants'] != null
          ? new List<String>.from(json['blocked_participants'])
          : [],
      conversationId: json['conversation_id'],
      description: json['description'] ?? "",
      fullName: json['full_name'],
      isGroupConversation: json['is_group_conversation'],
      mutedParticipants: json['muted_participants'] != null
          ? new List<String>.from(json['muted_participants'])
          : [],
      owner: json['owner'] == "" || json['owner'] == null ? '' : json['owner'],
      participants: json['participants'] != null
          ? new List<String>.from(json['participants'])
          : [],
      qrCode: json['qr_code'] == "" || json['qr_code'] == null
          ? ''
          : json['qr_code'],
      type: json['type'],
      userName: json['username'],
    );
  }

  /// Creating Server Payload From ChatConversation
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['conversation_id'] = this.conversationId;
    data['description'] = this.description;
    data['full_name'] = this.fullName;
    data['is_group_conversation'] = this.isGroupConversation;
    data['owner'] = this.owner;
    data['qr_code'] = this.qrCode;
    data['type'] = this.type;
    data['username'] = this.userName;
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
      data['participants'] = this.participants;
    }
    return data;
  }

  /// Creating ChatConversation From DB Payload
  factory ChatConversation.fromDBJson(Map<String, dynamic> json) {
    return ChatConversation(
      adminUsers: json['admin_users'] != null
          ? new List<String>.from(jsonDecode(json['admin_users']))
          : [],
      avatar: json['avatar'],
      blockedParticipants: json['blocked_participants'] != null
          ? new List<String>.from(jsonDecode(json['blocked_participants']))
          : [],
      conversationId: json['conversation_id'],
      description: json['description'],
      fullName: json['full_name'],
      isGroupConversation: json['is_group_conversation'] == 1 ? true : false,
      mutedParticipants: json['muted_participants'] != null
          ? new List<String>.from(jsonDecode(json['muted_participants']))
          : [],
      owner: json['owner'],
      participants: json['participants'] != null
          ? new List<String>.from(jsonDecode(json['participants']))
          : [],
      qrCode: json['qr_code'],
      type: json['type'],
      userName: json['username'],
    );
  }

  /// Creating DB Payload From ChatConversation
  Map<String, dynamic> toDBJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['conversation_id'] = this.conversationId;
    data['description'] = this.description;
    data['full_name'] = this.fullName;
    data['is_group_conversation'] = this.isGroupConversation ? 1 : 0;
    data['owner'] = this.owner;
    data['qr_code'] = this.qrCode;
    data['type'] = this.type;
    data['username'] = this.userName;
    if (this.adminUsers != null) {
      data['admin_users'] = jsonEncode(this.adminUsers);
    }
    if (this.blockedParticipants != null) {
      data['blocked_participants'] = jsonEncode(this.blockedParticipants);
    }
    if (this.mutedParticipants != null) {
      data['muted_participants'] = jsonEncode(this.mutedParticipants);
    }
    if (this.participants != null) {
      data['participants'] = jsonEncode(this.participants);
    }

    return data;
  }

  /// Creating ChatConversation From GROUP DETAIL Model Payload
  factory ChatConversation.fromGroupDetailModel(
      GroupDetailModel groupDetailModel) {
    return ChatConversation(
      adminUsers: groupDetailModel.adminUsers,
      avatar: groupDetailModel.avatar,
      blockedParticipants: groupDetailModel.blockedParticipants,
      conversationId: groupDetailModel.conversationId,
      description: groupDetailModel.description ?? "",
      fullName: groupDetailModel.fullName,
      isGroupConversation: groupDetailModel.isGroupConversation,
      mutedParticipants: groupDetailModel.mutedParticipants,
      owner: groupDetailModel.owner,
      participants: getParticipants(groupDetailModel.participants),
      qrCode: "",
      type: groupDetailModel.type,
      userName: groupDetailModel.username,
    );
  }

  static List<String> getParticipants(List<Participant> participants) {
    return participants.map((e) => e.userName).toList();
  }
}
