class PartialMessage {
  String id;
  String subtitle;
  String subject;
  String sender;
  String senderAvtar;
  String recipient;
  String timeStamp;
  bool isRead;
  bool isStarred;
  bool isArchived;

  // Pass in as named parameter in constructor
  PartialMessage({
    this.id,
    this.subtitle,
    this.subject,
    this.sender,
    this.senderAvtar,
    this.recipient,
    this.timeStamp,
    this.isRead,
    this.isStarred,
    this.isArchived,
  });
}

class Message {
  String id;
  String body;
  String subject;
  String sender;
  String senderAvtar;
  String recipient;
  String timeStamp;
  bool isRead;
  bool isStarred;
  bool isArchived;

  // Pass in as named parameter in constructor
  Message({
    this.id,
    this.body,
    this.subject,
    this.sender,
    this.senderAvtar,
    this.recipient,
    this.timeStamp,
    this.isRead,
    this.isStarred,
    this.isArchived,
  });
}
