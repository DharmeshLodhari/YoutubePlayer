import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/user_profile/screens/subscriptions/subscription_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';

class SubscriptionsAuth extends AuthService {
  Future<List<SubscriptionsModel>> getSubscriptionList(
      {required String accountType}) async {
    final String url = "${AppConfig.baseUrl}/api/v1/user/profile-pricing/";

    final headers = getNonAuthHeader();
    final response =
        await httpGet(url, headers: headers as Map<String, dynamic>?);
    debugPrint('GET SUBSCRIPTION LIST');
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List results = jsonDecode(response.body)['results'];
      final List<SubscriptionsModel> subscriptionModelList =
          results.map((json) => SubscriptionsModel.fromJson(json)).toList();

      return subscriptionModelList
          .where((element) => element.accountType == accountType)
          .toList();
    } else {
      return Future.error(response.body);
    }
  }

  Future<bool> verifyBusinessName({required String businessName}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/verify-business-name/?business_name=${Uri.encodeComponent(businessName)}";

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (jsonDecode(response.body)['available'] == true) {
        return true;
      } else {
        return false;
      }
    } else {
      return Future.error(response.body);
    }
  }

  Future upgradeUserAccount(
      {required int subscriptionsId,
      required String accountType,
      required String businessName}) async {
    bool? userAccountUpgraded;
    final String url = "${AppConfig.baseUrl}/api/v1/user/upgrade-user-account/";

    final headers = await getAuthHeaders();
    debugPrint(accountType);
    debugPrint(businessName);
    final data = {
      'id': subscriptionsId,
      "account_type": accountType,
      "business_name": businessName,
    };
    final response =
        await httpPost(url, headers: headers, body: jsonEncode(data));
    debugPrint('USER ACCOUNT UPGRADED');
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 201 && response.statusCode == 201) {
      return true;
    } else {
      return Future.error('Error : ${response.body}');
    }
  }
}
