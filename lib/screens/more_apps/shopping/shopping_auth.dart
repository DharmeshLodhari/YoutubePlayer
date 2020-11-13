import 'dart:convert';

import 'package:Slydo/screens/more_apps/shopping/models/ShoppingProduct.dart';
import 'package:Slydo/services/auth.dart';
import "package:http/http.dart" as http;

class ShoppingAuthService extends AuthService {
  // List Products
  Future<List<ShoppingProduct>> getProductList(
      String next, String previous) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/products/by-seller/black/";
    } else {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

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
    var url = secureBaseUrl + "/api/v1/products/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
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
    String url = baseUrl + "/api/v1/search/products/?search=" + searchedText;
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
}
