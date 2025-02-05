class UpdateGroupDetailModel {
  String? groupConversationId;
  String? avatar;
  String? description;
  String? name;
  UpdateGroupDetailModel(
      {required this.groupConversationId,
      this.avatar,
      this.name,
      this.description});
}
