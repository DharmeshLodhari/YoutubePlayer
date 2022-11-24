import 'dart:convert';

import 'package:Slydo/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import "package:http/http.dart" as http;

import '../../../data/environment.dart';
import '../../../utils/util.dart';
import 'models/Topics/CommentDetails.dart';
import 'models/Topics/ReplyCommentDetails.dart';
import 'models/Topics/YarnTopic.dart';
import 'models/ask_categories_model.dart';

class AskAuth extends AuthService {
  AskCategories createAskCategories(Map<String, dynamic> item) {
    AskCategories categories = AskCategories();
    categories.id = item['id'];
    categories.name = item['name'];
    categories.color = item['color'];
    categories.image = item['image'];

    return categories;
  }

  // Get all YARN Categories
  Future<Map<String, dynamic>?> getAllCategories(
      String? next, String previous) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl + "/api/v1/social/ask/list-categories/";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      List<AskCategories> askCategories = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        AskCategories categories = createAskCategories(item);
        askCategories.add(categories);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": askCategories
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Get all User's Selected Categories
  Future<Map<String, dynamic>?> getUsersCategories() async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/ask/user-interest/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      UsersCategories usersCategory;
      var jsonData = json.decode(response.body);
      debugPrint("JSON DECODED:- $jsonData");
      usersCategory = UsersCategories.fromJson(jsonData);

