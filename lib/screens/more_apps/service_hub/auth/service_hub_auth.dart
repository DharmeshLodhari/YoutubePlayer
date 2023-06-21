import 'dart:convert';
import 'dart:developer';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/active_job_listing.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/applicant_list_model.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/create_job_model.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/create_listing_model.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/job_location_model.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/jobs.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/list_of_categories.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/my_job_list_model.dart';
import 'package:Slydo/screens/more_apps/service_hub/models/retrieve_job_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/ShoppingProduct.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/checkout_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/search_user_item_with_filter.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';

// import '../models/store.dart';
//

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
      // if (todaysDeal == true) {
      //   url = AppConfig.baseUrl + "/api/v1/job-service/categories/?today_deals=true";
      // } else if (otherDeals == true) {
      //   url = AppConfig.baseUrl + "/api/v1/job-service/categories/?other_deals=true";
      // } else {
      url = "${AppConfig.baseUrl}/api/v1/job-service/categories/";
      // }
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('STORE URL ---> $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint('STORE URL BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      return ListOfCategories.fromJson(json.decode(response.body));
    }

    var jsonData = json.decode(response.body);
    return Future.error("$jsonData");
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
        // print(object)
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
    var url = "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/accept-job-applicant/";
    var _data = jsonEncode(data);
    debugPrint('ACCEPT JOB APPLICANT ::: $_data');

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers, body: _data);
    var jsonData = jsonDecode(response.body);

    debugPrint(
        "ACCEPT JOB APPLICANT URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return false;
    }
  }

  // reject applicant for the job

  Future<dynamic> rejectJobApplicant({String? jobId, Map? data}) async {
    var url = "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/reject-job-applicant/";
    var _data = jsonEncode(data);
    debugPrint('ACCEPT JOB APPLICANT ::: $_data');

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers, body: _data);
    var jsonData = jsonDecode(response.body);

    debugPrint(
        "ACCEPT JOB APPLICANT URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 201) {
      return jsonData;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return null;
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

  // retreive job

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

      // var jsonData = json.decode(response.body);
      // return Future.error("$jsonData");
    } on Exception catch (e) {
      showToast(message: e.toString());
      print(e);
    } catch (err) {
      // showSnackbar(context, message: message)
      showToast(message: err.toString());
      print(err);
    }
    return null;
  }

  // retreive listed job job

  Future<ActiveListingData?> retreiveListedJob({String? listingId}) async {
    try {
      var url = "${AppConfig.baseUrl}/api/v1/job-service/listing/$listingId/";
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
        return ActiveListingData.fromJson(json.decode(response.body));
      } else {
        showToast(message: response.body.toString());
        throw response.body;
      }

      // var jsonData = json.decode(response.body);
      // return Future.error("$jsonData");
    } on Exception catch (e) {
      showToast(message: e.toString());
      print(e);
    } catch (err) {
      // showSnackbar(context, message: message)
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

  // delete My job

  Future<bool> deleteMyJob(String jobId) async {
    var url = "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/";
    debugPrint("URL:- $url");
    var headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);
    debugPrint("response:- ${response.body}");
    if (response.statusCode == 204) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // delete My job server images

  Future<bool> deleteJobServerImage({String? pictureId, String? jobId}) async {
    var url = "${AppConfig.baseUrl}/api/v1/job-service/job/${jobId!}/delete-picture/${pictureId!}/";
    debugPrint("URL:- $url");
    var headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);
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
}
//   // List Products
//   Future<List<ShoppingProduct>?> getProductList(String next, String previous,
//       {String userName = "black",
//       bool todaysDeal = false,
//       bool otherDeals = false}) async {
//     var url = "";
//     if (next == "") {
//       if (todaysDeal == true) {
//         url = AppConfig.baseUrl + "/api/v1/products/?today_deals=true";
//       } else if (otherDeals == true) {
//         url = AppConfig.baseUrl + "/api/v1/products/?other_deals=true";
//       } else {
//         url = AppConfig.baseUrl + "/api/v1/products/by-seller/$userName/";
//       }
//     } else {
//       url = getSecureUrl(url: next);
//     }

//     debugPrint('STORE URL ---> $url');

//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);
//     debugPrint('STORE URL BODY ---> ${response.body}');

//     if (response.statusCode == 200) {
//       var jsonData = json.decode(response.body);

//       List<ShoppingProduct> products = [];
//       for (var item in jsonData["results"]) {
//         products.add(ShoppingProduct.fromJson(item));
//       }
//       return products;
//     }

//     var jsonData = json.decode(response.body);
//     return Future.error("$jsonData");
//   }

//   // Get single product
//   Future<ShoppingProduct> getShoppingProduct(String id) async {
//     var url = AppConfig.baseUrl + "/api/v1/products/" + id + "/";
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);
//     var jsonData = json.decode(response.body);
//     if (response.statusCode == 200) {
//       ShoppingProduct product = ShoppingProduct.fromJson(jsonData);
//       return product;
//     } else {
//       throw jsonData;
//     }
//   }

//   // List the  item with pagination
//   Future<Map<String, dynamic>?> searchShoppingProducts(
//       String searchedText, String? next, String? previous) async {
//     String url =
//         AppConfig.baseUrl + "/api/v1/search/products/?search=" + searchedText;
//     if (next == null) {
//       return null;
//     }
//     if (next != "") {
//       url = getSecureUrl(url: next);
//     }
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);

