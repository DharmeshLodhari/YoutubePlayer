import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserPostAuth extends AuthService {
  // Fetch User Posts Details
  Future<Map<String, dynamic>> listUserPosts({String? userName}) async {
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

  Future<bool> createBlogPost({
    required String title,
    required String tagLine,
    File? blogImage,
    List<String>? tags,
    required String blogPostBody,
    bool isPublic = false,
    String? publishedDate,
    bool isPublished = false,
    bool enableLikes = false,
    bool enableCommenting = false,
  }) async {
    var url = AppConfig.baseUrl + "/api/v1/social/posts/";
    var headers = await getAuthHeaders();

    if (blogImage != null) {
      var blogImagePath = blogImage.path;
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(url));

      //add fields
      if (tags != null) {
        request.fields["tags"] = jsonEncode(tags);
      }
      request.fields["title"] = title;
      request.fields["tag_line"] = tagLine;
      request.fields["text"] = blogPostBody;
      request.fields['public_read'] = jsonEncode(isPublic);
      request.fields['enable_like'] = jsonEncode(enableLikes);
      request.fields['is_published'] = jsonEncode(isPublished);
      request.fields['enable_commenting'] = jsonEncode(enableCommenting);

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
        "text": blogPostBody,
        'public_read': isPublic,
        'enable_like': enableLikes,
        'is_published': isPublished,
        'enable_commenting': enableCommenting,
      };
      if (tags != null) {
        _body['tags'] = tags;
      }
      var response =
          await httpPost(url, headers: headers, body: jsonEncode(_body));
      print('CREATE BLOG RESPONSE ----> ${response.body}');
      return response.statusCode == 201;
    }
  }

  Future<bool> updateBlogPost({
    String? title,
    String? tagLine,
    File? blogImage,
    List<String>? tags,
    String? blogPostBody,
    bool isPublic = false,
    String? publishedDate,
    required String blogId,
    bool isPublished = false,
    bool enableLikes = false,
    bool enableCommenting = false,
  }) async {
    var url = AppConfig.baseUrl + "/api/v1/social/posts/$blogId/";
    var headers = await getAuthHeaders();

    if (blogImage != null) {
      var blogImagePath = blogImage.path;
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("PATCH", Uri.parse(url));

      request.fields['public_read'] = jsonEncode(isPublic);
      request.fields['enable_like'] = jsonEncode(enableLikes);
      request.fields['is_published'] = jsonEncode(isPublished);
      request.fields['enable_commenting'] = jsonEncode(enableCommenting);
      if (title != null) {
        request.fields['title'] = title;
      }

      if (tagLine != null) {
        request.fields['tag_line'] = tagLine;
      }
      if (tags != null) {
        request.fields['tags'] = jsonEncode(tags);
      }
      if (blogPostBody != null) {
        request.fields['text'] = blogPostBody;
      }
      if (publishedDate != null) {
        request.fields['published_date'] = publishedDate;
      }

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

      if (response.statusCode == 200) {
        return true;
      } else {
        return Future.error(
            "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- $responseBody");
      }
    } else {
      Map<String, dynamic> body = {
        'public_read': isPublic,
        'enable_like': enableLikes,
        'is_published': isPublished,
        'enable_commenting': enableCommenting,
      };
      if (title != null) {
        body['title'] = title;
      }
      if (tagLine != null) {
        body['tag_line'] = tagLine;
      }
      if (tags != null) {
        body['tags'] = tags;
      }
      if (blogPostBody != null) {
        body['text'] = blogPostBody;
      }
      if (publishedDate != null) {
        body['published_date'] = publishedDate;
      }
      var response =
          await httpPatch(url, headers: headers, body: jsonEncode(body));

      print('UPDATE BLOG SETTINGS -----> ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
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
