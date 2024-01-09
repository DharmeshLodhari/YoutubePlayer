import 'dart:async';
import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/rider_registration/models/kyc_data_model.dart';
import 'package:Slydo/screens/more_apps/rider_registration/models/rider_model.dart';
import 'package:Slydo/screens/more_apps/rider_registration/models/rider_registration_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RiderRegistrationAuthService extends AuthService {
  Future<RiderModel> riderRegister(
      {RiderRegistrationModel? registrationModel}) async {
    var url = "${AppConfig.baseUrl}/api/v1/user/rider-kyc/";
    var headers = await getAuthHeaders();

    if (registrationModel != null) {
      //create multipart request for POST or PATCH method
      var request = http.MultipartRequest("POST", Uri.parse(url));

      //add fields
      request.fields.addAll(registrationModel.toRegisterRider());

      List<http.MultipartFile> files =
          await registrationModel.getMultipartFiles();
      //add multipart to request
      request.files.addAll(files);
      headers.forEach((k, v) => request.headers[k] = v);
      var response = await request.send();

      if (response.statusCode == 413) {
        return Future.error(
            "Please upload smaller image, This image is too large.");
      }
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonData = jsonDecode(responseBody);

        debugPrint('UPDATE ---> $jsonData');

        return RiderModel.fromJson(jsonData);
      } else {
        return Future.error(
            "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- $responseBody");
      }
    }
    return Future.error("Error while updating KYC");
  }

  // Status of KYC
  Future<KYCDataModel> getKYCStatus(String? username) async {
    var url = AppConfig.baseUrl + "/api/v1/user/rider-kyc/$username/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    print('Status of KYC...${response.body} and ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonData = jsonDecode(response.body);
      return KYCDataModel.fromJson(jsonData);
    } else {
      showToast(message: response.body.toString());
      throw response.body;
    }
  }

  Future<KYCDataModel> kycStatus(String? username) async {
    var url = AppConfig.baseUrl + "/api/v1/user/rider-kyc/$username/";
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers);
    print('Status of KYC...${response.body} and ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonData = jsonDecode(response.body);
      return KYCDataModel.fromJson(jsonData);
    } else {
      showToast(message: response.body.toString());
      throw response.body;
    }
  }
}
