class ChannelModel {
  String? id;
  String? owner;
  String? description;
  String? banner;
  String? avatar;
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
      this.avatar,
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
    noOfMembers = json['no_of_members'] ?? 0;
    avatar = json['avatar'] ?? "";
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['owner'] = owner;
    data['description'] = description;
    data['banner'] = banner;
    data['avatar'] = avatar;
    data['no_of_members'] = noOfMembers;
    data['blocked_participants'] = blockedParticipants;
    data['muted_participants'] = mutedParticipants;
    data['admin_users'] = adminUsers;
    data['group_name'] = groupName;
    data['group_subscription_fee'] = groupSubscriptionFee;
    data['group_subscription_currency'] = groupSubscriptionCurrency;
    data['group_max_allowed_users'] = groupMaxAllowedUsers;
    data['is_group_conversation'] = isGroupConversation;
    data['is_public_group'] = isPublicGroup;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    return data;
  }
}
