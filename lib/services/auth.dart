import 'dart:convert';
import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'device_info.dart';

final String baseUrl = "https://api.slydo.co";
final String secureBaseUrl = "https://api.slydo.co";
final String localHostUrl = "https://127.0.0.1:8080";

class AuthService {
  final String baseUrl = "https://api.slydo.co";
  final String secureBaseUrl = "https://api.slydo.co";
  final String localHostUrl = "https://127.0.0.1:8080";

  DatabaseHelper _db = DatabaseHelper();

  // This function creates a user object from named args passed in
  Future<User> createUser(Map<String, dynamic> userData) async {
    //delete old user if exist
    await _db.deleteUsers();

    // Create user instance
    User _user = User.fromJson(userData);

    await _db.saveUser(_user);
    return _user;
  }

  int getEpochTime(DateTime time) {
    var ms = time.millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  // Log user in if credentials are correct
  Future<User> authenticate(String phoneNumber, String password) async {
    // This method will pass the user name and password to the backend server
    // and if credentials are correct will receive payload with jwt and user info
    // which will be saved to the user table and jwt table then create
    // a user instance which we should pass around throughout the application as
    // the auth user.

    var url = secureBaseUrl + "/api/v1/user/auth/get-token/";
    var uuid = Uuid();
    var transactionId = uuid.v4();
    var headers = {
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
    };

    // Because the jwt expires every 5 minutes we will take note of the time they
    // where  created and the use that to compute the expiration time of the
    // token. So that we will only use the token if its still valid.
    // We play safe and use 4 minutes
    DateTime now = DateTime.now();
    int expirationTime =
        getEpochTime(now.add(Duration(seconds: 220))); // 3.66667 Minute

    Map _body = {"password": password, "phone_number": phoneNumber};
    var data = await getDeviceInfo();
    _body.addAll(data);

    debugPrint("Device Data: $data");

    var response = await http.post(url, body: _body, headers: headers);
    if (response.statusCode == 200) {
      Map<String, String> data = {};
      var jsonResponse = json.decode(response.body);
      data["access"] = jsonResponse[
          "access"]; // Get `access` and `refresh` Tokens from response
      data["refresh"] = jsonResponse["refresh"];
      data["expiration"] =
          expirationTime.toString(); // Convert expirationTime int to string .

      // Delete jwt from db if one exist
      await deleteJwt();
      await _db.saveJwt(data);

      // Save user to database
      var jsonData = jsonResponse["user"];
      jsonData["password"] = password;
      jsonData["url"] =
          secureBaseUrl + "/api/v1/user/customer/" + jsonData["username"];

      User user = await createUser(jsonData);

      return user;
    }
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    return User(
        uuid: null,
        url: null,
        phoneNumber: null,
        fullName: null,
        userName: null,
        avatar: null,
        qrCode: null,
        password: null);
  }

  // Log user out
  Future<void> logOut() async {
    var url = secureBaseUrl + "/api/v1/user/auth/logout/";
    var headers = await getAuthHeaders();
    await http.get(url, headers: headers);
    await deleteUsers();
    await deleteDevice();
    await unRegisterDevice();
  }

  // Delete user from db
  Future<int> deleteUsers() async {
    return await _db.deleteUsers();
  }

  // Delete device from db
  Future<int> deleteDevice() async {
    return await _db.deleteDevice();
  }

  // Close connection to db
  Future close() async => _db.close();

  // Get user instance from db
  Future<User> getUser() async {
    return await _db.getUser();
  }

  // Check if token has expired
  bool hasTokenExpired(String expirationTimeString) {
    // Will return false if token is still valid and true if token is no longer useful

    int expirationTime = int.parse(expirationTimeString);
    int now = getEpochTime(DateTime.now());
    return now >= expirationTime;
  }

  // Get jwt
  Future<Map<String, dynamic>> getJwt() async {
    return await _db.getJwt();
  }

  Future<Map<String, String>> getAuthHeaders() async {
    var tokenData = await _db.getJwt();
    String expirationTime = tokenData['expiration'];

    // Authenticate again if token has expired
    if (hasTokenExpired(expirationTime)) {
      debugPrint("Token Expired getting new one");
      User _user = await _db.getUser();
      await authenticate(_user.phoneNumber, _user.password);
      tokenData = await _db.getJwt(); // get new token now
    }

    String bearer = "Bearer " + tokenData["access"];
    var uuid = Uuid();
    var transactionId = uuid.v4();
    var headers = {
      "Authorization": bearer,
      "Content-type": "application/json",
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
    };
    // debugPrint("headres :- $headers");
    return headers;
  }

  Future<String> getAuthHeadersToken() async {
    var tokenData = await _db.getJwt();
    String expirationTime = tokenData['expiration'];

    // Authenticate again if token has expired
    if (hasTokenExpired(expirationTime)) {
      debugPrint("Token Expired getting new one");
      User _user = await getUser();
      await authenticate(_user.phoneNumber, _user.password);
      tokenData = await _db.getJwt(); // get new token now
    }

    String token = tokenData["access"];
    return token;
  }

  // Delete JWT from db
  Future<int> deleteJwt() async {
    return await _db.deleteJwt();
  }

  User createUserInstance(Map<String, dynamic> item) {
    User _user = User(
      uuid: item["uuid"],
      url: item["url"],
      phoneNumber: item["phone_number"],
      fullName: item["full_name"],
      userName: item["username"],
      avatar: item["avatar"],
      qrCode: item["qr_code"],
      password: item["password"],
      currency: item["default_currency"],
      isVerified: item["is_verified"],
    );
    return _user;
  }

  //register device
  Future<bool> registerDevice(Map data) async {
    var url = secureBaseUrl + "/api/v1/notification/register-device/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);

    var response = await http.post(url, headers: headers, body: _data);
    return response.statusCode == 200;
  }

  // it will unregister the device from server
  Future<bool> unRegisterDevice() async {
    var url = secureBaseUrl + "/api/v1/notification/unregister-device/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode({});
    var response;
    try {
      response = await http.patch(url, headers: headers, body: _data);
    } catch (e) {
      debugPrint(e.toString());
    }
    return response.statusCode == 200;
  }

  // it will tell the server our app is in which state
  Future<bool> updateAppState(Map data) async {
    var url = secureBaseUrl + "/api/v1/notification/update-app-state/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response;
    try {
      response = await http.patch(url, headers: headers, body: _data);
    } catch (e) {
      debugPrint("updateAppState : " + e.toString());
    }
    if (response.statusCode != 200) {
      var jsonData = response.body;
      debugPrint(jsonData);
    }
    return response.statusCode == 200;
  }

  Map getNonAuthHeader() {
    var uuid = Uuid();
    var transactionId = uuid.v4();
    var headers = {
      "Content-type": "application/json",
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
    };
    return headers;
  }

  /// Search Module
  // List the  item with pagination
  Future<Map<String, dynamic>> searchEndpointPagination(
      String url, String next, String previous) async {
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"],
      };
      return result;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }
}
