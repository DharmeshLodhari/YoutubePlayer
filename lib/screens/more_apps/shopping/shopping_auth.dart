import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/shopping/models/Picture.dart';
import 'package:Slydo/screens/more_apps/shopping/models/ShoppingProduct.dart';
import 'package:Slydo/screens/more_apps/shopping/models/product_details.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/checkout_screen.dart';
import 'package:Slydo/screens/super_store/models/product_industry_model.dart';
import 'package:Slydo/screens/user_profile/models/discount/discount_model.dart';
import 'package:Slydo/screens/user_profile/models/flash_tags/flash_tag_alert_model.dart';
import 'package:Slydo/screens/user_profile/models/search_user_item_with_filter.dart';
import 'package:Slydo/screens/user_profile/models/states_model.dart';
import 'package:Slydo/screens/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'models/store.dart';

class ShoppingAuthService extends AuthService {
  Future<Map<String, dynamic>?> getProductListForSuperStore(
      String? next, String? previous,
      {String userName = "black",
      String? categoryId,
      String? industryId,
      bool todaysDeal = false,
      bool otherDeals = false}) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (todaysDeal == true) {
        url =
            "${AppConfig.baseUrl}/api/v1/products/?today_deals=true&industry=$industryId";
      } else if (otherDeals == true) {
        url =
            "${AppConfig.baseUrl}/api/v1/products/?other_deals=true&industry=$industryId";
      } else {
        url = "${AppConfig.baseUrl}/api/v1/products/by-seller/$userName/";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    // debugPrint('STORE URL ---> $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    // debugPrint('STORE URL BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      // debugPrint('SHOPPPING AUTH ---> ${jsonData["results"]}');

      final List<ShoppingProduct> shoppingProducts = [];
      for (var item in jsonData["results"]) {
        shoppingProducts.add(ShoppingProduct.fromJson(item));
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": shoppingProducts
      };

      return result;
    }

    final jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  // List Products
  Future<List<ShoppingProduct>?> getProductList(String next, String previous,
      {String userName = "black",
      bool todaysDeal = false,
      bool otherDeals = false}) async {
    String url = "";
    if (next == "") {
      if (todaysDeal == true) {
        url = "${AppConfig.baseUrl}/api/v1/products/?today_deals=true";
      } else if (otherDeals == true) {
        url = "${AppConfig.baseUrl}/api/v1/products/?other_deals=true";
      } else {
        url = "${AppConfig.baseUrl}/api/v1/products/by-seller/$userName/";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    // debugPrint('STORE URL ---> $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    // debugPrint('STORE URL BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final List<ShoppingProduct> products = [];
      for (var item in jsonData["results"]) {
        products.add(ShoppingProduct.fromJson(item));
      }
      return products;
    }

    final jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  // Get single product
  Future<ShoppingProduct> getShoppingProduct(String id) async {
    final String url = "${AppConfig.baseUrl}/api/v1/products/$id/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    final jsonData = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final ShoppingProduct product = ShoppingProduct.fromJson(jsonData);
      return product;
    } else {
      throw jsonData;
    }
  }

  // Get cart item by address id
  Future<Map<String, dynamic>?> getCartItemsByAddressId(
      String? next, String? previous,
      {String? addressId}) async {
    String url = '';
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/shopping-cart/items-by-address/$addressId";
    } else {
      url = getSecureUrl(url: next);
    }

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final List<Product> shoppingProducts = [];
      for (var item in jsonData["results"]) {
        shoppingProducts.add(Product.fromJson(item));
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": shoppingProducts
      };

      return result;
    }

