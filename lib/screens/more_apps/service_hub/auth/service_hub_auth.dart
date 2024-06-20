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
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/job-service/categories/";
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('STORE URL ---> $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(
      url,
      headers: headers,
    );
    debugPrint('STORE URL BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ListOfCategories.fromJson(json.decode(response.body));
    }

    final jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  // List the search category item with pagination
  Future<Map<String, dynamic>?> getSearchCategoryList(
      String? next, String? previous, String text) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/job-service/categories/?search=$text";
    } else {
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
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  // get active job listing
  Future<ActiveJobListing?> getActiveJobListing(String? next, String? previous,
      {String? category,
      String? search,
      String? sortBy,
      String? priceFrom,
      String? priceTo,
      String? location}) async {
    String url = "/api/v1/job-service/listing/?";
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
      if (sortBy != null && sortBy != '') {
        url = "${url}sort_by=$sortBy&";
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

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    debugPrint('ACTIVE LISTING URL BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ActiveJobListing.fromJson(json.decode(response.body));
    }

    final jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  //get my job list
  Future<MyJobList?> getMyJobListing(String? next, String? previous,
      {String? myJobType, String? userId}) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (myJobType != null) {
        url = "${AppConfig.baseUrl}/api/v1/job-service/job/?$myJobType=$userId";
        debugPrint('my applied $url');
      } else {
        url = "${AppConfig.baseUrl}/api/v1/job-service/job/";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('My Job URL ---> $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    debugPrint('My Job LISTING URL BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MyJobList.fromJson(json.decode(response.body));
    }

    final jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  // get job location list
  Future<JobLocationModel?> getJobLocation(
    String? next,
    String? previous,
  ) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/job-service/locations/";
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('Job Location URL ---> $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    debugPrint('Job Location URL BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return JobLocationModel.fromJson(json.decode(response.body));
    }

    final jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  // get applicant list
  Future<List<JobApplicantModel>?> getApplicantListData(
      String? next, String? previous,
      {String? jobId}) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (jobId != null) {
        url = "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/applicants/";
        debugPrint('my job applicant $url');
      } else {
        url = "${AppConfig.baseUrl}/api/v1/job-service/job/";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('My Job URL ---> $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    debugPrint('Job APPLICANT LISTING URL BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedResponse = json.decode(response.body);
      return List<JobApplicantModel>.from(
          decodedResponse.map((model) => JobApplicantModel.fromJson(model)));
    }

    final jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  // accept applicant for the job
  Future<dynamic> acceptJobApplicant({String? jobId, Map? data}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/accept-job-applicant/";
    final data0 = jsonEncode(data);
    debugPrint('ACCEPT JOB APPLICANT ::: $data0');

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: data0);

    debugPrint(
        "ACCEPT JOB APPLICANT URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return false;
    }
  }

  // rate and review contractor
  Future<dynamic> rateAndReviewContrator({String? jobId, Map? data}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/rate-contractor/";
    final data0 = jsonEncode(data);
    debugPrint('ACCEPT JOB APPLICANT ::: $data0');

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: data0);

    debugPrint(
        "REVIEW AND RATE URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return false;
    }
  }

  // get rate and review contractor detail
  Future<dynamic> rateAndReviewContratorDetail({String? jobId}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/user-ratings/";

    final headers = await getAuthHeaders();
    final response = await httpGet(
      url,
      headers: headers,
    );

    debugPrint(
        "REVIEW AND RATE URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return false;
    }
  }

  // reject applicant for the job
  Future<dynamic> rejectJobApplicant({String? jobId, Map? data}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/reject-job-applicant/";
    final data0 = jsonEncode(data);
    debugPrint('ACCEPT JOB APPLICANT ::: $data0');

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: data0);

    debugPrint(
        "ACCEPT JOB APPLICANT URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return false;
    }
  }

  Future<JobModel?> createJobRequest(Map data) async {
    // debugPrint('actived $_data');
    final headers = await getAuthHeaders();
    final String url = "${AppConfig.baseUrl}/api/v1/job-service/job/";
    // var _data = jsonEncode(data.toString());
    // debugPrint('PLACE DATA ::: $_data');
    data["picture_count"] = data['localImages'].length;
    debugPrint('actived $data');

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("POST", Uri.parse(url));

    data.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    final List<MultipartFile> newList = [];

    for (int i = 0; i < data['localImages'].length; i++) {
      // Add fields
      request.fields["picturefile_$i"] = data['localImages'][i].path;

      // Create multipart using filepath, string or bytes
      final multipartFile = await http.MultipartFile.fromPath(
          "picturefile_$i", data['localImages'][i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    debugPrint('actived request ${request.files}');

    // Add multipart to request
    request.files.addAll(newList);

    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    final responseBody = await response.stream.bytesToString();
    debugPrint('job create $responseBody');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return JobModel.fromJson(json.decode(responseBody));
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

      throw responseBody;
    }
  }

  // edit job
  Future<JobModel?> editMyJob(Map data, {required String jobId}) async {
    // debugPrint('actived $_data');
    final headers = await getAuthHeaders();
    final String url = "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/";
    // var _data = jsonEncode(data.toString());
    // debugPrint('PLACE DATA ::: $_data');
    data["picture_count"] = data['localImages'].length;
    debugPrint('actived $data');

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("PATCH", Uri.parse(url));

    data.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    final List<MultipartFile> newList = [];

    for (int i = 0; i < data['localImages'].length; i++) {
      // Add fields
      request.fields["picturefile_$i"] = data['localImages'][i].path;

      // Create multipart using filepath, string or bytes
      final multipartFile = await http.MultipartFile.fromPath(
          "picturefile_$i", data['localImages'][i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    debugPrint('actived request ${request.files}');

    // Add multipart to request
    request.files.addAll(newList);

    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    final responseBody = await response.stream.bytesToString();
    debugPrint('job create $responseBody');
    // if (response.statusCode == 200 || response.statusCode == 201) {
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
      final String url = "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/";

      debugPrint('RETREIVE Job URL ---> $url');

      final headers = await getAuthHeaders();
      final response = await httpGet(url, headers: headers);
      debugPrint('RETREIVE Job LISTING URL BODY ---> ${response.body}');

      debugPrint("${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return JobModel.fromJson(json.decode(response.body));
      } else {
        showToast(message: response.body.toString());
        throw response.body;
      }
    } on Exception catch (e) {
      showToast(message: e.toString());
      debugPrint("Error: $e");
    } catch (err) {
      showToast(message: err.toString());
      debugPrint("$err");
    }
    return null;
  }

  // retrieve listed job job
  Future<ActiveListingData?> retreiveListedJob({String? listingId}) async {
    try {
      final String url =
          "${AppConfig.baseUrl}/api/v1/job-service/listing/$listingId/";
      debugPrint('RETREIVE Job URL ---> $url');

      final headers = await getAuthHeaders();
      final response = await httpGet(url, headers: headers);
      debugPrint('RETREIVE Job LISTING URL BODY ---> ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ActiveListingData.fromJson(json.decode(response.body));
      } else {
        showToast(message: response.body.toString());
        throw response.body;
      }
    } on Exception catch (e) {
      showToast(message: e.toString());
      debugPrint("Error: $e");
    } catch (err) {
      showToast(message: err.toString());
      debugPrint("$err");
    }
    return null;
  }

  // create listing job
  Future<dynamic> createListing(Map data) async {
    final String url = "${AppConfig.baseUrl}/api/v1/job-service/listing/";
    final data0 = jsonEncode(data);
    debugPrint('CREATE LISTING ::: $data0');

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: data0);
    final jsonData = jsonDecode(response.body);

    debugPrint(
        "CREATE LISTING URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonData;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return null;
    }
  }

  // remove from listing
  Future<bool> removeJobListing(String? listingId) async {
    final data = {"is_active": false};
    final data0 = jsonEncode(data);
    final String url =
        "${AppConfig.baseUrl}/api/v1/job-service/listing/$listingId/";
    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers, body: data0);
    debugPrint('lister...$response');
    debugPrint('lister. url..$url');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // end job
  Future<bool> endJob(String? jobId) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/end-job/";
    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers);
    debugPrint('end jobber...${response.body} and ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<dynamic> applyForJob(Map data, {String? jobId}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/apply-for-job/";
    final data0 = jsonEncode(data);
    debugPrint('APPLY FOR JOB  ::: $data0');

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: data0);
    final jsonData = jsonDecode(response.body);

    debugPrint(
        "APPLY FOR JOB URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonData;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return null;
    }
  }

  // cancel application
  Future<dynamic> cancelApplicationForJob(Map data, {String? jobId}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/cancel-application/";
    final data0 = jsonEncode(data);
    debugPrint('CANCEL FOR JOB  ::: $data0 and $jobId');

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: data0);
    final jsonData = jsonDecode(response.body);

    debugPrint(
        "APPLY FOR JOB URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonData;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return null;
    }
  }

  // delete My job
  Future<bool> deleteMyJob(String jobId) async {
    final String url = "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/";
    debugPrint("URL:- $url");
    final headers = await getAuthHeaders();
    final response = await httpDelete(url, headers: headers);
    debugPrint("response delete:- ${response.body}");
    debugPrint("response deleter:- ${response.statusCode}");
    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  // delete My job server images
  Future<bool> deleteJobServerImage({String? pictureId, String? jobId}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/job-service/job/${jobId!}/delete-picture/${pictureId!}/";
    debugPrint("URL:- $url");
    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);
    debugPrint("response:- ${response.body}");
    if (response.statusCode == 204) {
      return true;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // get job url
  Future<Map<String, dynamic>?> getJobOrService(String url) async {
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    final jsonData = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonData;
    } else {
      throw jsonData;
    }
  }

  //search my job list
  Future<MyJobList?> searchMyJobListing(String? next, String? previous,
      String? username, String? searchText) async {
    String url = "";
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

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    debugPrint('My Job LISTING URL BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return MyJobList.fromJson(json.decode(response.body));
    }

    final jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }
}
