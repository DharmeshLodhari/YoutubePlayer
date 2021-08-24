import 'dart:convert';

import 'package:Slydo/data/enviroment.dart';
import 'package:Slydo/screens/more_apps/shopping/models/ShoppingProduct.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/search_user_item_with_filter.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:http/http.dart';

import 'models/store.dart';

class ShoppingAuthService extends AuthService {
  // List Products
  Future<List<ShoppingProduct>> getProductList(
      String next, String previous) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl + "/api/v1/products/by-seller/black/";
    } else {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      List<ShoppingProduct> products = [];
      for (var item in jsonData["results"]) {
        products.add(ShoppingProduct.fromJson(item));
      }
      return products;
    }

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
  Future<Map<String, dynamic>> searchShoppingProducts(
      String searchedText, String next, String previous) async {
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
    product.sellerAvatar = item["seller_avatar"];
    product.price = item['price'].toString();
    product.currency = item["currency"];
    return product;
  }

  // List Products
  Future<Map<String, dynamic>> listOfProduct(String next, String previous,
      {String userId}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl + "/api/v1/products/by-seller/" + userId + "/";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

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

  // Add Product
  Future<bool> addProduct(Product product) async {
    var headers = await getAuthHeaders();
    var url = AppConfig.baseUrl + "/api/v1/products/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse(url));

    Map<dynamic, dynamic> _data = product.toMap();
    _data["available_from"] = dateToString(product.availableFrom);
    _data["image_count"] = product.localImages.length;

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });
    List<MultipartFile> newList = new List<MultipartFile>();
    for (int i = 0; i < product.localImages.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = product.localImages[i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", product.localImages[i].path);

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

  // Edit Product
  Future<bool> editProduct(Product product) async {
    var headers = await getAuthHeaders();
    var url =
        AppConfig.baseUrl + "/api/v1/products/" + product.id.toString() + "/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("PATCH", Uri.parse(url));

    Map<dynamic, dynamic> _data = product.toMap();
    _data["available_from"] = dateToString(product.availableFrom);
    _data["image_count"] = product.localImages.length;

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });
    List<MultipartFile> newList = new List<MultipartFile>();
    for (int i = 0; i < product.localImages.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = product.localImages[i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", product.localImages[i].path);

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
    if (response.statusCode == 200) {
      Product product = createProduct(jsonData);
      return product;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      throw jsonData;
    }
  }

  Future<Map<String, dynamic>> getProductOrService(String url) async {
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

    if (response.statusCode == 204) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  //Service
  Service createService(Map<String, dynamic> item) {
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
    service.price = item['price'].toString();
    service.currency = item["currency"];
    service.providerAvatar = item["provider_avatar"];

    return service;
  }

  // List services
  Future<Map<String, dynamic>> listServicesByProvider(
      String next, String previous,
      {String userId}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl + "/api/v1/services/by-provider/" + userId + "/";
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

  // addService
  Future<bool> addService(Service service) async {
    var headers = await getAuthHeaders();
    var url = AppConfig.baseUrl + "/api/v1/services/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse(url));

    Map<dynamic, dynamic> _data = service.toMap();
    _data["available_from"] = dateToString(service.availableFrom);
    _data["image_count"] = service.localImages.length;

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });
    List<MultipartFile> newList = new List<MultipartFile>();
    for (int i = 0; i < service.localImages.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = service.localImages[i].path;

      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", service.localImages[i].path);

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
    _data["available_from"] = dateToString(service.availableFrom);
    _data["image_count"] = service.localImages.length;

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    if (service.localImages.length > 0) {
      List<MultipartFile> newList = new List<MultipartFile>();
      for (int i = 0; i < service.localImages.length; i++) {
        //add fields
        request.fields["imagefile_$i"] = service.localImages[i].path;

        //create multipart using filepath, string or bytes
        var multipartFile = await http.MultipartFile.fromPath(
            "imagefile_$i", service.localImages[i].path);

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
  Future<bool> updateOrderStatus(String value, String orderId) async {
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
  Future<dynamic> listOrders(
      String next, String previous, String filterValue) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl + "/api/v1/order/";
      if (filterValue != "" && filterValue != null) {
        url = url + "?status__iexact=$filterValue";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      List items = List();
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
      throw json.decode(response.body);
    }
  }

  // Get single Order
  Future<dynamic> getOrder(String id) async {
    var url = AppConfig.baseUrl + "/api/v1/order/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      List items = List();
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

    if (response.statusCode == 200) {
      return getCartItems(jsonData);
    }
    debugPrint(
        "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
    return Future.error("ERROR:- ${response.body}");
  }

  Future<bool> addItemToShoppingCart(Map data) async {
    var url = AppConfig.baseUrl + "/api/v1/shopping-cart/add-item/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);
    var jsonData = jsonDecode(response.body);
    debugPrint("sent data: " + _data.toString());
    if (response.statusCode == 200) {
      debugPrint("response" + jsonData.toString());
      return true;
    }
    return false;
  }

  Future<bool> removeItemToShoppingCart(Map data) async {
    var url = AppConfig.baseUrl + "/api/v1/shopping-cart/remove-item/";
    var _data = jsonEncode(data);
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      debugPrint("response" + jsonData.toString());
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
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 201) {
      return jsonData;
    } else {
      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    }
  }

  List<dynamic> getCartItems(var jsonResponse) {
    List items = List();
    var data = jsonResponse["results"];

    for (int i = 0; i < data.length; i++) {
      if (data[i]["type"] == "product") {
        for (int j = 0; j < data[i]["qty"]; j++) {
          var product = Product.fromJson(data[i]);
          items.add(product);
        }
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
      {@required String type, @required String userId, String exclude}) async {
    String urlPart = type == "products"
        ? "sellers-other-products"
        : "providers-other-services";

    var url = "${AppConfig.baseUrl}/api/v1/$type/$urlPart/$userId/";

    if (exclude != null) {
      url += "?exclude=$exclude";
    }

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    List items = List();
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
  Future<Map<String, dynamic>> searchUsersServices(String next, String previous,
      {SearchItemWithFilterModel filterOptions}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl +
          "/api/v1/services/by-provider/" +
          filterOptions.searchedUser.userName +
          "/?";
      if (filterOptions.category != "All categories") {
        url = url + "category=${filterOptions.category}";
      }
      if (filterOptions.searchedText.trim() != "") {
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
  Future<Map<String, dynamic>> searchUsersProducts(String next, String previous,
      {SearchItemWithFilterModel filterOptions}) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl +
          "/api/v1/products/by-seller/" +
          filterOptions.searchedUser.userName +
          "/?";

      if (filterOptions.category != "All categories") {
        url = url + "category=${filterOptions.category}";
      }
      if (filterOptions.searchedText.trim() != "") {
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
    debugPrint(url);
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

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
}