//     debugPrint('SEARCH BODY ---> ${response.body}');

//     if (response.statusCode == 200) {
//       var jsonData = json.decode(response.body);

//       Map<String, dynamic> result = {
//         "count": jsonData["count"],
//         "next": jsonData["next"],
//         "previous": jsonData["previous"],
//         "results": jsonData["results"],
//       };
//       return result;
//     } else {
//       var jsonData = json.decode(response.body);
//       throw jsonData;
//     }
//   }

//   // List the  item with pagination
//   Future<Map<String, dynamic>?> searchServices(
//       String searchedText, String? next, String? previous) async {
//     String url =
//         AppConfig.baseUrl + "/api/v1/search/services/?search=" + searchedText;
//     if (next == null) {
//       return null;
//     }
//     if (next != "") {
//       url = getSecureUrl(url: next);
//     }
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);

//     debugPrint('SEARCH BODY ---> ${response.body}');

//     if (response.statusCode == 200) {
//       var jsonData = json.decode(response.body);

//       Map<String, dynamic> result = {
//         "count": jsonData["count"],
//         "next": jsonData["next"],
//         "previous": jsonData["previous"],
//         "results": jsonData["results"],
//       };
//       return result;
//     } else {
//       var jsonData = json.decode(response.body);
//       throw jsonData;
//     }
//   }

//   Future<Map<String, dynamic>?> searchShoppingProductsInSuperStore(
//       String searchedText, String? next, String? previous) async {
//     String url = AppConfig.baseUrl + "/api/v1/products/?search=" + searchedText;
//     if (next == null) {
//       return null;
//     }
//     if (next != "") {
//       url = getSecureUrl(url: next);
//     }
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);

//     debugPrint('SEARCH BODY ---> ${response.body}');

//     if (response.statusCode == 200) {
//       var jsonData = json.decode(response.body);

//       Map<String, dynamic> result = {
//         "count": jsonData["count"],
//         "next": jsonData["next"],
//         "previous": jsonData["previous"],
//         "results": jsonData["results"],
//       };
//       return result;
//     } else {
//       return null;
//     }
//   }

//   // delete product and service image

//   Future<bool> deleteProductOrServiceImage(String imageId) async {
//     var url = AppConfig.baseUrl + "/api/v1/images/" + imageId + "/";
//     debugPrint("URL:- $url");
//     var headers = await getAuthHeaders();
//     var response = await httpDelete(url, headers: headers);
//     debugPrint("response:- ${response.body}");
//     if (response.statusCode == 204) {
//       return true;
//     } else {
//       var jsonData = json.decode(response.body);
//       throw jsonData;
//     }
//   }

//   Future<ShoppingCartModelFromQrCode?> getShoppingCartDataFromQrCode(
//       {required url}) async {
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);

//     debugPrint('SHOPPING CART MODEL ::: ${response.body}');
//     if (response.statusCode == 200) {
//       ShoppingCartModelFromQrCode shoppingCartModel =
//           ShoppingCartModelFromQrCode.fromJson(jsonDecode(response.body));
//       return shoppingCartModel;
//     } else {
//       return null;
//       // return Future.error(response.body);
//     }
//   }

//   Future<bool> payForShoppingCart({required String cartId}) async {
//     String url = AppConfig.baseUrl +
//         "/api/v1/anonymous-shopping-cart/check-out-payment/$cartId/";

//     var headers = await getAuthHeaders();
//     var response = await httpPost(url, headers: headers);

//     if (response.statusCode == 200) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   //Products
//   Product createProduct(Map<String, dynamic> item) {
//     Product product = Product();
//     product.id = item['id'];
//     product.cover = item['cover'];
//     product.localImages = item['localImages'];
//     product.serverImages = product.imageDataToList(item['pictures']);
//     product.pictureMap = item['pictures'];
//     product.name = item['name'];
//     product.qrCode = item['qr_code'];
//     product.manufacturer = item['manufacturer'];
//     product.isAvailable = item["is_available"];
//     product.availableFrom = DateTime.parse(item['available_from']);
//     product.description = item['description'];
//     product.shortDescription = item["short_description"];
//     product.category = item['category'].toString();
//     product.condition = item['condition'];
//     product.seller = item['seller'];
//     product.sellerFullName = item['seller_fullname'] ?? "";
//     product.sellerAvatar = item["seller_avatar"];
//     product.price = item['price'].toString();
//     product.currency = item["currency"];
//     product.rating = formatRating(item['rating'] ?? 0.0);
//     product.canRate = item["can_rate"] ?? false;
//     product.enableInSuperStore = item["enable_in_superstore"] ?? false;

//     return product;
//   }

//   // List Products
//   Future<Map<String, dynamic>?> listOfProduct(String? next, String? previous,
//       {String? userName, bool otherDeals = false}) async {
//     debugPrint('CALLING PRODUCT');
//     var url = "";
//     if (next == null) {
//       return null;
//     }
//     if (next == "") {
//       if (otherDeals == true) {
//         url = AppConfig.baseUrl + "/api/v1/products/?other_deals=true";
//       } else {
//         url =
//             AppConfig.baseUrl + "/api/v1/products/by-seller/" + userName! + "/";
//       }
//     } else {
//       url = getSecureUrl(url: next);
//     }
//     debugPrint(url);
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);

//     debugPrint('CALLING OTHER DEALS ---> ${response.body}');

