import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/shopping/models/ShoppingProduct.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/checkout_screen.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/search_user_item_with_filter.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import '../../../data/state_notifier.dart';
import 'models/store.dart';

class ShoppingAuthService extends AuthService {
  Future<Map<String, dynamic>?> getProductListForSuperStore(
      String? next, String? previous,
      {String userName = "black",
      bool todaysDeal = false,
      bool otherDeals = false}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (todaysDeal == true) {
        url = AppConfig.baseUrl + "/api/v1/products/?today_deals=true";
      } else if (otherDeals == true) {
        url = AppConfig.baseUrl + "/api/v1/products/?other_deals=true";
      } else {
        url = AppConfig.baseUrl + "/api/v1/products/by-seller/$userName/";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('STORE URL ---> $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint('STORE URL BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      debugPrint('SHOPPPING AUTH ---> ${jsonData["results"]}');

      List<ShoppingProduct> shoppingProducts = [];
      for (var item in jsonData["results"]) {
        shoppingProducts.add(ShoppingProduct.fromJson(item));
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": shoppingProducts
      };

      return result;
    }

    var jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  // List Products
  Future<List<ShoppingProduct>?> getProductList(String next, String previous,
      {String userName = "black",
      bool todaysDeal = false,
      bool otherDeals = false}) async {
    var url = "";
    if (next == "") {
      if (todaysDeal == true) {
        url = AppConfig.baseUrl + "/api/v1/products/?today_deals=true";
      } else if (otherDeals == true) {
        url = AppConfig.baseUrl + "/api/v1/products/?other_deals=true";
      } else {
        url = AppConfig.baseUrl + "/api/v1/products/by-seller/$userName/";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('STORE URL ---> $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint('STORE URL BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      List<ShoppingProduct> products = [];
      for (var item in jsonData["results"]) {
        products.add(ShoppingProduct.fromJson(item));
      }
      return products;
    }

    var jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  // Get single product
  Future<ShoppingProduct> getShoppingProduct(String id) async {
    var url = AppConfig.baseUrl + "/api/v1/products/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      ShoppingProduct product = ShoppingProduct.fromJson(jsonData);
      return product;
    } else {
      throw jsonData;
    }
  }

  // List the  item with pagination
  Future<Map<String, dynamic>?> searchShoppingProducts(
      String searchedText, String? next, String? previous) async {
    String url =
        AppConfig.baseUrl + "/api/v1/search/products/?search=" + searchedText;
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('SEARCH BODY ---> ${response.body}');

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

  // List the  item with pagination
  Future<Map<String, dynamic>?> searchServices(
      String searchedText, String? next, String? previous) async {
    String url =
        AppConfig.baseUrl + "/api/v1/search/services/?search=" + searchedText;
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('SEARCH BODY ---> ${response.body}');

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

  Future<Map<String, dynamic>?> searchShoppingProductsInSuperStore(
      String searchedText, String? next, String? previous) async {
    String url = AppConfig.baseUrl + "/api/v1/products/?search=" + searchedText;
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('SEARCH BODY ---> ${response.body}');

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
      return null;
    }
  }

  // delete product and service image

  Future<bool> deleteProductOrServiceImage(String imageId) async {
    var url = AppConfig.baseUrl + "/api/v1/images/" + imageId + "/";
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

  Future<ShoppingCartModelFromQrCode?> getShoppingCartDataFromQrCode(
      {required url}) async {
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('SHOPPING CART MODEL ::: ${response.body}');
    if (response.statusCode == 200) {
      ShoppingCartModelFromQrCode shoppingCartModel =
          ShoppingCartModelFromQrCode.fromJson(jsonDecode(response.body));
      return shoppingCartModel;
    } else {
      return null;
      // return Future.error(response.body);
    }
  }

  Future<bool> payForShoppingCart({required String cartId}) async {
    String url = AppConfig.baseUrl +
        "/api/v1/anonymous-shopping-cart/check-out-payment/$cartId/";

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  //Products
  Product createProduct(Map<String, dynamic> item) {
    Product product = Product();
    product.id = item['id'];
    product.cover = item['cover'];
    product.localImages = item['localImages'];
    product.serverImages = product.imageDataToList(item['pictures']);
    product.pictureMap = item['pictures'];
    product.name = item['name'];
    product.qrCode = item['qr_code'];
    product.manufacturer = item['manufacturer'];
    product.isAvailable = item["is_available"];
    product.availableFrom = DateTime.parse(item['available_from']);
    product.description = item['description'];
    product.shortDescription = item["short_description"];
    product.category = item['category'].toString();
    product.condition = item['condition'];
    product.seller = item['seller'];
    product.sellerFullName = item['seller_fullname'] ?? "";
    product.sellerAvatar = item["seller_avatar"];
    product.price = item['price'].toString();
    product.currency = item["currency"];
    product.rating = formatRating(item['rating'] ?? 0.0);
    product.canRate = item["can_rate"] ?? false;
    product.enableInSuperStore = item["enable_in_superstore"] ?? false;
    product.variant = item["variants"] ?? null;
    product.addOns = item["add_ons"] ?? null;

    product.weight = item['weight'] ?? 0.0;
    product.weightSiUnit = item['weight_si_unit'] ?? '';
    product.height = item['height'] ?? 0.0;
    product.heightSiUnit = item['height_si_unit'] ?? '';
    product.width = item["width"] ?? 0.0;
    product.widthSiUnit = item["width_si_unit"] ?? '';
    product.trackInventory = item["track_inventory"] ?? false;
    product.quantity = item["quantity"];
    product.pricePercentageChange = item["price_percentage_change"] ?? 0.0;

    product.isShippable = item['is_shippable'] ?? false;
    // product.discountedPrice = item['discounted_price'] ?? 0;
    product.discountIsActive = item['discount_is_active'] ?? false;
    product.discountType = item['discount_type'] ?? '';
    product.discountValue = item["discount_value"] ?? 0;
    product.oldPrice = item["old_price"] ?? 0;

    return product;
  }

  // List Products
  Future<Map<String, dynamic>?> listOfProduct(
      String? next, String? previous, String? category, bool? channel,
      {String? userName, bool otherDeals = false}) async {
    debugPrint('CALLING PRODUCT');
    debugPrint('CALLING PRODUCT channel::: ${channel}');
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (otherDeals == true) {
        url = AppConfig.baseUrl + "/api/v1/products/?other_deals=true";
      } else {
        url =
            AppConfig.baseUrl + "/api/v1/products/by-seller/" + userName! + "/";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    if (category != "") {
      var cat = messageDecoderWithEmoji(category);
      if (category == "All") {
        url = AppConfig.baseUrl + "/api/v1/products/?other_deals=true";
      } else {
        url += AppConfig.baseUrl + "/api/v1/products/&categories=$cat/";
      }
    }

    if(channel == true){
      url = AppConfig.baseUrl + "/api/v1/channels-merchandise/$userName";
    }
    debugPrint(url);
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('CALLING OTHER DEALS ---> ${response.body}');

    if (response.statusCode == 200) {
      if (!response.body.contains('results')) {
        Map<String, dynamic> result = {
          "count": '',
          "next": '',
          "previous": '',
          "results": []
        };

        debugPrint('CALLING OTHER check 2 ---> ${result}');

        return result;
      }
      List<Product> productList = [];
      var jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        Product product = createProduct(item);
        productList.add(product);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": productList
      };

      debugPrint('CALLING OTHER check ---> ${result}');

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Add Product
  Future<List<dynamic>> addProduct(Product product, String channelUsername) async {
    var headers = await getAuthHeaders();
    var url = "${AppConfig.baseUrl}/api/v1/products/";

    if(channelUsername.isNotEmpty){
      url = "${AppConfig.baseUrl}/api/v1/channels-merchandise/$channelUsername/";
    }

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse(url));

    Map<dynamic, dynamic> _data = product.toMap();
    _data["available_from"] = dateToString(product.availableFrom!);
    _data["image_count"] = product.localImages!.length;
    _data.remove('variants');

    if(_data["height"] == null || _data["height"] == 0.0){
      _data['height'] = 0.0;
      _data['height_si_unit'] = '';
    }
    if(_data["weight"] == null || _data["weight"] == 0.0){
      _data['weight'] = 0.0;
      _data['weight_si_unit'] = '';
    }
    if(_data["width"] == null || _data["width"] == 0.0){
      _data['width'] = 0.0;
      _data['width_si_unit'] = '';
    }
    debugPrint('DATA from ---> $_data');

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });


    debugPrint('DATA from two ---> $_data');

    List<MultipartFile> newList = [];

    for (int i = 0; i < product.localImages!.length; i++) {
      debugPrint('DATA from two ---> ${product.localImages![i].path}');
      // Add fields
      request.fields["imagefile_$i"] = product.localImages![i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", product.localImages![i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    debugPrint('DATA from newList ---> $newList');
    // Add multipart to request
    request.files.addAll(newList);

    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    var responseBody = await response.stream.bytesToString();

    debugPrint(
        "URL $url PRODUCT STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

    bool backValue = false;
    if (response.statusCode == 201) {

      debugPrint('DATA from add product ---> ${responseBody}');

      var jsonData = json.decode(responseBody);
      String productId = "";
      if(jsonData['id'] != null || jsonData['id'] != ""){
        productId = jsonData['id'];
        backValue = true;
      }else{
          backValue = true;
      }
      return [backValue, productId];

    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

      throw responseBody;
    }
  }

  // Add Variant
  Future<bool> addVariant(Variant item, String productId) async {
    var headers = await getAuthHeaders();
    var url = AppConfig.baseUrl + "/api/v1/products/$productId/variants/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse(url));

    Map<dynamic, dynamic> _data = item.toMap();
    debugPrint('DATA ---> $_data');
    // _data["available_from"] = dateToString(variant.availableFrom!);
    _data["image_count"] = item.localImages!.length;

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    List<MultipartFile> newList = [];

    debugPrint('DATA from pictures ---> ${item.localImages!.length}');

    for (int i = 0; i < item.localImages!.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = item.localImages![i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", item.localImages![i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    debugPrint('DATA from pictures 2 ---> ${newList}');
    // Add multipart to request
    request.files.addAll(newList);

    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return true;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

      throw responseBody;
    }
  }

  // List the  variant with pagination
  Future<Map<String, dynamic>?> getVariantList(
      String productId, String? next, String? previous) async {
    String url =
        AppConfig.baseUrl + "/api/v1/products/$productId/variants/";

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('SEARCH BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      Map<String, dynamic> result = {
        // "count": jsonData["count"],
        // "next": jsonData["next"],
        // "previous": jsonData["previous"],
        "results": jsonData,
      };
      return result;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // delete single variant
  Future<bool> deleteVariant(String variantId) async {
    var url = AppConfig.baseUrl + "/api/v1/products/variants/$variantId/";
    var headers = await getAuthHeaders();
    var response = await httpDelete(
      url,
      headers: headers,
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // Update Variant
  Future<bool> updateVariant(Variant item, String variantId) async {
    var headers = await getAuthHeaders();
    var url = AppConfig.baseUrl + "/api/v1/products/variants/$variantId/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("PATCH", Uri.parse(url));

    Map<dynamic, dynamic> _data = item.toMap();
    debugPrint('DATA from ---> $_data');
    // _data["available_from"] = dateToString(variant.availableFrom!);
    _data["image_count"] = item.localImages!.length;

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    List<MultipartFile> newList = [];

    debugPrint('DATA from pictures ---> ${item.localImages!.length}');

    for (int i = 0; i < item.localImages!.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = item.localImages![i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", item.localImages![i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    debugPrint('DATA from pictures 2 ---> ${newList}');
    // Add multipart to request
    request.files.addAll(newList);

    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201|| response.statusCode == 200) {
      return true;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

      throw responseBody;
    }
  }

  // Edit Product
  Future<bool> editProduct(Product product, List<dynamic>? productAddOnsList) async {
    var headers = await getAuthHeaders();
    var url = AppConfig.baseUrl + "/api/v1/products/" + product.id.toString() + "/";

    //create multipart request for PATCH method
    var request = http.MultipartRequest("PATCH", Uri.parse(url));

    Map<dynamic, dynamic> _data = product.toMap();
    _data["available_from"] = dateToString(product.availableFrom!);
    _data["image_count"] = product.localImages!.length;

    if(_data["height"] == null || _data["height"] == 0.0){
      _data['height'] = 0.0;
      _data['height_si_unit'] = '';
    }
    if(_data["weight"] == null || _data["weight"] == 0.0){
      _data['weight'] = 0.0;
      _data['weight_si_unit'] = '';
    }
    if(_data["width"] == null || _data["width"] == 0.0){
      _data['width'] = 0.0;
      _data['width_si_unit'] = '';
    }

    if(productAddOnsList!.isNotEmpty){
      List ids = productAddOnsList
          .where((addOn) => addOn.id != null)
          .map((addOn) => addOn.id!)
          .toList();
      _data["add_ons"] = ids;

    }

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });
    List<MultipartFile> newList = [];
    for (int i = 0; i < product.localImages!.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = product.localImages![i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", product.localImages![i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    // Add multipart to request
    request.files.addAll(newList);
    debugPrint('UPDATE PRODUCT FIELDS -> ${_data}');
    headers.forEach((k, v) => request.headers[k] = v);

    var response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    var responseBody = await response.stream.bytesToString();
    debugPrint('UPDATE PRODUCT RESPONSE -> ${responseBody}');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw responseBody;
    }
  }

  // Get single product
  Future<Product> getProduct(String id) async {
    var url = AppConfig.baseUrl + "/api/v1/products/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = json.decode(response.body);
    log("jsonData :- $jsonData");
    if (response.statusCode == 200) {
      Product product = createProduct(jsonData);
      return product;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      throw jsonData;
    }
  }

  Future<Map<String, dynamic>?> getProductOrService(String url) async {
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      return jsonData;
    } else {
      throw jsonData;
    }
  }

  // delete single product
  Future<bool> deleteProduct(String id) async {
    var url = AppConfig.baseUrl + "/api/v1/products/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await httpDelete(
      url,
      headers: headers,
    );

    // debugPrint("fola add product delete ${response.statusCode}");
    // debugPrint("fola add product delete 2 ${response.body}");

    if (response.statusCode == 204) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  //Service
  Service createService(Map<String, dynamic> item) {
    debugPrint("==> $item");
    Service service = Service();
    service.id = item['id'];
    service.cover = item['cover'];
    service.localImages = item['localImages'];
    service.serverImages = service.imageDataToList(item['pictures']);
    service.pictureMap = item['pictures'];
    service.name = item['name'];
    service.qrCode = item['qr_code'];
    service.isAvailable = item["is_available"];
    service.availableFrom = DateTime.parse(item['available_from']);
    service.description = item['description'];
    service.shortDescription = item["short_description"];
    service.category = item['category'];
    service.provider = item['provider'];
    service.providerFullName = item['provider_fullname'] ?? "";
    service.price = item['price'].toString();
    service.currency = item["currency"];
    service.providerAvatar = item["provider_avatar"];
    service.rating = formatRating(item['rating'] ?? 0.0);
    service.canRate = item["can_rate"] ?? false;

    return service;
  }

  // List services
  Future<Map<String, dynamic>?> listOfServices(String? next, String? previous,
      {String? userName, bool otherDeals = false}) async {
    debugPrint('CALLING PRODUCT');
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (otherDeals == true) {
        url = AppConfig.baseUrl + "/api/v1/services/";
      } else {
        url = AppConfig.baseUrl + "/api/v1/services/";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('CALLING OTHER DEALS ---> ${response.body}');

    if (response.statusCode == 200) {
      List<Service> serviceList = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        Service service = createService(item);
        serviceList.add(service);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": serviceList
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // List services by provider
  Future<Map<String, dynamic>?> listServicesByProvider(
      String? next, String? previous,
      {String? userName}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          AppConfig.baseUrl + "/api/v1/services/by-provider/" + userName! + "/";
    } else {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      List<Service> serviceList = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        Service service = createService(item);
        serviceList.add(service);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": serviceList
      };
      return result;
    } else if (response.statusCode == 404) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      List<Service> serviceList = [];

      Map<String, dynamic> result = {
        "count": 0,
        "next": "test",
        "previous": "test",
        "results": serviceList
      };
      return result;
    }
  }

  // addService
  Future<bool> addService(Service service) async {
    var headers = await getAuthHeaders();
    var url = AppConfig.baseUrl + "/api/v1/services/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse(url));

    Map<dynamic, dynamic> _data = service.toMap();
    _data["available_from"] = dateToString(service.availableFrom!);
    _data["image_count"] = service.localImages!.length;

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });
    List<MultipartFile> newList = [];
    for (int i = 0; i < service.localImages!.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = service.localImages![i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
        "imagefile_$i",
        service.localImages![i].path,
      );

      debugPrint('DATA FOR SERVICE -> $_data');
      debugPrint('DATA FOR SERVICE FIELDS -> ${request.fields}');

      // Add multipart to newList
      newList.add(multipartFile);
    }

    // Add multipart to request
    request.files.addAll(newList);
    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      return true;
    } else {
      throw responseBody;
    }
  }

// edit service
  Future<bool> editService(Service service) async {
    var headers = await getAuthHeaders();
    var url =
        AppConfig.baseUrl + "/api/v1/services/" + service.id.toString() + "/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("PATCH", Uri.parse(url));

    Map<dynamic, dynamic> _data = service.toMap();
    _data["available_from"] = dateToString(service.availableFrom!);
    _data["image_count"] = service.localImages!.length;

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    if (service.localImages!.length > 0) {
      List<MultipartFile> newList = [];
      for (int i = 0; i < service.localImages!.length; i++) {
        //add fields
        request.fields["imagefile_$i"] = service.localImages![i].path;

        //create multipart using filepath, string or bytes
        var multipartFile = await http.MultipartFile.fromPath(
            "imagefile_$i", service.localImages![i].path);

        //add multipart to newList
        newList.add(multipartFile);
      }
      //add multipart to request
      request.files.addAll(newList);
    }
    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }

    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      return true;
    } else {
      throw responseBody;
    }
  }

// Get single service
  Future<Service> getService(String id) async {
    var url = AppConfig.baseUrl + "/api/v1/services/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      Service service = createService(jsonData);
      return service;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      throw jsonData;
    }
  }

  // delete single service
  Future<bool> deleteService(String id) async {
    var url = AppConfig.baseUrl + "/api/v1/services/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await httpDelete(
      url,
      headers: headers,
    );
    if (response.statusCode == 204) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // Update Order Status
  Future<bool> updateOrderStatus(String? value, String orderId) async {
    var data = {"status": value};
    var _data = jsonEncode(data);
    var url =
        AppConfig.baseUrl + "/api/v1/order/" + orderId + "/update-status/";
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // Update Order Note
  Future<bool> updateOrderNote(String note, String orderId) async {
    var data = {"note": note};
    var _data = jsonEncode(data);
    var url = AppConfig.baseUrl + "/api/v1/order/" + orderId + "/add-note/";
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // List of Orders
  Future<dynamic> listOrders(String? next, String? previous, String filterValue,
      DateTimeRange? dateTimeRange,
      {required bool isMerchant}) async {
    var url = "";
    if (next == null) {
      return null;
    }

    if (next == "") {
      url = AppConfig.baseUrl + "/api/v1/order/";

      url = url + "?merchant=$isMerchant";

      if (filterValue != "") {
        url = url + "&status=$filterValue";
      }
      if (dateTimeRange != null) {
        DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        String toDate = dateFormat.format(dateTimeRange.end);
        String fromDate = dateFormat.format(dateTimeRange.start);

        if (url.contains('?')) {
          url = url + "&start_date=$fromDate&end_date=$toDate";
        } else {
          url = url + "?start_date=$fromDate&end_date=$toDate";
        }
      }
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('URL ::: $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      List items = [];
      var data = jsonData["results"];

      for (int i = 0; i < data.length; i++) {
        var order = Order.fromJson(data[i]);

        items.add(order);
      }

      jsonData["results"] = items;
      return jsonData;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      debugPrint("STATUS CODE:- ${response.statusCode} ");
      throw json.decode(response.body);
    }
  }

  // Get the shipping options when making an order.
  Future<List<ShippingOptionsModel>> getShippingOptions(
      {required String merchantName}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/shipping-options/public-list/$merchantName/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = jsonDecode(response.body);

    debugPrint('URL :: $url');
    debugPrint('BODY shipping:: ${response.body}');
    debugPrint('STATUS CO  :: ${response.statusCode}');

    if (response.statusCode == 200) {
      List jsonDataResult = jsonData['results'];

      return jsonDataResult
          .map((json) => ShippingOptionsModel.fromJson(json))
          .toList();
    } else {
      debugPrint('BODY shipping 00:: ${response.body}');

      return Future.error(response.body);
    }
  }

  // Get single Order
  Future<dynamic> getOrder(String id) async {
    var url = AppConfig.baseUrl + "/api/v1/order/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = json.decode(response.body);

    if (response.statusCode == 200) {
      log("DATA=> $jsonData");
      List items = [];
      var data = jsonData["results"];
      for (int i = 0; i < data.length; i++) {
        if (data[i]["item"].containsKey("manufacturer")) {
          var product = Product.fromJson(data[i]["item"]);
          items.add({
            "type": "product",
            "item": product,
            "qty": int.parse(data[i]["qty"]),
          });
        }
        if (!data[i]["item"].containsKey("manufacturer")) {
          var service = Service.fromJson(data[i]["item"]);
          items.add({
            "type": "service",
            "item": service,
            "qty": int.parse(data[i]["qty"]),
          });
        }
      }
      return items;
    } else {
      throw jsonData;
    }
  }

  //ShoppingCart
  Future<List> getShoppingCart() async {
    var url = AppConfig.baseUrl + "/api/v1/shopping-cart/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = jsonDecode(response.body);

    debugPrint('fola one jsonData:::: ${jsonData}');

    if (response.statusCode == 200) {
      return getCartItems(jsonData);
    }

    return Future.error("ERROR:- ${response.body}");
  }

  Future<bool> addItemToShoppingCart(Map data) async {
    var url = AppConfig.baseUrl + "/api/v1/shopping-cart/add-item/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> removeItemFromShoppingCart(Map data) async {
    var url = AppConfig.baseUrl + "/api/v1/shopping-cart/remove-item/";
    var _data = jsonEncode(data);
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    } else
      return false;
  }

  //place shopping cart order
  Future<dynamic> placeOrderOfShoppingCart(Map data) async {
    var url = AppConfig.baseUrl + "/api/v1/shopping-cart/";
    var _data = jsonEncode(data);

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers, body: _data);
    var jsonData = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return jsonData;
    } else {
      return null;
    }
  }

  //place single order
  Future<dynamic> placeSingleOrder(Map data) async {
    var url = AppConfig.baseUrl + "/api/v1/shopping-cart/buy-now/";
    var _data = jsonEncode(data);

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers, body: _data);
    var jsonData = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return jsonData;
    } else {
      return null;
    }
  }

  Future<http.Response> createReviewableRecord(
      {required Map<String, dynamic> data}) async {
    var url =
        AppConfig.baseUrl + "/api/v1/social/reviews/create-reviewable-record/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);
    return response;
  }

  List<dynamic> getCartItems(var jsonResponse) {
    List items = [];
    var data = jsonResponse["results"];

    for (int i = 0; i < data.length; i++) {
      if (data[i]["type"] == "product") {
        debugPrint('fola one one:::: ${data[i]["qty"]}');

        // for (int j = 0; j < data[i]["qty"]; j++) {
          var product = Product.fromJson(data[i]);
          items.add(product);

          // debugPrint('fola one jsonData:::: ${product.name}');
        // }
      }
      if (data[i]["type"] == "service") {
        for (int j = 0; j < data[i]["qty"]; j++) {
          var service = Service.fromJson(data[i]);
          items.add(service);
        }
      }
    }
    return items;
  }


  Future<List<dynamic>> ownersOrderProductsAndServices(
      {required String type, required String? userId, String? exclude}) async {
    String urlPart = type == "products"
        ? "sellers-other-products"
        : "providers-other-services";

    var url = "${AppConfig.baseUrl}/api/v1/$type/$urlPart/$userId/";

    if (exclude != null) {
      url += "?exclude=$exclude";
    }

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    List items = [];
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      var data = jsonData["results"];
      for (int i = 0; i < data.length; i++) {
        if (type == "products") {
          var product = Product.fromJson(data[i]);
          items.add(product);
        }
        if (type == "services") {
          var service = Service.fromJson(data[i]);
          items.add(service);
        }
      }
      return items;
    } else if (response.statusCode == 500) {
      return Future.error(
          "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    } else {
      return items;
    }
  }

  // List services
  Future<Map<String, dynamic>?> searchUsersServices(
      String? next, String? previous,
      {SearchItemWithFilterModel? filterOptions}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl +
          "/api/v1/services/by-provider/" +
          filterOptions!.searchedUser!.userName! +
          "/?";
      if (filterOptions.category != "All categories") {
        url = url + "category=${filterOptions.category}";
      }
      if (filterOptions.searchedText!.trim() != "") {
        url = url + "&name__icontains=${filterOptions.searchedText}";
      }
      if (filterOptions.minAmount != null) {
        url = url + "&price__gte=${filterOptions.minAmount}";
      }
      if (filterOptions.maxAmount != null) {
        url = url + "&price__lte=${filterOptions.maxAmount}";
      }
      url = Uri.encodeFull(url);
    } else {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      List<Service> serviceList = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        Service service = createService(item);
        serviceList.add(service);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": serviceList
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      List<Service> serviceList = [];

      Map<String, dynamic> result = {
        "count": 0,
        "next": "test",
        "previous": "test",
        "results": serviceList
      };
      return result;
    }
  }

  // List Products
  Future<Map<String, dynamic>?> searchUsersProducts(
      String? next, String? previous,
      {SearchItemWithFilterModel? filterOptions}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      String userName =
          filterOptions!.userName ?? filterOptions.searchedUser!.userName!;
      url = AppConfig.baseUrl + "/api/v1/products/by-seller/" + userName + "/?";

      if (filterOptions.category != "All categories") {
        url = url + "category=${filterOptions.category}";
      }
      if (filterOptions.searchedText!.trim() != "") {
        url = url + "&name__icontains=${filterOptions.searchedText}";
      }
      if (filterOptions.minAmount != null) {
        url = url + "&price__gte=${filterOptions.minAmount}";
      }
      if (filterOptions.maxAmount != null) {
        url = url + "&price__lte=${filterOptions.maxAmount}";
      }

      debugPrint('SEARCH FILTER URL ---> $url');
      url = Uri.encodeFull(url);
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint('SEARCH FILTER STATUS CODE ---> ${response.statusCode}');
    debugPrint('SEARCH FILTER BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      List<Product> productList = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        Product product = createProduct(item);
        productList.add(product);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": productList
      };
      debugPrint("result:- $result");
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      List<Product> productList = [];
      Map<String, dynamic> result = {
        "count": 0,
        "next": "test",
        "previous": "test",
        "results": productList
      };
      return result;
    }
  }

  Future<Map<String, dynamic>?> searchUsersProductsInSuperStore(
      String? next, String? previous,
      {required SearchItemWithFilterModelForSuperStore filterOptions}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    debugPrint('SORT BY Search -> ${filterOptions.sortBy}');

    if (next == "") {
      url = AppConfig.baseUrl +
          "/api/v1/products/?search=${filterOptions.searchedText}";

      if (filterOptions.minPrice != null) {
        url = url + "&min_price=${filterOptions.minPrice}";
      }
      if (filterOptions.maxPrice != null) {
        url = url + "&max_price=${filterOptions.maxPrice}";
      }
      if (filterOptions.rating != null) {
        url = url + "&rating=${filterOptions.rating}";
      }
      if (filterOptions.categories.isNotEmpty) {
        url = url + "&categories=${filterOptions.categories.join(',')}";
      }
      if (filterOptions.sortBy != null) {
        url = url + "&sort_by=${filterOptions.sortBy}";
      }

      url = Uri.encodeFull(url);
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('SEARCH FILTER URL ---> $url');

    debugPrint(url);
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint('SEARCH FILTER STATUS CODE ---> ${response.statusCode}');
    debugPrint('SEARCH FILTER BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      List<Product> productList = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        Product product = createProduct(item);
        productList.add(product);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": productList
      };
      debugPrint("result:- $result");
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      List<Product> productList = [];
      Map<String, dynamic> result = {
        "count": 0,
        "next": "test",
        "previous": "test",
        "results": productList
      };
      return result;
    }
  }

  // Search Services

  Future<Map<String, dynamic>?> searchServiceInServices(
      String? next, String? previous,
      {required SearchItemWithFilterModelForSuperStore filterOptions}) async {
    print('SEARCH FILTER BODY ........');
    var url = "";
    if (next == null) {
      return null;
    }
    debugPrint('SORT BY Search -> ${filterOptions.sortBy}');

    if (next == "") {
      url = AppConfig.baseUrl +
          "/api/v1/services/?search=${filterOptions.searchedText}";

      if (filterOptions.minPrice != null) {
        url = url + "&min_price=${filterOptions.minPrice}";
      }
      if (filterOptions.maxPrice != null) {
        url = url + "&max_price=${filterOptions.maxPrice}";
      }
      if (filterOptions.rating != null) {
        url = url + "&rating=${filterOptions.rating}";
      }
      if (filterOptions.categories.isNotEmpty) {
        url = url + "&categories=${filterOptions.categories.join(',')}";
      }
      if (filterOptions.sortBy != null) {
        url = url + "&sort_by=${filterOptions.sortBy}";
      }

      url = Uri.encodeFull(url);
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('SEARCH FILTER URL ---> $url');

    debugPrint(url);
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint('SEARCH FILTER STATUS CODE ---> ${response.statusCode}');
    debugPrint('SEARCH FILTER BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      List<Service> serviceList = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        Service service = createService(item);
        serviceList.add(service);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": serviceList
      };
      debugPrint("result:- $result");
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      List<Product> productList = [];
      Map<String, dynamic> result = {
        "count": 0,
        "next": "test",
        "previous": "test",
        "results": productList
      };
      return result;
    }
  }

  Future<List<ServiceCategory>> getServiceCategories() async {
    var url = AppConfig.baseUrl + "/api/v1/services/choices/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<dynamic> results = jsonData["results"];

      List<ServiceCategory> categories = [];

      for (int i = 0; i < results.length; i++) {
        categories.add(ServiceCategory(messageDecoderWithEmoji(results[i])!));
      }

      return categories;
    } else {
      debugPrint(
          "URL: $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
      return Future.value(<ServiceCategory>[]);
    }
  }

  Future<List<ProductCategory>> getProductCategories() async {
    var url = AppConfig.baseUrl + "/api/v1/products/choices/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint(
        "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<dynamic> results = jsonData["results"];

      List<ProductCategory> categories = [];

      for (int i = 0; i < results.length; i++) {
        categories.add(ProductCategory(messageDecoderWithEmoji(results[i])!));
      }

      return categories;
    } else {
      debugPrint(
          "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
      return Future.value(<ProductCategory>[]);
    }
  }

 
  Future<List<ServiceCategory>> getServicesCategories() async {
    var url = AppConfig.baseUrl + "/api/v1/services/choices/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    

    debugPrint(
        "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
      
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      List<dynamic> results = jsonData["results"];

      List<ServiceCategory> categories = [];

      for (int i = 0; i < results.length; i++) {
        categories.add(ServiceCategory(messageDecoderWithEmoji(results[i])!));
      }

      return categories;
    } else {
      debugPrint(
          "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
          
      return Future.value(<ServiceCategory>[]);
    }
  }

  // merchant list
  Future<Map<String, dynamic>?> listOfMerchant(
      String? next, String? previous, String category,
      {String? userName, bool nearBy = false}) async {
    debugPrint('CALLING MERCHANT LIST');

    var url = '';
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (nearBy == true) {
        url = "${AppConfig.baseUrl}/api/v1/user/merchant-list/?nearby=true";
      } else if (nearBy == false) {
        url =
            "${AppConfig.baseUrl}/api/v1/user/merchant-list/?suggestions=true";
      }
      if (category == '' || category == 'All') {
        // url = "${AppConfig.baseUrl}/api/v1/user/merchant-list/";
      } else {
        url += "?categories=$category/";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint(url);
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('CALLING OTHER MERCHANT LIST ---> ${response.body}');

    if (response.statusCode == 200) {
      List<CustomerProfile> customerProfileList = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        // debugPrint('MERCHANT LIST 000---> ${item}');

        CustomerProfile customerProfile = CustomerProfile.fromJson(item);

        debugPrint('MERCHANT LIST 000---> ${customerProfile.toJson()}');
        // debugPrint('MERCHANT LIST 001---> ${item}');

        customerProfileList.add(customerProfile);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": customerProfileList
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  //search filter for merchant
  Future<Map<String, dynamic>?> searchMerchant(String? next, String? previous,
      {required SearchItemWithFilterModelForSuperStore filterOptions}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    debugPrint('STATE BY Search -> ${filterOptions.state}');

    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/user/merchant-list/";

      if (filterOptions.searchedText!.isNotEmpty) {
        url += '?search=${filterOptions.searchedText}';
      } else {
        url += '?search=${filterOptions.searchedText}';
      }

      if (filterOptions.categories.isNotEmpty) {
        url += '&categories=${filterOptions.categories.join(',')}';
      }

      if (filterOptions.state.isNotEmpty) {
        url += '&state=${filterOptions.state.join(',')}';
      }

      if (filterOptions.lga.isNotEmpty) {
        url += '&city=${filterOptions.lga.join(',')}';
      }

      url = Uri.encodeFull(url);
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('SEARCH FILTER URL ---> $url');

    debugPrint(url);
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint('SEARCH FILTER STATUS CODE ---> ${response.statusCode}');
    // debugPrint('SEARCH FILTER BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      List<CustomerProfile> customerProfileList = [];
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        CustomerProfile customerProfile = CustomerProfile.fromJson(item);

        debugPrint('SEARCH FILTER BODY ---> ${customerProfile.toJson()}');

        customerProfileList.add(customerProfile);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": customerProfileList
      };
      debugPrint("result:- $result");
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      List<CustomerProfile> customerProfileList = [];
      Map<String, dynamic> result = {
        "count": 0,
        "next": "test",
        "previous": "test",
        "results": customerProfileList
      };
      return result;
    }
  }

  // List the  add-on with pagination
  Future<dynamic> getAddOnsList(
      String productId, String? next, String? previous) async {
    String url =
        AppConfig.baseUrl + "/api/v1/products/add-ons/";

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('Add-Ons BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      List items = [];
      var data = jsonData["results"];

      for (int i = 0; i < data.length; i++) {
        var addOn = AddOns.fromJson(data[i]);
        items.add(addOn);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": items
      };

      // jsonData["results"] = items;
      return result;

    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // List the  add-on options with pagination
  Future<dynamic> getAddOnOptionsList(
      String productId, String? next, String? previous) async {
    String url =
        AppConfig.baseUrl + "/api/v1/products/add-on-options/";

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('Add-On Options BODY ---> ${response.body}');

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      List items = [];
      var data = jsonData["results"];

      for (int i = 0; i < data.length; i++) {
        var addOnOptions = AddOnOption.fromJson(data[i]);
        items.add(addOnOptions);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": items
      };

      // jsonData["results"] = items;
      return result;

    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }


  // Create Addon option
  Future<dynamic> createAddOnOption(AddOnOption addOnOption, String productId) async {
    var url = AppConfig.baseUrl + "/api/v1/products/add-on-options/";

    var headers = await getAuthHeaders();

    var request = http.MultipartRequest("POST", Uri.parse(url));

    request.fields["name"] = addOnOption.name!;
    request.fields["description"] = addOnOption.description!;
    request.fields["is_available"] =jsonEncode(addOnOption.isAvailable);
    request.fields["price"] = addOnOption.price!;

    if (addOnOption.picture != null) {
      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath("picture", addOnOption.picture!);

      // Add multipart to request
      request.files.add(multipartFile);
    }

    debugPrint('createAddOnOption FIELDS -> ${request.fields}');

    headers.forEach((k, v) => request.headers[k] = v);

    request.fields.forEach((key, value) {
      debugPrint("$key :- $value");
    });

    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller image, Your image is too large.");
    }
    var responseBody = await response.stream.bytesToString();
    debugPrint("$responseBody");

    if (response.statusCode == 201) {
      debugPrint("DATA:- ${request.fields}");
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");

      AddOnOption addOnOption = AddOnOption.fromJson(jsonDecode(responseBody));

      return addOnOption;
    } else {
      debugPrint("DATA:- ${request.fields}");
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");
      return Future.error("ERROR:- $responseBody");
    }

  }

  // Create Addon
  Future<dynamic> createAddOn(AddOns addOns, String productId) async {
    var url = AppConfig.baseUrl + "/api/v1/products/add-ons/";

    var headers = await getAuthHeaders();

    var request = http.Request("POST", Uri.parse(url));

    List<int?> idList = addOns.options!.map((option) => option.id).toList();
    request.body = json.encode({
      "name": addOns.name!,
      "description": addOns.description!,
      "is_required": addOns.isRequired,
      "select_type": addOns.selectType!.toLowerCase(),
      "options": idList
    });


    // debugPrint('DATA from ---> ${request.body}');

    headers.forEach((k, v) => request.headers[k] = v);


    var response = await request.send();

    var responseBody = await response.stream.bytesToString();
    debugPrint("$responseBody");

    if (response.statusCode == 201) {
      // debugPrint("DATA:- ${request.fields}");
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");

      var jsonData = jsonDecode(responseBody);

      AddOns addOns = AddOns();
      addOns.id = jsonData['id'];
      addOns.name = jsonData['name'];
      addOns.description = jsonData['description'];
      addOns.inputType = jsonData['input_type'];
      addOns.selectType = jsonData['select_type'];
      addOns.isRequired = jsonData['is_required'];

      List<AddOnOption> options = [];

      for(var item in jsonData['options']){
        AddOnOption addOnOption = AddOnOption();
        addOnOption.id = item;
        addOnOption.name = "";
        addOnOption.description = "";
        addOnOption.picture = "";
        addOnOption.merchant = "";
        addOnOption.price = "";
        addOnOption.currency = "";
        options.add(addOnOption);
      }

      addOns.options = options;

      return addOns;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");
      return Future.error("ERROR:- $responseBody");
    }

  }

  // delete Add-on
  Future<bool> deleteAddOn(int? id) async {
    var url = AppConfig.baseUrl + "/api/v1/products/add-ons/$id/";
    var headers = await getAuthHeaders();
    var response = await httpDelete(
      url,
      headers: headers,
    );

    debugPrint(
        "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
    if (response.statusCode == 204) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // delete Add-on option
  Future<bool> deleteAddOnOption(int? id) async {
    var url = AppConfig.baseUrl + "/api/v1/products/add-on-option/$id/";
    var headers = await getAuthHeaders();
    var response = await httpDelete(
      url,
      headers: headers,
    );

    debugPrint(
        "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
    if (response.statusCode == 204) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // Update Addon
  Future<dynamic> updateAddOn(AddOns addOns, String productId) async {
    var url = AppConfig.baseUrl + "/api/v1/products/add-ons/${addOns.id}/";

    var headers = await getAuthHeaders();

    var request = http.Request("PATCH", Uri.parse(url));

    List idList = addOns.options!.map((option) => option.id).toList();
    request.body = json.encode({
      "name": addOns.name!,
      "description": addOns.description!,
      "is_required": addOns.isRequired,
      "select_type": addOns.selectType!.toLowerCase(),
      "options": idList.isNotEmpty ? idList : "null"
    });

    debugPrint('DATA from ---> ${addOns.id}');
    debugPrint('DATA from ---> ${request.body}');

    headers.forEach((k, v) => request.headers[k] = v);

    var response = await request.send();

    var responseBody = await response.stream.bytesToString();
    debugPrint("$responseBody");

    if (response.statusCode == 201 || response.statusCode == 200) {
      // debugPrint("DATA:- ${request.fields}");
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");

      var jsonData = jsonDecode(responseBody);

      AddOns addOns = AddOns();
      addOns.id = jsonData['id'];
      addOns.name = jsonData['name'];
      addOns.description = jsonData['description'];
      addOns.inputType = jsonData['input_type'];
      addOns.selectType = jsonData['select_type'];
      addOns.isRequired = jsonData['is_required'];

      List<AddOnOption> options = [];

      for(var item in jsonData['options']){
        debugPrint("add-on option id:- ${item['id']}");

        AddOnOption addOnOption = AddOnOption.fromJson(item);
        // addOnOption.id = item['id'];
        // addOnOption.name = "";
        // addOnOption.description = "";
        // addOnOption.picture = "";
        // addOnOption.merchant = "";
        // addOnOption.price = "";
        // addOnOption.currency = "";

        options.add(addOnOption);
      }

      addOns.options = options;

      return addOns;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");
      return Future.error("ERROR:- $responseBody");
    }

  }


  // Update Addon option
  Future<dynamic> updateAddOnOption(AddOnOption addOnOption, String productId) async {
    var url = AppConfig.baseUrl + "/api/v1/products/add-on-options/${addOnOption.id}/";

    var headers = await getAuthHeaders();

    var request = http.MultipartRequest("PATCH", Uri.parse(url));

    request.fields["name"] = addOnOption.name!;
    request.fields["description"] = addOnOption.description!;
    request.fields["is_available"] =jsonEncode(addOnOption.isAvailable);
    request.fields["price"] = addOnOption.price!;

    if (addOnOption.picture != null && !addOnOption.picture!.contains("http")) {
      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath("picture", addOnOption.picture!);

      // Add multipart to request
      request.files.add(multipartFile);
    }

    debugPrint('createAddOnOption FIELDS -> ${request.fields}');

    headers.forEach((k, v) => request.headers[k] = v);

    request.fields.forEach((key, value) {
      debugPrint("$key :- $value");
    });

    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller image, Your image is too large.");
    }
    var responseBody = await response.stream.bytesToString();
    debugPrint("$responseBody");

    if (response.statusCode == 201) {
      debugPrint("DATA:- ${request.fields}");
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");

      AddOnOption addOnOption = AddOnOption.fromJson(jsonDecode(responseBody));

      return addOnOption;
    } else {
      debugPrint("DATA:- ${request.fields}");
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");
      return Future.error("ERROR:- $responseBody");
    }

  }

}

class ShoppingCartModelFromQrCode {
  String id;
  int subTotal;
  String status;
  String qrCode;
  int totalPrice;
  int shippingPrice;
  String merchantName;
  String merchantAvatar;
  String merchantCurrency;

  ShoppingCartModelFromQrCode({
    required this.id,
    required this.status,
    required this.qrCode,
    required this.subTotal,
    required this.totalPrice,
    required this.merchantName,
    required this.shippingPrice,
    required this.merchantAvatar,
    required this.merchantCurrency,
  });

  factory ShoppingCartModelFromQrCode.fromJson(Map<String, dynamic> json) {
    return ShoppingCartModelFromQrCode(
      id: json['id'],
      status: json['status'],
      qrCode: json['qr_code'],
      subTotal: json['subtotal'],
      totalPrice: json['total_price'],
      shippingPrice: json['shipping_price'],
      merchantName: json['merchant']['name'] ?? "",
      merchantAvatar: json['merchant']['avatar'] ?? "",
      merchantCurrency: json['merchant']['currency'] ?? "",
    );
  }
}
