import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/AddGroupModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/GroupDetailModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/UpdateGroupDetailModel.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/gif_model/GIFModel.dart';
import 'package:Slydo/screens/more_apps/messaging/models/message.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/Envelope.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../moments/models/comment_model.dart';
import 'chat/models/channel_model.dart';

class MessageAuth extends AuthService {
  // Send email to user.
  Future<bool> sendMessage(Map data) async {
    var url = AppConfig.baseUrl + "/api/v1/messaging/send/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, body: _data, headers: headers);

    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> sendSocketMessage(Map data, File media, {File? poster}) async {
    var url = AppConfig.chatUrl + "/api/v1/chat/create/";
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
    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");
      return Future.error("ERROR:- $responseBody");
    }
  }

  Future<bool> sendReplyMessage(
      {String? messageId, String? data, String? conversationId}) async {
    var url = AppConfig.chatUrl +
        "/api/v1/chat/reply-chat-message/$messageId/$conversationId/";
    var headers = await getAuthHeaders();
    debugPrint(
        "Data Sent MESSAGE ID:- $messageId CONVERSATION ID:- $conversationId DATA:- $data");
    var response = await httpPost(url, body: data, headers: headers);
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
    var url = AppConfig.baseUrl +
        "/api/v1/messaging/update/" +
        id +
        "/" +
        action +
        "/";
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers);

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
    var url = AppConfig.baseUrl + "/api/v1/messaging/delete/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);
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
    var url = AppConfig.baseUrl + "/api/v1/messaging/read/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

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
  Future<Map<String, dynamic>?> listMessages(String? next, String? previous,
      {String? filter}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (filter == null) {
        url = AppConfig.baseUrl + "/api/v1/messaging/list/all";
      } else {
        url = AppConfig.baseUrl + "/api/v1/messaging/list/" + filter + "/";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();

    var response = await httpGet(url, headers: headers);

    debugPrint('MESSAGE URL ::: ${response.statusCode}');
    debugPrint('MESSAGE ::: ${response.body}');

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
  Future<Map<String, dynamic>?> getChatMessages(String? next, String? previous,
      {String? conversionId}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.chatUrl + "/api/v1/chat/messages/" + conversionId! + "/";
    } else {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    debugPrint("URL:- $url");

    // var response = await http
    //     .get(url, headers: headers)
    //     .timeout(timeOutDuration, onTimeout: () => timeOutFunction(url: url));

    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      List<String> previousMessages = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        previousMessages.add(jsonEncode(item));
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": previousMessages
      };
      return result;
    } else if (response.statusCode == 500) {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("Server Error");
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("${response.body}");
    }
  }

