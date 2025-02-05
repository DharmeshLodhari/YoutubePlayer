class ChatMessageAction {
  bool? isDeletable;
  bool? isEditable;
  bool? isReplyable;
  bool? isCopyable;
  String? message;

  ChatMessageAction(
      {this.isDeletable = false,
      this.isEditable = false,
      this.isReplyable = false,
      this.isCopyable = false,
      required this.message});

  factory ChatMessageAction.fromJson(Map<String, dynamic> json) {
    return ChatMessageAction(
      isDeletable: json['isDeletable'],
      isEditable: json['isEditable'],
      isReplyable: json['isReplyable'],
      isCopyable: json['isCopyable'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isDeletable'] = isDeletable;
    data['isEditable'] = isEditable;
    data['isReplyable'] = isReplyable;
    data['message'] = message;
    return data;
  }
}