//     if (response.statusCode == 200) {
//       List<Product> productList = [];
//       var jsonData = json.decode(response.body);
//       for (var item in jsonData["results"]) {
//         Product product = createProduct(item);
//         productList.add(product);
//       }

//       Map<String, dynamic> result = {
//         "count": jsonData["count"],
//         "next": jsonData["next"],
//         "previous": jsonData["previous"],
//         "results": productList
//       };

//       return result;
//     } else if (response.statusCode == 500) {
//       return null;
//     } else {
//       return null;
//     }
//   }

//   // Add Product
//   Future<bool> addProduct(Product product) async {
//     var headers = await getAuthHeaders();
//     var url = AppConfig.baseUrl + "/api/v1/products/";

//     //create multipart request for POST or PATCH method
//     var request = http.MultipartRequest("POST", Uri.parse(url));

//     Map<dynamic, dynamic> _data = product.toMap();
//     debugPrint('DATA ---> $_data');
//     _data["available_from"] = dateToString(product.availableFrom!);
//     _data["image_count"] = product.localImages!.length;

//     _data.forEach((k, v) {
//       request.fields[k] = v.toString();
//     });

//     List<MultipartFile> newList = [];

//     for (int i = 0; i < product.localImages!.length; i++) {
//       // Add fields
//       request.fields["imagefile_$i"] = product.localImages![i].path;

//       // Create multipart using filepath, string or bytes
//       var multipartFile = await http.MultipartFile.fromPath(
//           "imagefile_$i", product.localImages![i].path);

//       // Add multipart to newList
//       newList.add(multipartFile);
//     }

//     // Add multipart to request
//     request.files.addAll(newList);

//     headers.forEach((k, v) => request.headers[k] = v);
//     var response = await request.send();
//     if (response.statusCode == 413) {
//       return Future.error(
//           "Please upload smaller images, One or all of your images are too large.");
//     }
//     var responseBody = await response.stream.bytesToString();
//     if (response.statusCode == 201) {
//       return true;
//     } else {
//       debugPrint(
//           "URL $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

//       throw responseBody;
//     }
//   }

//   // Edit Product
//   Future<bool> editProduct(Product product) async {
//     var headers = await getAuthHeaders();
//     var url =
//         AppConfig.baseUrl + "/api/v1/products/" + product.id.toString() + "/";

//     //create multipart request for POST or PATCH method
//     var request = http.MultipartRequest("PATCH", Uri.parse(url));

//     Map<dynamic, dynamic> _data = product.toMap();
//     _data["available_from"] = dateToString(product.availableFrom!);
//     _data["image_count"] = product.localImages!.length;

//     _data.forEach((k, v) {
//       request.fields[k] = v.toString();
//     });
//     List<MultipartFile> newList = [];
//     for (int i = 0; i < product.localImages!.length; i++) {
//       // Add fields
//       request.fields["imagefile_$i"] = product.localImages![i].path;

//       // Create multipart using filepath, string or bytes
//       var multipartFile = await http.MultipartFile.fromPath(
//           "imagefile_$i", product.localImages![i].path);

//       // Add multipart to newList
//       newList.add(multipartFile);
//     }

//     // Add multipart to request
//     request.files.addAll(newList);
//     debugPrint('UPDATE PRODUCT FIELDS -> ${_data}');
//     headers.forEach((k, v) => request.headers[k] = v);

//     var response = await request.send();

//     if (response.statusCode == 413) {
//       return Future.error(
//           "Please upload smaller images, One or all of your images are too large.");
//     }
//     var responseBody = await response.stream.bytesToString();
//     debugPrint('UPDATE PRODUCT RESPONSE -> ${responseBody}');

//     if (response.statusCode == 200) {
//       return true;
//     } else {
//       throw responseBody;
//     }
//   }

//   // Get single product
//   Future<Product> getProduct(String id) async {
//     var url = AppConfig.baseUrl + "/api/v1/products/" + id + "/";
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);
//     var jsonData = json.decode(response.body);
//     log("jsonData :- $jsonData");
//     if (response.statusCode == 200) {
//       Product product = createProduct(jsonData);
//       return product;
//     } else {
//       debugPrint(
//           "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
//       throw jsonData;
//     }
//   }

//   Future<Map<String, dynamic>?> getProductOrService(String url) async {
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);
//     var jsonData = json.decode(response.body);
//     if (response.statusCode == 200) {
//       return jsonData;
//     } else {
//       throw jsonData;
//     }
//   }

//   // delete single product
//   Future<bool> deleteProduct(String id) async {
//     var url = AppConfig.baseUrl + "/api/v1/products/" + id + "/";
//     var headers = await getAuthHeaders();
//     var response = await httpDelete(
//       url,
//       headers: headers,
//     );

//     if (response.statusCode == 204) {
//       return true;
//     } else {
//       var jsonData = json.decode(response.body);
//       throw jsonData;
//     }
//   }

//   //Service
//   Service createService(Map<String, dynamic> item) {
//     debugPrint("==> $item");
//     Service service = Service();
//     service.id = item['id'];
//     service.cover = item['cover'];
//     service.localImages = item['localImages'];
//     service.serverImages = service.imageDataToList(item['pictures']);
//     service.pictureMap = item['pictures'];
//     service.name = item['name'];
//     service.qrCode = item['qr_code'];
//     service.isAvailable = item["is_available"];
//     service.availableFrom = DateTime.parse(item['available_from']);
//     service.description = item['description'];
//     service.shortDescription = item["short_description"];
//     service.category = item['category'];
//     service.provider = item['provider'];
//     service.providerFullName = item['provider_fullname'] ?? "";
//     service.price = item['price'].toString();
//     service.currency = item["currency"];
//     service.providerAvatar = item["provider_avatar"];
//     service.rating = formatRating(item['rating'] ?? 0.0);
//     service.canRate = item["can_rate"] ?? false;

