class PartialMessage {
  String id;
  String subtitle;
  String subject;
  String sender;
  String senderAvatar;
  String recipient;
  String recipientAvatar;
  String timeStamp;
  bool isRead;
  bool isArchivedByRecipient;
  bool isStarredByRecipient;
  bool isArchivedBySender;
  bool isStarredBySender;

  // Pass in as named parameter in constructor
  PartialMessage({
    this.id,
    this.subtitle,
    this.subject,
    this.sender,
    this.senderAvatar,
    this.recipient,
    this.recipientAvatar,
    this.timeStamp,
    this.isRead,
    this.isArchivedByRecipient,
    this.isStarredByRecipient,
    this.isArchivedBySender,
    this.isStarredBySender,
  });
}

class Message {
  String id;
  String body;
  String subject;
  String sender;
  String senderAvatar;
  String recipient;
  String recipientAvatar;
  String timeStamp;
  bool isRead;
  bool isStarred;
  bool isArchivedByRecipient;
  bool isStarredByRecipient;
  bool isArchivedBySender;
  bool isStarredBySender;

  // Pass in as named parameter in constructor
  Message({
    this.id,
    this.body,
    this.subject,
    this.sender,
    this.senderAvatar,
    this.recipient,
    this.recipientAvatar,
    this.timeStamp,
    this.isRead,
    this.isStarred,
    this.isArchivedByRecipient,
    this.isStarredByRecipient,
    this.isArchivedBySender,
    this.isStarredBySender,
  });
}