  // Get status of the user you are chatting with
  Future<Map?> getChatUserStatus(String id) async {
    var url = AppConfig.chatUrl +
        "/api/v1/chat/retrieve-user-chat-status/" +
        id +
        "/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers)
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
  Future<Map<String, dynamic>?> searchProductAndServiceOfUser(
      String url, String? next, String? previous) async {
    debugPrint("URl:- $url");
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();

    var response = await httpGet(url, headers: headers);

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

  Future<ChatConversation> createGroupChat(
      {required AddGroupModel group}) async {
    var url = AppConfig.baseUrl + "/api/v1/user/group-conversation/";
    // debugPrint("URL:- $url");
    var headers = await getAuthHeaders();

    var request = http.MultipartRequest("POST", Uri.parse(url));

    List<String?> listOfUser = [];

    group.users!.forEach((element) {
      listOfUser.add(element.userName);
    });

    request.fields["group_name"] = group.groupName!;
    request.fields["participants"] = jsonEncode(listOfUser);
    request.fields["description"] = group.groupDescription!;
    request.fields["is_group_conversation"] = jsonEncode(true);
    request.fields["is_public_group"] = jsonEncode(group.makePublic);
    request.fields["age_restriction"] = jsonEncode(group.ageRestriction);
    //PAID GROUP OPTIONS
    request.fields["group_subscription_currency"] = 'NGN';
    if (group.channelFee != null) {
      request.fields["group_subscription_fee"] =
          jsonEncode(group.channelFee! * 100);
    }
    request.fields["group_max_allowed_users"] =
        jsonEncode(group.maxAllowedMembers);
    if (group.groupProfilePhoto != null) {
      // Create multipart using filepath, string or bytes
      var multipartFile1 =
          await http.MultipartFile.fromPath("banner", group.groupProfilePhoto!);

      // Add multipart to request
      request.files.add(multipartFile1);
    }

    debugPrint('CREATE GROUP FIELDS -> ${request.fields}');

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

  Future<Map<String, dynamic>?> updateGroupChat(
      {required UpdateGroupDetailModel group}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/${group.groupConversationId}/";
    // debugPrint("URL:- $url");
    var headers = await getAuthHeaders();

    var request = http.MultipartRequest("PATCH", Uri.parse(url));

    request.fields["group_name"] = group.name!;
    request.fields["description"] = group.description!;
    if (group.avatar != null) {
      // Create multipart using filepath, string or bytes
      var multipartFile1 =
          await http.MultipartFile.fromPath("banner", group.avatar!);

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
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");
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
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/detail/" +
        conversationID +
        "/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers)
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

  // Get status of the user you are chatting with
  Future<dynamic> fetchChannels() async {
    var url = AppConfig.baseUrl + "/api/v1/chat/conversation/channels/";

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers)
        .timeout(timeOutDuration, onTimeout: () => timeOutFunction());

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      // GroupDetailModel groupDetailModel = GroupDetailModel.fromJson(jsonData);
      debugPrint(jsonData.toString());
      return 'channels';
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  \nRESPONSE BODY:- \n${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> addParticipantToGroup(
      {required String conversationId,
      required List<CustomerProfile> users}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/add-user/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();

    List<String?> userList = users.map((user) => user.userName).toList();

    debugPrint("List of users to add:- $userList");

    Map<String, dynamic> data = {"users": userList};

    var response =
        await httpPost(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> joinChannel(
      {required String channelId, required String userName}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/join-channel/" +
        channelId +
        "/";
    var headers = await getAuthHeaders();

    debugPrint("List of users to add:- ${[userName]}");

    Map<String, dynamic> data = {
      "users": [userName]
    };

    var response =
        await httpPost(url, headers: headers, body: jsonEncode(data));

    debugPrint(
        "JOIN CHANNEL:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 412) {
      return Future.error(jsonDecode(response.body)['error']);
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> removeParticipantFromAdmin(
      {required String conversationId, String? userName}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/remove-admin-user/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var _data = jsonEncode(data);

    var response = await httpPatch(url, headers: headers, body: _data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> makeParticipantAdmin(
      {required String conversationId, String? userName}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/add-admin-user/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var _data = jsonEncode(data);

    var response = await httpPatch(url, headers: headers, body: _data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> muteParticipantFromGroup(
      {required String conversationId, String? userName}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/mute-participant/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var _data = jsonEncode(data);

    var response = await httpPatch(url, headers: headers, body: _data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> unMuteParticipantFromGroup(
      {required String conversationId, String? userName}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/unmute-participant/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var _data = jsonEncode(data);

    var response = await httpPatch(url, headers: headers, body: _data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> blockParticipantFromGroup(
      {required String conversationId, String? userName}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/block-participants/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var _data = jsonEncode(data);

    var response = await httpPatch(url, headers: headers, body: _data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> unBlockParticipantFromGroup(
      {required String conversationId, String? userName}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/unblock-participants/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var _data = jsonEncode(data);

    var response = await httpPatch(url, headers: headers, body: _data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> removeParticipantFromGroup(
      {required String conversationId, String? userName}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/remove-user/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();
    Map<String, dynamic> data = {"user": userName};

    var _data = jsonEncode(data);

    var response = await httpPatch(url, headers: headers, body: _data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> exitFromGroup({required String conversationId}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/exit-group/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();

    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> deleteGroup({required String conversationId}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/delete-group/" +
        conversationId +
        "/";
    var headers = await getAuthHeaders();

    var response = await httpDelete(url, headers: headers);

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
  Future<Map<String, dynamic>?> searchParticipantInGroup(
      String? next, String? previous,
      {String? conversationId, String? query}) async {
    var url = AppConfig.baseUrl +
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
    var response = await httpGet(url, headers: headers);

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

  void sendStopNudge({Map<String, dynamic>? dataToSend}) async {
    var url = AppConfig.chatUrl + "/api/v1/chat/conversation/stop-nudge/";
    var headers = await getAuthHeaders();

    var response =
        await httpPost(url, headers: headers, body: jsonEncode(dataToSend));

    if (response.statusCode == 200 || response.statusCode == 201) {
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<Map<String, dynamic>?> fetchMissedMessages(
      {String? next, String? previous}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.chatUrl + "/api/v1/chat/fetch-missed-messages/";
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint("URL:- $url");

    var headers = await getAuthHeaders();

    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      debugPrint(
          "STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");

      List<String> missedMessages = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        missedMessages.add(jsonEncode(item));
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": missedMessages
      };
      return result;
    } else {
      debugPrint(
          "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> acknowledgeMessagesToServer(
      {List? dataToBeSent}) async {
    var url = AppConfig.chatUrl + "/api/v1/chat/acknowledge-messages/";

    debugPrint("URL:- $url");
    var headers = await getAuthHeaders();

    Map<String, dynamic> data = {"data": dataToBeSent};

    debugPrint("DATA SENT:- $data");

    ///{id: 82860938-6308-4bb9-988d-1b2fc9f60f85,
    /// check_id: 3161786e-5fb8-48ce-91fa-8677001e56e0,
    /// conversation: ced68efb-dc48-4d20-9811-e2515aa47207,
    /// author: abiola.rasheed.19, text: hi,
    /// read_by_author: true, read_by_recipient: true,
    /// was_edited: false,
    /// updated_at: 2021-07-04T01:22:58.092910+01:00,
    /// created_at: 2021-07-04T01:22:58.092936+01:00,
    /// kind: text, deleted_for_recipient: false,
    /// deleted_for_author: false,
    /// delivered: true, meta_data: {},
    /// replied_to: null,
    /// from_customer_avatar: https://slydo-assets.s3.amazonaws.com/media/customer/avatar/4059d32af9974a66b898964736173075.jpg,
    /// to_customer_avatar: , type: acknowledge_message, processed: acknowledge_message}

    /// {"check_id": "6d2408ac-a2dc-4864-a306-600a702da378",
    /// "conversation_id": "ced68efb-dc48-4d20-9811-e2515aa47207",
    /// "username": "black",
    /// "delivered": true, "type": "acknowledge_message"}

    var _data = jsonEncode(data);

    var response = await httpPatch(url, headers: headers, body: _data);

    if (response.statusCode == 200) {
      debugPrint(
          "STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return jsonDecode(response.body);
    } else {
      debugPrint(
          "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> readByRecipientToServer(
      {Map<String, dynamic>? dataToBeSent}) async {
    var url = AppConfig.chatUrl +
        "/api/v1/chat/acknowledge-message-read-by-recipient/";

    debugPrint("URL:- $url");
    var headers = await getAuthHeaders();

    Map<String, dynamic> data = {"data": dataToBeSent};

    debugPrint("DATA SENT:- $data");

    var _data = jsonEncode(data);

    var response = await httpPatch(url, headers: headers, body: _data);

    if (response.statusCode == 200) {
      debugPrint(
          "STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return jsonDecode(response.body);
    } else {
      debugPrint(
          "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return Future.error("");
    }
  }

  Future<bool> sendEnvelope(
      {required bool isEmpty, Map<String, dynamic>? data}) async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/magic-envelop/";

    if (isEmpty) {
      url = AppConfig.baseUrl + "/api/v1/transactions/empty-envelop/";
    }

    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);

    var response = await httpPost(url, headers: headers, body: _data);

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

  Future<bool> putMoneyInEnvelope(
      {Map<String, dynamic>? data, required Envelope envelope}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/transactions/empty-envelop/${envelope.id}/";

    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);

    debugPrint("Data sent => $data");

    var response = await httpPatch(url, headers: headers, body: _data);

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

  Future<Envelope> getEnvelope({required Envelope envelope, String? id}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/transactions/magic-envelop/${envelope.id.toString()}/?message_id=$id";

    var headers = await getAuthHeaders();

    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      Envelope envelope = Envelope.fromJson(jsonDecode(response.body));

      return envelope;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<bool> cancelEnvelope(
      {required Envelope envelope, required Map<String, dynamic> data}) async {
    var type = envelope.type!.replaceAll("-envelop", "");

    // debugPrint("Message DATA:- $data");

    var url = AppConfig.baseUrl +
        "/api/v1/transactions/cancel-envelop/$type/${envelope.id}/";

    var headers = await getAuthHeaders();

    var param = {
      "check_id": data['check_id'],
      "conversation_id": data["conversation_id"] ?? data["conversation"],
    };

    debugPrint("URL:- $url  DATA sent:- $param}");

    var _data = jsonEncode(param);

    var response = await httpPatch(url, body: _data, headers: headers);

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

  Future<List<GIFModel>> searchGIF(
      {String? query, bool isRandom = false, bool isSticker = false}) async {
    var url = "";

    url =
        "https://api.giphy.com/v1/${isSticker ? "stickers" : "gifs"}/search?api_key=${AppConfig.gifApiKey}&q=$query&limit=50";
    if (isRandom) {
      if (isSticker) {
        url =
            "https://api.giphy.com/v1/stickers/trending?type=stickers&limit=50&api_key=${AppConfig.gifApiKey}";
      } else {
        url =
            "https://api.giphy.com/v1/gifs/trending?type=gifs&limit=50&api_key=${AppConfig.gifApiKey}";
      }
    }

    url = Uri.encodeFull(url);
    debugPrint("URL:- $url");

    var headers = await getAuthHeaders();

    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      List data = responseBody['data'];

      List<GIFModel> gifs = [];
      for (var item in data) {
        gifs.add(GIFModel.fromJson(item));
      }
      return gifs;
    } else {
      debugPrint(
          "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getChatWallpapers(
      String? next, String? previous,
      {String? filter}) async {
    await Future.delayed(Duration(seconds: 1));

    var url = "";

    // if (next == null) {
    //   return null;
    // }
    // if (next == "") {
    //   if (filter == null) {
    //     url = AppConfig.baseUrl + "/api/v1/messaging/list/all";
    //   } else {
    //     url = AppConfig.baseUrl + "/api/v1/messaging/list/" + filter + "/";
    //   }
    // } else {
    //   url = getSecureUrl(url: next);
    // }

    //var headers = await getAuthHeaders();
    //
    //var response = await httpGet(url, headers: headers);
    //
    // debugPrint('MESSAGE URL ::: ${response.statusCode}');
    // debugPrint('MESSAGE ::: ${response.body}');

    if (true) {
      var jsonData = {
        'count': 0,
        'next': '',
        'previous': '',
        'results': [
          'https://cdn.pixabay.com/photo/2018/08/14/13/23/ocean-3605547_1280.jpg',
          'https://cdn.pixabay.com/photo/2018/08/14/13/23/ocean-3605547_1280.jpg',
          'https://cdn.pixabay.com/photo/2018/08/14/13/23/ocean-3605547_1280.jpg',
        ]
      };

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData['results']
      };
      return result;
    }
    // else if (response.statusCode == 500) {
    //   throw "Server Error";
    // } else {
    //   debugPrint(
    //       "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
    //   return Future.error("ERROR:- ${response.body}");
    // }
  }

  Future<BasePaginationModel<List<ChannelModel>>> getChannels(
      {required String? nextUrl, String? searchText}) async {
    var url = AppConfig.baseUrl + "/api/v1/user/channels/";

    if (searchText != null && searchText.isNotEmpty) {
      url = url + "?search=$searchText";
    }

    var headers = await getAuthHeaders();

    var response = await httpGet(url, headers: headers);
    debugPrint(
        "GET CHANNELS $url ${response.statusCode}  RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");

      final jsonData = jsonDecode(response.body);
      List results = jsonData['results'];

      return BasePaginationModel<List<ChannelModel>>.fromJson(
        jsonData,
        results.map((e) => ChannelModel.fromJson(e)).toList(),
      );
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }
}