//     return service;
//   }

//   // List services
//   Future<Map<String, dynamic>?> listOfServices(String? next, String? previous,
//       {String? userName, bool otherDeals = false}) async {
//     debugPrint('CALLING PRODUCT');
//     var url = "";
//     if (next == null) {
//       return null;
//     }
//     if (next == "") {
//       if (otherDeals == true) {
//         url = AppConfig.baseUrl + "/api/v1/services/";
//       } else {
//         url =
//             AppConfig.baseUrl + "/api/v1/services/";
//       }
//     } else {
//       url = getSecureUrl(url: next);
//     }
//     debugPrint(url);
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);

//     debugPrint('CALLING OTHER DEALS ---> ${response.body}');

//     if (response.statusCode == 200) {
//       List<Service> serviceList = [];
//       var jsonData = json.decode(response.body);
//       for (var item in jsonData["results"]) {
//         Service service = createService(item);
//         serviceList.add(service);
//       }

//       Map<String, dynamic> result = {
//         "count": jsonData["count"],
//         "next": jsonData["next"],
//         "previous": jsonData["previous"],
//         "results": serviceList
//       };

//       return result;
//     } else if (response.statusCode == 500) {
//       return null;
//     } else {
//       return null;
//     }
//   }

//   // List services by provider
//   Future<Map<String, dynamic>?> listServicesByProvider(
//       String? next, String? previous,
//       {String? userName}) async {
//     var url = "";
//     if (next == null) {
//       return null;
//     }
//     if (next == "") {
//       url =
//           AppConfig.baseUrl + "/api/v1/services/by-provider/" + userName! + "/";
//     } else {
//       url = getSecureUrl(url: next);
//     }
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);

//     if (response.statusCode == 200) {
//       List<Service> serviceList = [];
//       var jsonData = json.decode(response.body);
//       for (var item in jsonData["results"]) {
//         Service service = createService(item);
//         serviceList.add(service);
//       }

//       Map<String, dynamic> result = {
//         "count": jsonData["count"],
//         "next": jsonData["next"],
//         "previous": jsonData["previous"],
//         "results": serviceList
//       };
//       return result;
//     } else if (response.statusCode == 404) {
//       return jsonDecode(response.body);
//     } else if (response.statusCode == 500) {
//       throw "Server Error";
//     } else {
//       List<Service> serviceList = [];

//       Map<String, dynamic> result = {
//         "count": 0,
//         "next": "test",
//         "previous": "test",
//         "results": serviceList
//       };
//       return result;
//     }
//   }

//   // addService
//   Future<bool> addService(Service service) async {
//     var headers = await getAuthHeaders();
//     var url = AppConfig.baseUrl + "/api/v1/services/";

//     //create multipart request for POST or PATCH method
//     var request = http.MultipartRequest("POST", Uri.parse(url));

//     Map<dynamic, dynamic> _data = service.toMap();
//     _data["available_from"] = dateToString(service.availableFrom!);
//     _data["image_count"] = service.localImages!.length;

//     _data.forEach((k, v) {
//       request.fields[k] = v.toString();
//     });
//     List<MultipartFile> newList = [];
//     for (int i = 0; i < service.localImages!.length; i++) {
//       // Add fields
//       request.fields["imagefile_$i"] = service.localImages![i].path;

//       // Create multipart using filepath, string or bytes
//       var multipartFile = await http.MultipartFile.fromPath(
//         "imagefile_$i",
//         service.localImages![i].path,
//       );

//       debugPrint('DATA FOR SERVICE -> $_data');
//       debugPrint('DATA FOR SERVICE FIELDS -> ${request.fields}');

//       // Add multipart to newList
//       newList.add(multipartFile);
//     }

//     // Add multipart to request
//     request.files.addAll(newList);
//     headers.forEach((k, v) => request.headers[k] = v);
//     var response = await request.send();
//     if (response.statusCode == 413) {
//       return Future.error(
//           "Please upload smaller images, One or all of your images are too large.");
//     }
//     var responseBody = await response.stream.bytesToString();
//     if (response.statusCode == 201) {
//       return true;
//     } else {
//       throw responseBody;
//     }
//   }

// // edit service
//   Future<bool> editService(Service service) async {
//     var headers = await getAuthHeaders();
//     var url =
//         AppConfig.baseUrl + "/api/v1/services/" + service.id.toString() + "/";

//     //create multipart request for POST or PATCH method
//     var request = http.MultipartRequest("PATCH", Uri.parse(url));

//     Map<dynamic, dynamic> _data = service.toMap();
//     _data["available_from"] = dateToString(service.availableFrom!);
//     _data["image_count"] = service.localImages!.length;

//     _data.forEach((k, v) {
//       request.fields[k] = v.toString();
//     });

//     if (service.localImages!.length > 0) {
//       List<MultipartFile> newList = [];
//       for (int i = 0; i < service.localImages!.length; i++) {
//         //add fields
//         request.fields["imagefile_$i"] = service.localImages![i].path;

