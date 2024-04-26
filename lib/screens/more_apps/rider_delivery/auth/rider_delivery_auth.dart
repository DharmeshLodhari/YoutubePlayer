import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class RiderDeliveryAuthService extends AuthService {
  //get all dispatch job list
  Future<Map<String, dynamic>?> getJobListing(
      String? next, String? previous) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/shipping/journeys/active-jobs/?user_current_location=3.6470794,6.6616402";
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('ALL Job URL ---> $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      final List<DeliveryModel> askCategories = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final DeliveryModel categories = DeliveryModel.fromJson(item);
        askCategories.add(categories);
      }

      final Map<String, dynamic> result = {
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

  //get job history
  Future<Map<String, dynamic>?> getRiderHistory(
      String? next, String? previous) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/shipping/journeys/";
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('My Job URL ---> $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      final List<DeliveryModel> askCategories = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final DeliveryModel categories = DeliveryModel.fromJson(item);
        askCategories.add(categories);
      }

      final Map<String, dynamic> result = {
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
  Future<DeliveryModel?> fetchJob(String? journeyId) async {
    try {
      final String url =
          "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId/?user_current_location=3.6470794,6.6616402";

      debugPrint('Fetch Job URL ---> $url');

      final headers = await getAuthHeaders();
      final response = await httpGet(url, headers: headers);
      debugPrint('Fetch Job URL BODY ---> ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return DeliveryModel.fromJson(jsonData);
      } else {
        showToast(message: response.body.toString());
        throw response.body;
      }
    } on Exception catch (e) {
      showToast(message: e.toString());
      debugPrint("Error: $e");
    } catch (err) {
      showToast(message: err.toString());
      debugPrint("Error: $err");
    }
    return null;
  }

  // Accept Offer
  Future<bool> acceptOffer(String? journeyId) async {
    if (journeyId == null) {
      return false;
    }
    final String url =
        "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId/accept-offer/";
    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers);

    try {
      handleServerErrors(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  // Reject Offer
  Future<bool> rejectOffer(String? journeyId) async {
    if (journeyId == null) {
      return false;
    }
    final String url =
        "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId/reject-offer/";
    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers);

    try {
      handleServerErrors(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  // Start Journey
  Future<bool> startJourney(String? journeyId) async {
    if (journeyId == null) {
      return false;
    }
    final String url =
        "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId/start-journey/";
    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers);

    try {
      handleServerErrors(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  // End Journey
  Future<bool> endJourney(String? journeyId) async {
    if (journeyId == null) {
      return false;
    }
    final String url =
        "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId/end-journey/";
    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers);

    try {
      handleServerErrors(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  // Cancel Journey
  Future<bool> cancelJourney(String? journeyId, String userChecked) async {
    if (journeyId == null) {
      return false;
    }
    final String url =
        "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId/cancel-offer/";
    final headers = await getAuthHeaders();

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("PATCH", Uri.parse(url));

    request.fields["cancellation_reason"] = userChecked;

    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();

    try {
      handleServerErrors(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  //Update Current Location
  Future<bool> updateCurrentLocation(
      String? journeyId, LocationData currentP) async {
    if (journeyId == null) {
      return false;
    }
    final String url =
        "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId/update-current-location/";
    final headers = await getAuthHeaders();

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("PATCH", Uri.parse(url));
    debugPrint(
        "Location : ${currentP.longitude},${currentP.latitude},${currentP.heading}");
    request.fields["location"] = "${currentP.longitude},${currentP.latitude}";
    request.fields["dispatcher_heading"] = "${currentP.heading}";

    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();

    try {
      handleServerErrors(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  //Update Journey Route
  Future<bool> updateJourneyRoute(String? journeyId, String userChecked) async {
    if (journeyId == null) {
      return false;
    }
    final String url =
        "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId/update-journey-route/";
    final headers = await getAuthHeaders();

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("PATCH", Uri.parse(url));

    request.fields["route"] = userChecked;

    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();

    try {
      handleServerErrors(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  // Send Delivery Evidence
  Future<bool> sendDeliveryEvidence(
      String? journeyId, String argument, BuildContext context) async {
    if (journeyId == null) {
      return false;
    }
    final String url =
        "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId/send-delivery-evidence/";
    final headers = await getAuthHeaders();

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("PATCH", Uri.parse(url));

    final http.MultipartFile? filePath =
        await http.MultipartFile.fromPath("delivery_evidence", argument);

    //add multipart to request
    request.files.add(filePath!);

    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller image, This image is too large.");
    }

    try {
      handleServerErrors(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  //Share Rider Experience
  Future<bool> shareExperience(String? journeyId, {Map? data}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId/send-journey-experience/";
    final _data = jsonEncode(data);
    debugPrint('Order details ::: $_data');

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: _data);

    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    try {
      handleServerErrors(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error : $e");
      return false;
    }
  }

  // Fetch a rider location
  Future<Map<String, dynamic>?> fetchRiderLocation(String? journeyId) async {
    try {
      final String url =
          "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId?location_only=true";

      debugPrint('Fetch rider location URL ---> $url');

      final headers = await getAuthHeaders();
      final response = await httpGet(url, headers: headers);
      debugPrint('Fetch rider location URL BODY ---> ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        showToast(message: response.body.toString());
        throw response.body;
      }
    } on Exception catch (e) {
      showToast(message: e.toString());
      debugPrint("Error: $e");
    } catch (err) {
      showToast(message: err.toString());
      debugPrint("Error: $err");
    }
    return null;
  }

  // Rider at pickup location
  Future<bool> atPickupLocation(int? orderId) async {
    if (orderId == null) {
      return false;
    }
    final String url =
        "${AppConfig.baseUrl}/api/v1/order/$orderId/set-rider-in-pickup-location/";
    final headers = await getAuthHeaders();

    try {
      final response = await httpPatch(url, headers: headers);

      handleServerErrors(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

// Rider at Delivery location
  Future<bool> atDeliveryLocation(int? orderId) async {
    if (orderId == null) {
      return false;
    }
    final String url =
        "${AppConfig.baseUrl}/api/v1/order/$orderId/set-rider-in-delivery-location/";
    final headers = await getAuthHeaders();

    try {
      final response = await httpPatch(url, headers: headers);

      handleServerErrors(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

// Rider pickup order
  Future<bool> riderPickupOrder(int? orderId) async {
    if (orderId == null) {
      return false;
    }
    final String url =
        "${AppConfig.baseUrl}/api/v1/order/$orderId/set-rider-picked-up-order/";
    final headers = await getAuthHeaders();

    try {
      final response = await httpPatch(url, headers: headers);

      handleServerErrors(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }
}
