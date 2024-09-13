import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Slydo/data/database_helper.dart';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/messaging/chat/models/chat_conversation.dart';
import 'package:Slydo/screens/moments/models/comment_model.dart';
import 'package:Slydo/screens/user_profile/models/jwt.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/services/device_info.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import 'models/UserAbout.dart';
import 'models/states_model.dart';

class UserAuth extends AuthService {
  // Fetch user profile
  Future<CustomerProfile> fetchCustomerProfile(String? userName) async {
    if (userName == null) {
      return CustomerProfile();
    }
    final String url = "${AppConfig.baseUrl}/api/v1/user/customer/$userName";
    const uuid = Uuid();
    final transactionId = uuid.v4();

    // var headers = await getAuthHeaders();
    final headers = {
      "Content-type": "application/json",
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
    };
    final response = await httpGet(url, headers: headers);

    // debugPrint(
    //     "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final CustomerProfile customerProfile =
          CustomerProfile.fromJson(jsonData);
      return customerProfile;
    } else {
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<CustomerProfile> fetchCustomerProfileWithAuth(String? userName) async {
    if (userName == null) {
      return CustomerProfile();
    }
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/customer/${userName.trim()}";

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('FETCH PROFILE WITH AUTH ::: $url ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final CustomerProfile customerProfile =
          CustomerProfile.fromJson(jsonData);
      return customerProfile;
    } else {
      // debugPrint(
      //     "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  Future<Map<String, dynamic>> fetchCustomerFollowers(String? userName) async {
    if (userName == null) {
      return {};
    }
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/follow/followers/${userName.trim()}/";

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('FETCH CUSTOMER FOLLOWER ::: $url ${response.body}');
    // debugPrint(
    //     "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<UserFollowers> userFollowers = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData['results']) {
        final UserFollowers userFollower = UserFollowers.fromJson(item);
        userFollowers.add(userFollower);
      }

      // debugPrint("CUSTOMER FOLLOWER COUNT::: ${jsonData['count']} ");
      // debugPrint("CUSTOMER FOLLOWER RESULT::: ${userFollowers.length} ");

      final Map<String, dynamic> result = {
        "count": jsonData['count'],
        "next": jsonData['next'],
        "previous": jsonData['previous'],
        "results": userFollowers
      };
      return result;
    } else {
      // debugPrint(
      //     "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  // Update User Avatar
  Future<CustomerProfile> updateUserAvatar(File? avatar) async {
    // debugPrint('CROPPED IMAGE AVATAR ---> $avatar');

    final User? user = await getUser();
    if (user == null) return Future.error("Try after Some time");
    final headers = await getAuthHeaders();
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/update-avatar/${user.userName!}/";

    if (avatar != null) {
      final avatarPath = avatar.path;
      //create multipart request for POST or PATCH method
      final request = http.MultipartRequest("PATCH", Uri.parse(url));

      //add fields
      request.fields["username"] = user.userName!;
      request.fields["full_name"] = user.fullName!;
      request.fields["avatar"] = user.avatar!;

      //create multipart using filepath, string or bytes.
      final multipartFile =
          await http.MultipartFile.fromPath("avatar", avatarPath);

      //add multipart to request
      request.files.add(multipartFile);
      headers.forEach((k, v) => request.headers[k] = v);
      final response = await request.send();

      if (response.statusCode == 413) {
        return Future.error(
            "Please upload smaller image, This image is too large.");
      }
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(responseBody);

        final CustomerProfile customerProfile = CustomerProfile(
          fullName: jsonData["full_name"],
          userName: jsonData["username"],
          avatar: jsonData["avatar"],
          qrCode: jsonData["qr_code"],
        );
        // debugPrint('UPDATE PICS 1 ---> ${jsonData["full_name"]}');
        // debugPrint('UPDATE PICS 2  ---> ${jsonData["username"]}');
        // debugPrint('UPDATE PICS 3 ---> ${jsonData["avatar"]}');
        // debugPrint('UPDATE PICS 4 ---> ${jsonData["qr_code"]}');

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
    final User? user = await getUser();
    if (user == null) return Future.error("User Not Found");
    final headers = await getAuthHeaders();
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/update-avatar/${user.userName!}/";

    final response = await httpDelete(url, headers: headers);

    // debugPrint(
    //     '   "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- ${response.body}")');
    if (response.statusCode == 204) {
      return true;
    } else {
      return Future.error(
          "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- ${response.body}");
    }
  }

  Future<User> verifyUserDetail(File documentPhoto, File userPhoto) async {
    final headers = await getAuthHeaders();
    final String url = "${AppConfig.baseUrl}/api/v1/user/kyc/";

    if (documentPhoto != null && userPhoto != null) {
      final document = documentPhoto.path;
      final selfie = userPhoto.path;
      //create multipart request for POST or PATCH method
      final request = http.MultipartRequest("PATCH", Uri.parse(url));

      //add fields
      request.fields["document"] = document;
      request.fields["selfie"] = selfie;

      //create multipart using filepath, string or bytes
      final multipartFile1 =
          await http.MultipartFile.fromPath("document", document);
      final multipartFile2 =
          await http.MultipartFile.fromPath("selfie", selfie);

      //add multipart to request
      request.files.add(multipartFile1);
      request.files.add(multipartFile2);
      headers.forEach((k, v) => request.headers[k] = v);
      final response = await request.send();

      final responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(responseBody);

        final User user = await createUser(jsonData);
        return user;
      } else {
        throw responseBody;
      }
    } else {
      throw "Can't get https.";
    }
  }

  // Register the user with the backend servers
  Future<bool> userRegistration(Map<String, dynamic> body) async {
    final Map<String, dynamic> data = {};
    final String url = "${AppConfig.baseUrl}/api/v1/user/account/";
    final headers = getNonAuthHeader();
    final getData = await getDeviceInfo();
    data.addAll(body);

    for (var element in getData.entries) {
      data[element.key] = element.value.toString();
    }

    final data0 = jsonEncode(data);

    // debugPrint('USER REGISTRATION DATA ::: $data0');

    final response = await httpPost(url,
        headers: headers as Map<String, dynamic>?, body: data0);
    // debugPrint('USER REGISTRATION RESPONSE ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    if (AppConfig.enableLogs.value) debugPrint("DATA SENT:- $data");
    // debugPrint(
    //     "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    return Future.error("Error:- ${response.body}");
  }

// it will register the phone number to get OTP
  Future<bool> registerPhoneNumber(String phoneNumber) async {
    final String url = "${AppConfig.baseUrl}/api/v1/sms/register-phone-number/";
    final headers = getNonAuthHeader();
    final data = {
      "phone": phoneNumber,
    };

    // debugPrint('PHONE NUMBER DATA ::: $data');

    final data0 = jsonEncode(data);
    final response = await httpPost(url,
        body: data0, headers: headers as Map<String, dynamic>?);

    // debugPrint('REGISTER PHONE NUMBER RESPONSE ::: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 205) {
      // final jsonData = json.decode(response.body);
      return true;
    } else {
      if (AppConfig.enableLogs.value) debugPrint("DATA SENT:- $data");
      // debugPrint(
      //     "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      final jsonData = json.decode(response.body);
      return Future.error(jsonData["error"]);
    }
  }

  // it will resend OTP for registration the phone number to get OTP
  Future<bool> registerResendOTP(String phoneNumber) async {
    final String url = "${AppConfig.baseUrl}/api/v1/sms/resend-otp/";
    final headers = getNonAuthHeader();
    final data = {
      "phone": phoneNumber,
    };

    // debugPrint('PHONE NUMBER DATA ::: $data');

    final data0 = jsonEncode(data);
    final response = await httpPost(url,
        body: data0, headers: headers as Map<String, dynamic>?);

    // debugPrint(
    //     'RESEND OTP REGISTER PHONE NUMBER RESPONSE ::: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      if (AppConfig.enableLogs.value) debugPrint("DATA SENT:- $data");
      // debugPrint(
      //     "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      final jsonData = json.decode(response.body);
      return Future.error(jsonData["error"]);
    }
  }