//         //create multipart using filepath, string or bytes
//         var multipartFile = await http.MultipartFile.fromPath(
//             "imagefile_$i", service.localImages![i].path);

//         //add multipart to newList
//         newList.add(multipartFile);
//       }
//       //add multipart to request
//       request.files.addAll(newList);
//     }
//     headers.forEach((k, v) => request.headers[k] = v);
//     var response = await request.send();
//     if (response.statusCode == 413) {
//       return Future.error(
//           "Please upload smaller images, One or all of your images are too large.");
//     }

//     var responseBody = await response.stream.bytesToString();
//     if (response.statusCode == 200) {
//       return true;
//     } else {
//       throw responseBody;
//     }
//   }

// // Get single service
//   Future<Service> getService(String id) async {
//     var url = AppConfig.baseUrl + "/api/v1/services/" + id + "/";
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);
//     var jsonData = json.decode(response.body);
//     if (response.statusCode == 200) {
//       Service service = createService(jsonData);
//       return service;
//     } else {
//       debugPrint(
//           "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
//       throw jsonData;
//     }
//   }

//   // delete single service
//   Future<bool> deleteService(String id) async {
//     var url = AppConfig.baseUrl + "/api/v1/services/" + id + "/";
//     var headers = await getAuthHeaders();
//     var response = await httpDelete(
//       url,
//       headers: headers,
//     );
//     if (response.statusCode == 204) {
//       return true;
//     } else {
//       var jsonData = json.decode(response.body);
//       throw jsonData;
//     }
//   }

//   // Update Order Status
//   Future<bool> updateOrderStatus(String? value, String orderId) async {
//     var data = {"status": value};
//     var _data = jsonEncode(data);
//     var url =
//         AppConfig.baseUrl + "/api/v1/order/" + orderId + "/update-status/";
//     var headers = await getAuthHeaders();
//     var response = await httpPatch(url, headers: headers, body: _data);
//     if (response.statusCode == 200) {
//       return true;
//     }
//     return false;
//   }

//   // Update Order Note
//   Future<bool> updateOrderNote(String note, String orderId) async {
//     var data = {"note": note};
//     var _data = jsonEncode(data);
//     var url = AppConfig.baseUrl + "/api/v1/order/" + orderId + "/add-note/";
//     var headers = await getAuthHeaders();
//     var response = await httpPatch(url, headers: headers, body: _data);
//     if (response.statusCode == 200) {
//       return true;
//     }
//     return false;
//   }

//   // List of Orders
//   Future<dynamic> listOrders(String? next, String? previous, String filterValue,
//       DateTimeRange? dateTimeRange,
//       {required bool isMerchant}) async {
//     var url = "";
//     if (next == null) {
//       return null;
//     }

//     if (next == "") {
//       url = AppConfig.baseUrl + "/api/v1/order/";

//       url = url + "?merchant=$isMerchant";

//       if (filterValue != "") {
//         url = url + "&status=$filterValue";
//       }
//       if (dateTimeRange != null) {
//         DateFormat dateFormat = DateFormat('yyyy-MM-dd');
//         String toDate = dateFormat.format(dateTimeRange.end);
//         String fromDate = dateFormat.format(dateTimeRange.start);

//         if (url.contains('?')) {
//           url = url + "&start_date=$fromDate&end_date=$toDate";
//         } else {
//           url = url + "?start_date=$fromDate&end_date=$toDate";
//         }
//       }
//     } else {
//       url = getSecureUrl(url: next);
//     }

//     debugPrint('URL ::: $url');

//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);

//     if (response.statusCode == 200) {
//       var jsonData = json.decode(response.body);

//       List items = [];
//       var data = jsonData["results"];

//       for (int i = 0; i < data.length; i++) {
//         var order = Order.fromJson(data[i]);

//         items.add(order);
//       }

//       jsonData["results"] = items;
//       return jsonData;
//     } else if (response.statusCode == 500) {
//       throw "Server Error";
//     } else {
//       debugPrint("STATUS CODE:- ${response.statusCode} ");
//       throw json.decode(response.body);
//     }
//   }

//   // Get the shipping options when making an order.
//   Future<List<ShippingOptionsModel>> getShippingOptions(
//       {required String merchantName}) async {
//     var url = AppConfig.baseUrl +
//         "/api/v1/shipping-options/public-list/$merchantName/";
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);
//     var jsonData = jsonDecode(response.body);

//     debugPrint('URL :: $url');
//     debugPrint('BODY :: ${response.body}');
//     debugPrint('STATUS CO :: ${response.statusCode}');

//     if (response.statusCode == 200) {
//       List jsonDataResult = jsonData['results'];

//       return jsonDataResult
//           .map((json) => ShippingOptionsModel.fromJson(json))
//           .toList();
//     } else {
//       return Future.error(response.body);
//     }
//   }

//   // Get single Order
//   Future<dynamic> getOrder(String id) async {
//     var url = AppConfig.baseUrl + "/api/v1/order/" + id + "/";
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);
//     var jsonData = json.decode(response.body);

//     if (response.statusCode == 200) {
//       log("DATA=> $jsonData");
//       List items = [];
//       var data = jsonData["results"];
//       for (int i = 0; i < data.length; i++) {
//         if (data[i]["item"].containsKey("manufacturer")) {
//           var product = Product.fromJson(data[i]["item"]);
//           items.add({
//             "type": "product",
//             "item": product,
//             "qty": int.parse(data[i]["qty"]),
//           });
//         }
//         if (!data[i]["item"].containsKey("manufacturer")) {
//           var service = Service.fromJson(data[i]["item"]);
//           items.add({
//             "type": "service",
//             "item": service,
//             "qty": int.parse(data[i]["qty"]),
//           });
//         }
//       }
//       return items;
//     } else {
//       throw jsonData;
//     }
//   }

