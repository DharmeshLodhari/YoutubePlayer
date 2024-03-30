import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/models/delivery_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

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
          "${AppConfig.baseUrl}/api/v1/shipping/journeys/active-jobs/?user_current_location=6.6616402,3.6470794";
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('ALL Job URL ---> $url');

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
  Future<DeliveryModel?> fetchJob(String? journeyId) async {
    try {
      String url =
          "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId/?user_current_location=6.6616402,3.6470794";

      debugPrint('Fetch Job URL ---> $url');

      var headers = await getAuthHeaders();
      var response = await httpGet(url, headers: headers);
      debugPrint('Fetch Job URL BODY ---> ${response.body}');

      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return DeliveryModel.fromJson(jsonData);
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
  Future<bool> acceptOffer(String? journeyId) async {
    if (journeyId == null) {
      return false;
    }
    String url = AppConfig.baseUrl +
        "/api/v1/shipping/journeys/$journeyId/accept-offer/";
    var headers = await getAuthHeaders();

    try {
      var response = await httpPatch(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey("error")) {
          showToast(message: jsonResponse['error']);
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // Reject Offer
  Future<bool> rejectOffer(String? journeyId) async {
    if (journeyId == null) {
      return false;
    }
    String url = AppConfig.baseUrl +
        "/api/v1/shipping/journeys/$journeyId/reject-offer/";
    var headers = await getAuthHeaders();

    try {
      var response = await httpPatch(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey("error")) {
          showToast(message: jsonResponse['error']);
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // Start Journey
  Future<bool> startJourney(String? journeyId) async {
    if (journeyId == null) {
      return false;
    }
    String url = AppConfig.baseUrl +
        "/api/v1/shipping/journeys/$journeyId/start-journey/";
    var headers = await getAuthHeaders();

    try {
      var response = await httpPatch(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey("error")) {
          showToast(message: jsonResponse['error']);
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // End Journey
  Future<bool> endJourney(String? journeyId) async {
    if (journeyId == null) {
      return false;
    }
    String url =
        AppConfig.baseUrl + "/api/v1/shipping/journeys/$journeyId/end-journey/";
    var headers = await getAuthHeaders();

    try {
      var response = await httpPatch(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey("error")) {
          showToast(message: jsonResponse['error']);
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // Cancel Journey
  Future<bool> cancelJourney(String? journeyId, String userChecked) async {
    if (journeyId == null) {
      return false;
    }
    String url = AppConfig.baseUrl +
        "/api/v1/shipping/journeys/$journeyId/cancel-offer/";
    var headers = await getAuthHeaders();

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("PATCH", Uri.parse(url));

    request.fields["cancellation_reason"] = userChecked;

    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();

    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 400) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        if (jsonResponse.containsKey("error")) {
          showToast(message: jsonResponse['error']);
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  //Update Current Location
  Future<bool> updateCurrentLocation(String? journeyId, LatLng currentP) async {
    if (journeyId == null) {
      return false;
    }
    String url = AppConfig.baseUrl +
        "/api/v1/shipping/journeys/$journeyId/update-current-location/";
    var headers = await getAuthHeaders();

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("PATCH", Uri.parse(url));
    debugPrint("Location : ${currentP.longitude},${currentP.latitude}");
    request.fields["location"] = "${currentP.longitude},${currentP.latitude}";

    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();

    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 400) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        if (jsonResponse.containsKey("error")) {
          showToast(message: jsonResponse['error']);
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  //Update Journey Route
  Future<bool> updateJourneyRoute(String? journeyId, String userChecked) async {
    if (journeyId == null) {
      return false;
    }
    String url = AppConfig.baseUrl +
        "/api/v1/shipping/journeys/$journeyId/update-journey-route/";
    var headers = await getAuthHeaders();

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("PATCH", Uri.parse(url));

    request.fields["route"] = userChecked;

    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();

    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 400) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        if (jsonResponse.containsKey("error")) {
          showToast(message: jsonResponse['error']);
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // Send Delivery Evidence
  Future<bool> sendDeliveryEvidence(
      String? journeyId, argument, BuildContext context) async {
    if (journeyId == null) {
      return false;
    }
    String url = AppConfig.baseUrl +
        "/api/v1/shipping/journeys/$journeyId/send-delivery-evidence/";
    var headers = await getAuthHeaders();

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("PATCH", Uri.parse(url));

    http.MultipartFile? filePath =
        await http.MultipartFile.fromPath("delivery_evidence", argument);

    //add multipart to request
    request.files.add(filePath);

    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller image, This image is too large.");
    }

    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 400) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        if (jsonResponse.containsKey("error")) {
          showToast(message: jsonResponse['error']);
          return false;
        }
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  //Share Rider Experience
  Future<bool> shareExperience(String? journeyId, {Map? data}) async {
    String url =
        "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId/send-journey-experience/";
    var _data = jsonEncode(data);
    debugPrint('Order details ::: $_data');

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers, body: _data);

    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 400) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey("error")) {
        showToast(message: jsonResponse['error']);
        return false;
      }
    }
    return false;
  }

  // Fetch a rider location
  Future<Map<String, dynamic>?> fetchRiderLocation(String? journeyId) async {
    try {
      String url =
          "${AppConfig.baseUrl}/api/v1/shipping/journeys/$journeyId?location_only=true";

      debugPrint('Fetch rider location URL ---> $url');

      var headers = await getAuthHeaders();
      var response = await httpGet(url, headers: headers);
      debugPrint('Fetch rider location URL BODY ---> ${response.body}');

      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
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
}
