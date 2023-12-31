import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';

class RiderDeliveryAuthService extends AuthService {
  //get rider job list
  Future<Map<String, dynamic>?> getJobListing(
      String? next, String? previous) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/shipping/journeys/active-jobs/?user_current_location=7.471104,9.060352";
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('My Job URL ---> $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      List<DeliveryModel> askCategories = [];
      var jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        DeliveryModel categories = DeliveryModel.fromJson(item);
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

  // Fetch a job
  Future<DeliveryModel?> fetchJob(String? jobId) async {
    try {
      var url = "${AppConfig.baseUrl}/api/v1/shipping/journeys/$jobId/";

      debugPrint('Fetch Job URL ---> $url');

      var headers = await getAuthHeaders();
      var response = await httpGet(url, headers: headers);
      debugPrint('Fetch Job URL BODY ---> ${response.body}');

      print(response.statusCode);
      if (response.statusCode == 200) {
        return DeliveryModel.fromJson(json.decode(response.body));
      } else {
        showToast(message: response.body.toString());
        throw response.body;
      }
    } on Exception catch (e) {
      showToast(message: e.toString());
      print(e);
    } catch (err) {
      showToast(message: err.toString());
      print(err);
    }
    return null;
  }

  // Accept Offer
  Future<bool> acceptOffer(String? jobId) async {
    var url =
        AppConfig.baseUrl + "/api/v1/shipping/journeys/$jobId/accept-offer/";
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers);
    print('Accept jobber...${response.body} and ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // Reject Offer
  Future<bool> rejectOffer(String? jobId) async {
    var url =
        AppConfig.baseUrl + "/api/v1/shipping/journeys/$jobId/reject-offer/";
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers);
    print('Reject jobber...${response.body} and ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // Start Journey
  Future<bool> startJourney(String? jobId) async {
    var url =
        AppConfig.baseUrl + "/api/v1/shipping/journeys/$jobId/start-offer/";
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers);
    print('Start jobber...${response.body} and ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // End Journey
  Future<bool> endJourney(String? jobId) async {
    var url = AppConfig.baseUrl + "/api/v1/shipping/journeys/$jobId/end-offer/";
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers);
    print('End jobber...${response.body} and ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // Cancel Journey
  Future<bool> cancelJourney(String? jobId) async {
    var url =
        AppConfig.baseUrl + "/api/v1/shipping/journeys/$jobId/cancel-offer/";
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers);
    print('Cancel jobber...${response.body} and ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }
}
