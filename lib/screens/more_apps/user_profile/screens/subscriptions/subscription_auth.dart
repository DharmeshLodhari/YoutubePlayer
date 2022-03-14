import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/user_post/models/user_post.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/subscriptions/subscription_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SubscriptionsAuth extends AuthService {
  Future<List<SubscriptionsModel>> getSubscriptionList(
      {required String accountType}) async {
    String url = AppConfig.baseUrl + "/api/v1/user/profile-pricing/";

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    print('GET SUBSCRIPTION LIST');
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200) {
      List results = jsonDecode(response.body)['results'];
      List<SubscriptionsModel> subscriptionModelList =
          results.map((json) => SubscriptionsModel.fromJson(json)).toList();

      return subscriptionModelList
          .where((element) => element.accountType == accountType)
          .toList();
    } else {
      return Future.error('${response.body}');
    }
  }

  Future upgradeUserAccount(
      {required int subscriptionsId,
      required String accountType,
      required String businessName}) async {
    bool? userAccountUpgraded;
    String url = AppConfig.baseUrl + "/api/v1/user/upgrade-user-account/";

    var headers = await getAuthHeaders();
    print(accountType);
    print(businessName);
    var data = {
      'id': subscriptionsId,
      "account_type": accountType,
      "business_name": businessName,
    };
    var response =
        await httpPost(url, headers: headers, body: jsonEncode(data));
    print('USER ACCOUNT UPGRADED');
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 201 && response.statusCode == 201) {
      return true;
    } else {
      return Future.error('Error : ${response.body}');
    }
  }
}
