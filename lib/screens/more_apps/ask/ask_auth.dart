import 'dart:convert';

import 'package:Slydo/services/auth.dart';
import 'package:flutter/cupertino.dart';

import '../../../data/environment.dart';
import '../../../utils/util.dart';
import 'models/ask_categories_model.dart';

class AskAuth extends AuthService {

  AskCategories createAskCategories(Map<String, dynamic> item) {
    AskCategories categories = AskCategories();
    categories.id = item['id'];
    categories.name = item['name'];

    return categories;
  }

  // Get all ASK Categories
  Future<Map<String, dynamic>?> getAllCategories(String? next, String previous, {String? userName, bool otherDeals = false}) async {
    debugPrint("CALLING ALL CATEGORIES");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (otherDeals == true) {
        url = AppConfig.baseUrl + "/api/v1/social/ask/list-categories/";
      } else {
        url =
            AppConfig.baseUrl + "/api/v1/social/ask/list-categories/";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      List<AskCategories> askCategories = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        AskCategories categories = createAskCategories(item);
        askCategories.add(categories);
      }

      Map<String, dynamic> result = {
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
}