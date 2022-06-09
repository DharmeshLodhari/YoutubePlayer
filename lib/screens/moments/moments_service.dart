import 'dart:convert';

import 'package:Slydo/screens/moments/moments_model.dart';
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

      List<MomentsModel> momentsList = [];
      List jsonResult = jsonData['results'];

      jsonResult.forEach((json) {
        momentsList.add(MomentsModel.fromJson(json));
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
      debugPrint('GET CONTRACT LIST :::: $jsonData');

      List<UserMomentsModel> momentsList = [];
      List jsonResult = jsonData['results'];

      jsonResult.forEach((json) {
        momentsList.add(UserMomentsModel.fromJson(json));
      });

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": momentsList
      };

      return result;
    } else {
      return Future.error(response.body);
    }
  }

  Future<List<MomentsModel>> getMomentsWithUserName(
      {required String userName}) async {
    String url = AppConfig.baseUrl + "/api/v1/social/moments/user/$userName/";

    final headers = await getAuthHeaders();

    Response response = await httpGet(url, headers: headers);

    debugPrint('USER MOMENTS :: $url');
    debugPrint('USER MOMENTS :: ${response.body}');
    debugPrint('USER MOMENTS :: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      UserMomentsModel userMomentsModel = UserMomentsModel.fromJson(jsonData);
      return userMomentsModel.moments!;
    } else {
      return Future.error(response.body);
    }
  }
}
