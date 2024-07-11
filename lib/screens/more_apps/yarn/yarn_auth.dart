import 'dart:convert';
import 'dart:developer';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/main.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';
import "package:http/http.dart" as http;
import 'package:http/http.dart';

import 'models/Topics/Notifications.dart';
import 'models/Topics/comment_details.dart';
import 'models/Topics/yarn_model.dart';
import 'models/ask_categories_model.dart';

class YarnAuth extends AuthService {
  YarnCategories createAskCategories(Map<String, dynamic> item) {
    final YarnCategories categories = YarnCategories();
    categories.id = item['id'];
    categories.name = item['name'];
    categories.color = item['color'];
    categories.image = item['image'];

    return categories;
  }

  ProductCategory createProductCategories(dynamic item) {
    final ProductCategory categories =
        ProductCategory(messageDecoderWithEmoji(item["name"])!, id: item["id"]);
    return categories;
  }

  // Get all YARN Categories
  Future<Map<String, dynamic>?> getAllCategories(
      String? next, String previous) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/social/ask/list-categories/";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<YarnCategories> askCategories = [];
      final jsonData = json.decode(response.body);

      // debugPrint("JSON CATEGORIES::- $jsonData");

      for (var item in jsonData["results"]) {
        final YarnCategories categories = createAskCategories(item);
        askCategories.add(categories);
      }

      final Map<String, dynamic> result = {
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

  // Get all Product Categories
  Future<Map<String, dynamic>?> getProductCategories(
      String? next, String previous) async {
    debugPrint("CALLING PRODUCT CATEGORIES");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/products/choices/";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<ProductCategory> productCategories = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        // ProductCategory categories = createProductCategories(item['name']);
        final ProductCategory categories = createProductCategories(item);
        productCategories.add(categories);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": productCategories
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
    String url = "";
    url = "${AppConfig.baseUrl}/api/v1/social/ask/user-interest/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      UsersCategories usersCategory;
      final jsonData = json.decode(response.body);
      debugPrint("JSON DECODED:- $jsonData");
      usersCategory = UsersCategories.fromJson(jsonData);

      final Map<String, dynamic> result = {"results": usersCategory};

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Get all User's Yarn Setting
  Future<UserYarnSettings?> getUserYarnSettings() async {
    String url = "";
    url = "${AppConfig.baseUrl}/api/v1/social/ask/user-interest/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      UserYarnSettings yarnSettings;
      final jsonData = json.decode(response.body);
      yarnSettings = UserYarnSettings.fromJson(jsonData);
      return yarnSettings;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Get all User's Yarn Setting
  Future<UserYarnSettings?> updateUserYarnSettings(Map body) async {
    String url = "";
    url = "${AppConfig.baseUrl}/api/v1/social/ask/user-interest/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response =
        await httpPost(url, headers: headers, body: jsonEncode(body));

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      UserYarnSettings yarnSettings;
      final jsonData = json.decode(response.body);
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
    String url = "";
    url = "${AppConfig.baseUrl}/api/v1/social/ask/user-interest/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: body);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      UsersCategories usersCategory;
      final jsonData = json.decode(response.body);
      debugPrint("JSON DECODED:- $jsonData");
      usersCategory = UsersCategories.fromJson(jsonData);

      final Map<String, dynamic> result = {"results": usersCategory};

      return result;
    } else if (response.statusCode == 500) {
      return Future.error("Please try again later !!");
    } else {
      return Future.error(response.body);
    }
  }

  // Save User's Selected Single Categories
  Future<Map<String, dynamic>?> saveUsersSingleCategories(
      String categoryId) async {
    String url = "";
    url =
        "${AppConfig.baseUrl}/api/v1/social/ask/user-single-interest/$categoryId/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      UsersCategories usersCategory;
      final jsonData = json.decode(response.body);
      debugPrint("JSON DECODED:- $jsonData");
      usersCategory = UsersCategories.fromJson(jsonData);

      final Map<String, dynamic> result = {"results": usersCategory};

      return result;
    } else if (response.statusCode == 500) {
      return Future.error("Please try again later !!");
    } else {
      return Future.error(response.body);
    }
  }

  // Delete User's Selected Single Categories
  Future<Map<String, dynamic>?> deleteUsersSingleCategories(
      String categoryId) async {
    String url = "";
    url =
        "${AppConfig.baseUrl}/api/v1/social/ask/user-single-interest/$categoryId/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpDelete(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      UsersCategories usersCategory;
      final jsonData = json.decode(response.body);
      debugPrint("JSON DECODED:- $jsonData");
      usersCategory = UsersCategories.fromJson(jsonData);

      final Map<String, dynamic> result = {"results": usersCategory};

      return result;
    } else if (response.statusCode == 500) {
      return Future.error("Please try again later !!");
    } else {
      return Future.error(response.body);
    }
  }