  // password reset OTP
  Future<http.Response> passwordResetOtp(String phoneNumber) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/sms/get-password-reset-token/";
    final headers = getNonAuthHeader();
    final data = {
      "phone": phoneNumber,
    };

    // debugPrint('password reset DATA ::: $data');

    final data0 = jsonEncode(data);
    final response = await httpPost(url,
        body: data0, headers: headers as Map<String, dynamic>?);

    // debugPrint('RESET PASSWORD OTP RESPONSE ::: ${response.body}');

    return response;
  }

  Future<bool> canContinueRegistrationWithPhoneNumber(
      {required String phoneNumber}) async {
    final String url = "${AppConfig.baseUrl}/api/v1/user/verify-phone-number/";

    final data = {"phone_number": '+234$phoneNumber'};
    final headers = getNonAuthHeader();

    final response = await httpPost(url,
        headers: headers as Map<String, dynamic>?, body: jsonEncode(data));

    final jsonData = jsonDecode(response.body);

    // debugPrint('PHONE NUMBER DATA ::: $data');
    // debugPrint(
    //     "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
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
    final String url = "${AppConfig.baseUrl}/api/v1/sms/verify/";
    final headers = getNonAuthHeader();
    final data = {
      "phone": phoneNumber,
      "code": otp,
      "password-token": passwordToken,
    };

    // debugPrint('VERIFY PHONE NUMBER DATA ::: $data');

    final data0 = jsonEncode(data);
    final response = await httpPost(url,
        body: data0, headers: headers as Map<String, dynamic>?);

    // debugPrint('VERIFY PHONE NUMBER RESPONSE DATA ::: ${response.body}');

    final jsonData = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final resetToken = jsonData['reset-token'];

      if (resetToken != null) {
        return resetToken;
      } else {
        return 'Successful';
      }
    } else {
      // debugPrint(
      //     "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return Future.error(jsonData);
    }
  }

  // it will verify the phone number to  OTP
  Future<bool> resetPassword(String passwordOne, String passwordTwo,
      String? phoneNumber, String? resetToken) async {
    final String url = "${AppConfig.baseUrl}/api/v1/user/auth/password-reset/";
    final headers = getNonAuthHeader();

    final data = {
      "password1": passwordOne,
      "password2": passwordTwo,
      "reset-token": resetToken,
      "phone-number": phoneNumber,
    };
    // var data = {
    //   "password1": '123457',
    //   "password2": '123457',
    //   "reset-token": '359927',
    //   "phone-number": phoneNumber,
    // };
    final data0 = jsonEncode(data);
    // debugPrint('_data :: $data');
    final response = await httpPatch(url,
        headers: headers as Map<String, dynamic>?, body: data0);
    final jsonData = jsonDecode(response.body);
    // debugPrint(
    //     "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw jsonData;
    }
  }

  Future<Map<String, dynamic>> changePassword(Map<String, dynamic> data) async {
    final String url = "${AppConfig.baseUrl}/api/v1/user/change-password/";
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: data0);
    // debugPrint(
    //     "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Because the jwt expires every 5 minutes we will take note of the time they
      // where  created and the use that to compute the expiration time of the
      // token. So that we will only use the token if its still valid.
      // We play safe and use 4 minutes
      final DateTime now = DateTime.now();
      final int expirationTime =
          getEpochTime(now.add(const Duration(seconds: 220))); // 3.66667 Minute

      final jsonResponse = json.decode(response.body);
      // debugPrint("===> $jsonResponse");

      jsonResponse["expiration"] = expirationTime;
      final Jwt jwt = Jwt.fromJson(jsonResponse);

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
      url = "${AppConfig.baseUrl}/api/v1/user/shipping-address/$customerName/";
    } else {
      url = "${AppConfig.baseUrl}/api/v1/user/address/";
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    final jsonData = jsonDecode(response.body);

    // debugPrint('USER ADDRESS -> $url');
    // debugPrint('USER ADDRESS -> $jsonData');

    if (response.statusCode == 200 || response.statusCode == 201) {
      // debugPrint('USER ADDRESS ::: $jsonData');
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
    final String url = "${AppConfig.baseUrl}/api/v1/user/about/$userName/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('FETCH USER ABOUT INFO RESPONSE ::: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return UserAbout.fromJson(jsonData);
    }
    return UserAbout();
  }

  Future<UserAbout> addOrUpdateUserBio(
      {UserAbout? userAbout, String? nickName}) async {
    final String url = "${AppConfig.baseUrl}/api/v1/user/about/";

    // debugPrint("Files send:-  before Headers");

    final headers = await getAuthHeaders();

    var responseBody;
    var response;

    // debugPrint("Files wallpaper -> ${userAbout?.wallpaper}");

    if (userAbout != null &&
        userAbout.wallpaper != "" &&
        !userAbout.wallpaper.contains("https") &&
        !userAbout.wallpaper.contains("http")) {
      // debugPrint("Files userAbout.wallpaper");

      final request = http.MultipartRequest("PATCH", Uri.parse(url));
      final Map<String, dynamic> data = userAbout.toJson();

      data.forEach((key, value) {
        if (key == "search_keywords") {
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] =
              (value is List<Map> || value is Map) ? jsonEncode(value) : value;
        }
      });

      request.fields['nickname'] = nickName ?? "";
      // debugPrint("Files send:- d ${request.files}");

      //create multipart using filepath, string or bytes
      final multipartFile =
          await http.MultipartFile.fromPath("wallpaper", userAbout.wallpaper);

      //add multipart to request
      request.files.add(multipartFile);

      headers.forEach((k, v) => request.headers[k] = v);

      // debugPrint("Files send:- ${request.files}");
      // debugPrint("Data Send:- ${request.fields}");

      response = await request.send();

      responseBody = await response.stream.bytesToString();
      // debugPrint(
      //     "URL FOR WALLPAPER: $url STATUSCODE:- ${response.statusCode} body:- $responseBody");
    } else {
      Map<String, dynamic> data = {};
      if (userAbout != null) {
        data = userAbout.toJson();
      }
      // debugPrint("USER DATA -->  $data");

      data['nickname'] = nickName;
      final data0 = jsonEncode(data);
      // debugPrint("Data Send:- $data0");
      response = await httpPatch(url, headers: headers, body: data0);

      responseBody = response.body;
      // debugPrint(
      //     "URL: $url STATUSCODE:- ${response.statusCode} body:- $responseBody");
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserAbout.fromJson(jsonDecode(responseBody));
    }
    return Future.error("$responseBody");
  }

  Future<List<StatesModel>> getStates() async {
    final String url = "${AppConfig.baseUrl}/api/v1/user/states";

    final headers = await getAuthHeaders();

    final http.Response response = await httpGet(url, headers: headers);

    // debugPrint('FETCH STATE RESPONSE ::: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List responseBody = jsonDecode(response.body);
      return responseBody.map((e) => StatesModel.fromJson(e)).toList();
    }
    return Future.error("Something went wrong");
  }

  Future<Map<String, dynamic>> updateSimpleUserDetail(
      {String? nickName, String? bio, String? wallpaper}) async {
    final String url = "${AppConfig.baseUrl}/api/v1/user/update-customer/";
    // debugPrint("URL:- $url");
    // debugPrint("URL WALLPAPER:- $wallpaper");

    var response;
    var responseBody;
    final headers = await getAuthHeaders();
    if (wallpaper != null) {
      final request = http.MultipartRequest("PATCH", Uri.parse(url));
      final Map<String, dynamic> data = {"nickname": nickName, "bio": bio};

      data.forEach((key, value) {
        request.fields[key] = value;
      });

      //create multipart using filepath, string or bytes
      final multipartFile =
          await http.MultipartFile.fromPath("wallpaper", wallpaper);

      //add multipart to request
      request.files.add(multipartFile);

      headers.forEach((k, v) => request.headers[k] = v);

      // debugPrint("Files send:- ${request.files}");
      // debugPrint("Data Send:- ${request.fields}");

      response = await request.send();

      responseBody = await response.stream.bytesToString();

      // debugPrint(
      //     "RESPONSE :- STATUS CODE:- ${response.statusCode} BODY:- $responseBody");
    } else {
      final data = {"nickname": nickName, "bio": bio};
      final headers = await getAuthHeaders();
      final data0 = jsonEncode(data);
      response = await httpPatch(url, headers: headers, body: data0);

      responseBody = response.body;
      // debugPrint(
      //     "RESPONSE :- STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final dynamic responseData = jsonDecode(responseBody);
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
    final headers = await getAuthHeaders();
    late String url;

    if (isUserNormalUser) {
      url = "${AppConfig.baseUrl}/api/v1/user/about/";
    } else {
      url = "${AppConfig.baseUrl}/api/v1/user/update-customer/";
    }

    final response = await httpDelete(url, headers: headers);

    // debugPrint('DELETE COVER ::::  ${response.body}');
    if (response.statusCode == 204) {
      return true;
    } else {
      return Future.error(
          "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- ${response.body}");
    }
  }

  Future<bool> addUserAddress(Map data) async {
    final String url = "${AppConfig.baseUrl}/api/v1/user/address/";
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPost(url, headers: headers, body: data0);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // debugPrint("ADDRESS ADDED: ${response.body}");

      return true;
    }
    // debugPrint("address add failed : ${response.body}");
    return true;
  }

  ///Friends List
  Future<Map<String, dynamic>?> contacts(String? next, String? previous) async {
    String url = "${AppConfig.baseUrl}/api/v1/user/contacts/";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    // debugPrint('USER RES CONTACTS :::: $response');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body) ?? {};
      // debugPrint('USER CONTACTS :::: $jsonData');

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"],
      };

      return result;
    } else {
      // debugPrint("${response.statusCode} ${response.body}");
      final jsonData = jsonDecode(response.body);
      throw jsonData;
    }
  }

  Future<List?> fetchMissedContact(
      {required String createdAt, String? conversationId}) async {
    final String url =
        "${AppConfig.chatUrl}/api/v1/chat/fetch-missed-conversations/";

    final headers = await getAuthHeaders();
    // debugPrint("URL:- $url");
    final Map<String, dynamic> data = {
      "conversation_id": conversationId,
      "created_at": DateTime.parse(createdAt).toUtc().toString()
    };

    if (AppConfig.enableLogs.value) debugPrint("DATA SENT:- $data");
    final response =
        await httpPost(url, headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200 || response.statusCode == 201) {
      // debugPrint("STATUSCODE:- ${response.statusCode} BODY:- ${response.body}");
      return jsonDecode(response.body);
    } else {
      // debugPrint(
      //     "URL:- $url STATUSCODE:- ${response.statusCode} RESPONSEBODY:- ${response.body}");
      return null;
    }
  }

  // Fetch user profile
  Future<ChatConversation> fetchContactProfile(String userName) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/connections/${userName.trim()}/";

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      // debugPrint("STATUS CODE:- ${response.statusCode}");
      // debugPrint("response from fetchCustomer = $jsonData");
      final ChatConversation customerProfile =
          ChatConversation.fromJson(jsonData);
      // debugPrint("ChatConversation => ${customerProfile.conversationId}");
      return customerProfile;
    } else {
      // debugPrint(
      //     "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- ${response.body}");
      return Future.error(
          "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- ${response.body}");
    }
  }

  Future<bool> removeFromContactList(CustomerProfile user) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/contacts/remove-from-contact/";
    // debugPrint("URL:- $url");
    final data = {"user": user.userName};
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: data0);
    // debugPrint(
    //     "RESPONSE :- STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // Check if user is the the checker's list of contact
  Future<bool> checkInContactList(String? user, String? checker) async {
    // Note that the checker is the request.user making this request.
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/contacts/check-in-contact/";
    final data = {"checker": checker, "user": user};
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);

    final response = await httpPatch(url, headers: headers, body: data0);
    // debugPrint("data $_data");
    // debugPrint("response ${response.statusCode} ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<bool> checkInRequest(String? user) async {
    // Note that the checker is the request.user making this request.
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/contact-request/check-in-request/";
    final data = {"to_user": user};
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: data0);
    // debugPrint("is In Request List-->${response.body}");
    // debugPrint("is In Request List-->${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<bool> makeContactRequest(CustomerProfile user) async {
    final String url = "${AppConfig.baseUrl}/api/v1/user/contact-request/";
    final data = {"to_user": user.userName};

    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPost(url, headers: headers, body: data0);
    // debugPrint("Data :- $data");
    // debugPrint("response :- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // Block Contact
  Future<Map<String, dynamic>?> listBlockUsers(
      String? next, String? previous) async {
    String url =
        "${AppConfig.baseUrl}/api/v1/user/contacts/list-block-contact/";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final Map<String, dynamic> result = {
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
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/contacts/block-contact/";
    final data = {"user": user.userName};
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: data0);
    log('message......mesaaager  ooooo. ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<bool> unBlockUser(CustomerProfile user) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/contacts/unblock-contact/";
    final data = {"user": user.userName};
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: data0);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // Contact Request
  Future<Map<String, dynamic>?> listContactRequests(
      String? next, String? previous) async {
    String url = "${AppConfig.baseUrl}/api/v1/user/contact-request/";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final Map<String, dynamic> result = {
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
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/contact-request/accept/";
    final data = {"user": user.userName};
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: data0);
    // debugPrint('RES __ ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<bool> cancelOrRejectContactRequest(CustomerProfile user) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/contact-request/cancel-or-reject/";
    final data = {"user": user.userName};
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: data0);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<bool> upgradeUserProfile(Map<String, dynamic> data) async {
    final String url = "${AppConfig.baseUrl}/api/v1/user/upgrade-user-account/";
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPost(url, headers: headers, body: data0);
    // log("Headers:- $headers body :- $data0 URL:- $url statuscode ${response.statusCode}  body:- ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<List?> getUserProfileUpgradeDetails() async {
    final String url = "${AppConfig.baseUrl}/api/v1/user/profile-pricing/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      return jsonData["results"];
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // it will reset the phone number to get OTP
  Future<bool> resetDevice({Map? data}) async {
    // String url = AppConfig.AppConfig.baseUrl + "/api/v1/user/reset-user-device/";
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
    // if (response.statusCode == 200 || response.statusCode == 201) {
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
    // String url = secureAppConfig.baseUrl + "/api/v1/sms/reset-user-device/";
    // var headers = getNonAuthHeader();
    // var data = {
    //   "phone": phoneNumber,
    // };
    // var _data = jsonEncode(data);
    // var response = await httpPost(url, body: _data, headers: headers);
    //
    // debugPrint("RESPONSE=> ${response.body}");
    //
    // if (response.statusCode == 200 || response.statusCode == 201) {
    //   var jsonData = json.decode(response.body);
    final jsonData = {"otp": "123456"};
    return jsonData['otp'];
    // } else {
    //   var jsonData = json.decode(response.body);
    //   return Future.error(jsonData["error"]);
    // }
  }

  // it will verify the phone number to  OTP
  Future<String> verifyOTPForResetDevice(
      String? phoneNumber, String otp) async {
    // String url = AppConfig.baseUrl + "/api/v1/sms/verify";
    // var headers = getNonAuthHeader();
    // var data = {"phone": phoneNumber, "code": otp};
    // var _data = jsonEncode(data);
    // var response = await httpPost(url, body: _data, headers: headers);
    //
    // if (response.statusCode == 200 || response.statusCode == 201) {
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
  //   String url = secureAppConfig.baseUrl +
  //       "/api/v1/user/group-conversation/search-user-contacts?q=$query/";
  //   debugPrint("UR");
  //   var headers = await getAuthHeaders();
  //
  //   var response = await httpGet(url, headers: headers);
  //
  //   if (response.statusCode == 200 || response.statusCode == 201) {
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
    String url =
        "${AppConfig.baseUrl}/api/v1/user/group-conversation/search-user-contacts";

    if (query != "") {
      url = "$url?q=$query/";
    }
    url = Uri.encodeFull(url);
    // debugPrint("URL:- $url");
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"],
      };
      return result;
    } else {
      // debugPrint(
      //     "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  //Follow or unfollow functions
  Future<bool> followOrUnfollowUser(String userName,
      {required bool shouldFollow}) async {
    late String url;
    var response;

    final data = {"followee": userName};

    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);

    if (shouldFollow == true) {
      url = "${AppConfig.baseUrl}/api/v1/user/follow/";
      response = await httpPost(url, headers: headers, body: data0);
    } else {
      url = "${AppConfig.baseUrl}/api/v1/user/follow/unfollow/";
      response = await httpPatch(url, headers: headers, body: data0);
    }

    // debugPrint("FOLLOWEE data :- $url");
    // debugPrint("FOLLOWEE data :- $data");
    // debugPrint("FOLLOWEE response :- ${response.statusCode}");
    // debugPrint("FOLLOWEE response :- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return Future.error('Something went wrong, please try again.');
  }

  Future<BasePaginationModel<List<CustomerProfile>>>
      getFollowingOrFollowersList(
          {required String? nextUrl,
          required String username,
          required bool isFollowingUser}) async {
    late String? url;

    if (nextUrl != null && nextUrl.isNotEmpty) {
      url = getSecureUrl(url: nextUrl);
    }

    if (isFollowingUser == true) {
      url = "${AppConfig.baseUrl}/api/v1/user/follow/following/$username/";
    } else {
      url = "${AppConfig.baseUrl}/api/v1/user/follow/followers/$username/";
    }

    final headers = await getAuthHeaders();
    final Response response = await httpGet(url, headers: headers);

    // debugPrint('FOLLOWING LIST ::: ${response.statusCode}');
    // debugPrint('FOLLOWING LIST ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      final List results = jsonData['results'];

      return BasePaginationModel<List<CustomerProfile>>.fromJson(
        jsonData,
        results.map((e) => CustomerProfile.fromJson(e)).toList(),
      );
    } else {
      return Future.error('Something went wrong, please try again.');
    }
  }

  Future<BasePaginationModel<List<CustomerProfile>>> getListOfSuggestions({
    required String? nextUrl,
  }) async {
    late String? url = "${AppConfig.baseUrl}/api/v1/user/suggestions/";

    if (nextUrl != null && nextUrl.isNotEmpty) {
      url = getSecureUrl(url: nextUrl);
    }

    final headers = await getAuthHeaders();
    final Response response = await httpGet(url, headers: headers);

    // debugPrint('SUGGESTIONS LIST ::: ${response.statusCode}');
    // debugPrint('SUGGESTIONS LIST ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      final List results = jsonData['results'];

      return BasePaginationModel<List<CustomerProfile>>.fromJson(
        jsonData,
        results.map((e) => CustomerProfile.fromJson(e)).toList(),
      );
    } else {
      return Future.error('Something went wrong, please try again.');
    }
  }

  Future<bool> deactivateUserAccount() async {
    final String url = "${AppConfig.baseUrl}/api/v1/user/deactivate-account/";
    // debugPrint("URL:- $url ");
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    if (response.statusCode == 204) {
      // debugPrint(
      //     "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return true;
    } else {
      // debugPrint(
      //     "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return false;
    }
  }

  Future<Map<String, dynamic>?> customizeProfile() async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/customer-profile-menu/";

    final headers = await getAuthHeaders();

    final response = await httpGet(url, headers: headers);
    // debugPrint(
    //     "RESPONSE STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final Map<String, dynamic> result = {"results": jsonData};

      return result;
    }
    return null;
  }

  Future<bool> updateCustomizeProfile(Map<String, dynamic> data) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/customer-profile-menu/";
    // var data = {"user": ''};
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: data0);
    // debugPrint(
    //     "RESPONSE STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }
}