//   //ShoppingCart
//   Future<List> getShoppingCart() async {
//     var url = AppConfig.baseUrl + "/api/v1/shopping-cart/";
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);
//     var jsonData = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       return getCartItems(jsonData);
//     }
//     debugPrint(
//         "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
//     return Future.error("ERROR:- ${response.body}");
//   }

//   Future<bool> addItemToShoppingCart(Map data) async {
//     var url = AppConfig.baseUrl + "/api/v1/shopping-cart/add-item/";
//     var headers = await getAuthHeaders();
//     var _data = jsonEncode(data);
//     var response = await httpPatch(url, headers: headers, body: _data);

//     var jsonData = jsonDecode(response.body);
//     debugPrint("sent data: " + _data.toString());
//     if (response.statusCode == 200) {
//       debugPrint("response" + jsonData.toString());
//       return true;
//     }
//     return false;
//   }

//   Future<bool> removeItemFromShoppingCart(Map data) async {
//     var url = AppConfig.baseUrl + "/api/v1/shopping-cart/remove-item/";
//     var _data = jsonEncode(data);
//     var headers = await getAuthHeaders();
//     var response = await httpPatch(url, headers: headers, body: _data);
//     if (response.statusCode == 200) {
//       var jsonData = jsonDecode(response.body);
//       debugPrint("response" + jsonData.toString());
//       return true;
//     } else
//       return false;
//   }

//   //place shopping cart order
//   Future<dynamic> placeOrderOfShoppingCart(Map data) async {
//     var url = AppConfig.baseUrl + "/api/v1/shopping-cart/";
//     var _data = jsonEncode(data);
//     debugPrint('PLACE DATA ::: $_data');

//     var headers = await getAuthHeaders();
//     var response = await httpPost(url, headers: headers, body: _data);
//     var jsonData = jsonDecode(response.body);

//     debugPrint(
//         "PLACE ORDER URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
//     if (response.statusCode == 201) {
//       return jsonData;
//     } else {
//       debugPrint(
//           "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
//       return null;
//     }
//   }

//   Future<http.Response> createReviewableRecord(
//       {required Map<String, dynamic> data}) async {
//     var url =
//         AppConfig.baseUrl + "/api/v1/social/reviews/create-reviewable-record/";
//     var headers = await getAuthHeaders();
//     var _data = jsonEncode(data);
//     var response = await httpPost(url, headers: headers, body: _data);
//     debugPrint('CREATE REVIEWABLE RECORD ::: ${response.statusCode}');
//     debugPrint('CREATE REVIEWABLE RECORD ::: ${response.body}');
//     return response;
//   }

//   List<dynamic> getCartItems(var jsonResponse) {
//     List items = [];
//     var data = jsonResponse["results"];

//     for (int i = 0; i < data.length; i++) {
//       if (data[i]["type"] == "product") {
//         for (int j = 0; j < data[i]["qty"]; j++) {
//           var product = Product.fromJson(data[i]);
//           items.add(product);
//         }
//       }
//       if (data[i]["type"] == "service") {
//         for (int j = 0; j < data[i]["qty"]; j++) {
//           var service = Service.fromJson(data[i]);
//           items.add(service);
//         }
//       }
//     }
//     return items;
//   }

//   Future<List<dynamic>> ownersOrderProductsAndServices(
//       {required String type, required String? userId, String? exclude}) async {
//     String urlPart = type == "products"
//         ? "sellers-other-products"
//         : "providers-other-services";

//     var url = "${AppConfig.baseUrl}/api/v1/$type/$urlPart/$userId/";

//     if (exclude != null) {
//       url += "?exclude=$exclude";
//     }
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);
//     List items = [];
//     if (response.statusCode == 200) {
//       var jsonData = json.decode(response.body);
//       var data = jsonData["results"];
//       for (int i = 0; i < data.length; i++) {
//         if (type == "products") {
//           var product = Product.fromJson(data[i]);
//           items.add(product);
//         }
//         if (type == "services") {
//           var service = Service.fromJson(data[i]);
//           items.add(service);
//         }
//       }
//       return items;
//     } else if (response.statusCode == 500) {
//       return Future.error(
//           "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
//     } else {
//       return items;
//     }
//   }

//   // List services
//   Future<Map<String, dynamic>?> searchUsersServices(
//       String? next, String? previous,
//       {SearchItemWithFilterModel? filterOptions}) async {
//     var url = "";
//     if (next == null) {
//       return null;
//     }
//     if (next == "") {
//       url = AppConfig.baseUrl +
//           "/api/v1/services/by-provider/" +
//           filterOptions!.searchedUser!.userName! +
//           "/?";
//       if (filterOptions.category != "All categories") {
//         url = url + "category=${filterOptions.category}";
//       }
//       if (filterOptions.searchedText!.trim() != "") {
//         url = url + "&name__icontains=${filterOptions.searchedText}";
//       }
//       if (filterOptions.minAmount != null) {
//         url = url + "&price__gte=${filterOptions.minAmount}";
//       }
//       if (filterOptions.maxAmount != null) {
//         url = url + "&price__lte=${filterOptions.maxAmount}";
//       }
//       url = Uri.encodeFull(url);
//     } else {
//       url = getSecureUrl(url: next);
//     }
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);

