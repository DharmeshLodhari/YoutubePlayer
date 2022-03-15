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

      print(
          'USER POST JSON ----> ${jsonData['results'][jsonData['results'].length - 2]['tag_line']}');
      print('SECOND USER POST JSON ----> ${jsonData['results'][1]}');
      return jsonData;
    }
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    return Future.error("${response.body}");
  }

  Future<List<UserPost>> getSimilarPosts({required String postID}) async {
    var url =
        AppConfig.baseUrl + "/api/v1/social/posts/list-similar-post/$postID/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200) {
      List jsonData = jsonDecode(response.body)['results'];
      print('JSON RESULT :::: $jsonData');

      List<UserPost> userPostList =
          jsonData.map((json) => UserPost.fromJson(json)).toList();

      return userPostList;
    } else {
      return Future.error("${response.body}");
    }
  }

  Future<UserPost> getPost({required String postID}) async {
    var url = AppConfig.baseUrl + "/api/v1/social/posts/$postID/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint(
        "URL GET POST $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200) {
      return UserPost.fromJson(jsonDecode(response.body));
    } else {
      return Future.error("${response.body}");
    }
  }

  Future<bool> createOrUpdateBlogPost({
    String? blogId,
    File? blogVideo,
    List<String>? tags,
    required String title,
    bool isPublic = false,
    String? publishedDate,
    required File blogImage,
    bool isPublished = false,
    bool enableLikes = false,
    required bool isUpdating,
    required String blogPostBody,
    bool enableCommenting = false,
    required String authorUserName,
  }) async {
    return _postBlogWithMedia(
      tags: tags,
      title: title,
      blogId: blogId,
      isPublic: isPublic,
      blogImage: blogImage,
      blogVideo: blogVideo,
      isUpdating: isUpdating,
      isPublished: isPublished,
      enableLikes: enableLikes,
      blogPostBody: blogPostBody,
      publishedDate: publishedDate,
      authorUserName: authorUserName,
      enableCommenting: enableCommenting,
    );
  }

  Future<bool> _postBlogWithMedia({
    String? blogId,
    File? blogVideo,
    List<String>? tags,
    required String title,
    bool isPublic = false,
    String? publishedDate,
    required File blogImage,
    bool isUpdating = false,
    bool isPublished = false,
    bool enableLikes = false,
    required String blogPostBody,
    bool enableCommenting = false,
    required String authorUserName,
  }) async {
    var urlToPostBlog = AppConfig.baseUrl + "/api/v1/social/posts/";
    var urlToUpdateBlog = AppConfig.baseUrl + "/api/v1/social/posts/$blogId/";
    String url = isUpdating ? urlToUpdateBlog : urlToPostBlog;
    var headers = await getAuthHeaders();

    String? blogImagePath;
    String? blogVideoPath;
    http.MultipartFile imageMultipartFile;
    http.MultipartFile videoMultipartFile;
    var request =
        http.MultipartRequest(isUpdating ? "PATCH" : "POST", Uri.parse(url));

    blogImagePath = blogImage.path;
    imageMultipartFile =
        await http.MultipartFile.fromPath("image", blogImagePath);
    request.files.add(imageMultipartFile);

    if (blogVideo != null) {
      blogVideoPath = blogVideo.path;
      videoMultipartFile =
          await http.MultipartFile.fromPath("video", blogVideoPath);
      request.files.add(videoMultipartFile);
    }

    //add fields
    if (tags != null) {
      request.fields["tags"] = jsonEncode(tags);
    }
    request.fields["title"] = title;
    request.fields["text"] = blogPostBody;
    request.fields["author_username"] = authorUserName;
    request.fields['public_read'] = jsonEncode(isPublic);
    request.fields['enable_like'] = jsonEncode(enableLikes);
    request.fields['is_published'] = jsonEncode(isPublished);
    request.fields['enable_commenting'] = jsonEncode(enableCommenting);

    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller video, This video is too large.");
    }
    var responseBody = await response.stream.bytesToString();
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      return Future.error(
          "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- $responseBody");
    }
  }

  // Future<bool> updateBlogPost({
  //   File? blogImage,
  //   File? blogVideo,
  //   List<String>? tags,
  //   required String title,
  //   bool isPublic = false,
  //   String? publishedDate,
  //   required String blogId,
  //   required String tagLine,
  //   bool isPublished = false,
  //   bool enableLikes = false,
  //   required String blogPostBody,
  //   bool enableCommenting = false,
  //
  // }) async {
  //   var url = AppConfig.baseUrl + "/api/v1/social/posts/$blogId/";
  //   var headers = await getAuthHeaders();
  //
  //   if (blogImage != null || blogVideo != null) {
  //     return _postBlogWithMedia(
  //       tags: tags,
  //       title: title,
  //       tagLine: tagLine,
  //       isUpdating: true,
  //       isPublic: isPublic,
  //       blogImage: blogImage,
  //       blogVideo: blogVideo,
  //       isPublished: isPublished,
  //       enableLikes: enableLikes,
  //       blogPostBody: blogPostBody,
  //       publishedDate: publishedDate,
  //       enableCommenting: enableCommenting,
  //     );
  //   } else {
  //     Map<String, dynamic> body = {
  //       "title": title,
  //       "tag_line": tagLine,
  //       "text": blogPostBody,
  //       'public_read': isPublic,
  //       'enable_like': enableLikes,
  //       'is_published': isPublished,
  //       'enable_commenting': enableCommenting,
  //     };
  //     if (tags != null) {
  //       body['tags'] = tags;
  //     }
  //     var response =
  //         await httpPatch(url, headers: headers, body: jsonEncode(body));
  //
  //     print('UPDATE BLOG SETTINGS -----> ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   }
  // }

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
