import 'dart:convert';

import 'package:Slydo/screens/moments/models/create_moment_model.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import '../../data/environment.dart';
import '../../utils/util.dart';
import 'models/comment_model.dart';

class MomentsService extends AuthService {
  Future getExploreMoments(String? next, String? previous) async {
    var url = "";
    if (next == null) {
      return null;
    }

    if (next == "") {
      url = AppConfig.baseUrl + '/api/v1/social/moments/explore/';
    } else {
      url = getSecureUrl(url: next);
    }

    final headers = await getAuthHeaders();

    Response response = await httpGet(url, headers: headers);
    debugPrint('EXPLORE MOMENTS ::: ${response.body}');
    debugPrint('EXPLORE MOMENTS ::: ${response.statusCode}');
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<ExploreMomentsModel> momentsList = [];
      List jsonResult = jsonData['results'];

      jsonResult.forEach((json) {
        momentsList.add(ExploreMomentsModel.fromJson(json));
      });

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": momentsList,
      };

      return result;
    } else {
      return Future.error(response.body);
    }
  }

  Future getContactMoments(String? next, String? previous) async {
    var url = "";
    if (next == null) {
      return null;
    }

    if (next == "") {
      url = AppConfig.baseUrl + '/api/v1/social/moments/';
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('URL MOMENTS:: $url');
    final headers = await getAuthHeaders();

    Response response = await httpGet(url, headers: headers);

    debugPrint('CONTACT MOMENT ::: ${response.body}');
    debugPrint('CONTACT MOMENT ::: ${response.statusCode}');

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      debugPrint('GET CONTACT LIST :::: $jsonData');

      List<MomentsModel> momentsList = [];
      List jsonResult = jsonData['results'];

      debugPrint('MOMENT LIS -> $jsonResult');

      jsonResult.forEach((json) {
        momentsList.add(MomentsModel.fromJson(json));
      });

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": momentsList
      };

      momentsList.forEach((element) {
        debugPrint('M MEDIA POSTER -> ${element.mediaPoster}');
      });

      return result;
    } else {
      return Future.error(response.body);
    }
  }

  Future<List<MomentsModel>> getMomentsWithOwnerName(
      {required String owner}) async {
    String url = AppConfig.baseUrl + "/api/v1/social/moments/user/$owner/";

    final headers = await getAuthHeaders();

    Response response = await httpGet(url, headers: headers);

    debugPrint('MY MOMENTS ::: ${response.body}');
    if (response.statusCode == 200) {
      List jsonData = jsonDecode(response.body)['moments'];

      return jsonData.map((e) => MomentsModel.fromJson(e)).toList();
    } else {
      return Future.error(response.body);
    }
  }

  Future<List<MomentsModel>> getSingleMoment({required String momentId}) async {
    String url = AppConfig.baseUrl + "/api/v1/social/moments/$momentId/";

    final headers = await getAuthHeaders();

    Response response = await httpGet(url, headers: headers);

    debugPrint('SINGLE MOMENT ::: ${response.body}');
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      return [MomentsModel.fromJson(jsonData)];
    } else {
      return Future.error(response.body);
    }
  }

  Future<BasePaginationModel<List<CommentModel>>> getMomentComments(
      {required String? nextUrl, required String momentID}) async {
    String? url = AppConfig.baseUrl +
        "/api/v1/social/moments/comments/$momentID/?page_size=8";

    if (nextUrl != null) {
      url = getSecureUrl(url: nextUrl);
    }

    final headers = await getAuthHeaders();

    Response response = await httpGet(url, headers: headers);

    debugPrint('COMMENTS MOMENTS ::: ${response.statusCode}');
    debugPrint('COMMENTS MOMENTS ::: ${response.body}');
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List results = jsonData['results'];

      return BasePaginationModel<List<CommentModel>>.fromJson(
        jsonData,
        results.map((e) => CommentModel.fromJson(e)).toList(),
      );
    } else {
      return Future.error(response.body);
    }
  }

  Future<bool> addCommentToMoment(
      {required String momentID, required Map<String, String> data}) async {
    String url =
        AppConfig.baseUrl + "/api/v1/social/moments/add-comments/$momentID/";

    debugPrint('MOMENT ID -> $momentID');
    final headers = await getAuthHeaders();

    var _data = jsonEncode(data);

    Response response = await httpPost(url, headers: headers, body: _data);

    debugPrint('ADD COMMENTS MOMENTS ::: ${response.statusCode}');
    debugPrint('ADD COMMENTS MOMENTS ::: ${response.body}');
    if (response.statusCode == 200) {
      return true;
      // List jsonData = jsonDecode(response.body)['moments'];

      // return jsonData.map((e) => MomentsModel.fromJson(e)).toList();
    } else {
      return Future.error(response.body);
    }
  }

  Future<bool> createMoment(
      {required CreateMomentModel createMomentModel}) async {
    String url = AppConfig.baseUrl + "/api/v1/social/moments/";

    final headers = await getAuthHeaders();

    var request = MultipartRequest("POST", Uri.parse(url));

    MultipartFile mediaMultipartFile =
        await MultipartFile.fromPath("media", createMomentModel.filePath);

    request.files.add(mediaMultipartFile);

    if (createMomentModel.text != null) {
      request.fields["text"] = createMomentModel.text!;
    }
    if (createMomentModel.url != null && createMomentModel.url!.isNotEmpty) {
      request.fields["url"] = createMomentModel.url!;
    }
    request.fields["isPublic"] = jsonEncode(createMomentModel.isPublic);

    request.fields["tags"] = jsonEncode(createMomentModel.userTags);
    request.fields["enable_payme"] = jsonEncode(createMomentModel.enablePayMe);
    request.fields["enable_like"] = jsonEncode(createMomentModel.enableLike);
    request.fields["enable_commenting"] =
        jsonEncode(createMomentModel.enableCommenting);

    debugPrint('REQUEST FIELDS :: ${request.fields}');
    if (createMomentModel.mediaPoster != null) {
      MultipartFile thumbnailMultipartFile = await MultipartFile.fromPath(
          "media_poster", createMomentModel.mediaPoster!);
      request.files.add(thumbnailMultipartFile);
    }

    debugPrint('FIELDS ::: ${request.fields}');
    headers.forEach((k, v) => request.headers[k] = v);

    var response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller video, This video is too large.");
    }

    var responseBody = await response.stream.bytesToString();
    debugPrint(
        "URL FOR CREATE MOMENT $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      return Future.error(
          "ERROR while calling moment $url StatusCode:- ${response.statusCode} Body:- $responseBody");
    }
  }

  Future<MomentsModel> likeMoment(String momentId) async {
    var url = AppConfig.baseUrl + "/api/v1/social/moments/like/$momentId/";
    Map<String, String> headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers);

    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    debugPrint('LIKE URL :: $url');
    if (response.statusCode == 200 || response.statusCode == 201) {
      MomentsModel momentsModel =
          MomentsModel.fromJson(jsonDecode(response.body));

      return momentsModel;
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

  Future<MomentsModel> dislikeMoment(String momentId) async {
    var url = AppConfig.baseUrl + "/api/v1/social/moments/dislike/$momentId/";
    Map<String, String> headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers);

    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    debugPrint('LIKE URL :: $url');
    if (response.statusCode == 200 || response.statusCode == 201) {
      MomentsModel momentsModel =
          MomentsModel.fromJson(jsonDecode(response.body));

      return momentsModel;
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

  Future<bool> deleteMoment(String momentId) async {
    var url = AppConfig.baseUrl + "/api/v1/social/moments/$momentId/";
    Map<String, String> headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);

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
    var url;

    if (nextPage != null) {
      url = getSecureUrl(url: nextPage);
    } else {
      url = AppConfig.baseUrl +
          "/api/v1/social/moments/search/?q=$searchText&page_size=4";
    }
    Map<String, String> headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint(
        "SEARCH MOMENT $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      List results = jsonData['results'];

      debugPrint('RESULT LENGTH -> ${results.length}');
      return BasePaginationModel<List<SearchMomentModel>>.fromJson(
        jsonData,
        results.map((e) => SearchMomentModel.fromJson(e)).toList(),
      );
    } else {
      return Future.error(response.body);
    }
  }
}