    final jsonData = json.decode(response.body);
    return Future.error("$jsonData");
  }

  // List the  item with pagination
  Future<Map<String, dynamic>?> searchShoppingProducts(
      String searchedText, String? next, String? previous) async {
    String url =
        "${AppConfig.baseUrl}/api/v1/search/products/?search=$searchedText";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('SEARCH BODY ---> ${response.body}');

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
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // List the  item with pagination
  Future<Map<String, dynamic>?> searchServices(
      String searchedText, String? next, String? previous) async {
    String url =
        "${AppConfig.baseUrl}/api/v1/search/services/?search=$searchedText";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('SEARCH BODY ---> ${response.body}');

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
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

// profile product today deals
  Future<Map<String, dynamic>?> getProductsDeals(String? next, String? previous,
      {String? url, bool todaysDeal = false}) async {
    if (next == null) {
      return null;
    }
    // debugPrint('STORE URL ---> $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url ?? "", headers: headers);
    // debugPrint('STORE URL BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      // debugPrint('SHOPPPING AUTH ---> ${jsonData["results"]}');

      final List<Product> product = [];
      for (var item in jsonData["results"]) {
        product.add(Product.fromJson(item));
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": product
      };

      return result;
    }
    return null;
    // }
    // return null;
  }

  // super store items tab
  Future<Map<String, dynamic>?> getProductsStoreTab(
    String? next,
    String? previous, {
    String? url,
  }) async {
    // debugPrint('STORE URL ---> $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url ?? "", headers: headers);
    // debugPrint('STORE URL BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      // debugPrint('SHOPPPING AUTH ---> ${jsonData["results"]}');

      final List<Product> product = [];
      for (var item in jsonData["results"]) {
        product.add(Product.fromJson(item));
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": product
      };

      return result;
    }
    return null;
    // }
    // return null;
  }

  // product deal of the day
  Future<Map<String, dynamic>?> getProductsDealsOfTheDay(
      String? next, String? previous,
      {String? industryId, String? merchantId}) async {
    if (next == null) {
      return null;
    }

    String apiUrl = '${AppConfig.baseUrl}/api/v1/products/?today_deals=true';

    if (industryId != null && industryId.isNotEmpty) {
      apiUrl = '$apiUrl&industry=$industryId';
    } else if (merchantId != null && merchantId.isNotEmpty) {
      apiUrl = '$apiUrl&merchant=$merchantId';
    }

    // debugPrint('STORE URL ---> $apiUrl');

    final headers = await getAuthHeaders();
    final response = await httpGet(apiUrl, headers: headers);
    // debugPrint('STORE URL BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      // debugPrint('SHOPPPING AUTH ---> ${jsonData["results"]}');

      final List<Product> product = [];
      for (var item in jsonData["results"]) {
        product.add(Product.fromJson(item));
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": product
      };

      return result;
    }
    return null;
  }

  Future<Map<String, dynamic>?> searchShoppingProductsInSuperStore(
      String searchedText, String? next, String? previous) async {
    String url = "${AppConfig.baseUrl}/api/v1/products/?search=$searchedText";
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('SEARCH BODY ---> ${response.body}');

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
      return null;
    }
  }

  // delete product and service image

  Future<bool> deleteProductOrServiceImage(String imageId) async {
    final String url = "${AppConfig.baseUrl}/api/v1/images/$imageId/";
    // debugPrint("URL:- $url");
    final headers = await getAuthHeaders();
    final response = await httpDelete(url, headers: headers);
    // debugPrint("response:- ${response.body}");
    if (response.statusCode == 204) {
      return true;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  Future<ShoppingCartModelFromQrCode?> getShoppingCartDataFromQrCode(
      {required url}) async {
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('SHOPPING CART MODEL ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final ShoppingCartModelFromQrCode shoppingCartModel =
          ShoppingCartModelFromQrCode.fromJson(jsonDecode(response.body));
      return shoppingCartModel;
    } else {
      return null;
      // return Future.error(response.body);
    }
  }

  Future<bool> payForShoppingCart({required String cartId}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/anonymous-shopping-cart/check-out-payment/$cartId/";

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  // super store deal of the day
  Future<Map<String, dynamic>?> getProductsStoreDeal(
      String? next, String? previous, String url) async {
    // debugPrint('STORE URL ---> $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    // debugPrint('STORE URL BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      // debugPrint('SHOPPPING AUTH ---> ${jsonData["results"]}');

      final List<Product> product = [];
      for (var item in jsonData["results"]) {
        product.add(Product.fromJson(item));
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": product
      };

      return result;
    }
    return null;
  }

  //Products
  Product createProduct(Map<String, dynamic> item) {
    final Product product = Product();
    product.id = item['id'];
    product.type = item['type'];
    product.cover = item['cover'];
    product.localImages = item['localImages'];
    product.serverImages = product.imageDataToList(item['pictures']);
    product.pictureMap = item['pictures'].isEmpty
        ? []
        : (item['pictures'] as List).map((i) => Picture.fromJson(i)).toList();
    product.name = item['name'];
    product.qrCode = item['qr_code'];
    product.manufacturer = item['manufacturer'];
    product.isAvailable = item["is_available"];
    product.availableFrom = DateTime.parse(item['available_from']);
    product.description = item['description'];
    product.shortDescription = item["short_description"];
    product.category = item['category'].isEmpty
        ? const ProductCategory("")
        : ProductCategory(item['category']["name"], id: item['category']["id"]);
    product.subCategory = item['sub_category'].isEmpty
        ? const ProductCategory("")
        : ProductCategory(item['sub_category']["name"],
            id: item['sub_category']["id"]);
    product.customCategory = item['custom_category'].isEmpty
        ? const ProductCategory("")
        : ProductCategory(item['custom_category']["name"],
            id: item['custom_category']["id"]);
    product.tags = item['tags'].isEmpty
        ? []
        : (item['tags'] as List).map((i) => Tags.fromJson(i)).toList();
    product.preparationTime = item['preparation_time'];
    product.condition = item['condition'];
    product.seller = item['seller'];
    product.sellerFullName = item['seller_fullname'] ?? "";
    product.sellerAvatar = item["seller_avatar"];
    product.price = item['price'];
    product.currency = item["currency"];
    product.rating = formatRating(item['rating'] ?? 0.0);
    product.canRate = item["can_rate"] ?? false;
    product.enableInSuperStore = item["enable_in_superstore"] ?? false;
    // product.variant = item["variants"] ?? null;
    product.variantModels = item['variants'].isEmpty
        ? []
        : (item['variants'] as List).map((i) => Variant.fromJson(i)).toList();
    product.weight = item['weight'] ?? 0.0;
    product.weightSiUnit = item['weight_si_unit'] ?? '';
    product.height = item['height'] ?? 0.0;
    product.heightSiUnit = item['height_si_unit'] ?? '';
    product.width = item["width"] ?? 0.0;
    product.widthSiUnit = item["width_si_unit"] ?? '';
    product.trackInventory = item["track_inventory"] ?? false;
    product.quantity = item["quantity"];
    product.pricePercentageChange = item["price_percentage_change"] ?? 0.0;
    product.discountId = item['discount'];
    product.discountValue = item['discount_value'];
    product.discountType = item['discount_type'];
    product.discountIsActive = item['discount_is_active'];
    product.discountedPrice = item['discounted_price'];
    // product.addOns = item['add_ons'];
    product.addOnsModels = item['add_ons'].isEmpty
        ? []
        : (item['add_ons'] as List).map((i) => AddOns.fromJson(i)).toList();
    product.addressId = item['address_id'];
    product.searchKeywords = item['search_keywords'] == null
        ? <String>[]
        : (item['search_keywords'] as List).map((i) => i.toString()).toList();
    // product.qty = item['qty'];
    product.isChecked = item["is_checked"] ?? false;
    product.priceRange = item["price_range"] ?? "0";
    product.originalPrice = item["original_price"] ?? 0;
    product.reviewScore = item["review_score"] ?? 0;
    return product;
  }

  // List Products
  Future<Map<String, dynamic>?> listOfProduct(
    String? next,
    String? previous,
    String? category,
    bool? channel, {
    String? userName,
    String selectedFilter = "",
    bool otherDeals = false,
  }) async {
    // debugPrint('CALLING PRODUCT');
    // debugPrint('CALLING PRODUCT channel::: $channel');

    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (otherDeals == true) {
        url = "${AppConfig.baseUrl}/api/v1/products/?other_deals=true";
      } else {
        url =
            "${AppConfig.baseUrl}/api/v1/products/by-seller/$userName/?sort_by=$selectedFilter";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    if (category != "") {
      final cat = messageDecoderWithEmoji(category);
      if (category == "All") {
        url = "${AppConfig.baseUrl}/api/v1/products/?other_deals=true";
      } else {
        url += "${AppConfig.baseUrl}/api/v1/products/&categories=$cat/";
      }
    }

    if (channel == true) {
      url = "${AppConfig.baseUrl}/api/v1/channels-merchandise/$userName";
    }

    // debugPrint("product list url _______________________$url");
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {
          "count": '',
          "next": '',
          "previous": '',
          "results": []
        };

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final List<Product> productList = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final Product product = createProduct(item);
        productList.add(product);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": productList
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // List Products
  Future<Map<String, dynamic>?> searchListOfProduct(
      String? next, String? previous, String? userName,
      {SearchItemWithFilterModel? filterOptions}) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/products/by-seller/$userName/?";

      if (filterOptions!.category != "" &&
          filterOptions.category != "All categories") {
        url = "${url}category=${filterOptions.categoryId}";
      }
      if (filterOptions.subCategory != "" &&
          filterOptions.subCategory != "All" &&
          filterOptions.subCategoryId != null) {
        url = "$url&sub_category=${filterOptions.subCategoryId}";
      }
      if (filterOptions.customCategory != "" &&
          filterOptions.customCategory != "All" &&
          filterOptions.customCategoryId != null) {
        url = "$url&custom_category=${filterOptions.customCategoryId}";
      }
      if (filterOptions.condition != "") {
        url = "$url&condition=${filterOptions.condition}";
      }
      if (filterOptions.manufacturer != "" &&
          filterOptions.manufacturer != "All") {
        url = "$url&manufacturer=${filterOptions.manufacturer}";
      }
      if (filterOptions.rating != "") {
        url = "$url&rating=${filterOptions.rating}";
      }
      if (filterOptions.searchedText!.trim() != "") {
        // url = url + "&name__icontains=${filterOptions.searchedText}";
        url = "$url&search=${filterOptions.searchedText}";
      }
      if (filterOptions.minAmount != null) {
        url = "$url&price__gte=${filterOptions.minAmount}";
      }
      if (filterOptions.maxAmount != null) {
        url = "$url&price__lte=${filterOptions.maxAmount}";
      }

      // debugPrint('SEARCH FILTER URL ---> $url');
      url = Uri.encodeFull(url);
    } else {
      url = getSecureUrl(url: next);
    }

    // debugPrint("product list url _______________________$url");
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {
          "count": '',
          "next": '',
          "previous": '',
          "results": []
        };

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final List<Product> productList = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final Product product = createProduct(item);
        productList.add(product);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": productList
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // List Discounted Products
  Future<Map<String, dynamic>?> listOfDiscountedProduct(
    String? next,
    String? previous,
    String? discountedId,
  ) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/business/discounts/$discountedId/merchant-discounted-consumables/product/";
    } else {
      url = getSecureUrl(url: next);
    }

    // debugPrint("product list url _______________________$url");
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {
          "count": '',
          "next": '',
          "previous": '',
          "results": []
        };

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final List<Product> productList = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final Product product = createProduct(item);
        productList.add(product);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": productList
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> searchOfDiscountedProduct(
      String? next, String? previous, String? discountedId,
      {SearchItemWithFilterModel? filterOptions}) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/business/discounts/$discountedId/merchant-discounted-consumables/product/?";

      if (filterOptions!.category != "" &&
          filterOptions.category != "All categories") {
        url = "${url}category=${filterOptions.categoryId}";
      }
      if (filterOptions.subCategory != "" &&
          filterOptions.subCategory != "All" &&
          filterOptions.subCategoryId != null) {
        url = "$url&sub_category=${filterOptions.subCategoryId}";
      }
      if (filterOptions.customCategory != "" &&
          filterOptions.customCategory != "All" &&
          filterOptions.customCategoryId != null) {
        url = "$url&custom_category=${filterOptions.customCategoryId}";
      }
      if (filterOptions.condition != "") {
        url = "$url&condition=${filterOptions.condition}";
      }
      if (filterOptions.manufacturer != "" &&
          filterOptions.manufacturer != "All") {
        url = "$url&manufacturer=${filterOptions.manufacturer}";
      }
      if (filterOptions.rating != "") {
        url = "$url&rating=${filterOptions.rating}";
      }
      if (filterOptions.searchedText!.trim() != "") {
        // url = url + "&name__icontains=${filterOptions.searchedText}";
        url = "$url&search=${filterOptions.searchedText}";
      }
      if (filterOptions.minAmount != null) {
        url = "$url&price__gte=${filterOptions.minAmount}";
      }
      if (filterOptions.maxAmount != null) {
        url = "$url&price__lte=${filterOptions.maxAmount}";
      }

      // debugPrint('SEARCH FILTER URL ---> $url');
      url = Uri.encodeFull(url);
    } else {
      url = getSecureUrl(url: next);
    }

    // debugPrint("product list url _______________________$url");
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {
          "count": '',
          "next": '',
          "previous": '',
          "results": []
        };

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final List<Product> productList = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final Product product = createProduct(item);
        productList.add(product);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": productList
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // List Products
  Future<Map<String, dynamic>?> listOfDiscountedServices(
    String? next,
    String? previous,
    String? discountedId,
  ) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/business/discounts/$discountedId/merchant-discounted-consumables/service/";
    } else {
      url = getSecureUrl(url: next);
    }

    // debugPrint("service list url _______________________$url");
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {
          "count": '',
          "next": '',
          "previous": '',
          "results": []
        };

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final List<Service> serviceList = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final Service service = createService(item);
        serviceList.add(service);
      }

      final Map<String, dynamic> result = {
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

  Future<Map<String, dynamic>?> searchOfDiscountedServices(
      String? next, String? previous, String? discountedId,
      {SearchItemWithFilterModel? filterOptions}) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/business/discounts/$discountedId/merchant-discounted-consumables/service/?";

      if (filterOptions!.category != "All categories") {
        url = "$url&category=${filterOptions.category}";
      }
      if (filterOptions.searchedText!.trim() != "") {
        url = "$url&name__icontains=${filterOptions.searchedText}";
      }
      if (filterOptions.minAmount != null) {
        url = "$url&price__gte=${filterOptions.minAmount}";
      }
      if (filterOptions.maxAmount != null) {
        url = "$url&price__lte=${filterOptions.maxAmount}";
      }
      url = Uri.encodeFull(url);
    } else {
      url = getSecureUrl(url: next);
    }

    // debugPrint("service list url _______________________$url");
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {
          "count": '',
          "next": '',
          "previous": '',
          "results": []
        };

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final List<Service> serviceList = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final Service service = createService(item);
        serviceList.add(service);
      }

      final Map<String, dynamic> result = {
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

  // List of users Product
  Future<Map<String, dynamic>?> listOfUsersProduct(
      {String? sectionUrl, String? name}) async {
    final String url = sectionUrl ??
        "${AppConfig.baseUrl}/api/v1/products/seller-products-by-custom-category/$name/?";

    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {"sectionProducts": []};

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final List sectionProducts = [];
      final jsonData = json.decode(response.body);

      for (var data in jsonData) {
        sectionProducts.add(data);
      }

      // debugPrint("_______________________________________$sectionProducts");

      final Map<String, dynamic> result = {
        "sectionProducts": sectionProducts,
      };

      // debugPrint('CALLING OTHER check ---> ${sectionProducts}');

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // List superstores
  Future<Map<String, dynamic>?> listOfSuperStores({String? sectionUrl}) async {
    final String url =
        sectionUrl ?? "${AppConfig.baseUrl}/api/v1/products/super-store/";

    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {"store": []};

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final List storeList = [];
      final jsonData = json.decode(response.body);
      final List<Product> productList = [];

      for (var data in jsonData) {
        storeList.add(data);
      }

      final Map<String, dynamic> result = {
        "store": storeList,
        "product": productList
      };

      // debugPrint('CALLING OTHER check ---> ${storeList}');

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // List superstores
  @override
  Future<Map<String, dynamic>?> listOfIndustries() async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/industries/?home=true";

    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {"product": []};

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final jsonData = json.decode(response.body);
      final List<ProductIndustryResults> results = (jsonData["results"] as List)
          .map((e) => ProductIndustryResults.fromJson(e))
          .toList();

      final Map<String, dynamic> result = {"product": results};

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Add Product
  Future<List<dynamic>> addProduct(Product product, String channelUsername,
      List<AddOns> productAddOnsList) async {
    final headers = await getAuthHeaders();
    String url = "${AppConfig.baseUrl}/api/v1/products/";

    if (channelUsername.isNotEmpty) {
      url =
          "${AppConfig.baseUrl}/api/v1/channels-merchandise/$channelUsername/";
    }

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("POST", Uri.parse(url));

    final Map<dynamic, dynamic> data = product.toMap();
    data["available_from"] = dateToString(product.availableFrom!);
    data["image_count"] = product.localImages!.length;
    data.remove('variants');

    if (data["height"] == null || data["height"] == 0.0) {
      data['height'] = 0.0;
      data['height_si_unit'] = '';
    }
    if (data["weight"] == null || data["weight"] == 0.0) {
      data['weight'] = 0.0;
      data['weight_si_unit'] = '';
    }
    if (data["width"] == null || data["width"] == 0.0) {
      data['width'] = 0.0;
      data['width_si_unit'] = '';
    }
    // debugPrint('DATA from ---> $data');

    if (productAddOnsList.isNotEmpty) {
      final List ids = productAddOnsList
          .where((addOn) => addOn.id != null)
          .map((addOn) => addOn.id!)
          .toList();
      data["add_ons"] = ids;
    }

    data.forEach((k, v) {
      if (k == "search_keywords") {
        request.fields[k] = jsonEncode(v);
      } else {
        request.fields[k] = v.toString();
      }
    });

    // debugPrint('DATA from two ---> $data');

    final List<MultipartFile> newList = [];

    for (int i = 0; i < product.localImages!.length; i++) {
      // debugPrint('DATA from two ---> ${product.localImages![i].path}');
      // Add fields
      request.fields["imagefile_$i"] = product.localImages![i].path;

      // Create multipart using filepath, string or bytes
      final multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", product.localImages![i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    // debugPrint('DATA from newList ---> $newList');
    // Add multipart to request
    request.files.addAll(newList);

    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    final responseBody = await response.stream.bytesToString();

    // debugPrint(
    //     "URL $url PRODUCT STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

    bool backValue = false;
    if (response.statusCode == 200 || response.statusCode == 201) {
      // debugPrint('DATA from add product ---> $responseBody');

      final jsonData = json.decode(responseBody);
      String productId = "";
      if (jsonData['id'] != null || jsonData['id'] != "") {
        productId = jsonData['id'];
        backValue = true;
      } else {
        backValue = true;
      }
      return [backValue, productId];
    } else {
      // debugPrint(
      //     "URL $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

      throw responseBody;
    }
  }

  // Add Variant
  Future<bool> addVariant(Variant item, String productId) async {
    final headers = await getAuthHeaders();
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/$productId/variants/";

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("POST", Uri.parse(url));

    final Map<dynamic, dynamic> data = item.toMap();
    // debugPrint('DATA ---> $data');
    // _data["available_from"] = dateToString(variant.availableFrom!);
    data["image_count"] = item.localImages!.length;

    data.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    final List<MultipartFile> newList = [];

    // debugPrint('DATA from pictures ---> ${item.localImages!.length}');

    for (int i = 0; i < item.localImages!.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = item.localImages![i].path;

      // Create multipart using filepath, string or bytes
      final multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", item.localImages![i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    // debugPrint('DATA from pictures 2 ---> $newList');
    // Add multipart to request
    request.files.addAll(newList);

    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      // debugPrint(
      //     "URL $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

      throw responseBody;
    }
  }

  // List the  variant with pagination
  Future<Map<String, dynamic>?> getVariantList(
      String productId, String? next, String? previous) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/$productId/variants/";

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('SEARCH BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Variant> variantList = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData) {
        variantList.add(Variant.fromJson(item));
      }

      final Map<String, dynamic> result = {
        // "count": jsonData["count"],
        // "next": jsonData["next"],
        // "previous": jsonData["previous"],
        "results": variantList,
      };
      return result;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // delete single variant
  Future<bool> deleteVariant(String variantId) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/variants/$variantId/";
    final headers = await getAuthHeaders();
    final response = await httpDelete(
      url,
      headers: headers,
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // Update Variant
  Future<bool> updateVariant(Variant item, String variantId) async {
    final headers = await getAuthHeaders();
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/variants/$variantId/";

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("PATCH", Uri.parse(url));

    final Map<dynamic, dynamic> data = item.toMap();
    // debugPrint('DATA from ---> $data');
    // _data["available_from"] = dateToString(variant.availableFrom!);
    data["image_count"] = item.localImages!.length;

    data.forEach((k, v) {
      request.fields[k] = v.toString();
    });

    final List<MultipartFile> newList = [];

    // debugPrint('DATA from pictures ---> ${item.localImages!.length}');

    for (int i = 0; i < item.localImages!.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = item.localImages![i].path;

      // Create multipart using filepath, string or bytes
      final multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", item.localImages![i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    // debugPrint('DATA from pictures 2 ---> $newList');
    // Add multipart to request
    request.files.addAll(newList);

    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      // debugPrint(
      //     "URL $url STATUS CODE:- ${response.statusCode} BODY:- $responseBody");

      throw responseBody;
    }
  }

  // Edit Product
  Future<bool> editProduct(
      Product product, List<dynamic>? productAddOnsList) async {
    final headers = await getAuthHeaders();
    final String url = "${AppConfig.baseUrl}/api/v1/products/${product.id}/";

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("PATCH", Uri.parse(url));

    final Map<dynamic, dynamic> data = product.toMap();
    data["available_from"] = dateToString(product.availableFrom!);
    data["image_count"] = product.localImages!.length;

    if (data["height"] == null || data["height"] == 0.0) {
      data['height'] = 0.0;
      data['height_si_unit'] = '';
    }
    if (data["weight"] == null || data["weight"] == 0.0) {
      data['weight'] = 0.0;
      data['weight_si_unit'] = '';
    }
    if (data["width"] == null || data["width"] == 0.0) {
      data['width'] = 0.0;
      data['width_si_unit'] = '';
    }

    if (productAddOnsList!.isNotEmpty) {
      final List ids = productAddOnsList
          .where((addOn) => addOn.id != null)
          .map((addOn) => addOn.id!)
          .toList();
      data["add_ons"] = ids;
    }

    data.forEach((k, v) {
      if (k == "search_keywords") {
        request.fields[k] = jsonEncode(v);
      } else {
        request.fields[k] = v.toString();
      }
    });

    final List<MultipartFile> newList = [];
    for (int i = 0; i < product.localImages!.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = product.localImages![i].path;

      // Create multipart using filepath, string or bytes
      final multipartFile = await http.MultipartFile.fromPath(
          "imagefile_$i", product.localImages![i].path);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    // Add multipart to request
    request.files.addAll(newList);
    // debugPrint('UPDATE PRODUCT FIELDS -> $data');
    headers.forEach((k, v) => request.headers[k] = v);

    final response = await request.send();

    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    final responseBody = await response.stream.bytesToString();
    // debugPrint('UPDATE PRODUCT RESPONSE -> $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw responseBody;
    }
  }

  // Get single product
  Future<Product> getProduct(String id) async {
    final String url = "${AppConfig.baseUrl}/api/v1/products/$id/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    final jsonData = json.decode(response.body);
    // log("jsonData :- $jsonData");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Product product = createProduct(jsonData);
      return product;
    } else {
      // debugPrint(
      //     "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      throw jsonData;
    }
  }

  Future<Map<String, dynamic>?> getProductOrService(String url) async {
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    final jsonData = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonData;
    } else {
      throw jsonData;
    }
  }

  // delete single product
  Future<bool> deleteProduct(String id) async {
    final String url = "${AppConfig.baseUrl}/api/v1/products/$id/";
    final headers = await getAuthHeaders();
    final response = await httpDelete(
      url,
      headers: headers,
    );

    // debugPrint("fola add product delete ${response.statusCode}");
    // debugPrint("fola add product delete 2 ${response.body}");

    if (response.statusCode == 204) {
      return true;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  //Service
  Service createService(Map<String, dynamic> item) {
    // debugPrint("==> $item");
    final Service service = Service();
    service.id = item['id'];
    service.cover = item['cover'];
    service.localImages = item['localImages'];
    service.serverImages = service.imageDataToList(item['pictures']);
    service.pictureMap = item['pictures'];
    service.name = item['name'];
    service.qrCode = item['qr_code'];
    service.isAvailable = item["is_available"];
    service.availableFrom = DateTime.parse(item['available_from']);
    service.discountId = item['discount'];
    service.discountIsActive = item['discount_is_active'];
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
    service.isChecked = item["is_checked"] ?? false;
    service.reviewScore = item["review_score"] ?? 0;
    return service;
  }

  // List services
  Future<Map<String, dynamic>?> listOfServices(String? next, String? previous,
      {String? userName, bool otherDeals = false}) async {
    // debugPrint('CALLING PRODUCT');
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (otherDeals == true) {
        url = "${AppConfig.baseUrl}/api/v1/services/";
      } else {
        url = "${AppConfig.baseUrl}/api/v1/services/";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Service> serviceList = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        final Service service = createService(item);
        serviceList.add(service);
      }

      final Map<String, dynamic> result = {
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
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/services/by-provider/${userName!}/";
    } else {
      url = getSecureUrl(url: next);
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Service> serviceList = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        final Service service = createService(item);
        serviceList.add(service);
      }

      final Map<String, dynamic> result = {
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
      final List<Service> serviceList = [];

      final Map<String, dynamic> result = {
        "count": 0,
        "next": "test",
        "previous": "test",
        "results": serviceList
      };
      return result;
    }
  }

  Future<Map<String, dynamic>?> searchListOfService(
      String? next, String? previous, String? userName,
      {SearchItemWithFilterModel? filterOptions}) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/services/by-provider/${userName!}/?";

      if (filterOptions!.category != "All categories") {
        url = "$url&category=${filterOptions.category}";
      }
      if (filterOptions.searchedText!.trim() != "") {
        url = "$url&name__icontains=${filterOptions.searchedText}";
      }
      if (filterOptions.minAmount != null) {
        url = "$url&price__gte=${filterOptions.minAmount}";
      }
      if (filterOptions.maxAmount != null) {
        url = "$url&price__lte=${filterOptions.maxAmount}";
      }
      url = Uri.encodeFull(url);
    } else {
      url = getSecureUrl(url: next);
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Service> serviceList = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        final Service service = createService(item);
        serviceList.add(service);
      }

      final Map<String, dynamic> result = {
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
      final List<Service> serviceList = [];

      final Map<String, dynamic> result = {
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
    final headers = await getAuthHeaders();
    final String url = "${AppConfig.baseUrl}/api/v1/services/";

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("POST", Uri.parse(url));

    final Map<dynamic, dynamic> data = service.toMap();
    data["available_from"] = dateToString(service.availableFrom!);
    data["image_count"] = service.localImages!.length;

    data.forEach((k, v) {
      if (k == "search_keywords") {
        request.fields[k] = jsonEncode(v);
      } else {
        request.fields[k] = v.toString();
      }
    });
    final List<MultipartFile> newList = [];
    for (int i = 0; i < service.localImages!.length; i++) {
      // Add fields
      request.fields["imagefile_$i"] = service.localImages![i].path;

      // Create multipart using filepath, string or bytes
      final multipartFile = await http.MultipartFile.fromPath(
        "imagefile_$i",
        service.localImages![i].path,
      );

      // debugPrint('DATA FOR SERVICE -> $data');
      // debugPrint('DATA FOR SERVICE FIELDS -> ${request.fields}');

      // Add multipart to newList
      newList.add(multipartFile);
    }

    // Add multipart to request
    request.files.addAll(newList);
    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw responseBody;
    }
  }

// edit service
  Future<bool> editService(Service service) async {
    final headers = await getAuthHeaders();
    final String url = "${AppConfig.baseUrl}/api/v1/services/${service.id}/";

    //create multipart request for POST or PATCH method
    final request = http.MultipartRequest("PATCH", Uri.parse(url));

    final Map<dynamic, dynamic> data = service.toMap();
    data["available_from"] = dateToString(service.availableFrom!);
    data["image_count"] = service.localImages!.length;

    data.forEach((k, v) {
      if (k == "search_keywords") {
        request.fields[k] = jsonEncode(v);
      } else {
        request.fields[k] = v.toString();
      }
    });

    if (service.localImages!.isNotEmpty) {
      final List<MultipartFile> newList = [];
      for (int i = 0; i < service.localImages!.length; i++) {
        //add fields
        request.fields["imagefile_$i"] = service.localImages![i].path;

        //create multipart using filepath, string or bytes
        final multipartFile = await http.MultipartFile.fromPath(
            "imagefile_$i", service.localImages![i].path);

        //add multipart to newList
        newList.add(multipartFile);
      }
      //add multipart to request
      request.files.addAll(newList);
    }
    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }

    final responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw responseBody;
    }
  }

// Get single service
  Future<Service> getService(String id) async {
    final String url = "${AppConfig.baseUrl}/api/v1/services/$id/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    final jsonData = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Service service = createService(jsonData);
      return service;
    } else {
      // debugPrint(
      //     "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      throw jsonData;
    }
  }

  // delete single service
  Future<bool> deleteService(String id) async {
    final String url = "${AppConfig.baseUrl}/api/v1/services/$id/";
    final headers = await getAuthHeaders();
    final response = await httpDelete(
      url,
      headers: headers,
    );
    if (response.statusCode == 204) {
      return true;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // Update Order Status
  Future<bool> updateOrderStatus(String? value, String orderId) async {
    final data = {"status": value};
    final data0 = jsonEncode(data);
    final String url =
        "${AppConfig.baseUrl}/api/v1/order/$orderId/update-status/";
    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers, body: data0);

    try {
      handleServerErrors(response);
    } catch (e) {
      return Future.error(response.body);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  //Update Date & Time
  Future<bool> updateOrderDateTime(
      String? shipmentType, String? dateTime, String orderId) async {
    final Map<String, dynamic> data = {};
    if (shipmentType == "PickUp") {
      data.addAll({
        "pickup_datetime": dateTime,
      });
    } else if (shipmentType == "In Store/Eat In") {
      data.addAll({
        "instore_datetime": dateTime,
      });
    }
    print(data);
    final data0 = jsonEncode(data);
    final String url = "${AppConfig.baseUrl}/api/v1/order/$orderId/";
    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers, body: data0);

    try {
      handleServerErrors(response);
    } catch (e) {
      return Future.error(response.body);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // Order Refund Request
  Future<bool> updateOrderRefundStatus(
      Map<String, dynamic> data, String orderId) async {
    final data0 = jsonEncode(data);
    final String url = "${AppConfig.baseUrl}/api/v1/order/$orderId/add-refund/";
    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers, body: data0);

    try {
      handleServerErrors(response);
    } catch (e) {
      return Future.error(response.body);
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // Update Order Note
  Future<bool> updateOrderNote(String note, String orderId) async {
    final data = {"note": note};
    final data0 = jsonEncode(data);
    final String url = "${AppConfig.baseUrl}/api/v1/order/$orderId/add-note/";
    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers, body: data0);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // List of Orders
  Future<dynamic> listOrders(String? next, String? previous,
      String selectedStatus, DateTimeRange? dateTimeRange,
      {required bool isMerchant,
      String? searchValue,
      String? filterValue}) async {
    final List<String> shippedStatus = [
      "Shipped",
      "Out For Delivery",
      "Order Picked Up",
      "Rider In Delivery Location",
      "Order Arrived",
      "Rider Picked Up Order",
    ];
    String url = "";

    if (next == null) {
      return null;
    }

    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/order/?";

      // url = "$url?merchant=$isMerchant";
      if (filterValue != null && filterValue != "") {
        url = "$url&shipping_type=$filterValue";
      }
      if (searchValue != null) {
        url = "$url&id=$searchValue";
      }
      if (selectedStatus != "") {
        if (selectedStatus == "Completed") {
          selectedStatus = 'Complete';
        }
        if (selectedStatus == "Shipped") {
          selectedStatus = 'shipped';
        }
        url = "$url&status=$selectedStatus";
      }

      if (dateTimeRange != null) {
        final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        final String toDate = dateFormat.format(dateTimeRange.end);
        final String fromDate = dateFormat.format(dateTimeRange.start);

        if (url.contains('?')) {
          url = "$url&start_date=$fromDate&end_date=$toDate";
        } else {
          url = "$url?start_date=$fromDate&end_date=$toDate";
        }
      }
    } else {
      url = getSecureUrl(url: next);
    }
    if (url.endsWith("?")) {
      url = url.replaceAll("?", "");
    }
    // debugPrint('URL ::: $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // try {
    //   handleServerErrors(response);
    // } catch (e) {
    //   return Future.error(response.body);
    // }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final List<Order> items = [];
      final data = jsonData["results"];
      for (int i = 0; i < data.length; i++) {
        final Order order = Order.fromJson(data[i]);
        items.add(order);
      }

      jsonData["results"] = items;
      return jsonData;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      return null;
      // debugPrint("STATUS CODE:- ${response.statusCode} ");
      // throw json.decode(response.body);
    }
  }

  // Get the shipping options when making an order.
  Future<List<ShippingOptionsModel>> getShippingOptions(
      {required String merchantName}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/shipping-options/public-list/$merchantName/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    final jsonData = jsonDecode(response.body);

    // debugPrint('URL :: $url');
    // debugPrint('BODY shipping:: ${response.body}');
    // debugPrint('STATUS CO  :: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List jsonDataResult = jsonData['results'];

      return jsonDataResult
          .map((json) => ShippingOptionsModel.fromJson(json))
          .toList();
    } else {
      debugPrint('BODY shipping 00:: ${response.body}');

      return Future.error(response.body);
    }
  }

  // Get single Order
  Future<Order> getOrder(String id) async {
    final String url = "${AppConfig.baseUrl}/api/v1/order/$id/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    final jsonData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // log("DATA=> $jsonData");
      // final List items = [];
      final data = jsonData["results"];
      for (int i = 0; i < data.length; i++) {
        final Order order = Order.fromJson(data[i]);
        return order;
      }
    }
    throw jsonData;
  }

  //ShoppingCart
  Future<List> getShoppingCart() async {
    final String url = "${AppConfig.baseUrl}/api/v1/shopping-cart/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return getCartItems(jsonData);
    }

    return Future.error("ERROR:- ${response.body}");
  }

  Future<bool> addOrUpdateItemToShoppingCart(Map<String, dynamic> data) async {
    final String url = "${AppConfig.baseUrl}/api/v1/shopping-cart/add-item/";
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: data0);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<bool> removeItemFromShoppingCart(Map data) async {
    final String url = "${AppConfig.baseUrl}/api/v1/shopping-cart/remove-item/";
    final data0 = jsonEncode(data);
    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers, body: data0);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  //place shopping cart order
  Future<dynamic> placeOrderOfShoppingCart(Map data) async {
    final String url = "${AppConfig.baseUrl}/api/v1/shopping-cart/";
    final data0 = jsonEncode(data);

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: data0);
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonData;
    } else {
      return null;
    }
  }

  //place single order
  Future<dynamic> placeSingleOrder(Map data) async {
    final String url = "${AppConfig.baseUrl}/api/v1/shopping-cart/buy-now/";
    final data0 = jsonEncode(data);

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: data0);
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonData;
    } else {
      return null;
    }
  }

  Future<http.Response> createReviewableRecord(
      {required Map<String, dynamic> data}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/social/reviews/create-reviewable-record/";
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPost(url, headers: headers, body: data0);
    return response;
  }

  List<dynamic> getCartItems(var jsonResponse) {
    final List items = [];
    final data = jsonResponse["results"];

    for (int i = 0; i < data.length; i++) {
      if (data[i]["type"] == "product") {
        // debugPrint('fola one one:::: ${data[i]["qty"]}');

        // for (int j = 0; j < data[i]["qty"]; j++) {
        final product = Product.fromJson(data[i]);
        items.add(product);

        // debugPrint('fola one jsonData:::: ${product.name}');
        // }
      }
      if (data[i]["type"] == "service") {
        for (int j = 0; j < data[i]["qty"]; j++) {
          final service = Service.fromJson(data[i]);
          items.add(service);
        }
      }
    }
    return items;
  }

  Future<List<dynamic>> ownersOrderProductsAndServices(
      {required String type, required String? userId, String? exclude}) async {
    final String urlPart = type == "products"
        ? "sellers-other-products"
        : "providers-other-services";

    String url = "${AppConfig.baseUrl}/api/v1/$type/$urlPart/$userId/";

    if (exclude != null) {
      url += "?exclude=$exclude";
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    final List items = [];
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      final data = jsonData["results"];
      for (int i = 0; i < data.length; i++) {
        if (type == "products") {
          final product = Product.fromJson(data[i]);
          items.add(product);
        }
        if (type == "services") {
          final service = Service.fromJson(data[i]);
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
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/services/by-provider/${filterOptions!.searchedUser!.userName!}/?";
      if (filterOptions.category != "All categories") {
        url = "$url&category=${filterOptions.category}";
      }
      if (filterOptions.searchedText!.trim() != "") {
        url = "$url&name__icontains=${filterOptions.searchedText}";
      }
      if (filterOptions.minAmount != null) {
        url = "$url&price__gte=${filterOptions.minAmount}";
      }
      if (filterOptions.maxAmount != null) {
        url = "$url&price__lte=${filterOptions.maxAmount}";
      }
      url = Uri.encodeFull(url);
    } else {
      url = getSecureUrl(url: next);
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Service> serviceList = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        final Service service = createService(item);
        serviceList.add(service);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": serviceList
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      final List<Service> serviceList = [];

      final Map<String, dynamic> result = {
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
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      final String userName =
          filterOptions!.userName ?? filterOptions.searchedUser!.userName!;
      url = "${AppConfig.baseUrl}/api/v1/products/by-seller/$userName/?";

      if (filterOptions.category != "" &&
          filterOptions.category != "All categories") {
        url = "${url}category=${filterOptions.categoryId}";
      }
      if (filterOptions.subCategory != "" &&
          filterOptions.subCategory != "All" &&
          filterOptions.subCategoryId != null) {
        url = "$url&sub_category=${filterOptions.subCategoryId}";
      }
      if (filterOptions.customCategory != "" &&
          filterOptions.customCategory != "All" &&
          filterOptions.customCategoryId != null) {
        url = "$url&custom_category=${filterOptions.customCategoryId}";
      }
      if (filterOptions.condition != "") {
        url = "$url&condition=${filterOptions.condition}";
      }
      if (filterOptions.manufacturer != "" &&
          filterOptions.manufacturer != "All") {
        url = "$url&manufacturer=${filterOptions.manufacturer}";
      }
      if (filterOptions.rating != "") {
        url = "$url&rating=${filterOptions.rating}";
      }
      if (filterOptions.searchedText!.trim() != "") {
        // url = url + "&name__icontains=${filterOptions.searchedText}";
        url = "$url&search=${filterOptions.searchedText}";
      }
      if (filterOptions.minAmount != null) {
        url = "$url&price__gte=${filterOptions.minAmount}";
      }
      if (filterOptions.maxAmount != null) {
        url = "$url&price__lte=${filterOptions.maxAmount}";
      }

      // debugPrint('SEARCH FILTER URL ---> $url');
      url = Uri.encodeFull(url);
    } else {
      url = getSecureUrl(url: next);
    }
    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    // debugPrint('SEARCH FILTER STATUS CODE ---> ${response.statusCode}');
    // debugPrint('SEARCH FILTER BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Product> productList = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        final Product product = createProduct(item);
        productList.add(product);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": productList
      };
      // debugPrint("result:- $result");
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      final List<Product> productList = [];
      final Map<String, dynamic> result = {
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
      {required SearchItemWithFilterModelForSuperStore filterOptions,
      String? query}) async {
    String url = "";
    if (next == null) {
      return null;
    }
    // debugPrint('SORT BY Search -> ${filterOptions.sortBy}');

    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/products/?search=${filterOptions.searchedText}";

      if (query != null && query.isNotEmpty) {
        url = url + query;
      }
      if (filterOptions.minPrice != null) {
        url = "$url&min_price=${filterOptions.minPrice}";
      }
      if (filterOptions.maxPrice != null) {
        url = "$url&max_price=${filterOptions.maxPrice}";
      }
      if (filterOptions.rating != null) {
        url = "$url&rating=${filterOptions.rating}";
      }
      if (filterOptions.categories.isNotEmpty) {
        url = "$url&categories=${filterOptions.categories.join(',')}";
      }
      if (filterOptions.sortBy != null) {
        url = "$url&sort_by=${filterOptions.sortBy}";
      }

      url = Uri.encodeFull(url);
    } else {
      url = getSecureUrl(url: next);
    }

    // debugPrint('SEARCH FILTER URL ---> $url');

    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    // debugPrint('SEARCH FILTER STATUS CODE ---> ${response.statusCode}');
    // debugPrint('SEARCH FILTER BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Product> productList = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        final Product product = createProduct(item);
        productList.add(product);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": productList
      };
      // debugPrint("result:- $result");
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      final List<Product> productList = [];
      final Map<String, dynamic> result = {
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
    // debugPrint('SEARCH FILTER BODY ........');
    String url = "";
    if (next == null) {
      return null;
    }
    // debugPrint('SORT BY Search -> ${filterOptions.sortBy}');

    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/services/?search=${filterOptions.searchedText}";

      if (filterOptions.minPrice != null) {
        url = "$url&min_price=${filterOptions.minPrice}";
      }
      if (filterOptions.maxPrice != null) {
        url = "$url&max_price=${filterOptions.maxPrice}";
      }
      if (filterOptions.rating != null) {
        url = "$url&rating=${filterOptions.rating}";
      }
      if (filterOptions.categories.isNotEmpty) {
        url = "$url&categories=${filterOptions.categories.join(',')}";
      }
      if (filterOptions.sortBy != null) {
        url = "$url&sort_by=${filterOptions.sortBy}";
      }

      url = Uri.encodeFull(url);
    } else {
      url = getSecureUrl(url: next);
    }

    // debugPrint('SEARCH FILTER URL ---> $url');

    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    // debugPrint('SEARCH FILTER STATUS CODE ---> ${response.statusCode}');
    // debugPrint('SEARCH FILTER BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Service> serviceList = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        final Service service = createService(item);
        serviceList.add(service);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": serviceList
      };
      // debugPrint("result:- $result");
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      final List<Product> productList = [];
      final Map<String, dynamic> result = {
        "count": 0,
        "next": "test",
        "previous": "test",
        "results": productList
      };
      return result;
    }
  }

  Future<List<ServiceCategory>> getServiceCategories() async {
    final String url = "${AppConfig.baseUrl}/api/v1/services/choices/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> results = jsonData["results"];

      final List<ServiceCategory> categories = [];

      for (int i = 0; i < results.length; i++) {
        categories.add(ServiceCategory(messageDecoderWithEmoji(results[i])!));
      }

      return categories;
    } else {
      // debugPrint(
      //     "URL: $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
      return Future.value(<ServiceCategory>[]);
    }
  }

  Future<List<ProductCategory>> getProductCategories() async {
    final String url = "${AppConfig.baseUrl}/api/v1/products/choices/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint(
    //     "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> results = jsonData["results"];

      final List<ProductCategory> categories = [];

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

  Future<List<ProductCategory>> obtainProductCategories(id) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/categories/?industry=$id";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint(
    //     "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> results = jsonData["results"];

      final List<ProductCategory> categories = [];

      for (int i = 0; i < results.length; i++) {
        categories
            .add(ProductCategory(results[i]['name']!, id: results[i]['id']));
      }

      return categories;
    } else {
      debugPrint(
          "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
      return Future.value(<ProductCategory>[]);
    }
  }

  Future<Map<String, dynamic>> getMerchantProductCategories(
      String? industryId, String? next, String? previous) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/merchant-categories/$industryId/";

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('Merchant Category BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"]
      };
      return result;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  Future<Map<String, dynamic>> getManufacturerList(
      String? username, String? next, String? previous) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/merchant-products-manufacturers/$username/";

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('Merchant Category BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"]
      };
      return result;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  Future<Map<String, dynamic>> getMerchantSubProductCategories(
      int? categoryId, String? next, String? previous) async {
    final String url;
    if (categoryId != null) {
      url = "${AppConfig.baseUrl}/api/v1/products/sub-categories/$categoryId/";
    } else {
      url = "${AppConfig.baseUrl}/api/v1/products/sub-categories/";
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('Merchant Category BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"]
      };
      return result;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  Future<List<ProductCategory>> obtainCustomCategory(name) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/merchant-custom-categories/merchant/$name/";
    // debugPrint("_________________________________________$url");
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint(
    //     "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> results = jsonData["results"];

      final List<ProductCategory> categories = [];

      for (int i = 0; i < results.length; i++) {
        categories
            .add(ProductCategory(results[i]['name']!, id: results[i]['id']));
      }

      return categories;
    } else {
      debugPrint(
          "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
      return Future.value(<ProductCategory>[]);
    }
  }

  Future<bool> createCustomCategory(String name) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/merchant-custom-categories/";
    final Map data = {"name": name};
    final data0 = jsonEncode(data);

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: data0);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  Future<bool> editCustomCategory(String name, dynamic id) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/merchant-custom-categories/$id/";
    final Map data = {"name": name};
    final data0 = jsonEncode(data);

    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers, body: data0);
    // debugPrint("__________________________________ ${response.statusCode}");
    // debugPrint("__________________________________ $data");
    // debugPrint("__________________________________ $response");
    // debugPrint("__________________________________ $id");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    return false;
  }

  //re-order custom category
  Future<bool> reOrderCustomCategory(
      Map<String, dynamic> categoryData, String? merchantUsername) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/merchant-custom-categories/merchant/$merchantUsername/";
    final Map<String, dynamic> data = {"ordering": categoryData};
    final data0 = jsonEncode(data);

    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers, body: data0);
    // debugPrint("__________________________________ ${response.statusCode}");
    // debugPrint("__________________________________ $data");
    // debugPrint("__________________________________ $response");
    // debugPrint("__________________________________ $merchantUsername");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    return false;
  }

  Future<bool> deleteCustomCategory(dynamic id) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/merchant-custom-categories/$id/";

    final headers = await getAuthHeaders();
    final response = await httpDelete(url, headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else {
      final jsonData = json.decode(response.body);
      // debugPrint("_________________________________$response");
      throw jsonData;
    }
  }

  Future<List<ProductCategory>> getProductSubCategories(dynamic id) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/sub-categories/$id";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint(
    //     "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> results = jsonData["results"];

      final List<ProductCategory> categories = [];

      for (int i = 0; i < results.length; i++) {
        categories
            .add(ProductCategory(results[i]['name']!, id: results[i]['id']));
      }

      return categories;
    } else {
      debugPrint(
          "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
      return Future.value(<ProductCategory>[]);
    }
  }

  Future<Map<String, dynamic>?> getProductTags(
      String? id, String? next, String? previous, String searchText) async {
    String url = "";
    if (next == null) {
      return null;
    }

    if (next == "") {
      if (searchText != null || searchText != "") {
        url = "${AppConfig.baseUrl}/api/v1/products/tags/?search=$searchText";
      } else {
        url = "${AppConfig.baseUrl}/api/v1/products/tags";
      }
      // "/api/v1/products/tags/?industries/${id}&search=${val}";
    } else {
      url = getSecureUrl(url: next);
    }

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint(
    //     "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Tags> categories = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        final Tags customerProfile = Tags.fromJson(item);

        // debugPrint('SEARCH FILTER BODY ---> ${customerProfile.toJson()}');

        categories.add(customerProfile);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": categories
      };
      // debugPrint("result:- $result");
      return result;
    } else {
      debugPrint(
          "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");
      final List<CustomerProfile> customerProfileList = [];
      final Map<String, dynamic> result = {
        "count": 0,
        "next": "test",
        "previous": "test",
        "results": customerProfileList
      };
      return result;
    }
  }

  Future<List<ServiceCategory>> getServicesCategories() async {
    final String url = "${AppConfig.baseUrl}/api/v1/services/choices/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint(
    //     "URL FOR CATEGORIES $url STATUS CODE:- ${response.statusCode} Body:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);

      final List<dynamic> results = jsonData["results"];

      final List<ServiceCategory> categories = [];

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
    // debugPrint('CALLING MERCHANT LIST');

    String url = '';
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

    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<CustomerProfile> customerProfileList = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        // debugPrint('MERCHANT LIST 000---> ${item}');

        final CustomerProfile customerProfile = CustomerProfile.fromJson(item);

        // debugPrint('MERCHANT LIST 000---> ${customerProfile.toJson()}');
        // debugPrint('MERCHANT LIST 001---> ${item}');

        customerProfileList.add(customerProfile);
      }

      final Map<String, dynamic> result = {
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
    String url = "";
    if (next == null) {
      return null;
    }
    // debugPrint('STATE BY Search -> ${filterOptions.state}');

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

    // debugPrint('SEARCH FILTER URL ---> $url');

    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    // debugPrint('SEARCH FILTER STATUS CODE ---> ${response.statusCode}');
    // debugPrint('SEARCH FILTER BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<CustomerProfile> customerProfileList = [];
      final jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        final CustomerProfile customerProfile = CustomerProfile.fromJson(item);

        // debugPrint('SEARCH FILTER BODY ---> ${customerProfile.toJson()}');

        customerProfileList.add(customerProfile);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": customerProfileList
      };
      // debugPrint("result:- $result");
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      final List<CustomerProfile> customerProfileList = [];
      final Map<String, dynamic> result = {
        "count": 0,
        "next": "test",
        "previous": "test",
        "results": customerProfileList
      };
      return result;
    }
  }

  // List Products
  Future<Map<String, dynamic>?> listOfFlashTags(
      String? next, String? previous, String? userName) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/notification/alerts/user-alerts/$userName/";
    } else {
      url = getSecureUrl(url: next);
    }
    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {
          "count": '',
          "next": '',
          "previous": '',
          "results": []
        };

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final List<FlashTagAlertModel> productList = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final FlashTagAlertModel product = FlashTagAlertModel.fromJson(item);
        productList.add(product);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": productList
      };

      // debugPrint('CALLING OTHER check ---> ${result}');

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

