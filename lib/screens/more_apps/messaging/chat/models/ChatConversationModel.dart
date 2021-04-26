class ChatConversationModel {
  List<String> adminUsers;
  String avatar;
  List<String> blockedParticipants;
  String conversationId;
  String fullName;
  List<String> mutedParticipants;
  List<String> participants;
  bool isGroupConversation;
  String type;
  String username;

  ChatConversationModel(
      {this.adminUsers = const [],
      this.avatar,
      this.blockedParticipants = const [],
      this.conversationId,
      this.fullName,
      this.mutedParticipants = const [],
      this.participants = const [],
      this.isGroupConversation,
      this.type,
      this.username});

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      adminUsers: json['admin_users'] != null
          ? new List<String>.from(json['admin_users'])
          : null,
      avatar: json['avatar'],
      isGroupConversation: json['is_group_conversation'],
      blockedParticipants: json['blocked_participants'] != null
          ? new List<String>.from(json['blocked_participants'])
          : null,
      conversationId: json['conversation_id'],
      fullName: json['full_name'],
      mutedParticipants: json['muted_participants'] != null
          ? new List<String>.from(json['muted_participants'])
          : null,
      participants: json['participants'] != null
          ? new List<String>.from(json['participants'])
          : null,
      type: json['type'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['conversation_id'] = this.conversationId;
    data['full_name'] = this.fullName;
    data['type'] = this.type;
    data['username'] = this.username;
    data['is_group_conversation'] = this.isGroupConversation;
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
}
