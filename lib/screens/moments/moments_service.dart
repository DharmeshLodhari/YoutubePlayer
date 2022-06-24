import 'dart:convert';

import 'package:Slydo/screens/moments/models/create_moment_model.dart';
import 'package:Slydo/screens/moments/models/moments_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

import '../../data/environment.dart';
import '../../utils/util.dart';

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

  Future<bool> createMoment(
      {required CreateMomentModel createMomentModel}) async {
    String url = AppConfig.baseUrl + "/api/v1/social/moments/";

    final headers = await getAuthHeaders();

    var request = MultipartRequest("POST", Uri.parse(url));

    MultipartFile mediaMultipartFile =
        await MultipartFile.fromPath("media", createMomentModel.filePath);

    request.files.add(mediaMultipartFile);

    request.fields["text"] = createMomentModel.text;
    request.fields["isPublic"] = jsonEncode(createMomentModel.isPublic);

    request.fields["tags"] = jsonEncode(createMomentModel.userTags);

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
}
