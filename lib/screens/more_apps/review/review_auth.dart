import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/review/models/review.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';

class ReviewAuth extends AuthService {
  // Fetch User Review Details
  Future<Map<String, dynamic>> fetchUserReviews({String? userName}) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/social/review/users/$userName/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return jsonData;
    } else if (response.statusCode == 404) {
      return jsonDecode(response.body);
    }
    return Future.error("${response.body}");
  }

  // Write User Reviews
  Future<bool> addUserReview(String userName, Map<String, dynamic> data) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/social/review/users/$userName/";
    final Map<String, String> headers = await getAuthHeaders();
    final _data = jsonEncode(data);
    debugPrint("Data:- $_data");
    final response = await httpPost(url, body: _data, headers: headers);
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      if (response.statusCode != 500) {
        final jsonData = jsonDecode(response.body);
        debugPrint(
            "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
        return Future.error(jsonData is Map
            ? jsonData["error"] ?? jsonData["author_username"]
            : jsonData is List
                ? jsonData[0]
                : jsonData);
      }
      return Future.error("Server Error");
    }
  }

  // Write User Reviews
  Future<Review> updateUserReview(
      Review review, Map<String, dynamic> data) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/social/reviews/${review.id}/";
    final Map<String, String> headers = await getAuthHeaders();
    final _data = jsonEncode(data);
    final response = await httpPatch(url, body: _data, headers: headers);
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Review review = Review.fromJson(jsonDecode(response.body));

      return review;
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
  } // Write User Reviews

  Future<Review> updateProductReview(
      Review review, Map<String, dynamic> data) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/social/reviews/${review.id}/";
    final Map<String, String> headers = await getAuthHeaders();
    final _data = jsonEncode(data);
    final response = await httpPatch(url, body: _data, headers: headers);
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Review review = Review.fromJson(jsonDecode(response.body));

      return review;
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

  Future<Review> updateServiceReview(
      Review review, Map<String, dynamic> data) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/social/reviews/${review.id}/";
    final Map<String, String> headers = await getAuthHeaders();
    final _data = jsonEncode(data);
    final response = await httpPatch(url, body: _data, headers: headers);
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Review review = Review.fromJson(jsonDecode(response.body));

      return review;
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

  Future<Review> likeReview(Review review) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/social/reviews/like/${review.id}/";
    final Map<String, String> headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);

    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Review review = Review.fromJson(jsonDecode(response.body));

      return review;
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

  Future<Review> dislikeReview(Review review) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/social/reviews/dislike/${review.id}/";
    final Map<String, String> headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);

    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Review review = Review.fromJson(jsonDecode(response.body));

      return review;
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

  // Write Product Reviews
  Future<bool> addProductReview(String id, Map<String, dynamic> data) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/social/review/products/$id/";
    final Map<String, String> headers = await getAuthHeaders();
    final _data = jsonEncode(data);
    debugPrint("Data:- $_data");
    final response = await httpPost(url, body: _data, headers: headers);
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      if (response.statusCode != 500) {
        final jsonData = jsonDecode(response.body);
        debugPrint(
            "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
        return Future.error(jsonData is Map
            ? jsonData["error"] ?? jsonData["author_username"]
            : jsonData is List
                ? jsonData[0]
                : jsonData);
      }
      return Future.error("Server Error");
    }
  }

  // Write Service Reviews
  Future<bool> addServiceReview(String id, Map<String, dynamic> data) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/social/review/services/$id/";
    final Map<String, String> headers = await getAuthHeaders();
    final _data = jsonEncode(data);
    debugPrint("Data:- $_data");
    final response = await httpPost(url, body: _data, headers: headers);
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      if (response.statusCode != 500) {
        final jsonData = jsonDecode(response.body);
        debugPrint(
            "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
        return Future.error(jsonData is Map
            ? jsonData["error"] ?? jsonData["author_username"]
            : jsonData is List
                ? jsonData[0]
                : jsonData);
      }
      return Future.error("Server Error");
    }
  }

  // Fetch Product Reviews
  Future<Map<String, dynamic>> fetchProductReviews({String? productId}) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/social/review/products/$productId/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 404) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      return jsonData;
    }
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    return Future.error("${response.body}");
  }

  Future<bool> checkIfCanReviewProductOrService(
      Map<String, dynamic> data) async {
    final String url = AppConfig.baseUrl +
        "/api/v1/social/reviews/check-if-user-can-review-product-or-service/";

    final headers = await getAuthHeaders();
    final _data = jsonEncode(data);
    debugPrint('CAN REVIEW URL :: ${_data}');

    final response = await httpPost(url, headers: headers, body: _data);
    final jsonData = jsonDecode(response.body);
    debugPrint('CAN REVIEW :: ${response.statusCode}');
    debugPrint('CAN REVIEW :: ${response.body}');
    if (response.statusCode == 200 && jsonData['can_review'] == true) {
      return true;
    }
    return Future.error("${response.body}");
  }

  // Fetch Service Reviews
  Future<Map<String, dynamic>> fetchServiceReviews({String? serviceId}) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/social/review/services/serviceId/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return jsonData;
    }
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    return Future.error("${response.body}");
  }
}
