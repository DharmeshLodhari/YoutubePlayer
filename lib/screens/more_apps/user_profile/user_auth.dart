import 'dart:convert';
import 'dart:io';

import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class UserAuth extends AuthService {
  // Fetch user profile
  Future<CustomerProfile> fetchCustomerProfile(String userName) async {
    var url = secureBaseUrl + "/api/v1/user/customer/" + userName.trim();
    var uuid = Uuid();
    var transactionId = uuid.v4();
    var headers = {
      "Content-type": "application/json",
      "TransactionId": transactionId,
      "DeviceType": Platform.isAndroid ? "Android" : "IOS",
      "User-Agent": "Slydo-Mobile",
    };
    var response = await http.get(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      CustomerProfile customerProfile = CustomerProfile(
        fullName: jsonData["full_name"],
        userName: jsonData["username"],
        avatar: jsonData["avatar"],
        qrCode: jsonData["qr_code"],
      );
      return customerProfile;
    } else {
      debugPrint(jsonData.toString());
      return null;
    }
  }

  // Update User Avatar
  Future<CustomerProfile> updateCustomerAvatar(File avatar) async {
    User user = await getUser();
    var headers = await getAuthHeaders();
    var url =
        secureBaseUrl + "/api/v1/user/update-avatar/" + user.userName + "/";

    if (avatar != null) {
      var avatarPath = avatar.path;
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("PATCH", Uri.parse(url));

      //add fields
      request.fields["username"] = user.userName;
      request.fields["full_name"] = user.fullName;
      request.fields["avatar"] = user.avatar;

      //create multipart using filepath, string or bytes
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
      if (response.statusCode == 200) {
        var jsonData = json.decode(responseBody);
        CustomerProfile customerProfile = CustomerProfile(
          fullName: jsonData["full_name"],
          userName: jsonData["username"],
          avatar: jsonData["avatar"],
          qrCode: jsonData["qr_code"],
        );
        return customerProfile;
      } else {
        throw responseBody;
      }
    } else {
      throw "Can't get https.";
    }
  }

  Future<User> verifyUserDetail(File documentPhoto, File userPhoto) async {
    var headers = await getAuthHeaders();
    var url = secureBaseUrl + "/api/v1/user/kyc/";

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
  Future<bool> userRegistration(Map _body) async {
    var data = {};
    var url = secureBaseUrl + "/api/v1/user/account/";

    // Convert to what the server is expecting
    data["password1"] = _body["password1"];
    data["password2"] = _body["password2"];
    data["full_name"] = _body["fullName"];
    data["phone_number"] = _body["phoneNumber"];

    var response = await http.post(url, body: data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

// it will register the phone number to get OTP
  Future<bool> registerPhoneNumber(String phoneNumber) async {
    var url = secureBaseUrl + "/api/v1/sms/register-phone-number";
    var headers = getNonAuthHeader();
    var data = {
      "phone": phoneNumber,
    };
    var _data = jsonEncode(data);
    var response = await http.post(url, body: _data, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw jsonData;
    }
  }

  // it will verify the phone number to  OTP
  Future<String> verifyPhoneNumber(
      // ignore: non_constant_identifier_names
      String phoneNumber,
      String otp,
      String passwordToken) async {
    var url = secureBaseUrl + "/api/v1/sms/verify";
    var headers = getNonAuthHeader();
    var data = {
      "phone": phoneNumber,
      "code": otp,
      "password-token": passwordToken,
    };
    var _data = jsonEncode(data);
    var response = await http.post(url, body: _data, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      var resetToken = jsonData['reset-token'];
      return resetToken;
    } else {
      throw jsonData;
    }
  }

  // it will verify the phone number to  OTP
  Future<bool> passwordReset(String passwordOne, String passwordTwo,
      String phoneNumber, String resetToken) async {
    var url = secureBaseUrl + "/api/v1/user/auth/password-reset/";
    var headers = getNonAuthHeader();
    var data = {
      "password1": passwordOne,
      "password2": passwordTwo,
      "reset-token": resetToken,
      "phone-number": phoneNumber,
    };
    var _data = jsonEncode(data);
    var response = await http.patch(url, body: _data, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      throw jsonData;
    }
  }

  Future<Address> fetchUserAddress() async {
    var url = secureBaseUrl + "/api/v1/user/address/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    var jsonData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Address.fromJson(jsonData);
    }
    return Address(
        addressLineOne: "",
        addressLineTwo: "",
        city: "",
        state: "",
        country: "",
        countryIsoCode: "NG");
  }

  Future<bool> addUserAddress(Map data) async {
    var url = secureBaseUrl + "/api/v1/user/address/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    debugPrint("address add failed : ${response.body}");
    return true;
  }

  ///Friends List

  Future<Map<String, dynamic>> contacts(String next, String previous) async {
    var url = secureBaseUrl + "/api/v1/user/contacts/";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body) ?? {};

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

  Future<bool> removeFromContactList(CustomerProfile user) async {
    var url = secureBaseUrl + "/api/v1/user/contacts/remove-from-contact/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // Check if user is the the checker's list of contact
  Future<bool> checkInContactList(String user, String checker) async {
    // Note that the checker is the request.user making this request.
    var url = secureBaseUrl + "/api/v1/user/contacts/check-in-contact/";
    var data = {"checker": checker, "user": user};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> checkInRequest(String user) async {
    // Note that the checker is the request.user making this request.
    var url = secureBaseUrl + "/api/v1/user/contact-request/check-in-request/";
    var data = {"to_user": user};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> makeContactRequest(CustomerProfile user) async {
    var url = secureBaseUrl + "/api/v1/user/contact-request/";
    var data = {"to_user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // Block Contact
  Future<Map<String, dynamic>> listBlockUsers(
      String next, String previous) async {
    var url = secureBaseUrl + "/api/v1/user/contacts/list-block-contact/";
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

  Future<bool> blockUser(CustomerProfile user) async {
    var url = secureBaseUrl + "/api/v1/user/contacts/block-contact/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> unBlockUser(CustomerProfile user) async {
    var url = secureBaseUrl + "/api/v1/user/contacts/unblock-contact/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // Contact Request
  Future<Map<String, dynamic>> listContactRequests(
      String next, String previous) async {
    var url = secureBaseUrl + "/api/v1/user/contact-request/";
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

  Future<bool> acceptContactRequest(CustomerProfile user) async {
    var url = secureBaseUrl + "/api/v1/user/contact-request/accept/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> rejectContactRequest(CustomerProfile user) async {
    var url = secureBaseUrl + "/api/v1/user/contact-request/cancel-or-reject/";
    var data = {"user": user.userName};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> upgradeUserProfile(Map<String, dynamic> data) async {
    var url = secureBaseUrl + "/api/v1/user/upgrade-user-account/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);

    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<List> getUserProfileUpgradeDetails() async {
    var url = secureBaseUrl + "/api/v1/user/profile-pricing/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      return jsonData["results"];
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }
}
