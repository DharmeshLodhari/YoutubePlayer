import 'dart:convert';

import 'package:Slydo/main.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import "package:http/http.dart" as http;

import '../../../data/environment.dart';
import '../../../utils/util.dart';
import '../user_profile/models/user.dart';
import 'models/Topics/CommentDetails.dart';
import 'models/Topics/Notifications.dart';
import 'models/Topics/yarn_model.dart';
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

  // Get all User's Yarn Setting
  Future<UserYarnSettings?> getUserYarnSettings() async {
    debugPrint("CALLING YARN SETTINGS");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/ask/user-interest/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      UserYarnSettings yarnSettings;
      var jsonData = json.decode(response.body);
      logger.d(jsonData);
      yarnSettings = UserYarnSettings.fromJson(jsonData);
      logger.d(yarnSettings);

      return yarnSettings;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Get all User's Yarn Setting
  Future<UserYarnSettings?> updateUserYarnSettings(Map body) async {
    debugPrint("CALLING YARN SETTINGS");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/ask/user-interest/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response =
        await httpPost(url, headers: headers, body: jsonEncode(body));

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 201) {
      UserYarnSettings yarnSettings;
      var jsonData = json.decode(response.body);
      debugPrint("JSON DECODED:- $jsonData");
      logger.d(jsonData);
      yarnSettings = UserYarnSettings.fromJson(jsonData);
      return yarnSettings;
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
      url = AppConfig.baseUrl + "/api/v1/social/ask/$yarnId/";
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
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl +
          "/api/v1/social/ask/?question=$isQuestion&search=$searchText";

      if (categoryId != null) {
        url = AppConfig.baseUrl +
            "/api/v1/social/ask/?question=$isQuestion&search=$searchText&categoryId=$categoryId";
      }


    } else {
      url = getSecureUrl(url: next);
    }
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

  //edit Yarn and Question
  Future editYarnAndQuestion(Yarn yarn) async {
    var headers = await getAuthHeaders();
    var url = AppConfig.baseUrl +
        "/api/v1/social/ask/" +
        yarn.id.toString() +
        "/edit-yarn-or-question/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse(url));

    // Map<dynamic, dynamic> _data = yarn.toJson();
    if (yarn.isQuestion) {
      request.fields["title"] = yarn.title!;
    }

    List<MultipartFile> newList = [];
    List<MultipartFile> thumbnailList = [];
    debugPrint("MEDIA LENGTH::: ${yarn.media.length}");
    int count = 0;
    for (int i = 0; i < yarn.media.length; i++) {
      if (yarn.media[i].id == null) {
        debugPrint("MEDIA TYPE::: ${yarn.media[i].mediaType}");
        var multipartFile;
        var thumbnailImage;
        request.fields['type'] = yarn.media[i].mediaType ?? "";
        if (yarn.media[i].mediaType == 'image') {
          // Add fields
          request.fields["mediafile_$count"] =
              yarn.media[i].mediaFile?.path ?? "";
          // Create multipart using filepath, string or bytes
          multipartFile = await http.MultipartFile.fromPath(
              "mediafile_$count", yarn.media[i].mediaFile!.path);
        } else if (yarn.media[i].mediaType == 'video') {
          // Add fields
          request.fields["mediafile_$count"] =
              yarn.media[i].mediaFile?.path ?? "";
          // Create multipart using filepath, string or bytes
          multipartFile = await http.MultipartFile.fromPath(
              "mediafile_$count", yarn.media[i].mediaFile!.path);
          // Add Poster Fields
          request.fields["mediaposter_$count"] =
              yarn.media[i].mediaPoster ?? '';

          thumbnailImage = await http.MultipartFile.fromPath(
              "mediaposter_$count", yarn.media[i].mediaPoster ?? '');
          thumbnailList.add(thumbnailImage);
        }
        // Add multipart to newList
        newList.add(multipartFile);
        count = count + 1;
      }
    }

    request.fields.addAll({
      "tags": jsonEncode(yarn.tags),
      "body": yarn.body ?? "",
      "category": yarn.category?.id ?? "",
      "author": yarn.author ?? "",
      "is_question": jsonEncode(yarn.isQuestion),
      "media_count": "$count",
      "enable_commenting": jsonEncode(yarn.enableCommenting ?? false),
      "enable_payme": jsonEncode(yarn.enablePayMe ?? false),
      "attachment": jsonEncode(yarn.attachment),
    });

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
    if (response.statusCode == 200) {
      var result = jsonDecode(responseBody);
      return result;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${jsonDecode(responseBody)}");

      throw responseBody;
    }
  }

  // Add Yarn and Question
  Future<bool> addYarnAndQuestion(Yarn addYarnAndQuestion) async {
    debugPrint("MEDIA LENGTH:- ${addYarnAndQuestion.media.length}");
    var headers = await getAuthHeaders();
    var url = AppConfig.baseUrl + "/api/v1/social/ask/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse(url));

    Map<dynamic, dynamic> _data = addYarnAndQuestion.toAddMap();
    debugPrint('DATA ---> $_data');

    if (addYarnAndQuestion.isQuestion ?? false) {
      request.fields["title"] = addYarnAndQuestion.title!;
    }

    var mapValue = {
      "tags": jsonEncode(addYarnAndQuestion.tags),
      "body": addYarnAndQuestion.body ?? "",
      "category": addYarnAndQuestion.category?.id ?? "0",
      "author": addYarnAndQuestion.author ?? "",
      "is_question": jsonEncode(addYarnAndQuestion.isQuestion),
      "media_count": jsonEncode(addYarnAndQuestion.media.length),
      "enable_commenting":
          jsonEncode(addYarnAndQuestion.enableCommenting ?? false),
      "enable_payme": jsonEncode(addYarnAndQuestion.enablePayMe ?? false),
      "type": "yarn",
      "is_sensitive_content":
          jsonEncode(addYarnAndQuestion.isSensitiveContent ?? false),
      "is_adult_content":
          jsonEncode(addYarnAndQuestion.isAdultContent ?? false),
      "age_restriction": jsonEncode(addYarnAndQuestion.ageRestriction ?? 13),
    };
    if (addYarnAndQuestion.attachment != null) {
      mapValue['attachment'] =
          jsonEncode(addYarnAndQuestion.attachment ?? null);
    }

    logger.d(' share as yar message...... $mapValue');

    request.fields.addAll(mapValue);

    List<MultipartFile> newList = [];
    List<MultipartFile> thumbnailList = [];
    debugPrint("MEDIA LENGTH::: ${addYarnAndQuestion.media.length}");
    for (int i = 0; i < addYarnAndQuestion.media.length; i++) {
      debugPrint("MEDIA TYPE::: ${addYarnAndQuestion.media[i].mediaType}");
      var multipartFile;
      var thumbnailImage;
      if (addYarnAndQuestion.media[i].mediaType == 'image') {
        // Add fields
        request.fields["mediafile_$i"] =
            addYarnAndQuestion.media[i].mediaFile!.path;
        // Create multipart using filepath, string or bytes
        multipartFile = await http.MultipartFile.fromPath(
            "mediafile_$i", addYarnAndQuestion.media[i].mediaFile!.path);
      } else if (addYarnAndQuestion.media[i].mediaType == 'video') {
        // Add fields
        request.fields["mediafile_$i"] =
            addYarnAndQuestion.media[i].mediaFile!.path;
        // Create multipart using filepath, string or bytes
        multipartFile = await http.MultipartFile.fromPath(
            "mediafile_$i", addYarnAndQuestion.media[i].mediaFile!.path);
        // Add Poster Fields
        request.fields["mediaposter_$i"] =
            addYarnAndQuestion.media[i].posterFile?.path ?? '';

        thumbnailImage = await http.MultipartFile.fromPath("mediaposter_$i",
            addYarnAndQuestion.media[i].posterFile?.path ?? '');
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

  Future<bool> deleteYarnMedia(String mediaId) async {
    var url = AppConfig.baseUrl +
        "/api/v1/social/ask/delete-yarn-media/" +
        mediaId +
        "/";
    debugPrint("URL:- $url");
    var headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);
    debugPrint("response:- ${response.body}");
    if (response.statusCode == 204) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // {"comment":"xyz","author_username:""};
  // ADD COMMENT TO YARN
  Future<YarnComment?> addCommentToYarn(
      String yarnId, Map<String, dynamic> body) async {
    debugPrint("CALLING ALL CATEGORIES");

    String url =
        AppConfig.baseUrl + "/api/v1/social/ask/yarn-comments/$yarnId/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var request = http.MultipartRequest("POST", Uri.parse(url));

    logger.d('body to see $body and d ${body['media_count'].length}');

    Map<String, String> payload = {
      "comment": body['comment'] ?? "",
      "author_username": body['author_username'] ?? "",
      "enable_payme": jsonEncode(body['enable_payme'] ?? false),
      "enable_commenting": jsonEncode(body['enable_commenting'] ?? false),
      "is_adult_content": jsonEncode(body['is_adult_content'] ?? false),
      "is_sensitive_content": jsonEncode(body['is_sensitive_content'] ?? false),
      "age_restriction": jsonEncode(body['age_restriction'] ?? 13),
      "media_count": jsonEncode(
          body['media_count'] != null ? body['media_count'].length : 0),
    };

    print('print payload let see $payload');
    request.fields.addAll(payload);
    List<MultipartFile> newList = [];
    List<MultipartFile> thumbnailList = [];
    if (body['media_count'].isNotEmpty) {
      debugPrint("MEDIA LENGTH::: ${body['media_count'].length}");
      for (int i = 0; i < body['media_count'].length; i++) {
        debugPrint("MEDIA TYPE::: ${body['media_count'][i].mediaType}");
        var multipartFile;
        var thumbnailImage;
        if (body['media_count'][i].mediaType == 'image') {
          // Add fields
          request.fields["mediafile_$i"] =
              body['media_count'][i].mediaFile!.path;
          // Create multipart using filepath, string or bytes
          multipartFile = await http.MultipartFile.fromPath(
              "mediafile_$i", body['media_count'][i].mediaFile!.path);
        } else if (body['media_count'][i].mediaType == 'video') {
          // Add fields
          request.fields["mediafile_$i"] =
              body['media_count'][i].mediaFile!.path;
          // Create multipart using filepath, string or bytes
          multipartFile = await http.MultipartFile.fromPath(
              "mediafile_$i", body['media_count'][i].mediaFile!.path);
          // Add Poster Fields
          request.fields["mediaposter_$i"] =
              body['media_count'][i].mediaPoster ?? '';

          thumbnailImage = await http.MultipartFile.fromPath(
              "mediaposter_$i", body['media_count'][i].mediaPoster ?? '');
          thumbnailList.add(thumbnailImage);
        }

        // Add multipart to newList
        newList.add(multipartFile);
      }
      // Add multipart to request
      request.files.addAll(newList);
      request.files.addAll(thumbnailList);
    }

    debugPrint('REQUEST FIELDS ---> ${request.fields}');
    debugPrint('REQUEST FILES ---> ${request.files}');

    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }

    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      YarnComment commentDetails =
          YarnComment.fromJson(json.decode(responseBody));
      return commentDetails;
    } else if (response.statusCode == 500) {
      return Future.error("Please try again later !!");
    } else {
      throw responseBody;
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

  // Toggle commenting
  Future<Map<String, dynamic>?> toggleCommenting(
      String? yarnId, bool status) async {
    String url =
        getSecureUrl(url: AppConfig.baseUrl + "/api/v1/social/ask/$yarnId/");
    var headers = await getAuthHeaders();
    var response = await httpPatch(url,
        headers: headers, body: jsonEncode({"enable_commenting": status}));
    return jsonDecode(response.body);
  }

  // Delete Single Comment
  Future<bool?> deleteComment(String commentId) async {
    debugPrint("CALLING ALL COMMENTS");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/ask/comments/$commentId/";
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

    var request = http.MultipartRequest("POST", Uri.parse(url));
    // var response =
    //     await httpPost(url, headers: headers, body: jsonEncode(body));

    // debugPrint(
    //     "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    Map<String, String> payload = {
      "comment": body['comment'] ?? "",
      "is_reply": jsonEncode(body['is_reply']),
      "author_username": body['author_username'] ?? "",
      "enable_payme": jsonEncode(body['enable_payme'] ?? false),
      "enable_commenting": jsonEncode(body['enable_commenting'] ?? false),
      "is_adult_content": jsonEncode(body['is_adult_content'] ?? false),
      "is_sensitive_content": jsonEncode(body['is_sensitive_content'] ?? false),
      "age_restriction": jsonEncode(body['age_restriction'] ?? 13),
      "media_count": jsonEncode(
          body['media_count'] != null ? body['media_count'].length : 0),
    };

    request.fields.addAll(payload);
    List<MultipartFile> newList = [];
    List<MultipartFile> thumbnailList = [];
    if (body['media_count'].isNotEmpty) {
      debugPrint("MEDIA LENGTH::: ${body['media_count'].length}");
      for (int i = 0; i < body['media_count'].length; i++) {
        debugPrint("MEDIA TYPE::: ${body['media_count'][i].mediaType}");
        var multipartFile;
        var thumbnailImage;
        if (body['media_count'][i].mediaType == 'image') {
          // Add fields
          request.fields["mediafile_$i"] =
              body['media_count'][i].mediaFile!.path;
          // Create multipart using filepath, string or bytes
          multipartFile = await http.MultipartFile.fromPath(
              "mediafile_$i", body['media_count'][i].mediaFile!.path);
        } else if (body['media_count'][i].mediaType == 'video') {
          // Add fields
          request.fields["mediafile_$i"] =
              body['media_count'][i].mediaFile!.path;
          // Create multipart using filepath, string or bytes
          multipartFile = await http.MultipartFile.fromPath(
              "mediafile_$i", body['media_count'][i].mediaFile!.path);
          // Add Poster Fields
          request.fields["mediaposter_$i"] =
              body['media_count'][i].mediaPoster ?? '';

          thumbnailImage = await http.MultipartFile.fromPath(
              "mediaposter_$i", body['media_count'][i].mediaPoster ?? '');
          thumbnailList.add(thumbnailImage);
        }

        // Add multipart to newList
        newList.add(multipartFile);
      }
      // Add multipart to request
      request.files.addAll(newList);
      request.files.addAll(thumbnailList);
    }

    debugPrint('REQUEST FIELDS ---> ${request.fields}');
    debugPrint('REQUEST FILES ---> ${request.files}');

    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }

    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      YarnComment commentDetail =
          YarnComment.fromJson(json.decode(responseBody));
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
      for (var item in jsonData['results']) {
        YarnComment replyCommentDetail = YarnComment.fromJson(item);
        commentDetails.add(replyCommentDetail);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
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
  Future<Yarn?> addReYarn(Map<String, dynamic> body) async {
    debugPrint("CALLING REYARN");
    String url = "";
    url = AppConfig.baseUrl + "/api/v1/social/ask/reyarn/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    // var headers = <String,dynamic>{};
    var response =
        await httpPost(url, headers: headers, body: jsonEncode(body));
    if (response.statusCode == 401) {
      var headers = await getAuthHeaders();
      var response =
          await httpPost(url, headers: headers, body: jsonEncode(body));
    }

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = jsonDecode(response.body);
      Yarn reYarn = Yarn.fromJson(data);
      return reYarn;
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
      url = AppConfig.baseUrl + "/api/v1/social/ask/notifications/";
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