//     if (response.statusCode == 200) {
//       List<Service> serviceList = [];
//       var jsonData = json.decode(response.body);
//       for (var item in jsonData["results"]) {
//         Service service = createService(item);
//         serviceList.add(service);
//       }

//       Map<String, dynamic> result = {
//         "count": jsonData["count"],
//         "next": jsonData["next"],
//         "previous": jsonData["previous"],
//         "results": serviceList
//       };
//       return result;
//     } else if (response.statusCode == 500) {
//       throw "Server Error";
//     } else {
//       List<Service> serviceList = [];

//       Map<String, dynamic> result = {
//         "count": 0,
//         "next": "test",
//         "previous": "test",
//         "results": serviceList
//       };
//       return result;
//     }
//   }

//   // List Products
//   Future<Map<String, dynamic>?> searchUsersProducts(
//       String? next, String? previous,
//       {SearchItemWithFilterModel? filterOptions}) async {
//     var url = "";
//     if (next == null) {
//       return null;
//     }
//     if (next == "") {
//       String userName =
//           filterOptions!.userName ?? filterOptions.searchedUser!.userName!;
//       url = AppConfig.baseUrl + "/api/v1/products/by-seller/" + userName + "/?";

//       if (filterOptions.category != "All categories") {
//         url = url + "category=${filterOptions.category}";
//       }
//       if (filterOptions.searchedText!.trim() != "") {
//         url = url + "&name__icontains=${filterOptions.searchedText}";
//       }
//       if (filterOptions.minAmount != null) {
//         url = url + "&price__gte=${filterOptions.minAmount}";
//       }
//       if (filterOptions.maxAmount != null) {
//         url = url + "&price__lte=${filterOptions.maxAmount}";
//       }

//       debugPrint('SEARCH FILTER URL ---> $url');
//       url = Uri.encodeFull(url);
//     } else {
//       url = getSecureUrl(url: next);
//     }
//     debugPrint(url);
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);
//     debugPrint('SEARCH FILTER STATUS CODE ---> ${response.statusCode}');
//     debugPrint('SEARCH FILTER BODY ---> ${response.body}');

//     if (response.statusCode == 200) {
//       List<Product> productList = [];
//       var jsonData = json.decode(response.body);
//       for (var item in jsonData["results"]) {
//         Product product = createProduct(item);
//         productList.add(product);
//       }

//       Map<String, dynamic> result = {
//         "count": jsonData["count"],
//         "next": jsonData["next"],
//         "previous": jsonData["previous"],
//         "results": productList
//       };
//       debugPrint("result:- $result");
//       return result;
//     } else if (response.statusCode == 500) {
//       throw "Server Error";
//     } else {
//       List<Product> productList = [];
//       Map<String, dynamic> result = {
//         "count": 0,
//         "next": "test",
//         "previous": "test",
//         "results": productList
//       };
//       return result;
//     }
//   }

//   Future<Map<String, dynamic>?> searchUsersProductsInSuperStore(
//       String? next, String? previous,
//       {required SearchItemWithFilterModelForSuperStore filterOptions}) async {
//     var url = "";
//     if (next == null) {
//       return null;
//     }
//     debugPrint('SORT BY Search -> ${filterOptions.sortBy}');

//     if (next == "") {
//       url = AppConfig.baseUrl +
//           "/api/v1/products/?search=${filterOptions.searchedText}";

//       if (filterOptions.minPrice != null) {
//         url = url + "&min_price=${filterOptions.minPrice}";
//       }
//       if (filterOptions.maxPrice != null) {
//         url = url + "&max_price=${filterOptions.maxPrice}";
//       }
//       if (filterOptions.rating != null) {
//         url = url + "&rating=${filterOptions.rating}";
//       }
//       if (filterOptions.categories.isNotEmpty) {
//         url = url + "&categories=${filterOptions.categories.join(',')}";
//       }
//       if (filterOptions.sortBy != null) {
//         url = url + "&sort_by=${filterOptions.sortBy}";
//       }

//       url = Uri.encodeFull(url);
//     } else {
//       url = getSecureUrl(url: next);
//     }

//     debugPrint('SEARCH FILTER URL ---> $url');

//     debugPrint(url);
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);
//     debugPrint('SEARCH FILTER STATUS CODE ---> ${response.statusCode}');
//     debugPrint('SEARCH FILTER BODY ---> ${response.body}');

//     if (response.statusCode == 200) {
//       List<Product> productList = [];
//       var jsonData = json.decode(response.body);
//       for (var item in jsonData["results"]) {
//         Product product = createProduct(item);
//         productList.add(product);
//       }

//       Map<String, dynamic> result = {
//         "count": jsonData["count"],
//         "next": jsonData["next"],
//         "previous": jsonData["previous"],
//         "results": productList
//       };
//       debugPrint("result:- $result");
//       return result;
//     } else if (response.statusCode == 500) {
//       throw "Server Error";
//     } else {
//       List<Product> productList = [];
//       Map<String, dynamic> result = {
//         "count": 0,
//         "next": "test",
//         "previous": "test",
//         "results": productList
//       };
//       return result;
//     }
//   }

//   // Search Services

