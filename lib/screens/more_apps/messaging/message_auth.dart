import 'dart:convert';
import 'dart:io';

import 'package:Slydo/screens/more_apps/messaging/chat/models/AddGroupModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/GroupDetailModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/UpdateGroupDetailModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/models_for_db/ChatMessage.dart';
import 'package:Slydo/screens/more_apps/messaging/models/message.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
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
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> sendSocketMessage(Map data, File media, {File poster}) async {
    var url = secureBaseUrl + "/api/v1/chat/create/";
    // debugPrint("URL:- $url");
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
      // debugPrint("$key :- $value");
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
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");
      return Future.error("ERROR:- $responseBody");
    }
  }

  Future<bool> sendReplyMessage(
      {String messageId, String data, String conversationId}) async {
    var url = secureBaseUrl +
        "/api/v1/chat/reply-chat-message/$messageId/$conversationId/";
    var headers = await getAuthHeaders();
    debugPrint(
        "Data Sent MESSAGE ID:- $messageId CONVERSATION ID:- $conversationId DATA:- $data");
    var response = await http.post(url, body: data, headers: headers);
    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  // it will update the message actions:  [Archived,UnArchived,Starred,UnStarred]
  Future<bool> updateMessage(String id, String action) async {
    var url =
        secureBaseUrl + "/api/v1/messaging/update/" + id + "/" + action + "/";
    var headers = await getAuthHeaders();
    var response = await http.patch(url, headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
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
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  // Get single message
  Future<Message> getMessage(String id) async {
    var url = secureBaseUrl + "/api/v1/messaging/read/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      Message message = Message(
        subject: jsonData["subject"],
        id: jsonData["id"],
        body: jsonData["body"],
        timeStamp: jsonData["time_sent"],
        isRead: jsonData["is_read"],
        recipient: jsonData["recipient"],
        recipientType: jsonData["recipient_type"] ?? "User",
        sender: jsonData["sender"],
        senderAvatar: jsonData["sender_avatar"],
        senderType: jsonData["sender_type"] ?? "User",
        recipientAvatar: jsonData["recipient_avatar"],
        isArchivedByRecipient: jsonData["is_archived_by_recipient"],
        isStarredByRecipient: jsonData["is_starred_by_recipient"],
        isArchivedBySender: jsonData["is_archived_by_sender"],
        isStarredBySender: jsonData["is_starred_by_sender"],
      );
      return message;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
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
      url = getSecureUrl(url: next);
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
          recipientType: item["recipient_type"] ?? "User",
          sender: item["sender"],
          senderAvatar: item["sender_avatar"],
          senderType: item["sender_type"] ?? "User",
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
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
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
    } else {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();

    // var response = await http
    //     .get(url, headers: headers)
    //     .timeout(timeOutDuration, onTimeout: () => timeOutFunction(url: url));

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      debugPrint("URL:- $url RESPONSE STATUS CODE:- ${response.statusCode} ");
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
      return Future.error("Server Error");
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("${response.body}");
    }
  }

  // Get status of the user you are chatting with
  Future<Map> getChatUserStatus(String id) async {
    var url =
        secureBaseUrl + "/api/v1/chat/retrieve-user-chat-status/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http
        .get(url, headers: headers)
        .timeout(timeOutDuration, onTimeout: () => timeOutFunction());

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      return jsonData;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  // List the  item with pagination
  Future<Map<String, dynamic>> searchProductAndServiceOfUser(
      String url, String next, String previous) async {
    debugPrint("URl:- $url");
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
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
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<ChatConversation> createGroupChat({AddGroupModel group}) async {
    var url = secureBaseUrl + "/api/v1/user/group-conversation/";
    // debugPrint("URL:- $url");
    var headers = await getAuthHeaders();

    var request = http.MultipartRequest("POST", Uri.parse(url));

    List<String> listOfUser = [];

    group.users.forEach((element) {
      listOfUser.add(element.userName);
    });

    request.fields["participants"] = jsonEncode(listOfUser);
    request.fields["group_name"] = group.groupName;
    request.fields["description"] = group.groupDescription;

    request.fields["is_group_conversation"] = jsonEncode(true);

    if (group.groupProfilePhoto != null) {
      // Create multipart using filepath, string or bytes
      var multipartFile1 =
          await http.MultipartFile.fromPath("banner", group.groupProfilePhoto);

      // Add multipart to request
      request.files.add(multipartFile1);
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
      debugPrint("DATA:- ${request.fields}");
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");

      ChatConversation chatConversation =
          ChatConversation.fromJson(jsonDecode(responseBody));

      return chatConversation;
    } else {
      debugPrint("DATA:- ${request.fields}");
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");
      return Future.error("ERROR:- $responseBody");
    }
  }

  Future<Map<String, dynamic>> updateGroupChat(
      {UpdateGroupDetailModel group}) async {
    var url = secureBaseUrl +
        "/api/v1/user/group-conversation/${group.groupConversationId}/";
    // debugPrint("URL:- $url");
    var headers = await getAuthHeaders();

    var request = http.MultipartRequest("PATCH", Uri.parse(url));

    request.fields["group_name"] = group.name;
    request.fields["description"] = group.description;

    if (group.avatar != null) {
      // Create multipart using filepath, string or bytes
      var multipartFile1 =
          await http.MultipartFile.fromPath("banner", group.avatar);

      // Add multipart to request
      request.files.add(multipartFile1);
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

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");
      return Future.error("ERROR:- $responseBody");
    }
  }

  // Get status of the user you are chatting with
  Future<GroupDetailModel> getGroupConversationDetail(
      String conversationID) async {
    var url = secureBaseUrl +
        "/api/v1/user/group-conversation/detail/" +
        conversationID +
        "/";
    var headers = await getAuthHeaders();
    var response = await http
        .get(url, headers: headers)
        .timeout(timeOutDuration, onTimeout: () => timeOutFunction());

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      GroupDetailModel groupDetailModel = GroupDetailModel.fromJson(jsonData);
      return groupDetailModel;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  \nRESPONSE BODY:- \n${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> addParticipantToGroup(
      {String conversationId, List<CustomerProfile> users}) async {
    var url = secureBaseUrl +
        "/api/v1/user/group-conversation/add-user/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();

    List<String> userList = users.map((user) => user.userName).toList();

    debugPrint("List of users to add:- $userList");

    Map<String, dynamic> data = {"users": userList};

    var response =
        await http.post(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> removeParticipantFromAdmin(
      {String conversationId, String userName}) async {
    var url = secureBaseUrl +
        "/api/v1/user/group-conversation/remove-admin-user/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var response =
        await http.patch(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> makeParticipantAdmin(
      {String conversationId, String userName}) async {
    var url = secureBaseUrl +
        "/api/v1/user/group-conversation/add-admin-user/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var response =
        await http.patch(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> muteParticipantFromGroup(
      {String conversationId, String userName}) async {
    var url = secureBaseUrl +
        "/api/v1/user/group-conversation/mute-participant/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var response =
        await http.patch(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> unMuteParticipantFromGroup(
      {String conversationId, String userName}) async {
    var url = secureBaseUrl +
        "/api/v1/user/group-conversation/unmute-participant/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var response =
        await http.patch(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> blockParticipantFromGroup(
      {String conversationId, String userName}) async {
    var url = secureBaseUrl +
        "/api/v1/user/group-conversation/block-participants/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var response =
        await http.patch(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> unBlockParticipantFromGroup(
      {String conversationId, String userName}) async {
    var url = secureBaseUrl +
        "/api/v1/user/group-conversation/unblock-participants/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var response =
        await http.patch(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> removeParticipantFromGroup(
      {String conversationId, String userName}) async {
    var url = secureBaseUrl +
        "/api/v1/user/group-conversation/remove-user/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var response =
        await http.patch(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> exitFromGroup({String conversationId}) async {
    var url = secureBaseUrl +
        "/api/v1/user/group-conversation/exit-group/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();

    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> deleteGroup({String conversationId}) async {
    var url = secureBaseUrl +
        "/api/v1/user/group-conversation/delete-group/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();

    var response = await http.delete(url, headers: headers);

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  // Search User in Contact
  Future<Map<String, dynamic>> searchParticipantInGroup(
      String next, String previous,
      {String conversationId, String query}) async {
    var url = secureBaseUrl +
        "/api/v1/user/group-conversation/search-participants/$conversationId";
    if (query != "") {
      url = url + "?q=$query/";
    }
    debugPrint("URL:- $url");
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
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
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  void sendStopNudge({Map<String, dynamic> dataToSend}) async {
    var url = secureBaseUrl + "/api/v1/chat/conversation/stop-nudge/";
    var headers = await getAuthHeaders();

    var response =
        await http.post(url, headers: headers, body: jsonEncode(dataToSend));

    if (response.statusCode == 200 || response.statusCode == 201) {
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<Map<String, dynamic>> fetchMissedMessages(
      {List<ChatMessage> chatMessages}) async {
    var url = secureBaseUrl + "/api/v1/chat/fetch-missed-messages/";

    debugPrint("URL:- $url");
    var headers = await getAuthHeaders();

    List<Map<String, dynamic>> dataToBeSent = [];

    chatMessages.forEach((element) {
      dataToBeSent.add({
        "conversation_id": element.conversationId,
        "created_at":
            DateTime.parse(element.createdAt).toUtc().toIso8601String(),
        "check_id": element.checkId
      });
    });

    Map<String, dynamic> data = {"data": dataToBeSent};

    debugPrint("DATA SENT:- $data");

    var response =
        await http.post(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200) {
      debugPrint(
          "STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return jsonDecode(response.body);
    } else {
      debugPrint(
          "URL:- $url STATUSCODE:- ${response.statusCode} BODY:- ${response.body}");
      return null;
    }
  }

  Future<bool> sendEnvelope({bool isEmpty, Map<String, dynamic> data}) async {
    var url = secureBaseUrl + "/api/v1/transactions/magic-envelop/";

    if (isEmpty) {
      url = secureBaseUrl + "/api/v1/transactions/empty-envelop/";
    }

    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);

    var response = await http.post(url, headers: headers, body: _data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }
}
