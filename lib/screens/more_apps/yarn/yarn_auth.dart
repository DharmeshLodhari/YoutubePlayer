import 'dart:convert';

import 'package:Slydo/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import "package:http/http.dart" as http;

import '../../../data/environment.dart';
import '../../../utils/util.dart';
import '../user_profile/models/user.dart';
import 'models/Topics/CommentDetails.dart';
import 'models/Topics/Notifications.dart';
import 'models/Topics/YarnTopic.dart';
import 'models/ask_categories_model.dart';

class YarnAuth extends AuthService {
  YarnCategories createAskCategories(Map<String, dynamic> item) {
    YarnCategories categories = YarnCategories();
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
      List<YarnCategories> askCategories = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        YarnCategories categories = createAskCategories(item);
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
  Future<Map<String, dynamic>?> getAllYarn(String? next, String previous,
      {String? type,
      bool isType = false,
      String? categoryId,
      String? userName}) async {
    debugPrint("CALLING ALL YARNS");
    debugPrint("NEXT URL:- $next");
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
        url =
            AppConfig.baseUrl + "/api/v1/social/ask/$type/?username=$userName";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      List<Yarn> yarnTopics = [];
      var jsonData = json.decode(response.body);
      debugPrint("GET DATA:- $jsonData");
      for (var item in jsonData["results"]) {
        Yarn yarnTopic = Yarn.fromJson(item);
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

  // Get Single Yarn Question
  Future<Map<String, dynamic>?> getSingleTopics({String? yarnId}) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    if (yarnId != null) {
      url = AppConfig.baseUrl + "/api/v1/social/ask/$yarnId";
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      Yarn yarnTopic = Yarn.fromJson(jsonData);

      Map<String, dynamic> result = {"results": yarnTopic};
      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Delete Single Yarn Question
  Future<bool?> deleteSingleTopics({String? yarnId}) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    if (yarnId != null) {
      url = AppConfig.baseUrl + "/api/v1/social/ask/$yarnId";
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Search Yarns
  Future<Map<String, dynamic>?> getSearchYarns(String? next, String previous,
      {bool isQuestion = false, String? searchText, String? categoryId}) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl +
          "/api/v1/social/ask/?question=$isQuestion&search=$searchText&categoryId=$categoryId";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      List<Yarn> yarnTopics = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        Yarn yarnTopic = Yarn.fromJson(item);
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
      "media_count": jsonEncode(addYarnAndQuestion.localImages!.length),
      "enable_commenting": jsonEncode(addYarnAndQuestion.enableCommenting!),
      "enable_payme": jsonEncode(addYarnAndQuestion.enablePayme!),
    });

    List<MultipartFile> newList = [];
    List<MultipartFile> thumbnailList = [];
    debugPrint("MEDIA LENGTH::: ${addYarnAndQuestion.localImages!.length}");
    for (int i = 0; i < addYarnAndQuestion.localImages!.length; i++) {
      debugPrint(
          "MEDIA TYPE::: ${addYarnAndQuestion.localImages![i].mediaType}");
      var multipartFile;
      var thumbnailImage;
      if (addYarnAndQuestion.localImages![i].mediaType == 'image') {
        // Add fields
        request.fields["mediafile_$i"] =
            addYarnAndQuestion.localImages![i].mediaFile!.path;
        // Create multipart using filepath, string or bytes
        multipartFile = await http.MultipartFile.fromPath(
            "mediafile_$i", addYarnAndQuestion.localImages![i].mediaFile!.path);
      } else if (addYarnAndQuestion.localImages![i].mediaType == 'video') {
        // Add fields
        request.fields["mediafile_$i"] =
            addYarnAndQuestion.localImages![i].mediaFile!.path;
        // Create multipart using filepath, string or bytes
        multipartFile = await http.MultipartFile.fromPath(
            "mediafile_$i", addYarnAndQuestion.localImages![i].mediaFile!.path);
        // Add Poster Fields
        request.fields["mediaposter_$i"] =
            addYarnAndQuestion.localImages![i].mediaPoster ?? '';

        thumbnailImage = await http.MultipartFile.fromPath("mediaposter_$i",
            addYarnAndQuestion.localImages![i].mediaPoster ?? '');
        thumbnailList.add(thumbnailImage);
      }

      // Add multipart to newList
      newList.add(multipartFile);
    }

    // Add multipart to request
    request.files.addAll(newList);
    request.files.addAll(thumbnailList);
    debugPrint('REQUEST FIELDS ---> ${request.fields}');
    debugPrint('REQUEST FILES ---> ${request.files}');

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
  Future<YarnComment?> addCommentToYarn(
      String yarnId, Map<String, dynamic> body) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/ask/yarn-comments/$yarnId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response =
        await httpPost(url, headers: headers, body: jsonEncode(body));

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      YarnComment commentDetails =
          YarnComment.fromJson(json.decode(response.body));
      return commentDetails;
    } else if (response.statusCode == 500) {
      return Future.error("Please try again later !!");
    } else {
      return Future.error("${response.body}");
    }
  }

  // Get all Comment
  Future<Map<String, dynamic>?> getAllComments(
      String? next, String previous, String postId,
      {String? sortBy}) async {
    debugPrint("CALLING ALL COMMENTS");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (sortBy != null) {
        url = AppConfig.baseUrl +
            "/api/v1/social/ask/yarn-comments/$postId/?sort_by=$sortBy";
      } else {
        url = AppConfig.baseUrl + "/api/v1/social/ask/yarn-comments/$postId/";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint(
        "COMMENTS RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");
    if (response.statusCode == 200) {
      List<YarnComment> commentsDetails = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        YarnComment commentsDetail = YarnComment.fromJson(item);
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

  // Delete Single Comment
  Future<bool?> deleteComment(String postId) async {
    debugPrint("CALLING ALL COMMENTS");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/ask/comments/$postId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD COMMENT TO YARN
  Future<YarnComment?> addReplyToComment(
      String commentId, Map<String, dynamic> body) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url = AppConfig.baseUrl +
        "/api/v1/social/ask/reply-a-yarn-comment/$commentId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response =
        await httpPost(url, headers: headers, body: jsonEncode(body));

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      YarnComment commentDetail =
          YarnComment.fromJson(json.decode(response.body));
      return commentDetail;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Get all Reply
  Future<Map<String, dynamic>?> getAllReply(
      String? next, String previous, String commentId,
      {String? sortBy}) async {
    debugPrint("CALLING ALL COMMENTS");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (sortBy != null) {
        url = AppConfig.baseUrl +
            "/api/v1/social/ask/reply-a-yarn-comment/$commentId/?sort_by=$sortBy";
      } else {
        url = AppConfig.baseUrl +
            "/api/v1/social/ask/reply-a-yarn-comment/$commentId/";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      List<YarnComment> commentDetails = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData) {
        YarnComment replyCommentDetail = YarnComment.fromJson(item);
        commentDetails.add(replyCommentDetail);
      }

      Map<String, dynamic> result = {
        // "count": jsonData["count"],
        // "next": jsonData["next"],
        // "previous": jsonData["previous"],
        "results": commentDetails
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD LIKE TO YARN
  Future<Map<String, dynamic>?> addLike(String postId) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/ask/up-vote/$postId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD DISLIKE TO YARN
  Future<Map<String, dynamic>?> addDisLike(String postId) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/ask/down-vote/$postId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD LIKE TO YARN
  Future<Map<String, dynamic>?> addLikeComment(String postId) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/comments/like/$postId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD DISLIKE TO YARN
  Future<Map<String, dynamic>?> addDisLikeComment(String postId) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/comments/dislike/$postId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Add Report to YARN
  Future<bool?> addReport(String postId, Map<String, dynamic> body) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/ask/report/$postId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response =
        await httpPost(url, headers: headers, body: jsonEncode(body));

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD TO STATUS FOR POST
  Future<bool?> addStatusInPost(String topicId, String status) async {
    Map<String, dynamic> body = {
      "status": status,
      "yarn": topicId,
    };

    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url = AppConfig.baseUrl +
        "/api/v1/social/ask/user-yarn-visibility-options/$topicId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response =
        await httpPost(url, headers: headers, body: jsonEncode(body));

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> searchUser(
      String? next, String? previous, String searchText) async {
    String url =
        AppConfig.baseUrl + "/api/v1/search/users/?search=" + searchText;
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers)
        .timeout(timeOutDuration, onTimeout: () => timeOutFunction());

    print('SEARCH USER ::: ${response.body}');
    if (response.statusCode == 200) {
      List<CustomerProfile> customerProfiles = [];
      var jsonData = json.decode(response.body);

      for (var item in jsonData['results']) {
        CustomerProfile customerProfile = CustomerProfile.fromJson(item);
        customerProfiles.add(customerProfile);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": customerProfiles,
      };
      return result;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // ADD REYARN TO YARN
  Future<bool?> addReYarn(Map<String, dynamic> body) async {
    debugPrint("CALLING REYARN");
    String url = "";
    url = AppConfig.baseUrl +
        "/api/v1/social/ask/reyarn/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response =
    await httpPost(url, headers: headers, body: jsonEncode(body));

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Get all Comment
  Future<Map<String, dynamic>?> getAllNotification(
      String? next, String previous) async {
    debugPrint("CALLING ALL NOTIFICATION");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl +
          "/api/v1/social/ask/notifications/";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint(
        "COMMENTS RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");
    if (response.statusCode == 200) {
      List<Notifications> notifications = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        Notifications notification = Notifications.fromJson(item);
        notifications.add(notification);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": notifications
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }
}
