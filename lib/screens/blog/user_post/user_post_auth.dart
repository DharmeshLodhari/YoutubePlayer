import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/blog/super_blog/super_blog.dart';
import 'package:Slydo/screens/blog/user_post/models/user_post.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserPostAuth extends AuthService {
  Future<Map<String, dynamic>?> listAllPosts(
      {String? next = "",
      String? titleToSearch,
      required SlydoBlogsMenu slydoBlogsMenu}) async {
    final String slydoBlogsMenuString = slydoBlogsMenu.name.toLowerCase();

    String url = "";
    if (next == null) {
      return null;
    }

    if (next == "") {
      if (titleToSearch != null) {
        url =
            "${AppConfig.baseUrl}/api/v1/social/posts/public/?search=$titleToSearch";
      } else {
        if (slydoBlogsMenuString == "all") {
          url = "${AppConfig.baseUrl}/api/v1/social/posts/public/";
        } else {
          url =
              "${AppConfig.baseUrl}/api/v1/social/posts/$slydoBlogsMenuString";
        }
      }
    } else {
      url = getSecureUrl(url: next);
    }

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint(
    //     "ALL POST URL $url STATUS CODE:- ${response.statusCode} LIST USER POST BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      return jsonData;
    }
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode}  BODY:- ${response.body}");
    return Future.error(response.body);
  }

  Future<Map<String, dynamic>?> listUserPosts(
      {String? next = "",
      String? pageSize,
      required String? userName,
      String? channelUserName}) async {
    var url = AppConfig.baseUrl;
    if (next == null) {
      return null;
    }

    if (next == "") {
      if (pageSize != null) {
        url = "$url/api/v1/social/posts/user/$userName/?page_size=$pageSize";
      } else {
        if (channelUserName != '') {
          url =
              "${AppConfig.baseUrl}/api/v1/social/posts/channel/$channelUserName/";
        } else if (channelUserName == '') {
          url = "${AppConfig.baseUrl}/api/v1/social/posts/user/$userName/";
        }
      }
    } else {
      url = getSecureUrl(url: next);
    }

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint(
    //     "URL $url STATUS CODE:- ${response.statusCode} LIST USER POST BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return jsonData;
    }
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode}  BODY:- ${response.body}");
    return Future.error(response.body);
  }

  Future<List<UserPost>> getSimilarPosts({required String postID}) async {
    final url =
        "${AppConfig.baseUrl}/api/v1/social/posts/list-similar-post/$postID/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    // debugPrint(
    //     "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List jsonData = jsonDecode(response.body)['results'];
      // debugPrint('JSON RESULT :::: $jsonData');

      final List<UserPost> userPostList =
          jsonData.map((json) => UserPost.fromJson(json)).toList();

      return userPostList;
    } else {
      return Future.error(response.body);
    }
  }

  Future<UserPost?> getSinglePost({required String postID}) async {
    final url = "${AppConfig.baseUrl}/api/v1/social/posts/$postID/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    // debugPrint(
    //     "URL GET POST $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      // debugPrint('AUTHOR NAME ::: ${jsonDecode(response.body)}');
      return UserPost.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      return Future.error(response.body);
    }
  }

  Future<bool> updateBlogView({required String postId}) async {
    final url =
        "${AppConfig.baseUrl}/api/v1/social/post/update-post-views/$postId/";
    final Map<String, String> headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint(
    //     "UPDATE POST VIEW URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      if (response.statusCode != 500) {
        final jsonData = jsonDecode(response.body);
        // debugPrint(
        //     "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
        return Future.error(jsonData is Map
            ? jsonData["error"]
            : jsonData is List
                ? jsonData[0]
                : jsonData);
      }
      return Future.error("Server Error");
    }
  }

  Future<dynamic> uploadPickedMediaForPostBody(
      {required String mediaFile}) async {
    final url =
        "${AppConfig.baseUrl}/api/v1/social/posts/blog-post-inline-media-file/";
    final headers = await getAuthHeaders();

    // debugPrint('MEDIA FILE ::: $mediaFile');

    final request = http.MultipartRequest("POST", Uri.parse(url));

    final http.MultipartFile mediaMultipartFile =
        await http.MultipartFile.fromPath("media", mediaFile);

    request.files.add(mediaMultipartFile);

    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller video, This video is too large.");
    }
    final responseBody = await response.stream.bytesToString();
    final responseBodyDecoded = jsonDecode(responseBody);

    // debugPrint('MEDIA RESPONSE ::: $responseBody');

    // debugPrint(
    //     "URL $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

    if (response.statusCode == 201 || response.statusCode == 200) {
      // debugPrint('MEDIA RESPONSE SUCCESS ::: $responseBody');
      return responseBodyDecoded;
    } else {
      return Future.error(
          "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- $responseBody");
    }
  }

  Future<bool> createOrUpdateBlogPost({
    String? blogId,
    File? blogVideo,
    List<String>? tags,
    required String title,
    bool isPublic = false,
    String? publishedDate,
    File? blogImage,
    bool isPublished = false,
    bool enableLikes = false,
    required bool isUpdating,
    List<String>? inLineMediaIds,
    required String blogPostBody,
    bool enableCommenting = false,
    required String authorUserName,
    String? channelUsername,
  }) async {
    var urlToPostBlog = "${AppConfig.baseUrl}/api/v1/social/posts/";
    if (channelUsername!.isNotEmpty) {
      urlToPostBlog =
          "${AppConfig.baseUrl}/api/v1/social/posts/channel/$channelUsername/";
    }

    var urlToUpdateBlog = "${AppConfig.baseUrl}/api/v1/social/posts/$blogId/";
    if (channelUsername.isNotEmpty) {
      urlToUpdateBlog =
          "${AppConfig.baseUrl}/api/v1/social/posts/channel/$blogId/";
    }

    final String url = isUpdating ? urlToUpdateBlog : urlToPostBlog;
    final headers = await getAuthHeaders();

    // debugPrint('fola blog post::: $url');

    String? blogImagePath;
    String? blogVideoPath;
    http.MultipartFile imageMultipartFile;
    http.MultipartFile videoMultipartFile;
    final request =
        http.MultipartRequest(isUpdating ? "PATCH" : "POST", Uri.parse(url));

    if (blogImage != null && blogImage.path.isNotEmpty) {
      blogImagePath = blogImage.path;
      imageMultipartFile =
          await http.MultipartFile.fromPath("image", blogImagePath);

      request.files.add(imageMultipartFile);
    }

    if (blogVideo != null && blogVideo.path.isNotEmpty) {
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
    request.fields["media"] = jsonEncode(inLineMediaIds);
    request.fields['enable_like'] = jsonEncode(enableLikes);
    request.fields['is_published'] = jsonEncode(isPublished);
    request.fields['enable_commenting'] = jsonEncode(enableCommenting);

    headers.forEach((k, v) => request.headers[k] = v);

    final response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller video, This video is too large.");
    }
    final responseBody = await response.stream.bytesToString();
    // debugPrint(
    //     "URL FOR POSTING BLOG $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      return Future.error(
          "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- $responseBody");
    }
  }

  Future<bool> deleteBlog({required String blogId}) async {
    final url = "${AppConfig.baseUrl}/api/v1/social/posts/$blogId/";
    final Map<String, String> headers = await getAuthHeaders();
    final response = await httpDelete(url, headers: headers);

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      // debugPrint(
      //     "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return true;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<UserPost> likeUserPost(UserPost post) async {
    final url = "${AppConfig.baseUrl}/api/v1/social/posts/like/${post.id}/";
    final Map<String, String> headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);

    // debugPrint(
    //     "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    //
    // debugPrint('LIKE URL :: $url');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final UserPost userPost = UserPost.fromJson(jsonDecode(response.body));

      return userPost;
    } else {
      if (response.statusCode != 500) {
        final jsonData = jsonDecode(response.body);
        // debugPrint(
        //     "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
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
    final url = "${AppConfig.baseUrl}/api/v1/social/posts/dislike/${post.id}/";
    final Map<String, String> headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);

    // debugPrint(
    //     "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final UserPost userPost = UserPost.fromJson(jsonDecode(response.body));

      return userPost;
    } else {
      if (response.statusCode != 500) {
        final jsonData = jsonDecode(response.body);
        // debugPrint(
        //     "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
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
