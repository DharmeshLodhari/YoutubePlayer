class AttachmentItemModel {
  String id;
  String title;

  AttachmentItemModel({required this.id, required this.title});

  factory AttachmentItemModel.fromJson(Map<String, dynamic> json) {
    return AttachmentItemModel(id: json['id'], title: json['name']);
  }
}