      Map<String, dynamic> result = {"results": usersCategory};

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Save User's Selected Categories
  Future<Map<String, dynamic>?> saveUsersCategories(String body) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/ask/user-interest/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers, body: body);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 201) {
      UsersCategories usersCategory;
      var jsonData = json.decode(response.body);
      debugPrint("JSON DECODED:- $jsonData");
      usersCategory = UsersCategories.fromJson(jsonData);

      Map<String, dynamic> result = {"results": usersCategory};

      return result;
    } else if (response.statusCode == 500) {
      return Future.error("Please try again later !!");
    } else {
      return Future.error("${response.body}");
    }
  }

  // Save User's Selected Single Categories
  Future<Map<String, dynamic>?> saveUsersSingleCategories(
      String categoryId) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url = AppConfig.baseUrl +
        "/api/v1/social/ask/user-single-interest/$categoryId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      UsersCategories usersCategory;
      var jsonData = json.decode(response.body);
      debugPrint("JSON DECODED:- $jsonData");
      usersCategory = UsersCategories.fromJson(jsonData);

      Map<String, dynamic> result = {"results": usersCategory};

      return result;
    } else if (response.statusCode == 500) {
      return Future.error("Please try again later !!");
    } else {
      return Future.error("${response.body}");
    }
  }

  // Delete User's Selected Single Categories
  Future<Map<String, dynamic>?> deleteUsersSingleCategories(
      String categoryId) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url = AppConfig.baseUrl +
        "/api/v1/social/ask/user-single-interest/$categoryId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      UsersCategories usersCategory;
      var jsonData = json.decode(response.body);
      debugPrint("JSON DECODED:- $jsonData");
      usersCategory = UsersCategories.fromJson(jsonData);

      Map<String, dynamic> result = {"results": usersCategory};

      return result;
    } else if (response.statusCode == 500) {
      return Future.error("Please try again later !!");
    } else {
      return Future.error("${response.body}");
    }
  }

  // Get all YARN Topics
  Future<Map<String, dynamic>?> getAllTopics(String? next, String previous,
      {String? type, bool isType = false, String? categoryId}) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (isType) {
        if (categoryId != null) {
          url = AppConfig.baseUrl +
              "/api/v1/social/ask/?$type=$isType&category=$categoryId";
        } else {
          url = AppConfig.baseUrl + "/api/v1/social/ask/?$type=$isType";
        }
      } else {
        url = AppConfig.baseUrl + "/api/v1/social/ask/$type/";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      List<YarnTopic> yarnTopics = [];
      var jsonData = json.decode(response.body);
      debugPrint("GET DATA:- $jsonData");
      for (var item in jsonData["results"]) {
        YarnTopic yarnTopic = YarnTopic.fromJson(item);
        yarnTopics.add(yarnTopic);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": yarnTopics
      };
      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Search Yarns
  Future<Map<String, dynamic>?> getSearchYarns(String? next, String previous,
      {bool isQuestion = false, String? searchText}) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl +
          "/api/v1/social/ask/?question=$isQuestion&search=$searchText";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      List<YarnTopic> yarnTopics = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        YarnTopic yarnTopic = YarnTopic.fromJson(item);
        yarnTopics.add(yarnTopic);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": yarnTopics
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Add Yarn and Question
  Future<bool> addYarnAndQuestion(AddYarnAndQuestion addYarnAndQuestion) async {
    var headers = await getAuthHeaders();
    var url = AppConfig.baseUrl + "/api/v1/social/ask/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse(url));

    Map<dynamic, dynamic> _data = addYarnAndQuestion.toAddMap();
    debugPrint('DATA ---> $_data');
    // _data["available_from"] = dateToString(product.availableFrom!);
    // _data["image_count"] = product.localImages!.length;

    // _data.forEach((k, v) {
    //   request.fields[k] = jsonEncode(v);
    // });

    request.fields.addAll({
      "tags": jsonEncode(addYarnAndQuestion.tags),
      "title": addYarnAndQuestion.title!,
      "body": addYarnAndQuestion.body!,
      "category": addYarnAndQuestion.categoryId!,
      "author": addYarnAndQuestion.author!,
      "is_question": jsonEncode(addYarnAndQuestion.isQuestion!),
      "media_count": jsonEncode(addYarnAndQuestion.localImages!.length)
    });

    List<MultipartFile> newList = [];

    for (int i = 0; i < addYarnAndQuestion.localImages!.length; i++) {
      // Add fields
      request.fields["mediafile_$i"] = addYarnAndQuestion.localImages![i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "mediafile_$i", addYarnAndQuestion.localImages![i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    // Add multipart to request
    request.files.addAll(newList);
    debugPrint('REQUEST FIELDS ---> ${request.fields}');

    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${jsonDecode(responseBody)}");

      throw responseBody;
    }
  }

  // {"comment":"xyz","author_username:""};
  // ADD COMMENT TO YARN
  Future<CommentDetails?> addCommentToYarn(
      String yarnId, Map<String, dynamic> body) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/ask/comments/$yarnId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response =
        await httpPost(url, headers: headers, body: jsonEncode(body));

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      CommentDetails commentDetails =
          CommentDetails.fromJson(json.decode(response.body));
      return commentDetails;
    } else if (response.statusCode == 500) {
      return Future.error("Please try again later !!");
    } else {
      return Future.error("${response.body}");
    }
  }

  // Get all Comment
  Future<Map<String, dynamic>?> getAllComments(
    String? next,
    String previous,
    String postId,
  ) async {
    debugPrint("CALLING ALL COMMENTS");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl + "/api/v1/social/ask/comments/$postId/";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      List<CommentDetails> commentsDetails = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        CommentDetails commentsDetail = CommentDetails.fromJson(item);
        commentsDetails.add(commentsDetail);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": commentsDetails
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD COMMENT TO YARN
  Future<ReplyCommentDetails?> addReplyToComment(
      String commentId, Map<String, dynamic> body) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url =
        AppConfig.baseUrl + "/api/v1/social/ask/reply-a-yarn-comment/$commentId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response =
        await httpPost(url, headers: headers, body: jsonEncode(body));

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      ReplyCommentDetails replyCommentDetail =
      ReplyCommentDetails.fromJson(json.decode(response.body));
      return replyCommentDetail;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Get all Reply
  Future<Map<String, dynamic>?> getAllReply(
    String? next,
    String previous,
    String commentId,
  ) async {
    debugPrint("CALLING ALL COMMENTS");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl +
          "/api/v1/social/ask/reply-a-yarn-comment/$commentId/";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      List<ReplyCommentDetails> replyCommentDetails = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData) {
        ReplyCommentDetails replyCommentDetail = ReplyCommentDetails.fromJson(item);
        replyCommentDetails.add(replyCommentDetail);
      }

      Map<String, dynamic> result = {
        // "count": jsonData["count"],
        // "next": jsonData["next"],
        // "previous": jsonData["previous"],
        "results": replyCommentDetails
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD LIKE TO YARN
  Future<int?> addLike(String postId) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url =
        AppConfig.baseUrl + "/api/v1/social/ask/up-vote/$postId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response =
    await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      int voteCount = 0;
      var data = json.decode(response.body);
      voteCount = data['vote_count'];
      return voteCount;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD DISLIKE TO YARN
  Future<int?> addDisLike(String postId) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url =
        AppConfig.baseUrl + "/api/v1/social/ask/down-vote/$postId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response =
    await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      int downVoteCount = 0;
      var data = json.decode(response.body);
      downVoteCount = data['down_vote_count'];
      return downVoteCount;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD LIKE TO YARN
  Future<int?> addLikeComment(String postId) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url =
        AppConfig.baseUrl + "/api/v1/social/ask/up-vote/$postId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response =
    await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      int voteCount = 0;
      var data = json.decode(response.body);
      voteCount = data['vote_count'];
      return voteCount;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD DISLIKE TO YARN
  Future<int?> addDisLikeComment(String postId) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url =
        AppConfig.baseUrl + "/api/v1/social/ask/down-vote/$postId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response =
    await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      int downVoteCount = 0;
      var data = json.decode(response.body);
      downVoteCount = data['down_vote_count'];
      return downVoteCount;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }
}
