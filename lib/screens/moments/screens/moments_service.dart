import 'dart:convert';

import 'package:Slydo/screens/moments/models/create_moment_model.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/foundation.dart';
import "package:http/http.dart" as http;
import 'package:http/http.dart';

import '../../../data/environment.dart';
import '../../../utils/util.dart';
import '../../more_apps/yarn/models/Topics/CommentDetails.dart';
import '../models/comment_model.dart';

class MomentsService extends AuthService {
  Future getExploreMoments(String? next, String? previous,
      {num? page_size}) async {
    String url = "";
    if (next == null) {
      return null;
    }

    if (next == "") {
      url = '${AppConfig.baseUrl}/api/v1/social/moments/explore/';
    } else {
      url = getSecureUrl(url: next);
    }

    if (page_size != null) {
      if (url.contains("page_size")) {
        url = url;
      } else if (url.contains("?")) {
        url = "$url&page_size=$page_size";
      } else {
        url = "$url?page_size=$page_size";
      }
    }
    final headers = await getAuthHeaders();

    final Response response = await httpGet(url, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);

      final List<ExploreMomentsModel> momentsList = [];
      final List jsonResult = jsonData['results'];

      for (var json in jsonResult) {
        momentsList.add(ExploreMomentsModel.fromJson(json));
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": momentsList,
      };

      return result;
    } else {
      return Future.error('Something went wrong');
    }
  }

  Future getContactMoments({String? next, String? previous}) async {
    String url = "";
    if (next == null) {
      return null;
    }

    if (next == "") {
      url = '${AppConfig.baseUrl}/api/v1/social/moments/';
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('URL MOMENTS getContactMoments:: $url');
    final headers = await getAuthHeaders();

    final Response response = await httpGet(url, headers: headers);

    debugPrint('CONTACT MOMENT ::: ${response.body}');
    debugPrint('CONTACT MOMENT ::: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      debugPrint('GET CONTACT LIST :::: $jsonData');

      final List<MomentsModel> momentsList = [];
      final List jsonResult = jsonData['results'];

      for (var json in jsonResult) {
        momentsList.add(MomentsModel.fromJson(json));
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": momentsList
      };

      return result;
    } else {
      return Future.error('Something went wrong');
    }
  }

  Future<List<MomentsModel>> getMomentsWithOwnerName({
    required String ownerName,
    bool fromUserProfile =
        false, // This is true when we click on the moment's button from a user's profile.
    required String? channelUsername,
    // bool isChannel = false,
  }) async {
    late String url;

    if (fromUserProfile == true) {
      url = "${AppConfig.baseUrl}/api/v1/social/moments/public/$ownerName/";
    } else if (channelUsername != '') {
      url =
          "${AppConfig.baseUrl}/api/v1/social/moments/channel/$channelUsername/";
    } else if (channelUsername == '') {
      url = "${AppConfig.baseUrl}/api/v1/social/moments/user/$ownerName/";
    }

    final headers = await getAuthHeaders();

    final Response response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      List jsonData = [];

      if (channelUsername != '') {
        jsonData = jsonDecode(response.body)['results'][0]['moments'];
      } else if (channelUsername == '') {
        jsonData = jsonDecode(response.body)['moments'];
      }

      return jsonData.map((e) => MomentsModel.fromJson(e)).toList();
    } else {
      return Future.error(jsonDecode(response.body)['error']);
    }
  }

  Future<List<MomentsModel>> getSingleMoment({required String momentId}) async {
    final String url = "${AppConfig.baseUrl}/api/v1/social/moments/$momentId/";

    final headers = await getAuthHeaders();

    final Response response = await httpGet(url, headers: headers);

    debugPrint('SINGLE MOMENT ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);

      return [MomentsModel.fromJson(jsonData)];
    } else {
      return Future.error('Something went wrong');
    }
  }

  Future<Map<String, dynamic>?> getMomentComments(
      String? nextUrl, String momentID) async {
    String? url =
        "${AppConfig.baseUrl}/api/v1/social/moments/comments/$momentID/?page_size=8";
    if (nextUrl != null) {
      url = getSecureUrl(url: nextUrl);
    }

    final headers = await getAuthHeaders();

    final Response response = await httpGet(url, headers: headers);

    final Map<String, dynamic>? pinnedYarn = await getPinnedComment(momentID);

    debugPrint('COMMENTS MOMENTS ::: ${response.statusCode}');
    debugPrint('COMMENTS MOMENTS ::: ${response.body}');
    debugPrint('COMMENTS MOMENTS PINNED ::: $pinnedYarn');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      List results = jsonData['results'];

      if (pinnedYarn == null) {
      } else {
        if (pinnedYarn.isNotEmpty) {
          pinnedYarn['pinned'] = true;

          final List<dynamic> pinnedYarnList = [pinnedYarn];
          // debugPrint('COMMENTS MOMENTS PINNED ::: ${pinnedYarnList}');

          results = pinnedYarnList + results;
        }
      }

      final List<YarnComment> commentDetails = [];
      for (var item in results) {
        final YarnComment replyCommentDetail = YarnComment.fromJson(item);
        commentDetails.add(replyCommentDetail);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "results": commentDetails
      };

      return result;
    } else {
      return Future.error('Something went wrong');
    }
  }

  // ADD COMMENT TO Moment
  Future<YarnComment?> addCommentToMoment(
      String commentId, Map<String, dynamic> body) async {
    String url = "";
    url = "${AppConfig.baseUrl}/api/v1/social/moments/add-comments/$commentId/";
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
        } else if (body['media_count'][i].mediaType == 'gif') {
          // Add fields
          request.fields["mediafile_$i"] = body['media_count'][i].mediaFile;
          // Create multipart using filepath, string or bytes
          multipartFile = await http.MultipartFile.fromPath(
              "mediafile_$i", body['media_count'][i].mediaFile);
        }

        // Add multipart to newList
        newList.add(multipartFile);
      }
      // Add multipart to request
      request.files.addAll(newList);
      request.files.addAll(thumbnailList);
    }

    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final YarnComment yarnComment =
          YarnComment.fromJson(json.decode(responseBody));

      return yarnComment;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // ADD REPLY COMMENT TO Moment
  Future<YarnComment?> addReplyToComment(
      String commentId, Map<String, dynamic> body) async {
    String url = "";
    url =
        "${AppConfig.baseUrl}/api/v1/social/moments/reply-comments/$commentId/";
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

    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final YarnComment yarnComment =
          YarnComment.fromJson(json.decode(responseBody));

      return yarnComment;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAllComments(String commentId) async {
    debugPrint("CALLING ALL COMMENTS");
    String url = "";
    url =
        "${AppConfig.baseUrl}/api/v1/social/moments/reply-comments/$commentId/";

    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    final Map<String, dynamic>? pinnedYarn = await getPinnedComment(commentId);

    debugPrint(
        "COMMENTS RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body.toString()}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<YarnComment> commentsDetails = [];
      final jsonData = json.decode(response.body);

      debugPrint('COMMENTS RESPONSE CODE::: $jsonData');

      List<dynamic> results = jsonData['results'];
      debugPrint('COMMENTS RESPONSE agian CODE::: $results');

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
        debugPrint('Fola test getAllComments::: $item');

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

  // get pinned comment
  Future<Map<String, dynamic>?> getPinnedComment(String yarnId) async {
    debugPrint("CALLING PINNED COMMENT");
    String url = "";
    url = "${AppConfig.baseUrl}/api/v1/social/moments/pinned-comment/$yarnId/";
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

  Future<bool> createMoment(
      {required CreateMomentModel createMomentModel,
      String? channelUsername}) async {
    String url = "${AppConfig.baseUrl}/api/v1/social/moments/";

    debugPrint("URL FOR CREATE MOMENT test $channelUsername");

    if (channelUsername!.isNotEmpty) {
      url =
          "${AppConfig.baseUrl}/api/v1/social/moments/channel/$channelUsername/";
    }

    final headers = await getAuthHeaders();

    final request = MultipartRequest("POST", Uri.parse(url));

    final MultipartFile mediaMultipartFile =
        await MultipartFile.fromPath("media", createMomentModel.filePath);

    request.files.add(mediaMultipartFile);

    request.fields["text"] = createMomentModel.text!;

    if (createMomentModel.attachmentMap != null) {
      request.fields["attachment"] =
          jsonEncode(createMomentModel.attachmentMap!);
    }
    request.fields["is_public"] = jsonEncode(createMomentModel.isPublic);

    request.fields["tags"] = jsonEncode(createMomentModel.userTags);
    if (createMomentModel.payMeLabel != null) {
      request.fields["pay_me_label"] = createMomentModel.payMeLabel!;
    }
    if (createMomentModel.payMeButtonColor != null) {
      request.fields["payme_button_color"] =
          createMomentModel.payMeButtonColor!;
    }
    if (createMomentModel.filePath.contains('.mp4')) {
      request.fields["duration"] = createMomentModel.duration!;
    }

    request.fields["enable_payme"] = jsonEncode(createMomentModel.enablePayMe);
    request.fields["enable_like"] = jsonEncode(createMomentModel.enableLike);
    request.fields["enable_commenting"] =
        jsonEncode(createMomentModel.enableCommenting);
    request.fields["is_permanent"] = jsonEncode(createMomentModel.isPermanent);

    debugPrint('REQUEST FIELDS :: ${request.fields}');
    if (createMomentModel.mediaPoster != null) {
      final MultipartFile thumbnailMultipartFile = await MultipartFile.fromPath(
          "media_poster", createMomentModel.mediaPoster!);
      request.files.add(thumbnailMultipartFile);
    }

    debugPrint('FIELDS ::: ${request.fields}');
    headers.forEach((k, v) => request.headers[k] = v);

    final response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller video, This video is too large.");
    }

    final responseBody = await response.stream.bytesToString();
    debugPrint(
        "URL FOR CREATE MOMENT $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      return Future.error(
          "ERROR while calling moment $url StatusCode:- ${response.statusCode} Body:- $responseBody");
    }
  }

  Future<MomentsModel> updateMoment(
      {required String momentId,
      required Map<String, dynamic> data,
      String? channelUsername}) async {
    String url = "${AppConfig.baseUrl}/api/v1/social/moments/$momentId/";

    if (channelUsername != null) {
      url =
          "${AppConfig.baseUrl}/api/v1/social/moments/channel/$channelUsername/$momentId/";
    }

    final Map<String, String> headers = await getAuthHeaders();
    final response = await httpPatch(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    debugPrint(
        "URL $url REQUEST FIELD: $data STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final MomentsModel momentsModel =
          MomentsModel.fromJson(jsonDecode(response.body));

      return momentsModel;
    } else {
      if (response.statusCode != 500) {
        final jsonData = jsonDecode(response.body);
        debugPrint(
            "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
        return Future.error(jsonData is Map
            ? jsonData["error"]
            : jsonData is List
                ? jsonData[0]
                : 'Something went wrong');
      }
      return Future.error("Server Error");
    }
  }

  Future<MomentsModel> likeMoment(String momentId) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/social/moments/like/$momentId/";
    final Map<String, String> headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);

    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    debugPrint('LIKE URL :: $url');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final MomentsModel momentsModel =
          MomentsModel.fromJson(jsonDecode(response.body));

      return momentsModel;
    } else {
      if (response.statusCode != 500) {
        final jsonData = jsonDecode(response.body);
        debugPrint(
            "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
        return Future.error(jsonData is Map
            ? jsonData["error"]
            : jsonData is List
                ? jsonData[0]
                : 'Something went wrong');
      }
      return Future.error("Server Error");
    }
  }

  Future<bool> updateMomentView(String momentId) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/social/moments/update-moment-view/$momentId/";
    final Map<String, String> headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint(
        "UPDATE MOMENT VIEW URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      if (response.statusCode != 500) {
        final jsonData = jsonDecode(response.body);
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

  Future<MomentsModel> dislikeMoment(String momentId) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/social/moments/dislike/$momentId/";
    final Map<String, String> headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);

    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    debugPrint('LIKE URL :: $url');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final MomentsModel momentsModel =
          MomentsModel.fromJson(jsonDecode(response.body));

      return momentsModel;
    } else {
      if (response.statusCode != 500) {
        final jsonData = jsonDecode(response.body);
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

  Future<bool> deleteMoment(String momentId, String? channelUsername) async {
    String url = "${AppConfig.baseUrl}/api/v1/social/moments/$momentId/";

    if (channelUsername!.isNotEmpty) {
      url =
          "${AppConfig.baseUrl}/api/v1/social/moments/channel/$channelUsername/$momentId/";
    }

    final Map<String, String> headers = await getAuthHeaders();
    final response = await httpDelete(url, headers: headers);

    debugPrint(
        "URL TO DELETE $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      return Future.error(response.body);
    }
  }

  Future<BasePaginationModel<List<SearchMomentModel>>> searchMoment(
      {required String? nextPage, required String? searchText}) async {
    debugPrint('SEARCHED TEXT ---> $searchText');
    String url;

    if (nextPage != null) {
      url = getSecureUrl(url: nextPage);
    } else {
      url =
          "${AppConfig.baseUrl}/api/v1/social/moments/search/?q=$searchText&page_size=10";
    }
    final Map<String, String> headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint(
        "SEARCH MOMENT $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      final List results = jsonData['results'];

      debugPrint('RESULT LENGTH -> ${results.length}');

      for (var item in results) {
        debugPrint('RESULT searched item moment:::: $item');
      }

      return BasePaginationModel<List<SearchMomentModel>>.fromJson(
        jsonData,
        results.map((e) => SearchMomentModel.fromJson(e)).toList(),
      );
    } else {
      return Future.error('Something went wrong');
    }
  }
}
