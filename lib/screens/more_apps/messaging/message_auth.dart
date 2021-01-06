import 'dart:convert';
import 'dart:io';

import 'package:Slydo/screens/more_apps/messaging/models/message.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MessageAuth extends AuthService {
  // Send email to user.
  Future<bool> sendMessage(Map data) async {
    var url = secureBaseUrl + "/api/v1/messaging/send/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, body: _data, headers: headers);
    if (response.statusCode == 201) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  Future<bool> sendSocketMessage(Map data, File media, {File poster}) async {
    var url = secureBaseUrl + "/api/v1/chat/create/";
    debugPrint("URL:- $url");
    var headers = await getAuthHeaders();

    var request = http.MultipartRequest("POST", Uri.parse(url));

    data.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    // Add fields
    request.fields["media"] = media.path;

    // Create multipart using filepath, string or bytes
    var multipartFile1 = await http.MultipartFile.fromPath("media", media.path);

    // Add multipart to request
    request.files.add(multipartFile1);

    // adding poster
    if (poster != null) {
      request.fields["poster"] = poster.path;
      var multipartFile2 =
          await http.MultipartFile.fromPath("poster", poster.path);
      request.files.add(multipartFile2);
    }

    headers.forEach((k, v) => request.headers[k] = v);

    request.fields.forEach((key, value) {
      debugPrint("$key :- $value");
    });

    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller image, Your image is too large.");
    }
    var responseBody = await response.stream.bytesToString();
    debugPrint("$responseBody");
    if (response.statusCode == 201) {
      return true;
    } else {
      return Future.error("${response.statusCode} $responseBody");
    }
  }

  // it will update the message actions:  [Archived,UnArchived,Starred,UnStarred]
  Future<bool> updateMessage(String id, String action) async {
    var url =
        secureBaseUrl + "/api/v1/messaging/update/" + id + "/" + action + "/";
    var headers = await getAuthHeaders();
    var response = await http.patch(url, headers: headers);
    var jsonData = json.decode(response.body);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw jsonData;
    }
  }

  // it will delete the message
  Future<bool> deleteMessage(String id) async {
    var url = secureBaseUrl + "/api/v1/messaging/delete/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.delete(url, headers: headers);
    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  // Get single message
  Future<Message> getMessage(String id) async {
    var url = secureBaseUrl + "/api/v1/messaging/read/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      Message message = Message(
        subject: jsonData["subject"],
        id: jsonData["id"],
        body: jsonData["body"],
        timeStamp: jsonData["time_sent"],
        isRead: jsonData["is_read"],
        recipient: jsonData["recipient"],
        sender: jsonData["sender"],
        senderAvatar: jsonData["sender_avatar"],
        recipientAvatar: jsonData["recipient_avatar"],
        isArchivedByRecipient: jsonData["is_archived_by_recipient"],
        isStarredByRecipient: jsonData["is_starred_by_recipient"],
        isArchivedBySender: jsonData["is_archived_by_sender"],
        isStarredBySender: jsonData["is_starred_by_sender"],
      );
      return message;
    } else {
      throw jsonData;
    }
  }

  // List messages filters: [archived,sent,starred,all]
  Future<Map<String, dynamic>> listMessages(String next, String previous,
      {String filter}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/messaging/list/" + filter + "/";
    } else {
      url = next;
    }
    var headers = await getAuthHeaders();

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<PartialMessage> messagesList = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        PartialMessage message = PartialMessage(
          subtitle: item["subtitle"],
          subject: item["sender"],
          id: item["id"],
          timeStamp: item["time_sent"],
          isRead: item["is_read"],
          recipient: item["recipient"],
          sender: item["sender"],
          senderAvatar: item["sender_avatar"],
          recipientAvatar: item["recipient_avatar"],
          isArchivedByRecipient: item["is_archived_by_recipient"],
          isStarredByRecipient: item["is_starred_by_recipient"],
          isArchivedBySender: item["is_archived_by_sender"],
          isStarredBySender: item["is_starred_by_sender"],
        );
        messagesList.add(message);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": messagesList
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  // List messages filters: [archived,sent,starred,all]
  Future<Map<String, dynamic>> getChatMessages(String next, String previous,
      {String conversionId}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/chat/messages/" + conversionId + "/";
      debugPrint("$url");
    } else {
      url = next;
    }
    var headers = await getAuthHeaders();

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<String> previousMessages = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"])
        previousMessages.add(jsonEncode(item));

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": previousMessages
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  // Get status of the user you are chatting with
  Future<Map> getChatUserStatus(String id) async {
    var url =
        secureBaseUrl + "/api/v1/chat/retrieve-user-chat-status/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return jsonData;
    } else {
      return {};
    }
  }

  // List the  item with pagination
  Future<Map<String, dynamic>> searchProductAndServiceOfUser(
      String url, String next, String previous) async {
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"],
      };
      return result;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }
}
