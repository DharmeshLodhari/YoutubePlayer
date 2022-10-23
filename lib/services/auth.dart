import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/SecureUser.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/jwt.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/secure_storage.dart';
import 'package:Slydo/utils/country_picker/country.dart';
import 'package:Slydo/utils/country_picker/utils.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import 'device_info.dart';

class AuthService {
  // static int authCallCount = 0;
  // static int authCallLimit = 5;

  final Duration timeOutDuration = Duration(seconds: 12);
  final String timeOutErrorMessage = "Check your network";

  DatabaseHelper _db = DatabaseHelper();

  static const int API_CALL_RETRY_COUNT = 5;

  // This function creates a user object from named args passed in
  Future<User> createUser(Map<String, dynamic> userData) async {
    //delete old user if exist
    await _db.deleteUsers();

    // Create user instance
    User _user = User.fromJson(userData);

    await _db.saveUser(_user);
    return Future.value(_user);
  }

  int getEpochTime(DateTime time) {
    var ms = time.millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  // To get refresh token
  // Log user in if credentials are correct
  // Future<User> getRefreshToken() async {
  //   // This method will pass the user name and password to the backend server
  //   // and if credentials are correct will receive payload with jwt and user info
  //   // which will be saved to the user table and jwt table then create
  //   // a user instance which we should pass around throughout the application as
  //   // the auth user.
  //
  //   var uri = AppConfig.baseUrl + "/api/v1/user/auth/refresh-token";
  //   var uuid = Uuid();
  //   var transactionId = uuid.v4();
  //   var headers = {
  //     "TransactionId": transactionId,
  //     "DeviceType": Platform.isAndroid ? "Android" : "IOS",
  //     "User-Agent": "Slydo-Mobile",
  //   };
  //
  //   debugPrint('TRANSACTION-ID :: $transactionId');
  //
  //   // Because the jwt expires every 5 minutes we will take note of the time they
  //   // where  created and the use that to compute the expiration time of the
  //   // token. So that we will only use the token if its still valid.
  //   // We play safe and use 4 minutes
  //   DateTime now = DateTime.now();
  //   int expirationTime =
  //       getEpochTime(now.add(Duration(seconds: 220))); // 3.66667 Minute
  //
  //   Map _body = {"refresh": refreshToken};
  //   var data = await getDeviceInfo();
  //   // data['device_id'] = "CB52C6A6-4C0E-4FE0-A753-C9A936AEA8BB";
  //   _body.addAll(data);
  //
  //   debugPrint("=> $_body");
  //   Uri url = Uri.parse(uri);
  //
  //   debugPrint("URL => $url BODY => $_body");
  //
  //   var response = await http.post(url, body: _body, headers: headers);
  //   print('RESPONSE:-----> $response');
  //
  //   if (response.statusCode == 200) {
  //     debugPrint(
  //         "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
  //
  //     Map<String, dynamic> jsonResponse = jsonDecode(response.body);
  //     jsonResponse["expiration"] = expirationTime;
  //     jsonResponse["refresh_token"] = refreshToken;
  //
  //     Jwt jwt = Jwt.fromJson(jsonResponse);
  //     await _db.saveJwt(jwt);
  //
  //     // Save user to database
  //     var jsonData = jsonResponse["user"];
  //     log("User=> $jsonData");
  //     jsonData["password"] = password;
  //     jsonData["url"] =
  //         AppConfig.baseUrl + "/api/v1/user/customer/" + jsonData["username"];
  //     User user = await createUser(jsonData);
  //
  //     return Future.value(user);
  //   }
  //
  //   debugPrint(
  //       "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
  //
  //   try {
  //     var jsonData = jsonDecode(response.body);
  //
  //     if (jsonData["detail"] != null) {
  //       return Future.error("${jsonData["detail"]}");
  //     } else {
  //       return Future.error("${response.body}");
  //     }
  //   } catch (e) {
  //     return Future.error("${response.body}");
  //   }
  // }

  Future<User> authenticate(String? phoneNumber, String? password) async {
    // This method will pass the user name and password to the backend server
    // and if credentials are correct will receive payload with jwt and user info
    // which will be saved to the user table and jwt table then create
    // a user instance which we should pass around throughout the application as
    // the auth user.

    var uri = AppConfig.baseUrl + "/api/v1/user/auth/get-token/";
    var uuid = Uuid();
    var transactionId = uuid.v4();
    var headers = {
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
    };

    debugPrint('TRANSACTION-ID :: $transactionId');

    // Because the jwt expires every 5 minutes we will take note of the time they
    // where  created and the use that to compute the expiration time of the
    // token. So that we will only use the token if its still valid.
    // We play safe and use 4 minutes
    DateTime now = DateTime.now();
    int expirationTime =
        getEpochTime(now.add(Duration(seconds: 220))); // 3.66667 Minute

    Map _body = {"password": password, "phone_number": phoneNumber};
    var data = await getDeviceInfo();
    // data['device_id'] = "CB52C6A6-4C0E-4FE0-A753-C9A936AEA8BB";
    _body.addAll(data);

    debugPrint("=> $_body");
    Uri url = Uri.parse(uri);

    debugPrint("URL => $url BODY => $_body");

    var response = await http.post(url, body: _body, headers: headers);
    print('RESPONSE:-----> $response');

    if (response.statusCode == 200) {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      jsonResponse["expiration"] = expirationTime;

      Jwt jwt = Jwt.fromJson(jsonResponse);
      await _db.saveJwt(jwt);

      // Save user to database
      var jsonData = jsonResponse["user"];
      log("User=> $jsonData");
      jsonData["password"] = password;
      jsonData["url"] =
          AppConfig.baseUrl + "/api/v1/user/customer/" + jsonData["username"];
      User user = await createUser(jsonData);

      return Future.value(user);
    }

    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    try {
      var jsonData = jsonDecode(response.body);

      if (jsonData["detail"] != null) {
        return Future.error("${jsonData["detail"]}");
      } else {
        return Future.error("${response.body}");
      }
    } catch (e) {
      return Future.error("Something went wrong, please try again.");
    }
  }

  // Log user out
  Future<void> logOut() async {
    var uri = AppConfig.baseUrl + "/api/v1/user/auth/logout/";
    var headers = await getAuthHeaders();
    debugPrint("URL:- $uri Called !!");
    Uri url = Uri.parse(uri);
    var response = await http.get(url, headers: headers);
    debugPrint(
        "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    unRegisterDevice();
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
  Future<User?> getUser() async {
    return Future.value(await _db.getUser());
  }

  // Check if token has expired
  bool hasTokenExpired(String expirationTimeString) {
    // Will return false if token is still valid and true if token is no longer useful

    if (expirationTimeString == "") return true;
    int expirationTime = int.parse(expirationTimeString);
    int now = getEpochTime(DateTime.now());

    bool hasTokenExpired = now >= expirationTime;

    if (hasTokenExpired) {
      debugPrint(
          "Expiration Time :- $expirationTimeString  NOW TIME:- $now  (now >= expirationTime) ($now >= $expirationTime)  ${now >= expirationTime}");
    }

    return hasTokenExpired;
  }

  // Get jwt
  Future<Jwt?> getJwt() async {
    return await _db.getJwt();
  }

  Future<Map<String, String>> getUserAuthDetails() async {
    User? _user = await _db.getUser();

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String countryFromPref = sharedPreferences.getString('country') ?? "NG";

    Country country = CountryPickerUtils.getCountryByIsoCode(countryFromPref);

    SecureUser secureUser = await SecureStorage().getUser();
    String phoneNumber = secureUser.phoneNumber ?? "";
    String password = secureUser.password ?? "";

    if (phoneNumber != "") {
      phoneNumber = "+" + country.phoneCode! + phoneNumber;
    }

    if (phoneNumber == "" || password == "") {
      phoneNumber = _user?.phoneNumber ?? "";
      password = _user?.password ?? "";
    }
    return {'phoneNumber': phoneNumber, 'password': password};
  }

  // For fetching new token for user if somehow user is not found then
  // we are logging out that user to get a fresh token
  Future<Jwt> fetchNewToken() async {
    debugPrint("Token Expired getting new one");

    Jwt? jwt;

    await Connectivity().checkConnectivity().then((value) async {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        try {
          Map<String, String> userAuthDetailsMap = await getUserAuthDetails();

          await authenticate(
            userAuthDetailsMap['phoneNumber'],
            userAuthDetailsMap['password'],
          );
        } catch (error) {
          debugPrint("ERROR:- while fetching new Token $error");
          await Future.delayed(Duration(milliseconds: 500));
          fetchNewToken();
        }

        jwt = await _db.getJwt(); // get new token now

        if (jwt == null) {
          debugPrint("ERROR:- while fetching new Token JWT IS FOUND NULL");
          await Future.delayed(Duration(milliseconds: 500));
          fetchNewToken();
        }
      } else {
        await Future.delayed(Duration(milliseconds: 500));
        fetchNewToken();
      }
    });

    return jwt!;
  }

  Future<Map<String, String>> getAuthHeaders() async {
    // we are setting this variable assuming that the token is expired
    // after that we will check in db has token expire or not if not then we will
    // send that token in header else we will fetch new token
    bool isNewTokenNeeded = true;

    Jwt? jwt = await _db.getJwt();

    String? expirationTime = jwt?.expiration ?? null;

    if ((jwt?.access ?? null) != null && (jwt?.access ?? "") != "") {
      isNewTokenNeeded = true;
    }

    if (expirationTime != null && expirationTime != "") {
      if (!hasTokenExpired(expirationTime)) {
        isNewTokenNeeded = false;
      } else {
        debugPrint("EXPIRED DUE TO EXPIRED TIME >>>>>>>>>>>!!");
      }
    }

    // Authenticate again if token has expired
    if (isNewTokenNeeded) {
      debugPrint("TOKEN EXPIRE REASON 1");
      jwt = await fetchNewToken();
    }

    if (jwt?.access == null || jwt?.access == "") {
      debugPrint("TOKEN EXPIRE REASON 2");
      jwt = await fetchNewToken();
    }

    String bearer = "Bearer " + jwt!.access!;
    // log("$bearer");
    var uuid = Uuid();
    var transactionId = uuid.v4();

    // debugPrint('BEARER :: $bearer');
    // debugPrint('TRANSACTION ID  :: $transactionId');

    var headers = {
      "Authorization": bearer,
      "Content-type": "application/json; charset=utf-8",
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
      "App-Version": appVersion
    };
    return headers;
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
    var url = AppConfig.baseUrl + "/api/v1/notification/register-device/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);

    var response = await httpPost(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    debugPrint(
        "URL:- $url STATUSCODE:- ${response.statusCode} RESPONSEBODY:- ${response.body}");
    return false;
  }

  // it will unregister the device from server
  Future<bool> unRegisterDevice() async {
    var uri = AppConfig.baseUrl + "/api/v1/notification/unregister-device/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode({});
    debugPrint("URL:- $uri Called !!");
    Uri url = Uri.parse(uri);
    late var response;
    try {
      response = await http.patch(url, headers: headers, body: _data);
    } catch (e) {
      debugPrint(
          "URL:- $url STATUS CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");
      debugPrint("ERROR: WHILE UNREGISTERING DEVICE :-" + e.toString());
    }
    debugPrint(
        "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    return response.statusCode == 200;
  }

  // it will tell the server our app is in which state
  Future<bool> updateAppState(Map data) async {
    var url = AppConfig.baseUrl + "/api/v1/notification/update-app-state/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response;
    try {
      response = await httpPatch(url, headers: headers, body: _data);
    } catch (e) {
      debugPrint(
          "URL:- $url STATUSCODE:- ${response?.statusCode} RESPONSEBODY:- ${response?.body}");
      debugPrint("updateAppState : " + e.toString());
    }
    if (response != null) {
      if (response.statusCode != 200) {
        var jsonData = response.body;
        debugPrint(jsonData);
      }
      return response.statusCode == 200;
    }
    return Future.value(false);
  }

  Map getNonAuthHeader() {
    var uuid = Uuid();
    var transactionId = uuid.v4();
    var headers = {
      "Content-type": "application/json",
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
      "App-Version": appVersion,
    };
    debugPrint('APP VERSION -> $appVersion}');

    return headers;
  }

  /// Search Module
  // List the  item with pagination
  Future<Map<String, dynamic>?> searchEndpointPagination(
      String url, String? next, String? previous) async {
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers)
        .timeout(timeOutDuration, onTimeout: () => timeOutFunction());

    print('SEARCH USER ::: ${response.body}');
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

  FutureOr<http.Response> timeOutFunction({String? url}) {
    if (url != null) {
      debugPrint("Timeout on URL:- $url");
    }

    return Future.error("$timeOutErrorMessage");
  }

  Future<void> wasTokenBlackListed(var response) async {
    if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 423) {
      try {
        var jsonData = jsonDecode(response.body);
        // {detail: Given token not valid for any token type, code: token_not_valid, messages: [{status_code: 423}]}

        debugPrint(
            "Token Black List ===> ${response.statusCode}  ${response.body}");

        try {
          if (jsonData["messages"][0]["status_code"] == 423 ||
              jsonData["messages"][0]["status_code"] == "423") {
            //  showUserLogoutCard(context: myGlobals.navigationKey.currentContext);
          }
        } catch (error) {
          debugPrint("Token is Valid");
        }
      } catch (error) {
        debugPrint("ERROR TOKEN IS BLACK LISTED");
      }
    }
    return;
  }

  /// TO CHECK IF WE GET TOKEN EXPIRED RESPONSE FROM API
  Future<bool> isTokenExpire(var response) async {
    if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 423) {
      try {
        var jsonData = jsonDecode(response.body);
        // {detail: Given token not valid for any token type, code: token_not_valid, messages: [{status_code: 423}]}

        debugPrint(
            "Token Black List ===> ${response.statusCode}  ${response.body}");

        try {
          if (jsonData["messages"][0]["status_code"] == 423 ||
              jsonData["messages"][0]["status_code"] == "423") {
            return true;
          }
        } catch (error) {
          debugPrint("Token is Valid");
        }
      } catch (error) {
        debugPrint("TOKEN IS EXPIRED !!!+++");
      }
    }
    return false;
  }

  Future<Response> httpGet(
    String url, {
    Map<String, dynamic>? headers,
    int count = API_CALL_RETRY_COUNT,
  }) async {
    Uri uri = Uri.parse(url);
    debugPrint("URL:- $uri");

    var response = await http
        .get(uri, headers: headers as Map<String, String>?)
        .timeout(timeOutDuration, onTimeout: () => timeOutFunction());

    /// WE WILL CALL THIS API API_CALL_RETRY_COUNT number of time to ensure token expire issue is not face by user
    bool result = await isTokenExpire(response);
    if (result) {
      count = count - 1;
      if (count != 0) {
        return await httpGet(url, headers: headers, count: count);
      }
    }
    // var utf8runs = response.body.runes.toList();
    // Response res = Response(utf8.decode(utf8runs), response.statusCode);
    await wasTokenBlackListed(response);
    return response;
  }

  Future<Response> httpPost(
    String url, {
    Map<String, dynamic>? headers,
    String? body,
    int count = API_CALL_RETRY_COUNT,
  }) async {
    Uri uri = Uri.parse(url);
    var response = await http
        .post(uri, headers: headers as Map<String, String>?, body: body)
        .timeout(timeOutDuration, onTimeout: () => timeOutFunction());

    /// WE WILL CALL THIS API API_CALL_RETRY_COUNT number of time to ensure token expire issue is not face by user
    bool result = await isTokenExpire(response);
    if (result) {
      count = count - 1;
      if (count != 0) {
        return await httpPost(url, headers: headers, body: body, count: count);
      }
    }

    await wasTokenBlackListed(response);
    return response;
  }

  Future<Response> httpPatch(
    String url, {
    Map<String, dynamic>? headers,
    String? body,
    int count = API_CALL_RETRY_COUNT,
  }) async {
    Uri uri = Uri.parse(url);
    var response = await http
        .patch(uri, headers: headers as Map<String, String>?, body: body)
        .timeout(timeOutDuration, onTimeout: () => timeOutFunction());

    /// WE WILL CALL THIS API API_CALL_RETRY_COUNT number of time to ensure token expire issue is not face by user
    bool result = await isTokenExpire(response);
    if (result) {
      count = count - 1;
      if (count != 0) {
        return await httpPatch(url, headers: headers, body: body, count: count);
      }
    }

    await wasTokenBlackListed(response);
    return response;
  }

  // Future<Response> imageUploader(
  //   String url, {
  //   Map<String, dynamic>? headers,
  //   String? body,
  // }) {
  //   var request = http.MultipartRequest("PATCH", Uri.parse(url));
  // }

  Future<Response> httpDelete(String url,
      {Map<String, dynamic>? headers, int count = API_CALL_RETRY_COUNT}) async {
    Uri uri = Uri.parse(url);
    var response =
        await http.delete(uri, headers: headers as Map<String, String>?);

    /// WE WILL CALL THIS API API_CALL_RETRY_COUNT number of time to ensure token expire issue is not face by user
    bool result = await isTokenExpire(response);
    if (result) {
      count = count - 1;
      if (count != 0) {
        return await httpDelete(url, headers: headers, count: count);
      }
    }

    await wasTokenBlackListed(response)
        .timeout(timeOutDuration, onTimeout: () => timeOutFunction());

    return response;
  }
}
