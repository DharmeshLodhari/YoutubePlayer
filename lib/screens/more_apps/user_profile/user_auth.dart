import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/models/ChatConversation.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/jwt.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'models/UserAbout.dart';
import 'models/states_model.dart';

class UserAuth extends AuthService {
  // Fetch user profile
  Future<CustomerProfile> fetchCustomerProfile(String? userName) async {
    if (userName == null) {
      return CustomerProfile();
    }
    var url = AppConfig.baseUrl + "/api/v1/user/customer/" + userName.trim();
    var uuid = Uuid();
    var transactionId = uuid.v4();

    var headers = {
      "Content-type": "application/json",
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
    };
    var response = await httpGet(url, headers: headers);

    debugPrint(
        "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      CustomerProfile customerProfile = CustomerProfile.fromJson(jsonData);
      return customerProfile;
    } else {
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<CustomerProfile> fetchCustomerProfileWithAuth(String? userName) async {
    if (userName == null) {
      return CustomerProfile();
    }
    var url = AppConfig.baseUrl + "/api/v1/user/customer/" + userName.trim();

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    print('FETCH PROFILE WITH AUTH ::: $url ${response.body}');
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      print('FETCH PROFILE  ::: $url ${jsonData['profile']['contact']}');

      CustomerProfile customerProfile = CustomerProfile.fromJson(jsonData);
      return customerProfile;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  // Update User Avatar
  Future<CustomerProfile> updateUserAvatar(File? avatar) async {
    debugPrint('CROPPED IMAGE AVATAR ---> $avatar');

    User? user = await getUser();
    if (user == null) return Future.error("Try after Some time");
    var headers = await getAuthHeaders();
    var url = AppConfig.baseUrl +
        "/api/v1/user/update-avatar/" +
        user.userName! +
        "/";

    if (avatar != null) {
      var avatarPath = avatar.path;
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("PATCH", Uri.parse(url));

      //add fields
      request.fields["username"] = user.userName!;
      request.fields["full_name"] = user.fullName!;
      request.fields["avatar"] = user.avatar!;

      //create multipart using filepath, string or bytes.
      var multipartFile =
          await http.MultipartFile.fromPath("avatar", avatarPath);

      //add multipart to request
      request.files.add(multipartFile);
      headers.forEach((k, v) => request.headers[k] = v);
      var response = await request.send();

      if (response.statusCode == 413) {
        return Future.error(
            "Please upload smaller image, This image is too large.");
      }
      var responseBody = await response.stream.bytesToString();
      debugPrint('UPDATE PICS ---> ${responseBody}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(responseBody);

        CustomerProfile customerProfile = CustomerProfile(
          fullName: jsonData["full_name"],
          userName: jsonData["username"],
          avatar: jsonData["avatar"],
          qrCode: jsonData["qr_code"],
        );
        debugPrint('UPDATE PICS 1 ---> ${jsonData["full_name"]}');
        debugPrint('UPDATE PICS 2  ---> ${jsonData["username"]}');
        debugPrint('UPDATE PICS 3 ---> ${jsonData["avatar"]}');
        debugPrint('UPDATE PICS 4 ---> ${jsonData["qr_code"]}');

        return customerProfile;
      } else {
        return Future.error(
            "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- $responseBody");
      }
    }
    return Future.error("Error while updating profile avatar");
  }

  // Update User Avatar
  Future<bool> deleteUserAvatar() async {
    User? user = await getUser();
    if (user == null) return Future.error("User Not Found");
    var headers = await getAuthHeaders();
    var url = AppConfig.baseUrl +
        "/api/v1/user/update-avatar/" +
        user.userName! +
        "/";

    var response = await httpDelete(url, headers: headers);
    if (response.statusCode == 204) {
      return true;
    } else {
      return Future.error(
          "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- ${response.body}");
    }
  }

  Future<User> verifyUserDetail(File documentPhoto, File userPhoto) async {
    var headers = await getAuthHeaders();
    var url = AppConfig.baseUrl + "/api/v1/user/kyc/";

    if (documentPhoto != null && userPhoto != null) {
      var document = documentPhoto.path;
      var selfie = userPhoto.path;
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("PATCH", Uri.parse(url));

      //add fields
      request.fields["document"] = document;
      request.fields["selfie"] = selfie;

      //create multipart using filepath, string or bytes
      var multipartFile1 =
          await http.MultipartFile.fromPath("document", document);
      var multipartFile2 = await http.MultipartFile.fromPath("selfie", selfie);

      //add multipart to request
      request.files.add(multipartFile1);
      request.files.add(multipartFile2);
      headers.forEach((k, v) => request.headers[k] = v);
      var response = await request.send();

      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        var jsonData = json.decode(responseBody);

        User user = await createUser(jsonData);
        return user;
      } else {
        throw responseBody;
      }
    } else {
      throw "Can't get https.";
    }
  }

  // Register the user with the backend servers
  Future<bool> userRegistration(Map<String, dynamic> _body) async {
    Map<String, dynamic> data = {};
    var url = AppConfig.baseUrl + "/api/v1/user/account/";
    var headers = getNonAuthHeader();
    var _getData = await getDeviceInfo();
    data.addAll(_body);

    _getData.entries.forEach((element) {
      data[element.key] = element.value.toString();
    });

    var _data = jsonEncode(data);

    debugPrint('USER REGISTRATION DATA ::: $_data');

    var response = await httpPost(url,
        headers: headers as Map<String, dynamic>?, body: _data);
    debugPrint('USER REGISTRATION RESPONSE ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    debugPrint("DATA SENT:- $data");
    debugPrint(
        "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    return Future.error("Error:- ${response.body}");
  }

// it will register the phone number to get OTP
  Future<bool> registerPhoneNumber(String phoneNumber) async {
    var url = AppConfig.baseUrl + "/api/v1/sms/register-phone-number";
    var headers = getNonAuthHeader();
    var data = {
      "phone": phoneNumber,
    };

    debugPrint('PHONE NUMBER DATA ::: $data');

    var _data = jsonEncode(data);
    var response = await httpPost(url,
        body: _data, headers: headers as Map<String, dynamic>?);

    debugPrint('REGISTER PHONE NUMBER RESPONSE ::: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint("DATA SENT:- $data");
      debugPrint(
          "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      var jsonData = json.decode(response.body);
      return Future.error(jsonData["error"]);
    }
  }

  Future<bool> canContinueRegistrationWithPhoneNumber(
      {required String phoneNumber}) async {
    String url = AppConfig.baseUrl + "/api/v1/user/verify-phone-number/";

    var data = {"phone_number": '+234$phoneNumber'};
    var headers = getNonAuthHeader();

    var response = await httpPost(url,
        headers: headers as Map<String, dynamic>?, body: jsonEncode(data));

    var jsonData = jsonDecode(response.body);

    debugPrint('PHONE NUMBER DATA ::: $data');
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200) {
      if (jsonData['exist'] == true) {
        // If {"exist":true} it means phone number already exists on our server so the user can't proceed with the entered phone number.
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  // it will verify the phone number to  OTP
  Future<String?> verifyPhoneNumber(
      // ignore: non_constant_identifier_names
      String? phoneNumber,
      String otp,
      String passwordToken) async {
    late String result;
    var url = AppConfig.baseUrl + "/api/v1/sms/verify";
    var headers = getNonAuthHeader();
    var data = {
      "phone": phoneNumber,
      "code": otp,
      "password-token": passwordToken,
    };

    debugPrint('VERIFY PHONE NUMBER DATA ::: $data');

    var _data = jsonEncode(data);
    var response = await httpPost(url,
        body: _data, headers: headers as Map<String, dynamic>?);

    debugPrint('VERIFY PHONE NUMBER RESPONSE DATA ::: ${response.body}');
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      var resetToken = jsonData['reset-token'];

      if (resetToken != null) {
        return resetToken;
      } else {
        return 'Successful';
      }
    } else {
      debugPrint(
          "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return Future.error(jsonData);
    }
  }

  // it will verify the phone number to  OTP
  Future<bool> resetPassword(String passwordOne, String passwordTwo,
      String? phoneNumber, String? resetToken) async {
    var url = AppConfig.baseUrl + "/api/v1/user/auth/password-reset/";
    var headers = getNonAuthHeader();

    var data = {
      "password1": passwordOne,
      "password2": passwordTwo,
      "reset-token": resetToken,
      "phone-number": phoneNumber,
    };
    var _data = jsonEncode(data);
    debugPrint('_data :: $data');
    var response = await httpPatch(url,
        headers: headers as Map<String, dynamic>?, body: _data);
    var jsonData = jsonDecode(response.body);
    debugPrint(
        "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200) {
      return true;
    } else {
      throw jsonData;
    }
  }

  Future<Map<String, dynamic>> changePassword(Map<String, dynamic> data) async {
    var url = AppConfig.baseUrl + "/api/v1/user/change-password/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);
    debugPrint(
        "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200) {
      // Because the jwt expires every 5 minutes we will take note of the time they
      // where  created and the use that to compute the expiration time of the
      // token. So that we will only use the token if its still valid.
      // We play safe and use 4 minutes
      DateTime now = DateTime.now();
      int expirationTime =
          getEpochTime(now.add(Duration(seconds: 220))); // 3.66667 Minute

      var jsonResponse = json.decode(response.body);
      debugPrint("===> $jsonResponse");

      jsonResponse["expiration"] = expirationTime;
      Jwt jwt = Jwt.fromJson(jsonResponse);

      // Delete jwt from db if one exist
      // await deleteJwt();
      await DatabaseHelper().saveJwt(jwt);

      return {"new_password": data["new_password1"]};
    } else {
      return Future.error("ERROR: - ${response.body}");
    }
  }

  Future<ShippingAddress> fetchUserAddress({String? customerName}) async {
    String url = "";
    if (customerName != null) {
      url = AppConfig.baseUrl + "/api/v1/user/shipping-address/$customerName/";
    } else {
      url = AppConfig.baseUrl + "/api/v1/user/address/";
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = jsonDecode(response.body);

    debugPrint('USER ADDRESS -> $url');
    debugPrint('USER ADDRESS -> $jsonData');

    if (response.statusCode == 200) {
      debugPrint('USER ADDRESS ::: $jsonData');
      return ShippingAddress.fromJson(jsonData);
    }
    return ShippingAddress(
        addressLineOne: "",
        addressLineTwo: "",
        city: "",
        userState: UserState(),
        country: "",
        countryIsoCode: "NG");
  }

  Future<UserAbout> fetchUserAboutInfo({String? userName}) async {
    var url = AppConfig.baseUrl + "/api/v1/user/about/$userName/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('FETCH USER ABOUT INFO RESPONSE ::: ${response.body}');

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return UserAbout.fromJson(jsonData);
    }
    return UserAbout();
  }

  Future<UserAbout> addOrUpdateUserBio(
      {UserAbout? userAbout, String? nickName}) async {
    var url = AppConfig.baseUrl + "/api/v1/user/about/";

    debugPrint("Files send:-  before Headers");

    var headers = await getAuthHeaders();

    var responseBody;
    var response;

    debugPrint("Files wallpaper -> ${userAbout?.wallpaper}");

    if (userAbout != null &&
        userAbout.wallpaper != "" &&
        !userAbout.wallpaper.contains("https") &&
        !userAbout.wallpaper.contains("http")) {
      debugPrint("Files userAbout.wallpaper");

      var request = http.MultipartRequest("PATCH", Uri.parse(url));
      Map<String, dynamic> data = userAbout.toJson();

      data.forEach((key, value) {
        request.fields[key] =
            (value is List<Map> || value is Map) ? jsonEncode(value) : value;
      });

      request.fields['nickname'] = nickName!;
      debugPrint("Files send:- d ${request.files}");

      //create multipart using filepath, string or bytes
      var multipartFile =
          await http.MultipartFile.fromPath("wallpaper", userAbout.wallpaper);

      //add multipart to request
      request.files.add(multipartFile);

      headers.forEach((k, v) => request.headers[k] = v);

      debugPrint("Files send:- ${request.files}");
      debugPrint("Data Send:- ${request.fields}");

      response = await request.send();

      responseBody = await response.stream.bytesToString();
      debugPrint(
          "URL FOR WALLPAPER: $url STATUSCODE:- ${response.statusCode} body:- $responseBody");
    } else {
      Map<String, dynamic> data = {};
      if (userAbout != null) {
        data = userAbout.toJson();
      }
      debugPrint("USER DATA -->  ${data}");

      data['nickname'] = nickName;
      var _data = jsonEncode(data);
      debugPrint("Data Send:- $_data");
      response = await httpPatch(url, headers: headers, body: _data);

      responseBody = response.body;
      debugPrint(
          "URL: $url STATUSCODE:- ${response.statusCode} body:- $responseBody");
    }
    if (response.statusCode == 200) {
      return UserAbout.fromJson(jsonDecode(responseBody));
    }
    return Future.error("$responseBody");
  }

  Future<List<StatesModel>> getStates() async {
    String? url = AppConfig.baseUrl + "/api/v1/user/states";

    var headers = await getAuthHeaders();

    http.Response response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      List responseBody = jsonDecode(response.body);
      return responseBody.map((e) => StatesModel.fromJson(e)).toList();
    }
    return Future.error("Something went wrong");
  }

  Future<Map<String, dynamic>> updateSimpleUserDetail(
      {String? nickName, String? bio, String? wallpaper}) async {
    var url = AppConfig.baseUrl + "/api/v1/user/update-customer/";
    debugPrint("URL:- $url");
    debugPrint("URL WALLPAPER:- $wallpaper");

    var response;
    var responseBody;
    var headers = await getAuthHeaders();
    if (wallpaper != null) {
      var request = http.MultipartRequest("PATCH", Uri.parse(url));
      Map<String, dynamic> data = {"nickname": nickName, "bio": bio};

      data.forEach((key, value) {
        request.fields[key] = value;
      });

      //create multipart using filepath, string or bytes
      var multipartFile =
          await http.MultipartFile.fromPath("wallpaper", wallpaper);

      //add multipart to request
      request.files.add(multipartFile);

      headers.forEach((k, v) => request.headers[k] = v);

      debugPrint("Files send:- ${request.files}");
      debugPrint("Data Send:- ${request.fields}");

      response = await request.send();

      responseBody = await response.stream.bytesToString();

      debugPrint(
          "RESPONSE :- STATUS CODE:- ${response.statusCode} BODY:- $responseBody");
    } else {
      var data = {"nickname": nickName, "bio": bio};
      var headers = await getAuthHeaders();
      var _data = jsonEncode(data);
      response = await httpPatch(url, headers: headers, body: _data);

      responseBody = response.body;
      debugPrint(
          "RESPONSE :- STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    }

    if (response.statusCode == 200) {
      dynamic responseData = jsonDecode(responseBody);
      return {
        "nickname": responseData['nickname'],
        "bio": responseData['bio'],
        "chat_wallpaper": responseData['chat_wallpaper'],
        "wallpaper": responseData['wallpaper'],
      };
    }
    return Future.error('Something went wrong.');
  }

  Future<bool> deleteImageCover({bool isUserNormalUser = false}) async {
    var headers = await getAuthHeaders();
    late var url;

    if (isUserNormalUser) {
      url = AppConfig.baseUrl + "/api/v1/user/about/";
    } else {
      url = AppConfig.baseUrl + "/api/v1/user/update-customer/";
    }

    var response = await httpDelete(url, headers: headers);

    debugPrint('DELETE COVER ::::  ${response.body}');
    if (response.statusCode == 204) {
      return true;
    } else {
      return Future.error(
          "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- ${response.body}");
    }
  }

  Future<bool> addUserAddress(Map data) async {
    var url = AppConfig.baseUrl + "/api/v1/user/address/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("ADDRESS ADDED: ${response.body}");

      return true;
    }
    debugPrint("address add failed : ${response.body}");
    return true;
  }

  ///Friends List

  Future<Map<String, dynamic>?> contacts(String? next, String? previous) async {
    var url = AppConfig.baseUrl + "/api/v1/user/contacts/";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint('USER RES CONTACTS :::: $response');

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body) ?? {};
      debugPrint('USER CONTACTS :::: $jsonData');

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"],
      };

      return result;
    } else {
      debugPrint("${response.statusCode} ${response.body}");
      var jsonData = jsonDecode(response.body);
      throw jsonData;
    }
  }

  Future<List?> fetchMissedContact(
      {required String createdAt, String? conversationId}) async {
    var url = AppConfig.chatUrl + "/api/v1/chat/fetch-missed-conversations/";

    var headers = await getAuthHeaders();
    debugPrint("URL:- $url");
    Map<String, dynamic> data = {
      "conversation_id": conversationId,
      "created_at": DateTime.parse(createdAt).toUtc().toString()
    };

    debugPrint("DATA SENT:- $data");
    var response =
        await httpPost(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200) {
      debugPrint("STATUSCODE:- ${response.statusCode} BODY:- ${response.body}");
      return jsonDecode(response.body);
    } else {
      debugPrint(
          "URL:- $url STATUSCODE:- ${response.statusCode} RESPONSEBODY:- ${response.body}");
      return null;
    }
  }

  // Fetch user profile
  Future<ChatConversation> fetchContactProfile(String userName) async {
    var url =
        AppConfig.baseUrl + "/api/v1/user/connections/" + userName.trim() + "/";

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      debugPrint("STATUS CODE:- ${response.statusCode}");
      debugPrint("response from fetchCustomer = $jsonData");
      ChatConversation customerProfile = ChatConversation.fromJson(jsonData);
      debugPrint("ChatConversation => ${customerProfile.conversationId}");
      return customerProfile;
    } else {
      debugPrint(
          "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- ${response.body}");
      return Future.error(
          "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- ${response.body}");
    }
  }

  Future<bool> removeFromContactList(CustomerProfile user) async {
    var url = AppConfig.baseUrl + "/api/v1/user/contacts/remove-from-contact/";
    debugPrint("URL:- $url");
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);
    debugPrint(
        "RESPONSE :- STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // Check if user is the the checker's list of contact
  Future<bool> checkInContactList(String? user, String? checker) async {
    // Note that the checker is the request.user making this request.
    var url = AppConfig.baseUrl + "/api/v1/user/contacts/check-in-contact/";
    var data = {"checker": checker, "user": user};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);

    var response = await httpPatch(url, headers: headers, body: _data);
    // debugPrint("data $_data");
    // debugPrint("response ${response.statusCode} ${response.body}");
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> checkInRequest(String? user) async {
    // Note that the checker is the request.user making this request.
    var url =
        AppConfig.baseUrl + "/api/v1/user/contact-request/check-in-request/";
    var data = {"to_user": user};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> makeContactRequest(CustomerProfile user) async {
    var url = AppConfig.baseUrl + "/api/v1/user/contact-request/";
    var data = {"to_user": user.userName};

    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);
    debugPrint("Data :- $data");
    debugPrint("response :- ${response.body}");
    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // Block Contact
  Future<Map<String, dynamic>?> listBlockUsers(
      String? next, String? previous) async {
    var url = AppConfig.baseUrl + "/api/v1/user/contacts/list-block-contact/";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

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
      return Future.error(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");
    }
  }

  Future<bool> blockUser(CustomerProfile user) async {
    var url = AppConfig.baseUrl + "/api/v1/user/contacts/block-contact/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> unBlockUser(CustomerProfile user) async {
    var url = AppConfig.baseUrl + "/api/v1/user/contacts/unblock-contact/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // Contact Request
  Future<Map<String, dynamic>?> listContactRequests(
      String? next, String? previous) async {
    var url = AppConfig.baseUrl + "/api/v1/user/contact-request/";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

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
      return Future.error(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");
    }
  }

  Future<bool> acceptContactRequest(CustomerProfile user) async {
    var url = AppConfig.baseUrl + "/api/v1/user/contact-request/accept/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);
    debugPrint('RES __ ${response.body}');
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> rejectContactRequest(CustomerProfile user) async {
    var url =
        AppConfig.baseUrl + "/api/v1/user/contact-request/cancel-or-reject/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> upgradeUserProfile(Map<String, dynamic> data) async {
    var url = AppConfig.baseUrl + "/api/v1/user/upgrade-user-account/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);
    log("Headers:- $headers body :- $_data URL:- $url statuscode ${response.statusCode}  body:- ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<List?> getUserProfileUpgradeDetails() async {
    var url = AppConfig.baseUrl + "/api/v1/user/profile-pricing/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      return jsonData["results"];
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // it will reset the phone number to get OTP
  Future<bool> resetDevice({Map? data}) async {
    // var url = AppConfig.AppConfig.baseUrl + "/api/v1/user/reset-user-device/";
    //
    // var headers = getNonAuthHeader();
    // var deviceData = await getDeviceInfo();
    // data.addAll(deviceData);
    //
    // var _data = jsonEncode(data);
    // debugPrint("URL:- $url");
    // debugPrint("DATA SENT:- $_data");
    // var response = await httpPost(url, body: _data, headers: headers);
    //
    // if (response.statusCode == 200) {
    return true;
    // } else {
    //   debugPrint(
    //       "URL:- $url \nRESPONSE STATUS CODE:- ${response.statusCode}  \nRESPONSE BODY:- ${response.body}");
    //
    //   return Future.error(
    //       "RESPONSE STATUS CODE:- ${response.statusCode}  \nRESPONSE BODY:- ${response.body}");
    // }
  }

  // it will register the phone number to get OTP
  Future<String?> sendOTPForResetDevice(String phoneNumber) async {
    // var url = secureAppConfig.baseUrl + "/api/v1/sms/reset-user-device/";
    // var headers = getNonAuthHeader();
    // var data = {
    //   "phone": phoneNumber,
    // };
    // var _data = jsonEncode(data);
    // var response = await httpPost(url, body: _data, headers: headers);
    //
    // debugPrint("RESPONSE=> ${response.body}");
    //
    // if (response.statusCode == 200) {
    //   var jsonData = json.decode(response.body);
    var jsonData = {"otp": "123456"};
    return jsonData['otp'];
    // } else {
    //   var jsonData = json.decode(response.body);
    //   return Future.error(jsonData["error"]);
    // }
  }

  // it will verify the phone number to  OTP
  Future<String> verifyOTPForResetDevice(
      String? phoneNumber, String otp) async {
    // var url = AppConfig.baseUrl + "/api/v1/sms/verify";
    // var headers = getNonAuthHeader();
    // var data = {"phone": phoneNumber, "code": otp};
    // var _data = jsonEncode(data);
    // var response = await httpPost(url, body: _data, headers: headers);
    //
    // if (response.statusCode == 200) {
    //   var jsonData = json.decode(response.body);
    //   var resetToken = jsonData['reset-token'];
    //   return resetToken;
    return "xyzabc";
    // } else {
    //   debugPrint(
    //       "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
    //
    //   return Future.error(
    //       "RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
    // }
  }

  // Future<bool> searchUserInContact(String next ,String previous,{String query}) async {
  //   var url = secureAppConfig.baseUrl +
  //       "/api/v1/user/group-conversation/search-user-contacts?q=$query/";
  //   debugPrint("UR");
  //   var headers = await getAuthHeaders();
  //
  //   var response = await httpGet(url, headers: headers);
  //
  //   if (response.statusCode == 200) {
  //     debugPrint("Result:- ${response.body}");
  //     return true;
  //   } else {
  //     debugPrint(
  //         "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
  //     return Future.error("ERROR:- ${response.body}");
  //   }
  // }

  // Search User in Contact
  Future<Map<String, dynamic>?> searchUserInContact(
      String? next, String? previous,
      {String? query}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/user/group-conversation/search-user-contacts";

    if (query != "") {
      url = url + "?q=$query/";
    }
    url = Uri.encodeFull(url);
    debugPrint("URL:- $url");
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

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
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }
}