  // Get all YARN Topics
  Future<Map<String, dynamic>?> getAllYarn(String? next, String previous,
      {String? type,
      bool isType = false,
      String? categoryId,
      String? userName,
      String? latestTrending,
      String? isChannel,
      int pageSize = 21}) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (isType) {
        if (categoryId != null) {
          url =
              "${AppConfig.baseUrl}/api/v1/social/ask/$latestTrending/?$type=$isType&category=$categoryId";
        } else {
          if (latestTrending != null) {
            url = "${AppConfig.baseUrl}/api/v1/social/ask/$latestTrending/";
          } else {
            url = "${AppConfig.baseUrl}/api/v1/social/ask/?$type=$isType";
          }
        }
      } else {
        if (isChannel == 'channel') {
          url = "${AppConfig.baseUrl}/api/v1/social/ask/channel/$userName/";
        } else if (isChannel == '') {
          url =
              "${AppConfig.baseUrl}/api/v1/social/ask/$type/?username=$userName";
        }
      }
    } else {
      url = getSecureUrl(url: next);
    }
    if (pageSize != "") {
      if (url.contains("page_size")) {
        url = url;
      } else if (url.contains("?")) {
        url = "$url&page_size=$pageSize";
      } else {
        url = "$url?page_size=$pageSize";
      }
    }

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Yarn> yarnTopics = [];
      final jsonData = json.decode(response.body);

      // debugPrint("GET DATA yarn list:- $jsonData");
      for (var item in jsonData["results"]) {
        final Yarn yarnTopic = Yarn.fromJson(item);
        yarnTopics.add(yarnTopic);

        debugPrint("GET DATA Yarn:- ${item['viewers_avatars']}");
      }

      final Map<String, dynamic> result = {
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

  // Get all SAVED YARN Topics
  Future<Map<String, dynamic>?> getAllSavedYarn(String? next, String previous,
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
      url =
          "${AppConfig.baseUrl}/api/v1/social/ask/user-yarn-visibility-options";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint('GET DATA saved Yarn::: $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Yarn> yarnTopics = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final Yarn yarnTopic = Yarn.fromJson(item);
        yarnTopics.add(yarnTopic);
      }

      final Map<String, dynamic> result = {
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

  // Delete Save Yarn
  Future<bool?> deleteSavedYarn({String? savedYarnID}) async {
    debugPrint("REMOVING SAVED YARN ID");
    String url = "";
    if (savedYarnID != null) {
      url =
          "${AppConfig.baseUrl}/api/v1/social/ask/user-saved-or-hidden-yarns/$savedYarnID/";
    }

    final headers = await getAuthHeaders();
    final response = await httpDelete(url, headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Get Single Yarn Question
  Future<Map<String, dynamic>?> getSingleTopics({String? yarnId}) async {
    String url = "";
    if (yarnId != null) {
      url = "${AppConfig.baseUrl}/api/v1/social/ask/$yarnId";
    }
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      final Yarn yarnTopic = Yarn.fromJson(jsonData);

      final Map<String, dynamic> result = {"results": yarnTopic};
      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Delete Single Yarn Question
  Future<bool?> deleteSingleTopics({String? yarnId}) async {
    String url = "";
    if (yarnId != null) {
      url = "${AppConfig.baseUrl}/api/v1/social/ask/$yarnId/";
    }
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpDelete(url, headers: headers);

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
      url =
          "${AppConfig.baseUrl}/api/v1/social/ask/?question=$isQuestion&search=$searchText";

      if (categoryId != null) {
        url =
            "${AppConfig.baseUrl}/api/v1/social/ask/?question=$isQuestion&search=$searchText&categoryId=$categoryId";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Yarn> yarnTopics = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        final Yarn yarnTopic = Yarn.fromJson(item);
        yarnTopics.add(yarnTopic);
      }

      final Map<String, dynamic> result = {
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
    final headers = await getAuthHeaders();
    final String url =
        "${AppConfig.baseUrl}/api/v1/social/ask/${yarn.id}/edit-yarn-or-question/";

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("POST", Uri.parse(url));

    // Map<dynamic, dynamic> _data = yarn.toJson();
    if (yarn.isQuestion) {
      request.fields["title"] = yarn.title!;
    }

    final List<MultipartFile> newList = [];
    final List<MultipartFile> thumbnailList = [];
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
      "body": messageDecoderWithEmoji(yarn.body) ?? "",
      "category": yarn.category?.id ?? "0",
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
    final response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = jsonDecode(responseBody);
      return result;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${jsonDecode(responseBody)}");

      throw responseBody;
    }
  }

  // Add Yarn and Question
  Future<StreamedResponse> _createYarn(
      Yarn addYarnAndQuestion, String url) async {
    debugPrint("MEDIA LENGTH:- ${addYarnAndQuestion.media.length}");
    final headers = await getAuthHeaders();

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("POST", Uri.parse(url));

    final Map<dynamic, dynamic> data = addYarnAndQuestion.toAddMap();
    debugPrint('DATA ---> $data');

    if (addYarnAndQuestion.isQuestion) {
      request.fields["title"] = addYarnAndQuestion.title!;
    }

    final mapValue = {
      "tags": jsonEncode(addYarnAndQuestion.tags),
      "body": messageDecoderWithEmoji(addYarnAndQuestion.body) ?? "",
      // "body": addYarnAndQuestion.body ?? "",
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
      mapValue['attachment'] = jsonEncode(addYarnAndQuestion.attachment);
    }

    if (addYarnAndQuestion.reYarn != null) {
      mapValue['reyarn'] = addYarnAndQuestion.reYarn!.id!;
      // logger.d("reyarnId ${mapValue['reyarn']}");
    }

    logger.d(' share as yar message...... $mapValue');

    request.fields.addAll(mapValue);

    final List<MultipartFile> newList = [];
    final List<MultipartFile> thumbnailList = [];
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
    final response = await request.send();

    return response;
  }

  // ADD REYARN TO YARN
  Future<Yarn?> addReYarn(Yarn reYarn) async {
    debugPrint("CALLING REYARN");

    String url = "";
    url = "${AppConfig.baseUrl}/api/v1/social/ask/reyarn/";
    debugPrint(url);

    final response = await _createYarn(reYarn, url);

    debugPrint("MEDIA LENGTH::: ${reYarn.media.length}");

    // if (response.statusCode == 401) {
    //   final headers = await getAuthHeaders();
    //   // var response =
    //   // await httpPost(url, headers: headers, body: jsonEncode(body));
    //   final response = await _createYarn(reYarn, url);
    // }

    // debugPrint(
    //     "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.stream.bytesToString()}");
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(responseBody);
      final Yarn reYarn = Yarn.fromJson(data);

      return reYarn;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Add Yarn and Question
  Future<dynamic> addYarnAndQuestion(
      Yarn addYarnAndQuestion, String s, String channelUsername) async {
    log('ppppppp${addYarnAndQuestion.toJson().toString()}');
    debugPrint("MEDIA LENGTH:- ${addYarnAndQuestion.media.length}");
    final headers = await getAuthHeaders();
    String url = "${AppConfig.baseUrl}/api/v1/social/ask/";

    if (channelUsername.isNotEmpty) {
      url = "${AppConfig.baseUrl}/api/v1/social/ask/channel/$channelUsername/";
    }

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("POST", Uri.parse(url));

    final Map<dynamic, dynamic> data0 = addYarnAndQuestion.toAddMap();
    debugPrint('DATA ---> $data0');

    if (addYarnAndQuestion.isQuestion) {
      request.fields["title"] =
          messageDecoderWithEmoji(addYarnAndQuestion.title)!;
    }

    final mapValue = {
      "tags": jsonEncode(addYarnAndQuestion.tags),
      "body": messageDecoderWithEmoji(addYarnAndQuestion.body) ?? "",
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
          messageDecoderWithEmoji(jsonEncode(addYarnAndQuestion.attachment))!;
    }
    // if (addYarnAndQuestion.userReyarned != null) {
    //   mapValue['user_reyarned'] = jsonEncode(addYarnAndQuestion.userReyarned);
    // }

    // logger.d(' share as yarn message...... $mapValue');
    debugPrint('share as yarn message ---> $mapValue');
    request.fields.addAll(mapValue);

    final List<MultipartFile> newList = [];
    final List<MultipartFile> thumbnailList = [];
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
    final response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    final responseBody = await response.stream.bytesToString();

    debugPrint('RESPONSE BODY url :::: $url');
    debugPrint('RESPONSE BODY :::: $responseBody');
    debugPrint('RESPONSE BODY 111 :::: ${jsonDecode(responseBody)}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('RESPONSE BODY create:::: $responseBody');

      if (s == 'Add') {
        final data = jsonDecode(responseBody);
        final Yarn reYarn = Yarn.fromJson(data);

        return reYarn;
      } else {
        return true;
      }
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${jsonDecode(responseBody)}");

      throw responseBody;
    }
  }

  Future<bool> deleteYarnMedia(String mediaId) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/social/ask/delete-yarn-media/$mediaId/";
    final headers = await getAuthHeaders();
    final response = await httpDelete(url, headers: headers);
    debugPrint("response:- ${response.body}");
    if (response.statusCode == 204) {
      return true;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // ADD COMMENT TO YARN
  Future<YarnComment?> addCommentToYarn(
      String yarnId, Map<String, dynamic> body) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/social/ask/yarn-comments/$yarnId/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final request = http.MultipartRequest("POST", Uri.parse(url));

    // logger.d('body to see $body and d ${body['media_count'].length}');

    final Map<String, String> payload = {
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

    if (body['attachment'] != null) {
      payload['attachment'] =
          jsonEncode(Map<String, dynamic>.from(body['attachment']));
    }

    request.fields.addAll(payload);
    final List<MultipartFile> newList = [];
    final List<MultipartFile> thumbnailList = [];
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
    final response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }

    final responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200 || response.statusCode == 201) {
      final YarnComment commentDetails =
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
      String? next, String previous, String yarnId,
      {String? sortBy}) async {
    debugPrint("CALLING ALL COMMENTS");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (sortBy != null) {
        url =
            "${AppConfig.baseUrl}/api/v1/social/ask/yarn-comments/$yarnId/?sort_by=$sortBy";
      } else {
        url = "${AppConfig.baseUrl}/api/v1/social/ask/yarn-comments/$yarnId/";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    final Map<String, dynamic>? pinnedYarn = await getPinnedComment(yarnId);

    debugPrint(
        "COMMENTS RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<YarnComment> commentsDetails = [];
      final jsonData = json.decode(response.body);

      debugPrint(
          'COMMENTS RESPONSE CODE::: ${jsonData['results'].runtimeType}');

      List<dynamic> results = jsonData['results'];

      if (pinnedYarn == null) {
      } else {
        if (pinnedYarn.isNotEmpty) {
          pinnedYarn['pinned'] = true;

          final List<dynamic> pinnedYarnList = [pinnedYarn];

          results = pinnedYarnList + results;
        }
      }

      for (var item in results) {
        final YarnComment commentsDetail = YarnComment.fromJson(item);
        commentsDetails.add(commentsDetail);
      }

      final Map<String, dynamic> result = {
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
    final String url =
        getSecureUrl(url: "${AppConfig.baseUrl}/api/v1/social/ask/$yarnId/");
    final headers = await getAuthHeaders();
    final response = await httpPatch(url,
        headers: headers, body: jsonEncode({"enable_commenting": status}));
    return jsonDecode(response.body);
  }

  // Delete Single Comment
  Future<bool?> deleteComment(String commentId) async {
    debugPrint("CALLING ALL COMMENTS");
    String url = "";
    url = "${AppConfig.baseUrl}/api/v1/social/comments/$commentId/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpDelete(url, headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Pin Single Comment
  Future<bool?> pinComment(String yarnId, String commentId,
      {bool? isComment}) async {
    debugPrint("CALLING POST TO PIN COMMENT");
    String url = "";
    if (isComment == false) {
      url =
          "${AppConfig.baseUrl}/api/v1/social/ask/pinned-comment/$yarnId/$commentId/";
    } else {
      url =
          "${AppConfig.baseUrl}/api/v1/social/moments/pinned-comment/$yarnId/$commentId/";
    }
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE PINNED POST CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // get pinned comment
  Future<Map<String, dynamic>?> getPinnedComment(String yarnId) async {
    debugPrint("CALLING PINNED COMMENT");
    String url = "";
    url = "${AppConfig.baseUrl}/api/v1/social/ask/pinned-comment/$yarnId/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE PINNED GET CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return data;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // DELETE PINNED COMMENT
  Future<bool?> deletePinnedComment(String yarnId, String commentId,
      {bool? isComment}) async {
    debugPrint("CALLING DELETE PIN COMMENT");
    String url = "";
    if (isComment == false) {
      url =
          "${AppConfig.baseUrl}/api/v1/social/ask/pinned-comment/$yarnId/$commentId/";
    } else {
      url =
          "${AppConfig.baseUrl}/api/v1/social/moments/pinned-comment/$yarnId/$commentId/";
    }

    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpDelete(url, headers: headers);

    debugPrint(
        "RESPONSE PINNED DELETE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
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
    String url = "";
    url =
        "${AppConfig.baseUrl}/api/v1/social/ask/reply-a-yarn-comment/$commentId/";
    debugPrint(url);

    final headers = await getAuthHeaders();

    final request = http.MultipartRequest("POST", Uri.parse(url));

    // debugPrint(
    //     "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    final Map<String, String> payload = {
      "comment": messageDecoderWithEmoji(body['comment']) ?? "",
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

    if (body['attachment'] != null) {
      payload['attachment'] =
          jsonEncode(Map<String, dynamic>.from(body['attachment']));
    }

    request.fields.addAll(payload);
    final List<MultipartFile> newList = [];
    final List<MultipartFile> thumbnailList = [];
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
    final response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final YarnComment commentDetail =
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
        url =
            "${AppConfig.baseUrl}/api/v1/social/ask/reply-a-yarn-comment/$commentId/?sort_by=$sortBy";
      } else {
        url =
            "${AppConfig.baseUrl}/api/v1/social/ask/reply-a-yarn-comment/$commentId/";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<YarnComment> commentDetails = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData['results']) {
        final YarnComment replyCommentDetail = YarnComment.fromJson(item);
        commentDetails.add(replyCommentDetail);
      }

      final Map<String, dynamic> result = {
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
    String url = "";
    url = "${AppConfig.baseUrl}/api/v1/social/ask/up-vote/$postId/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return data;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD DISLIKE TO YARN
  Future<Map<String, dynamic>?> addDisLike(String postId) async {
    String url = "";
    url = "${AppConfig.baseUrl}/api/v1/social/ask/down-vote/$postId/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return data;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD LIKE TO YARN
  Future<Map<String, dynamic>?> addLikeComment(String commentId) async {
    String url = "";
    url = "${AppConfig.baseUrl}/api/v1/social/comments/like/$commentId/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return data;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD DISLIKE TO YARN
  Future<Map<String, dynamic>?> addDisLikeComment(String commentId) async {
    String url = "";
    url = "${AppConfig.baseUrl}/api/v1/social/comments/dislike/$commentId/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return data;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Add Report to Momnet coment
  Future<bool?> reportCommentMoment(
      String postId, Map<String, dynamic> body) async {
    debugPrint("CALLING ALL REPORT");
    String url = "";
    // if (isMomentComment = false) {
    url = "${AppConfig.baseUrl}/api/v1/social/moments/report/$postId/";
    // } else {
    //   url = "${AppConfig.baseUrl}/api/v1/social/moments/report/$postId/";
    // }
    debugPrint('url$url');
    debugPrint('report body::: $body');

    final headers = await getAuthHeaders();
    final response =
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

  // Add Report to YARN
  Future<bool?> addReport(String postId, Map<String, dynamic> body) async {
    debugPrint("CALLING ALL REPORT");
    String url = "";
    // if (isMomentComment = false) {
    url = "${AppConfig.baseUrl}/api/v1/social/ask/report/$postId/";
    // } else {
    //   url = "${AppConfig.baseUrl}/api/v1/social/moments/report/$postId/";
    // }
    debugPrint('url$url');
    debugPrint('report body::: $body');

    final headers = await getAuthHeaders();
    final response =
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

  Future<bool?> reportJob(Map<String, dynamic> body) async {
    debugPrint("CALLING ALL REPORT");
    String url = "";
    // if (isMomentComment = false) {
    url = "${AppConfig.baseUrl}/api/v1/job-service/report-job/";
    // } else {
    //   url = "${AppConfig.baseUrl}/api/v1/social/moments/report/$postId/";
    // }
    debugPrint('url$url');
    debugPrint('report body::: $body');

    final headers = await getAuthHeaders();
    final response =
        await httpPost(url, headers: headers, body: jsonEncode(body));

    debugPrint(
        "RESPONSE CODE,.,.,.,.,:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

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
    final Map<String, dynamic> body = {
      "status": status,
      "yarn": topicId,
    };

    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    url =
        "${AppConfig.baseUrl}/api/v1/social/ask/user-yarn-visibility-options/$topicId/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response =
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

  Future<Map<String, dynamic>?> searchUser(
      String? next, String? previous, String searchText) async {
    String url = "${AppConfig.baseUrl}/api/v1/search/users/?search=$searchText";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = next;
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers)
        .timeout(timeOutDuration, onTimeout: () => timeOutFunction());

    debugPrint('SEARCH USER ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<CustomerProfile> customerProfiles = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData['results']) {
        final CustomerProfile customerProfile = CustomerProfile.fromJson(item);
        customerProfiles.add(customerProfile);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": customerProfiles,
      };
      return result;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // Get all Notifications
  Future<Map<String, dynamic>?> getAllNotification(
      String? next, String previous) async {
    debugPrint("CALLING ALL NOTIFICATION");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/social/ask/notifications/";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint(
        "COMMENTS RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Notifications> notifications = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        final Notifications notification = Notifications.fromJson(item);
        notifications.add(notification);
      }

      final Map<String, dynamic> result = {
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

  // delete Notifications
  Future<bool?> deleteNotification(String? notificationId) async {
    debugPrint("CALLING DELETE NOTIFICATION");
    final String url =
        "${AppConfig.baseUrl}/api/v1/social/ask/notifications/$notificationId/";

    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpDelete(url, headers: headers);

    debugPrint(
        "DELETE NOTIFICATION RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }
}
