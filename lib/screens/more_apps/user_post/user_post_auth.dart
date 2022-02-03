import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';

class UserPostAuth extends AuthService {
  // Fetch User Posts Details
  Future<Map<String, dynamic>> getUserPostList({String? userName}) async {
    var url = AppConfig.baseUrl + "/api/v1/social/posts/user/$userName/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      return jsonData;
    }
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    return Future.error("${response.body}");
  }

  Future<UserPost> likeUserPost(UserPost post) async {
    var url = AppConfig.baseUrl + "/api/v1/social/posts/like/${post.id}/";
    Map<String, String> headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers);

    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      UserPost userPost = UserPost.fromJson(jsonDecode(response.body));

      return userPost;
    } else {
      if (response.statusCode != 500) {
        var jsonData = jsonDecode(response.body);
        debugPrint(
            "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
        return Future.error(jsonData is Map
            ? jsonData["error"]
            : jsonData is List
                ? jsonData[0]
                : jsonData);
      }
      return Future.error("Server Error");
    }
  }

  Future<UserPost> dislikeUserPost(UserPost post) async {
    var url = AppConfig.baseUrl + "/api/v1/social/posts/dislike/${post.id}/";
    Map<String, String> headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers);

    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      UserPost userPost = UserPost.fromJson(jsonDecode(response.body));

      return userPost;
    } else {
      if (response.statusCode != 500) {
        var jsonData = jsonDecode(response.body);
        debugPrint(
            "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
        return Future.error(jsonData is Map
            ? jsonData["error"]
            : jsonData is List
                ? jsonData[0]
                : jsonData);
      }
      return Future.error("Server Error");
    }
  }
}
