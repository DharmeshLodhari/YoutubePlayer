import 'dart:convert';

import 'package:Slydo/utils/date_time_and_money_converter.dart';
import 'package:Slydo/utils/util.dart';

class ChatMessage {
  String? author;
  String? authorFullName;
  String? checkId;
  String? conversationId;
  String? createdAt;
  bool? deletedForAuthor;
  bool? deletedForRecipient;
  bool? delivered;
  String? messageId;
  String? kind;
  String? media;
  String? metaData;
  String? poster;
  bool? readByAuthor;
  bool? readByRecipient;
  String? repliedTo;
  String? text;
  String? type;
  String? updatedAt;
  bool? wasEdited;
  String? fromCustomerAvatar;
  String? toCustomerAvatar;

  ChatMessage(
      {this.author,
      this.authorFullName,
      this.checkId,
      this.conversationId,
      this.createdAt,
      this.deletedForAuthor,
      this.deletedForRecipient,
      this.delivered,
      this.messageId,
      this.kind,
      this.media = "",
      this.metaData = "{}",
      this.poster = "",
      this.readByAuthor,
      this.readByRecipient,
      this.repliedTo = "{}",
      this.text,
      this.type,
      this.updatedAt,
      this.wasEdited,
      this.toCustomerAvatar = defaultImage,
      this.fromCustomerAvatar = defaultImage});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      author: json['author'],
      authorFullName: json['author_full_name'],
      checkId: json['check_id'],
      conversationId: json['conversation_id'] ?? json['conversation'],
      createdAt: DateTime.parse(json['created_at']).toIso8601String(),
      deletedForAuthor: json['deleted_for_author'],
      deletedForRecipient: json['deleted_for_recipient'],
      delivered: json['delivered'],
      messageId: json['id'],
      kind: json['kind'],
      media: json['media'],
      metaData: json['meta_data'] is Map
          ? jsonEncode(json['meta_data'])
          : json['meta_data'] ?? "{}",
      poster: json['poster'],
      readByAuthor: json['read_by_author'],
      readByRecipient: json['read_by_recipient'],
      repliedTo: json['replied_to'] is Map
          ? jsonEncode(json['replied_to'])
          : json['replied_to'] ?? "{}",
      text: json['text'] is Map
          ? jsonEncode(json['text'])
          : json['text'].toString(),
      type: json['type'],
      updatedAt: json['updated_at'],
      wasEdited: json['was_edited'],
      fromCustomerAvatar: json['from_customer_avatar'] ?? defaultImage,
      toCustomerAvatar: json['to_customer_avatar'] ?? defaultImage,
    );
  }

  factory ChatMessage.fromDBJson(Map<String, dynamic> json) {
    return ChatMessage(
      author: json['author'],
      authorFullName: json['author_full_name'],
      checkId: json['check_id'],
      conversationId: json['conversation_id'],
      createdAt: convertMillisecondsSinceEpochToString(json['created_at']),
      deletedForAuthor: convertIntToBool(json['deleted_for_author']),
      deletedForRecipient: convertIntToBool(json['deleted_for_recipient']),
      delivered: convertIntToBool(json['delivered']),
      messageId: json['message_id'],
      kind: json['kind'],
      media: json['media'],
      metaData: json['meta_data'],
      poster: json['poster'],
      readByAuthor: convertIntToBool(json['read_by_author']),
      readByRecipient: convertIntToBool(json['read_by_recipient']),
      repliedTo: json['replied_to'],
      text: json['text'],
      type: json['type'],
      updatedAt: json['updated_at'] != null
          ? convertMillisecondsSinceEpochToString(json['updated_at'])
          : "",
      fromCustomerAvatar: json['from_customer_avatar'] ?? defaultImage,
      toCustomerAvatar: json['to_customer_avatar'] ?? defaultImage,
      wasEdited: convertIntToBool(
        json['was_edited'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['author'] = this.author;
    data['author_full_name'] = this.authorFullName;
    data['check_id'] = this.checkId;
    data['conversation_id'] = this.conversationId;
    data['created_at'] = this.createdAt;
    data['deleted_for_author'] = this.deletedForAuthor;
    data['deleted_for_recipient'] = this.deletedForRecipient;
    data['delivered'] = this.delivered;
    data['id'] = this.messageId;
    data['kind'] = this.kind;
    data['media'] = this.media;
    data['meta_data'] = this.metaData;
    data['poster'] = this.poster;
    data['read_by_author'] = this.readByAuthor;
    data['read_by_recipient'] = this.readByRecipient;
    data['replied_to'] = this.repliedTo;
    data['text'] = this.text;
    data['type'] = this.type;
    data['updated_at'] = this.updatedAt;
    data['was_edited'] = this.wasEdited;
    data["to_customer_avatar"] = this.toCustomerAvatar;
    data["from_customer_avatar"] = this.fromCustomerAvatar;
    return data;
  }

  Map<String, dynamic> toDBJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['author'] = this.author;
    data['author_full_name'] = this.authorFullName;
    data['check_id'] = this.checkId;
    data['conversation_id'] = this.conversationId;
    data['created_at'] = convertStringToMillisecondsSinceEpoch(this.createdAt);
    data['deleted_for_author'] =
        convertBoolToInt(this.deletedForAuthor, defaultValue: false);
    data['deleted_for_recipient'] =
        convertBoolToInt(this.deletedForRecipient, defaultValue: false);
    data['delivered'] = convertBoolToInt(this.delivered, defaultValue: false);
    data['message_id'] = this.messageId;
    data['kind'] = this.kind;
    data['media'] = this.media;
    data['meta_data'] = this.metaData == null ? "{}" : this.metaData;
    data['poster'] = this.poster;
    data['read_by_author'] =
        convertBoolToInt(this.readByAuthor, defaultValue: true);
    data['read_by_recipient'] =
        convertBoolToInt(this.readByRecipient, defaultValue: false);
    data['replied_to'] = this.repliedTo == null ? "{}" : this.repliedTo;
    data['text'] = this.text;
    data['type'] = this.type ?? "chatroom_message";
    data['updated_at'] = convertStringToMillisecondsSinceEpoch(this.updatedAt);
    data['was_edited'] = convertBoolToInt(this.wasEdited, defaultValue: false);
    data["to_customer_avatar"] = this.toCustomerAvatar ?? defaultImage;
    data["from_customer_avatar"] = this.fromCustomerAvatar ?? defaultImage;
    return data;
  }

  static int convertBoolToInt(bool? value, {bool? defaultValue}) {
    if (value == null) {
      return defaultValue! ? 1 : 0;
    }
    return value ? 1 : 0;
  }

  static bool convertIntToBool(int? value) {
    if (value == null) {
      return false;
    }
    return value == 1 ? true : false;
  }
}
