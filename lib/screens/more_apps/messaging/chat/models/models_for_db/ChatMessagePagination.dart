class ChatMessagePagination {
  String conversationId;
  int count;
  String next;
  String previous;

  ChatMessagePagination(
      {this.conversationId,
      this.count = 0,
      this.next = "",
      this.previous = ""});

  factory ChatMessagePagination.fromJson(Map<String, dynamic> json) {
    return ChatMessagePagination(
      conversationId: json['conversation_id'],
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['conversation_id'] = this.conversationId;
    data['count'] = this.count;
    data['next'] = this.next;
    data['previous'] = this.previous;
    return data;
  }
}
