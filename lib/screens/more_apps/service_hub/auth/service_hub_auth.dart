import 'dart:convert';
import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/active_job_listing.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/applicant_list_model.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/job_location_model.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/jobs.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/list_of_categories.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/my_job_list_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:http/http.dart';

class ServiceHubAuthService extends AuthService {
  // get list of categories
  Future<ListOfCategories?> getListOfCategories(
    String? next,
    String? previous,
  ) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/job-service/categories/";
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('STORE URL ---> $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(
      url,
      headers: headers,
    );
    debugPrint('STORE URL BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      return ListOfCategories.fromJson(json.decode(response.body));
    }

    var jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  // List the search category item with pagination
  Future<Map<String, dynamic>?> getSearchCategoryList(
      String url, String? next, String? previous) async {
    debugPrint("URl:- $url");
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

  // get active job listing
  Future<ActiveJobListing?> getActiveJobListing(String? next, String? previous,
      {String? category, search, sortby, priceFrom, priceTo, location}) async {
    var url = "/api/v1/job-service/listing/?";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (search != null) {
        url = "${url}search=$search&";
      }
      if (category != null && category != '') {
        url += "category=$category&";
      }
      if (sortby != null && sortby != '') {
        url = "${url}sort_by=$sortby&";
      }
      if (priceFrom != null && priceFrom != '') {
        url += "price_from=$priceFrom&";
      }
      if (priceTo != null && priceTo != '') {
        url += "price_to=$priceTo&";
      }
      if (location != null && location != '') {
        url += "location=$location";
      }
      url = AppConfig.baseUrl + url;
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('ACTIVE STORE URL ---> $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint('ACTIVE LISTING URL BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      return ActiveJobListing.fromJson(json.decode(response.body));
    }

    var jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  //get my job list
  Future<MyJobList?> getMyJobListing(String? next, String? previous,
      {String? myJobType, String? userId}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (myJobType != null) {
        url = "${AppConfig.baseUrl}/api/v1/job-service/job/?$myJobType=$userId";
        print('my applied $url');
      } else {
        url = "${AppConfig.baseUrl}/api/v1/job-service/job/";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('My Job URL ---> $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint('My Job LISTING URL BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      return MyJobList.fromJson(json.decode(response.body));
    }

    var jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  // get job location list
  Future<JobLocationModel?> getJobLocation(
    String? next,
    String? previous,
  ) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/job-service/locations/";
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('Job Location URL ---> $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint('Job Location URL BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      return JobLocationModel.fromJson(json.decode(response.body));
    }

    var jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  // get applicant list
  Future<List<JobApplicantModel>?> getApplicantListData(
      String? next, String? previous,
      {String? jobId}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (jobId != null) {
        url = "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/applicants/";
        print('my job applicant $url');
      } else {
        url = "${AppConfig.baseUrl}/api/v1/job-service/job/";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('My Job URL ---> $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint('Job APPLICANT LISTING URL BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      var decodedResponse = json.decode(response.body);
      return List<JobApplicantModel>.from(
          decodedResponse.map((model) => JobApplicantModel.fromJson(model)));
    }

    var jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  // accept applicant for the job
  Future<dynamic> acceptJobApplicant({String? jobId, Map? data}) async {
    var url =
        "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/accept-job-applicant/";
    var _data = jsonEncode(data);
    debugPrint('ACCEPT JOB APPLICANT ::: $_data');

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers, body: _data);
    var jsonData = jsonDecode(response.body);

    debugPrint(
        "ACCEPT JOB APPLICANT URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return false;
    }
  }

  // reject applicant for the job
  Future<dynamic> rejectJobApplicant({String? jobId, Map? data}) async {
    var url =
        "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/reject-job-applicant/";
    var _data = jsonEncode(data);
    debugPrint('ACCEPT JOB APPLICANT ::: $_data');

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers, body: _data);
    var jsonData = jsonDecode(response.body);

    debugPrint(
        "ACCEPT JOB APPLICANT URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return false;
    }
  }

  Future<JobModel?> createJobRequest(Map _data) async {
    // print('actived $_data');
    var headers = await getAuthHeaders();
    var url = "${AppConfig.baseUrl}/api/v1/job-service/job/";
    // var _data = jsonEncode(data.toString());
    // debugPrint('PLACE DATA ::: $_data');
    _data["picture_count"] = _data['localImages'].length;
    print('actived $_data');

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse(url));

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    List<MultipartFile> newList = [];

    for (int i = 0; i < _data['localImages'].length; i++) {
      // Add fields
      request.fields["picturefile_$i"] = _data['localImages'][i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "picturefile_$i", _data['localImages'][i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    print('actived request ${request.files}');

    // Add multipart to request
    request.files.addAll(newList);

    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    var responseBody = await response.stream.bytesToString();
    print('job create $responseBody');
    if (response.statusCode == 201) {
      return JobModel.fromJson(json.decode(responseBody));
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

      throw responseBody;
    }
  }

  // edit job
  Future<JobModel?> editMyJob(Map _data, {required String jobId}) async {
    // print('actived $_data');
    var headers = await getAuthHeaders();
    var url = "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/";
    // var _data = jsonEncode(data.toString());
    // debugPrint('PLACE DATA ::: $_data');
    _data["picture_count"] = _data['localImages'].length;
    print('actived $_data');

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("PATCH", Uri.parse(url));

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    List<MultipartFile> newList = [];

    for (int i = 0; i < _data['localImages'].length; i++) {
      // Add fields
      request.fields["picturefile_$i"] = _data['localImages'][i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "picturefile_$i", _data['localImages'][i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    print('actived request ${request.files}');

    // Add multipart to request
    request.files.addAll(newList);

    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    var responseBody = await response.stream.bytesToString();
    print('job create $responseBody');
    // if (response.statusCode == 200) {
    //   return JobModel.fromJson(json.decode(responseBody));
    // } else {
    //   debugPrint(
    //       "URL $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

    //   throw responseBody;
    // }

    if (response.statusCode >= 400) {
      throw responseBody;
    }

    return JobModel.fromJson(json.decode(responseBody));
  }

  // retrieve job
  Future<JobModel?> retreiveJob({String? jobId}) async {
    try {
      var url = "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/";
      // if (next == null) {
      //   return null;
      // } else {
      //   url = getSecureUrl(url: next);
      // }
      // url = getSecureUrl(url: next);

      debugPrint('RETREIVE Job URL ---> $url');

      var headers = await getAuthHeaders();
      var response = await httpGet(url, headers: headers);
      debugPrint('RETREIVE Job LISTING URL BODY ---> ${response.body}');
      print(response.statusCode);
      if (response.statusCode == 200) {
        return JobModel.fromJson(json.decode(response.body));
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

  // retrieve listed job job
  Future<ActiveListingData?> retreiveListedJob({String? listingId}) async {
    try {
      var url = "${AppConfig.baseUrl}/api/v1/job-service/listing/$listingId/";
      debugPrint('RETREIVE Job URL ---> $url');

      var headers = await getAuthHeaders();
      var response = await httpGet(url, headers: headers);
      debugPrint('RETREIVE Job LISTING URL BODY ---> ${response.body}');
      print(response.statusCode);
      if (response.statusCode == 200) {
        return ActiveListingData.fromJson(json.decode(response.body));
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

  // create listing job
  Future<dynamic> createListing(Map data) async {
    var url = "${AppConfig.baseUrl}/api/v1/job-service/listing/";
    var _data = jsonEncode(data);
    debugPrint('CREATE LISTING ::: $_data');

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers, body: _data);
    var jsonData = jsonDecode(response.body);

    debugPrint(
        "CREATE LISTING URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 201) {
      return jsonData;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return null;
    }
  }

  // remove from listing
  Future<bool> removeJobListing(String? listingId) async {
    var data = {"is_active": false};
    var _data = jsonEncode(data);
    var url =
        AppConfig.baseUrl + "/api/v1/job-service/listing/" + listingId! + '/';
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<dynamic> applyForJob(Map data, {String? jobId}) async {
    var url =
        "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/apply-for-job/";
    var _data = jsonEncode(data);
    debugPrint('APPLY FOR JOB  ::: $_data');

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers, body: _data);
    var jsonData = jsonDecode(response.body);

    debugPrint(
        "APPLY FOR JOB URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 201) {
      return jsonData;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return null;
    }
  }

  // cancel application
  Future<dynamic> cancelApplicationForJob(Map data, {String? jobId}) async {
    var url =
        "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/cancel-application/";
    var _data = jsonEncode(data);
    debugPrint('CANCEL FOR JOB  ::: $_data and $jobId');

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers, body: _data);
    var jsonData = jsonDecode(response.body);

    debugPrint(
        "APPLY FOR JOB URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200) {
      return jsonData;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return null;
    }
  }

  // delete My job
  Future<bool> deleteMyJob(String jobId) async {
    var url = "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/";
    debugPrint("URL:- $url");
    var headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);
    debugPrint("response:- ${response.body}");
    debugPrint("response:- ${response.statusCode}");
    if (response.statusCode == 204) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      return false;
    }
  }

  // delete My job server images
  Future<bool> deleteJobServerImage({String? pictureId, String? jobId}) async {
    var url =
        "${AppConfig.baseUrl}/api/v1/job-service/job/${jobId!}/delete-picture/${pictureId!}/";
    debugPrint("URL:- $url");
    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers);
    debugPrint("response:- ${response.body}");
    if (response.statusCode == 204) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // get job url
  Future<Map<String, dynamic>?> getJobOrService(String url) async {
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return jsonData;
    } else {
      throw jsonData;
    }
  }

  //search my job list
  Future<MyJobList?> searchMyJobListing(String? next, String? previous,
      String? username, String? searchText) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/job-service/job/?related=$username&search=$searchText";
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('My Search Job URL ---> $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint('My Job LISTING URL BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      return MyJobList.fromJson(json.decode(response.body));
    }

    var jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }
}