//add flash tag
  Future<FlashTagAlertModel?> addUpdateFlashTag(
      FlashTagAlertModel flashTagAlertModelForAdd,
      {bool isEdit = false}) async {
    String url = "${AppConfig.baseUrl}/api/v1/notification/alerts/";

    if (isEdit == false) {
      url = "${AppConfig.baseUrl}/api/v1/notification/alerts/";
    } else {
      url =
          "${AppConfig.baseUrl}/api/v1/notification/alerts/${flashTagAlertModelForAdd.id}/";
    }

    final data = jsonEncode(flashTagAlertModelForAdd.toAddUpdate());

    final headers = await getAuthHeaders();
    Response? response;

    if (isEdit == false) {
      response = await httpPost(url, headers: headers, body: data);
    } else {
      response = await httpPatch(url, headers: headers, body: data);
    }
    final FlashTagAlertModel flashTagAlertModel =
        FlashTagAlertModel.fromJson(jsonDecode(response.body));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return flashTagAlertModel;
    }
    return null;
  }

  // delete flashTag
  Future<bool> deleteFlashTag(String id) async {
    final String url = "${AppConfig.baseUrl}/api/v1/notification/alerts/$id/";
    final headers = await getAuthHeaders();
    final response = await httpDelete(
      url,
      headers: headers,
    );
    if (response.statusCode == 204) {
      return true;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // List shipping state
  Future<Map<String, dynamic>?> getShippingStates() async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/shipping/states/?country_code=NG";

    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<StatesModel> stateList = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData) {
        final StatesModel states = StatesModel.fromJson(item);
        stateList.add(states);
      }

      final Map<String, dynamic> result = {"results": stateList};

      // debugPrint('CALLING OTHER check ---> ${result}');

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // set default address
  Future<Map<String, dynamic>?> setDefaultAddress(String? id) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/shipping/addresses/$id/set-as-default/";

    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {
          "count": '',
          "next": '',
          "previous": '',
          "results": []
        };

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final List<ShippingAddress> shippingAddressList = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final ShippingAddress address = ShippingAddress.fromJson(item);
        shippingAddressList.add(address);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": shippingAddressList
      };

      // debugPrint('CALLING OTHER check ---> ${result}');

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // List shipping city
  Future<Map<String, dynamic>?> getShippingCities(String code) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/shipping/cities/?state_code=$code";

    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Cities> cityList = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData) {
        final Cities cities = Cities.fromJson(item);
        cityList.add(cities);
      }

      final Map<String, dynamic> result = {"results": cityList};

      // debugPrint('CALLING OTHER check ---> ${result}');

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // List address
  Future<Map<String, dynamic>?> listOfDispatchAddress(
      String? next, String? previous) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/shipping/addresses/";
    } else {
      url = getSecureUrl(url: next);
    }
    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {
          "count": '',
          "next": '',
          "previous": '',
          "results": []
        };

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final List<ShippingAddress> shippingAddressList = [];
      final jsonData = json.decode(response.body);
      // debugPrint("$jsonData");
      for (var item in jsonData["results"]) {
        final ShippingAddress address = ShippingAddress.fromJson(item);
        shippingAddressList.add(address);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": shippingAddressList
      };

      // debugPrint('CALLING OTHER check ---> ${result}');

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // List Discounts
  Future<Map<String, dynamic>?> listOfDiscounts(String? next, String? previous,
      {bool? activeDiscount}) async {
    String url = "";
    if (next == null) {
      return null;
    }
    final startTime = DateTime.now();
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/business/discounts/";
    } else if (activeDiscount!) {
      url = "${AppConfig.baseUrl}/api/v1/business/discounts/active-discounts";
    } else {
      url = getSecureUrl(url: next);
    }
    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {
          "count": '',
          "next": '',
          "previous": '',
          "results": []
        };

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final List<DiscountModel> discountList = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final DiscountModel discount = DiscountModel.fromJson(item);
        discountList.add(discount);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": discountList
      };

      final endTime = DateTime.now();
      // debugPrint(
      //     'discount List: ${endTime.difference(startTime).inMilliseconds}ms');
      // debugPrint('CALLING OTHER check ---> ${result}');
      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // List Discounts
  Future<Map<String, dynamic>?> listOfMerchantDiscounts(
      String? next, String? previous, CustomerProfile? user) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/business/discounts/merchant-discounts/${user?.userName}/";
    } else {
      url = getSecureUrl(url: next);
    }
    // debugPrint(url);
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (!response.body.contains('results')) {
        final Map<String, dynamic> result = {
          "count": '',
          "next": '',
          "previous": '',
          "results": []
        };

        // debugPrint('CALLING OTHER check 2 ---> $result');

        return result;
      }
      final List<DiscountModel> discountList = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final DiscountModel discount = DiscountModel.fromJson(item);
        discountList.add(discount);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": discountList
      };

      // debugPrint('CALLING OTHER check ---> ${result}');
      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // delete address
  Future<bool> deleteAddress(String id) async {
    final String url = "${AppConfig.baseUrl}/api/v1/shipping/addresses/$id/";
    final headers = await getAuthHeaders();
    final response = await httpDelete(
      url,
      headers: headers,
    );
    if (response.statusCode == 204) {
      return true;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  //add update  address
  Future<ShippingAddress?> addUpdateAddress(ShippingAddress itemModel,
      {bool isEdit = false}) async {
    String url = "${AppConfig.baseUrl}/api/v1/shipping/addresses/";

    if (isEdit == false) {
      url = "${AppConfig.baseUrl}/api/v1/shipping/addresses/";
    } else {
      url = "${AppConfig.baseUrl}/api/v1/shipping/addresses/${itemModel.id}/";
    }

    final data = jsonEncode(itemModel.toAddUpdate());

    final headers = await getAuthHeaders();
    Response? response;

    if (isEdit == false) {
      response = await httpPost(url, headers: headers, body: data);
    } else {
      response = await httpPatch(url, headers: headers, body: data);
    }

    try {
      handleServerErrors(response);
    } catch (e) {
      return Future.error(response.body);
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      final ShippingAddress item =
          ShippingAddress.fromJson(jsonDecode(response.body));
      return item;
    }
    return null;
  }

  //add update  discount
  Future<DiscountModel?> addUpdateDiscount(DiscountModel itemModel,
      {bool isEdit = false}) async {
    final headers = await getAuthHeaders();
    String url = "${AppConfig.baseUrl}/api/v1/business/discounts/";

    if (isEdit == false) {
      url = "${AppConfig.baseUrl}/api/v1/business/discounts/";
    } else {
      url = "${AppConfig.baseUrl}/api/v1/business/discounts/${itemModel.id}/";
    }

    final request;
    if (isEdit == false) {
      request = http.MultipartRequest("POST", Uri.parse(url));
    } else {
      request = http.MultipartRequest("PATCH", Uri.parse(url));
    }

    final Map<dynamic, dynamic> data = itemModel.toAddUpdate();

    data.forEach((k, v) {
      if (k == 'consumables') {
        request.fields[k] = jsonEncode(v);
      } else {
        request.fields[k] = v.toString();
      }
    });

    if (itemModel.poster != null && !itemModel.poster!.contains("http")) {
      // Create multipart using filepath, string or bytes
      final multipartFile =
          await http.MultipartFile.fromPath("poster", itemModel.poster!);

      // Add multipart to request
      request.files.add(multipartFile);
    }

    // debugPrint("Request ${request.fields}");

    headers.forEach((k, v) => request.headers[k] = v);
    final response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final DiscountModel item =
          DiscountModel.fromJson(json.decode(responseBody));
      return item;
    }

    return Future.error(responseBody);
  }

  // delete discount
  Future<bool> deleteDiscount(String id) async {
    final String url = "${AppConfig.baseUrl}/api/v1/business/discounts/$id/";
    final headers = await getAuthHeaders();
    final response = await httpDelete(
      url,
      headers: headers,
    );
    if (response.statusCode == 204) {
      return true;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // List the  add-on with pagination
  Future<Map<String, dynamic>> getAddOnsList(
      String productId, String? next, String? previous) async {
    final String url = "${AppConfig.baseUrl}/api/v1/products/add-ons/";

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('Add-Ons BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final List<AddOns> items = [];
      final data = jsonData["results"];

      for (int i = 0; i < data.length; i++) {
        final addOn = AddOns.fromJson(data[i]);
        items.add(addOn);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": items
      };

      // jsonData["results"] = items;
      return result;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // List the  add-on options with pagination
  Future<Map<String, dynamic>> getAddOnOptionsList(
      String productId, String? next, String? previous) async {
    final String url = "${AppConfig.baseUrl}/api/v1/products/add-on-options/";

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('Add-On Options BODY ---> ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);

      final List<AddOnOption> items = [];
      final data = jsonData["results"];

      for (int i = 0; i < data.length; i++) {
        final AddOnOption addOnOptions = AddOnOption.fromJson(data[i]);
        items.add(addOnOptions);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": items
      };

      // jsonData["results"] = items;
      return result;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // Create Addon option
  Future<dynamic> createAddOnOption(
      AddOnOption addOnOption, String productId) async {
    final String url = "${AppConfig.baseUrl}/api/v1/products/add-on-options/";

    final headers = await getAuthHeaders();

    final request = http.MultipartRequest("POST", Uri.parse(url));

    request.fields["name"] = addOnOption.name!;
    request.fields["description"] = addOnOption.description!;
    request.fields["is_available"] = jsonEncode(addOnOption.isAvailable);
    request.fields["price"] = addOnOption.price!;

    if (addOnOption.picture != null) {
      // Create multipart using filepath, string or bytes
      final multipartFile =
          await http.MultipartFile.fromPath("picture", addOnOption.picture!);

      // Add multipart to request
      request.files.add(multipartFile);
    }

    // debugPrint('createAddOnOption FIELDS -> ${request.fields}');

    headers.forEach((k, v) => request.headers[k] = v);

    request.fields.forEach((key, value) {
      debugPrint("$key :- $value");
    });

    final response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller image, Your image is too large.");
    }
    final responseBody = await response.stream.bytesToString();
    // debugPrint(responseBody);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // debugPrint("DATA:- ${request.fields}");
      // debugPrint(
      //     "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");

      final AddOnOption addOnOption =
          AddOnOption.fromJson(jsonDecode(responseBody));

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
    final String url = "${AppConfig.baseUrl}/api/v1/products/add-ons/";

    final headers = await getAuthHeaders();

    final request = http.Request("POST", Uri.parse(url));

    final List<int?> idList =
        addOns.options!.map((option) => option.id).toList();
    request.body = json.encode({
      "name": addOns.name!,
      "description": addOns.description!,
      "is_required": addOns.isRequired,
      "select_type": addOns.selectType!.toLowerCase(),
      "options": idList
    });

    // debugPrint('DATA from ---> ${request.body}');

    headers.forEach((k, v) => request.headers[k] = v);

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();
    // debugPrint(responseBody);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // debugPrint("DATA:- ${request.fields}");
      // debugPrint(
      //     "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");

      final jsonData = jsonDecode(responseBody);

      final AddOns addOns = AddOns();
      addOns.id = jsonData['id'];
      addOns.name = jsonData['name'];
      addOns.description = jsonData['description'];
      addOns.inputType = jsonData['input_type'];
      addOns.selectType = jsonData['select_type'];
      addOns.isRequired = jsonData['is_required'];

      final List<AddOnOption> options = [];

      for (var item in jsonData['options']) {
        final AddOnOption addOnOption = AddOnOption();
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
    final String url = "${AppConfig.baseUrl}/api/v1/products/add-ons/$id/";
    final headers = await getAuthHeaders();
    final response = await httpDelete(
      url,
      headers: headers,
    );

    // debugPrint(
    //     "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
    if (response.statusCode == 204) {
      return true;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // delete Add-on option
  Future<bool> deleteAddOnOption(int? id) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/add-on-option/$id/";
    final headers = await getAuthHeaders();
    final response = await httpDelete(
      url,
      headers: headers,
    );

    // debugPrint(
    //     "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
    if (response.statusCode == 204) {
      return true;
    } else {
      final jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // Update Addon
  Future<dynamic> updateAddOn(AddOns addOns, String productId) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/add-ons/${addOns.id}/";

    final headers = await getAuthHeaders();

    final request = http.Request("PATCH", Uri.parse(url));

    final List idList = addOns.options!.map((option) => option.id).toList();
    request.body = json.encode({
      "name": addOns.name!,
      "description": addOns.description!,
      "is_required": addOns.isRequired,
      "select_type": addOns.selectType!.toLowerCase(),
      "options": idList.isNotEmpty ? idList : "null"
    });

    // debugPrint('DATA from ---> ${addOns.id}');
    // debugPrint('DATA from ---> ${request.body}');

    headers.forEach((k, v) => request.headers[k] = v);

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();
    // debugPrint(responseBody);

    if (response.statusCode == 201 || response.statusCode == 200) {
      // debugPrint("DATA:- ${request.fields}");
      // debugPrint(
      //     "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");

      final jsonData = jsonDecode(responseBody);

      final AddOns addOns = AddOns();
      addOns.id = jsonData['id'];
      addOns.name = jsonData['name'];
      addOns.description = jsonData['description'];
      addOns.inputType = jsonData['input_type'];
      addOns.selectType = jsonData['select_type'];
      addOns.isRequired = jsonData['is_required'];

      final List<AddOnOption> options = [];

      for (var item in jsonData['options']) {
        // debugPrint("add-on option id:- ${item['id']}");

        final AddOnOption addOnOption = AddOnOption.fromJson(item);
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
  Future<AddOnOption> updateAddOnOption(
      AddOnOption addOnOption, String productId) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/products/add-on-options/${addOnOption.id}/";

    final headers = await getAuthHeaders();

    final request = http.MultipartRequest("PATCH", Uri.parse(url));

    request.fields["name"] = addOnOption.name ?? "";
    request.fields["description"] = addOnOption.description ?? "";
    request.fields["is_available"] = jsonEncode(addOnOption.isAvailable);
    request.fields["price"] = addOnOption.price ?? "";

    if (addOnOption.picture != null && !addOnOption.picture!.contains("http")) {
      // Create multipart using filepath, string or bytes
      final http.MultipartFile multipartFile =
          await http.MultipartFile.fromPath(
              "picture", addOnOption.picture ?? "");

      // Add multipart to request
      request.files.add(multipartFile);
    }

    // debugPrint('createAddOnOption FIELDS -> ${request.fields}');

    headers.forEach((k, v) => request.headers[k] = v);

    request.fields.forEach((key, value) {
      debugPrint("$key :- $value");
    });

    final response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller image, Your image is too large.");
    }
    final responseBody = await response.stream.bytesToString();
    // debugPrint(responseBody);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // debugPrint("DATA:- ${request.fields}");
      // debugPrint(
      //     "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");

      final AddOnOption addOnOption =
          AddOnOption.fromJson(jsonDecode(responseBody));

      return addOnOption;
    } else {
      debugPrint("DATA:- ${request.fields}");
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- $responseBody");
      return Future.error("ERROR:- $responseBody");
    }
  }

  Future<ProductDetails> getProductLink() async {
    final String url = "${AppConfig.baseUrl}/api/v1/products/add-by-token/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    // debugPrint('Status of KYC...${response.body} and ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return ProductDetails.fromJson(jsonData);
    } else {
      showToast(message: response.body.toString());
      throw response.body;
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
