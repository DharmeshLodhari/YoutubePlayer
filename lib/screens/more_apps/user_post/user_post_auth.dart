import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

      print('USER POST JSON ----> ${jsonData}');
      return jsonData;
    }
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    return Future.error("${response.body}");
  }

  Future<bool> postUserBlogPost(
      {required title,
      required tagLine,
      required String blogBodyText,
      File? blogImage}) async {
    var url = AppConfig.baseUrl + "/api/v1/social/posts/";
    var headers = await getAuthHeaders();

    if (blogImage != null) {
      var blogImagePath = blogImage.path;
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(url));

      //add fields
      request.fields["title"] = title;
      request.fields["tag_line"] = tagLine;
      request.fields["text"] = blogBodyText;

      //create multipart using filepath, string or bytes.
      var multipartFile =
          await http.MultipartFile.fromPath("image", blogImagePath);

      //add multipart to request
      request.files.add(multipartFile);
      headers.forEach((k, v) => request.headers[k] = v);
      var response = await request.send();

      if (response.statusCode == 413) {
        return Future.error(
            "Please upload smaller image, This image is too large.");
      }
      var responseBody = await response.stream.bytesToString();
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");
      print('CREATE BLOG RESPONSE ----> $responseBody');

      if (response.statusCode == 201) {
        return true;
      } else {
        return Future.error(
            "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- $responseBody");
      }
    } else {
      Map<String, dynamic> _body = {
        "tag_line": tagLine,
        "title": title,
        "text": blogBodyText
      };
      var response =
          await httpPost(url, headers: headers, body: jsonEncode(_body));
      print('CREATE BLOG RESPONSE ----> ${response.body}');
      return response.statusCode == 201;
    }
  }

  Future<bool> updateBlogSettings({
    required String blogId,
    String? tags,
    bool isPublished = false,
    bool enableLikes = false,
    bool enableCommenting = false,
    bool isPublic = false,
    String? publishedDate,
  }) async {
    var url = AppConfig.baseUrl + "/api/v1/social/posts/$blogId/";
    var headers = await getAuthHeaders();

    Map<String, dynamic> body = {
      'public_read': isPublic,
      'is_published': isPublished,
      'enable_like': enableLikes,
      'enable_commenting': enableCommenting,
      'published_date': publishedDate,
    };

    if (tags != null) {
      body['tags'] = tags.replaceAll(' ', '').split(',');
    }
    print('BODY:::: $body');

    var response =
        await httpPatch(url, headers: headers, body: jsonEncode(body));

    print('UPDATE BLOG SETTINGS -----> ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteBlog({required String blogId}) async {
    var url = AppConfig.baseUrl + "/api/v1/social/posts/$blogId/";
    Map<String, String> headers = await getAuthHeaders();
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