//   Future<Map<String, dynamic>?> searchServiceInServices(
//       String? next, String? previous,
//       {required SearchItemWithFilterModelForSuperStore filterOptions}) async {
//     var url = "";
//     if (next == null) {
//       return null;
//     }
//     debugPrint('SORT BY Search -> ${filterOptions.sortBy}');

//     if (next == "") {
//       url = AppConfig.baseUrl +
//           "/api/v1/services/?search=${filterOptions.searchedText}";

//       if (filterOptions.minPrice != null) {
//         url = url + "&min_price=${filterOptions.minPrice}";
//       }
//       if (filterOptions.maxPrice != null) {
//         url = url + "&max_price=${filterOptions.maxPrice}";
//       }
//       if (filterOptions.rating != null) {
//         url = url + "&rating=${filterOptions.rating}";
//       }
//       if (filterOptions.categories.isNotEmpty) {
//         url = url + "&categories=${filterOptions.categories.join(',')}";
//       }
//       if (filterOptions.sortBy != null) {
//         url = url + "&sort_by=${filterOptions.sortBy}";
//       }

//       url = Uri.encodeFull(url);
//     } else {
//       url = getSecureUrl(url: next);
//     }

//     debugPrint('SEARCH FILTER URL ---> $url');

//     debugPrint(url);
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);
//     debugPrint('SEARCH FILTER STATUS CODE ---> ${response.statusCode}');
//     debugPrint('SEARCH FILTER BODY ---> ${response.body}');

//     if (response.statusCode == 200) {
//       List<Service> serviceList = [];
//       var jsonData = json.decode(response.body);
//       for (var item in jsonData["results"]) {
//         Service service = createService(item);
//         serviceList.add(service);
//       }

//       Map<String, dynamic> result = {
//         "count": jsonData["count"],
//         "next": jsonData["next"],
//         "previous": jsonData["previous"],
//         "results": serviceList
//       };
//       debugPrint("result:- $result");
//       return result;
//     } else if (response.statusCode == 500) {
//       throw "Server Error";
//     } else {
//       List<Product> productList = [];
//       Map<String, dynamic> result = {
//         "count": 0,
//         "next": "test",
//         "previous": "test",
//         "results": productList
//       };
//       return result;
//     }
//   }

//   Future<List<ServiceCategory>> getServiceCategories() async {
//     var url = AppConfig.baseUrl + "/api/v1/services/choices/";
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);
//     if (response.statusCode == 200) {
//       var jsonData = jsonDecode(response.body);

//       List<dynamic> results = jsonData["results"];

//       List<ServiceCategory> categories = [];

//       for (int i = 0; i < results.length; i++) {
//         categories.add(ServiceCategory(messageDecoderWithEmoji(results[i])!));
//       }

//       return categories;
//     } else {
//       debugPrint(
//           "URL: $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
//       return Future.value(<ServiceCategory>[]);
//     }
//   }

//   Future<List<ProductCategory>> getProductCategories() async {
//     var url = AppConfig.baseUrl + "/api/v1/products/choices/";
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);

//     debugPrint(
//         "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
//     if (response.statusCode == 200) {
//       var jsonData = jsonDecode(response.body);

//       List<dynamic> results = jsonData["results"];

//       List<ProductCategory> categories = [];

//       for (int i = 0; i < results.length; i++) {
//         categories.add(ProductCategory(messageDecoderWithEmoji(results[i])!));
//       }

//       return categories;
//     } else {
//       debugPrint(
//           "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
//       return Future.value(<ProductCategory>[]);
//     }
//   }

//   Future<List<ServiceCategory>> getServicesCategories() async {
//     var url = AppConfig.baseUrl + "/api/v1/services/choices/";
//     var headers = await getAuthHeaders();
//     var response = await httpGet(url, headers: headers);

//     debugPrint(
//         "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
//     if (response.statusCode == 200) {
//       var jsonData = jsonDecode(response.body);

//       List<dynamic> results = jsonData["results"];

//       List<ServiceCategory> categories = [];

//       for (int i = 0; i < results.length; i++) {
//         categories.add(ServiceCategory(messageDecoderWithEmoji(results[i])!));
//       }

//       return categories;
//     } else {
//       debugPrint(
//           "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
//       return Future.value(<ServiceCategory>[]);
//     }
//   }

// }

// class ShoppingCartModelFromQrCode {
//   String id;
//   int subTotal;
//   String status;
//   String qrCode;
//   int totalPrice;
//   int shippingPrice;
//   String merchantName;
//   String merchantAvatar;
//   String merchantCurrency;

//   ShoppingCartModelFromQrCode({
//     required this.id,
//     required this.status,
//     required this.qrCode,
//     required this.subTotal,
//     required this.totalPrice,
//     required this.merchantName,
//     required this.shippingPrice,
//     required this.merchantAvatar,
//     required this.merchantCurrency,
//   });

//   factory ShoppingCartModelFromQrCode.fromJson(Map<String, dynamic> json) {
//     return ShoppingCartModelFromQrCode(
//       id: json['id'],
//       status: json['status'],
//       qrCode: json['qr_code'],
//       subTotal: json['subtotal'],
//       totalPrice: json['total_price'],
//       shippingPrice: json['shipping_price'],
//       merchantName: json['merchant']['name'] ?? "",
//       merchantAvatar: json['merchant']['avatar'] ?? "",
//       merchantCurrency: json['merchant']['currency'] ?? "",
//     );
//   }
// }
