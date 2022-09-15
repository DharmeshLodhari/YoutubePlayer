class ChannelModel {
  String? id;
  String? owner;
  String? description;
  String? banner;
  int? noOfMembers;
  List<String>? blockedParticipants;
  List<String>? mutedParticipants;
  List<String>? adminUsers;
  String? groupName;
  int? groupSubscriptionFee;
  String? groupSubscriptionCurrency;
  int? groupMaxAllowedUsers;
  bool? isGroupConversation;
  bool? isPublicGroup;
  String? updatedAt;
  String? createdAt;
  bool? isMember;

  ChannelModel(
      {this.id,
      this.owner,
      this.isMember = false,
      this.description,
      this.banner,
      this.noOfMembers,
      this.blockedParticipants,
      this.mutedParticipants,
      this.adminUsers,
      this.groupName,
      this.groupSubscriptionFee,
      this.groupSubscriptionCurrency,
      this.groupMaxAllowedUsers,
      this.isGroupConversation,
      this.isPublicGroup,
      this.updatedAt,
      this.createdAt});

  ChannelModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    owner = json['owner'];
    isMember = json['is_member'] ?? false;
    description = json['description'];
    banner = json['banner'];
    noOfMembers = json['no_of_members'] != null ? json['no_of_members'] : 0;
    mutedParticipants = json['muted_participants'] != null
        ? json['muted_participants'].cast<String>()
        : [];
    blockedParticipants = json['blocked_participants'] != null
        ? json['blocked_participants'].cast<String>()
        : [];
    adminUsers =
        json['admin_users'] != null ? json['admin_users'].cast<String>() : [];
    groupName = json['group_name'];
    groupSubscriptionFee = json['group_subscription_fee'];
    groupSubscriptionCurrency = json['group_subscription_currency'];
    groupMaxAllowedUsers = json['group_max_allowed_users'];
    isGroupConversation = json['is_group_conversation'];
    isPublicGroup = json['is_public_group'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['owner'] = this.owner;
    data['description'] = this.description;
    data['banner'] = this.banner;
    data['no_of_members'] = this.noOfMembers;
    data['blocked_participants'] = this.blockedParticipants;
    data['muted_participants'] = this.mutedParticipants;
    data['admin_users'] = this.adminUsers;
    data['group_name'] = this.groupName;
    data['group_subscription_fee'] = this.groupSubscriptionFee;
    data['group_subscription_currency'] = this.groupSubscriptionCurrency;
    data['group_max_allowed_users'] = this.groupMaxAllowedUsers;
    data['is_group_conversation'] = this.isGroupConversation;
    data['is_public_group'] = this.isPublicGroup;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    return data;
  }
}
