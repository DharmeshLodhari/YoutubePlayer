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
  String username;

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
      this.qrCode = "",
      this.type,
      this.username});

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      adminUsers: json['admin_users'] != null
          ? new List<String>.from(json['admin_users'])
          : null,
      avatar: json['avatar'],
      blockedParticipants: json['blocked_participants'] != null
          ? new List<String>.from(json['blocked_participants'])
          : null,
      conversationId: json['conversation_id'],
      description: json['description'],
      fullName: json['full_name'],
      isGroupConversation: json['is_group_conversation'],
      mutedParticipants: json['muted_participants'] != null
          ? new List<String>.from(json['muted_participants'])
          : null,
      owner: json['owner'],
      participants: json['participants'] != null
          ? new List<String>.from(json['participants'])
          : null,
      qrCode: json['qr_code'],
      type: json['type'],
      username: json['username'],
    );
  }

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
    data['username'] = this.username;
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
