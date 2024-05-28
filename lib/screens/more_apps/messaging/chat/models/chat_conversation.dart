import 'dart:convert';

import 'package:Slydo/screens/more_apps/messaging/chat/models/group_detail_model.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/participant_model.dart';
import 'package:Slydo/utils/date_time_and_money_converter.dart';
import 'package:flutter/foundation.dart';

/// Model for user's connection list
class ChatConversation {
  List<String?> adminUsers;
  String? avatar;
  String? banner;
  List<String?> blockedParticipants;
  String? conversationId;
  String? description;
  String? fullName;
  bool? isGroupConversation;
  List<String?> mutedParticipants;
  String? createdAt;
  String? owner;
  List<String?> participants;
  String? qrCode;
  String? type;
  String? conversationType;
  String? userName;
  bool? isVerified;

  ChatConversation(
      {this.adminUsers = const [],
      this.avatar,
      this.banner,
      this.blockedParticipants = const [],
      this.conversationId,
      this.description,
      this.fullName,
      this.createdAt,
      this.isGroupConversation,
      this.mutedParticipants = const [],
      this.owner,
      this.participants = const [],
      this.qrCode,
      this.type,
      this.conversationType,
      this.userName,
      this.isVerified = false});

  /// Creating ChatConversation From Server Payload
  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    debugPrint('JSON VE ->> ${json['is_verified']}');
    return ChatConversation(
      adminUsers: json['admin_users'] != null
          ? List<String>.from(json['admin_users'])
          : [],
      avatar: json['avatar'],
      banner: json['banner'],
      blockedParticipants: json['blocked_participants'] != null
          ? List<String>.from(json['blocked_participants'])
          : [],
      isVerified: json['is_verified'] ?? false,
      conversationId: json['conversation_id'],
      description: json['description'] ?? "",
      fullName: json['full_name'] != null ? json['full_name'] : '',
      isGroupConversation: json['is_group_conversation'],
      createdAt: json['created_at'] ?? DateTime.now().toUtc().toIso8601String(),
      mutedParticipants: json['muted_participants'] != null
          ? List<String>.from(json['muted_participants'])
          : [],
      owner: json['owner'] == "" || json['owner'] == null ? '' : json['owner'],
      participants: json['participants'] != null
          ? List<String>.from(json['participants'])
          : [],
      qrCode: json['qr_code'] == "" || json['qr_code'] == null
          ? ''
          : json['qr_code'],
      type: json['type'],
      conversationType: json['conversation_type'],
      userName: json['username'] != null ? json['username'] : '',
    );
  }

  /// Creating Server Payload From ChatConversation
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['avatar'] = avatar;
    data['banner'] = banner;
    data['conversation_id'] = conversationId;
    data['description'] = description;
    data['full_name'] = fullName;
    data['is_group_conversation'] = isGroupConversation;
    data['owner'] = owner;
    data['qr_code'] = qrCode;
    data['created_at'] = createdAt;
    data['type'] = type;
    data['conversation_type'] = conversationType;
    data['username'] = userName;
    data['admin_users'] = adminUsers;
    data['blocked_participants'] = blockedParticipants;
    data['muted_participants'] = mutedParticipants;
    data['participants'] = participants;
    data['is_verified'] = isVerified;
    return data;
  }

  /// Creating ChatConversation From DB Payload
  factory ChatConversation.fromDBJson(Map<String, dynamic> json) {
    return ChatConversation(
      adminUsers: json['admin_users'] != null
          ? List<String>.from(jsonDecode(json['admin_users']))
          : [],
      avatar: json['avatar'],
      banner: json['banner'],
      blockedParticipants: json['blocked_participants'] != null
          ? List<String>.from(jsonDecode(json['blocked_participants']))
          : [],
      conversationId: json['conversation_id'],
      description: json['description'],
      fullName: json['full_name'],
      createdAt: convertMillisecondsSinceEpochToString(json['created_at']),
      isGroupConversation: json['is_group_conversation'] == 1 ? true : false,
      mutedParticipants: json['muted_participants'] != null
          ? List<String>.from(jsonDecode(json['muted_participants']))
          : [],
      owner: json['owner'],
      isVerified: json['is_verified'] == 1 ? true : false,
      participants: json['participants'] != null
          ? List<String>.from(jsonDecode(json['participants']))
          : [],
      qrCode: json['qr_code'],
      type: json['type'],
      conversationType: json['conversation_type'],
      userName: json['username'],
    );
  }

  /// Creating DB Payload From ChatConversation
  Map<String, dynamic> toDBJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['avatar'] = avatar;
    data['banner'] = banner;
    data['conversation_id'] = conversationId;
    data['description'] = description;
    data['full_name'] = fullName;
    data['is_group_conversation'] = isGroupConversation! ? 1 : 0;
    data['owner'] = owner;
    data['qr_code'] = qrCode;
    data['type'] = type;
    data['conversation_type'] = conversationType;
    data['username'] = userName;
    data['created_at'] = convertStringToMillisecondsSinceEpoch(createdAt);
    data['admin_users'] = jsonEncode(adminUsers);
    data['blocked_participants'] = jsonEncode(blockedParticipants);
    data['muted_participants'] = jsonEncode(mutedParticipants);
    data['participants'] = jsonEncode(participants);
    data['is_verified'] = isVerified != null && isVerified! == true ? 1 : 0;

    return data;
  }

  /// Creating ChatConversation From GROUP DETAIL Model Payload
  factory ChatConversation.fromGroupDetailModel(
      GroupDetailModel groupDetailModel) {
    return ChatConversation(
      adminUsers: groupDetailModel.adminUsers,
      avatar: groupDetailModel.avatar,
      banner: groupDetailModel.banner,
      blockedParticipants: groupDetailModel.blockedParticipants,
      conversationId: groupDetailModel.conversationId,
      description: groupDetailModel.description ?? "",
      fullName: groupDetailModel.fullName,
      isGroupConversation: groupDetailModel.isGroupConversation,
      mutedParticipants: groupDetailModel.mutedParticipants,
      createdAt: groupDetailModel.createdAt,
      owner: groupDetailModel.owner,
      isVerified: groupDetailModel.isVerified,
      participants: getParticipants(groupDetailModel.participants),
      qrCode: "",
      type: groupDetailModel.type,
      conversationType: groupDetailModel.conversationType,
      userName: groupDetailModel.username,
    );
  }

  static List<String?> getParticipants(List<Participant> participants) {
    return participants.map((e) => e.userName).toList();
  }

  static ChatConversation fromChatConversation(
      ChatConversation chatConversation) {
    ChatConversation _chatConversation = ChatConversation();
    _chatConversation.adminUsers = chatConversation.adminUsers;
    _chatConversation.avatar = chatConversation.avatar;
    _chatConversation.banner = chatConversation.banner;
    _chatConversation.blockedParticipants =
        chatConversation.blockedParticipants;
    _chatConversation.conversationId = chatConversation.conversationId;
    _chatConversation.description = chatConversation.description;
    _chatConversation.fullName = chatConversation.fullName;
    _chatConversation.isGroupConversation =
        chatConversation.isGroupConversation;
    _chatConversation.createdAt = chatConversation.createdAt;
    _chatConversation.mutedParticipants = chatConversation.mutedParticipants;
    _chatConversation.owner = chatConversation.owner;
    _chatConversation.participants = chatConversation.participants;
    _chatConversation.qrCode = chatConversation.qrCode;
    _chatConversation.type = chatConversation.type;
    _chatConversation.conversationType = chatConversation.conversationType;
    _chatConversation.userName = chatConversation.userName;
    _chatConversation.isVerified = chatConversation.isVerified;

    return _chatConversation;
  }
}
