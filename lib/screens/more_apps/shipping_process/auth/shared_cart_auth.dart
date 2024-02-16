import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SharedCartAuthService extends AuthService {
  // Create Shared Shopping cart group
  Future<bool> createCartGroup({Map? data}) async {
    String url =
        "${AppConfig.baseUrl}/api/v1/shopping-cart/create-shared-shopping-cart/";
    var _data = jsonEncode(data);
    debugPrint('Order details ::: $_data');

    var headers = await getAuthHeaders();
    var response = await httpPost(url, headers: headers, body: _data);
    var jsonData = jsonDecode(response.body);

    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    return false;
  }

  //List Shared Shopping Carts
  Future<Map<String, dynamic>?> getSharedCartList(
      String? next, String? previous) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/shopping-cart/list-shared-shopping-cart/";
    } else {
      url = getSecureUrl(url: next);
    }

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers)
        .timeout(timeOutDuration, onTimeout: () => timeOutFunction());

    print('List of cart group ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<SharedCartModel> sharedCart = [];
      var jsonData = json.decode(response.body);

      // Map<String, dynamic> jsonData = {
      //   "results": [
      //     {
      //       "id": "ceeeb02b-8461-47da-83e8-0fab4048f6c2",
      //       "members_details": [
      //         {
      //           "username": "psami",
      //           "avatar":
      //               "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
      //           "full_name": "Samo"
      //         },
      //         {
      //           "username": "japa",
      //           "avatar":
      //               "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/ca75f781-3615-4e3c-9e65-803ebcf7eb4b.jpg",
      //           "full_name": "Japa Inc"
      //         },
      //         {
      //           "username": "blackstriker",
      //           "avatar":
      //               "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/310d1a87-48e9-4fee-b876-36cae907dcf7.jpg",
      //           "full_name": "Black Striker Enterprise"
      //         },
      //         {
      //           "username": "psami",
      //           "avatar":
      //               "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
      //           "full_name": "Samo"
      //         },
      //         {
      //           "username": "japa",
      //           "avatar":
      //               "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/ca75f781-3615-4e3c-9e65-803ebcf7eb4b.jpg",
      //           "full_name": "Japa Inc"
      //         },
      //         {
      //           "username": "blackstriker",
      //           "avatar":
      //               "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/310d1a87-48e9-4fee-b876-36cae907dcf7.jpg",
      //           "full_name": "Black Striker Enterprise"
      //         }
      //       ],
      //       "name": "My special cart",
      //       "shared": true,
      //       "members": ["psami", "japa", "blackstriker"],
      //       "customer_username": "sanxynet",
      //       "created_at": "2024-01-29T14:15:19.164792+01:00",
      //       "cart_items": {}
      //     },
      //     {
      //       "id": "29e6e39b-4c6c-4ecf-b2bc-b9fc1d7f3538",
      //       "members_details": [
      //         {
      //           "username": "psami",
      //           "avatar":
      //               "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
      //           "full_name": "Samo"
      //         },
      //         {
      //           "username": "japa",
      //           "avatar":
      //               "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/ca75f781-3615-4e3c-9e65-803ebcf7eb4b.jpg",
      //           "full_name": "Japa Inc"
      //         },
      //       ],
      //       "name": "Birthday hangout",
      //       "shared": true,
      //       "members": ["psami", "okey", "boss", "sam"],
      //       "customer_username": "psami",
      //       "created_at": "2023-10-23T17:17:11.581465+01:00"
      //     },
      //     {
      //       "id": "1efe0ea8-5029-4d39-af3e-3b2f89216993",
      //       "members_details": [
      //         {
      //           "username": "psami",
      //           "avatar":
      //               "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
      //           "full_name": "Samo"
      //         },
      //         {
      //           "username": "japa",
      //           "avatar":
      //               "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/ca75f781-3615-4e3c-9e65-803ebcf7eb4b.jpg",
      //           "full_name": "Japa Inc"
      //         },
      //         {
      //           "username": "boss",
      //           "avatar": "http://0.0.0.0:8000/static/images/User_Avatar.png",
      //           "full_name": "boss"
      //         }
      //       ],
      //       "name": "Picnic Hangout",
      //       "shared": true,
      //       "members": ["psami", "sam", "boss"],
      //       "customer_username": "psami",
      //       "created_at": "2023-10-25T06:35:58.780674+01:00"
      //     }
      //   ],
      // };

      for (var item in jsonData["results"]) {
        SharedCartModel categories = SharedCartModel.fromJson(item);
        sharedCart.add(categories);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": sharedCart
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  Future<SharedCartModel> getCartDetails(String? cartId) async {
    var url = "${AppConfig.baseUrl}/api/v1/shopping-cart/$cartId/";

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers)
        .timeout(timeOutDuration, onTimeout: () => timeOutFunction());

    print('List of cart group ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return SharedCartModel.fromJson(jsonData);
    } else {
      return Future.error(response.body);
    }
  }

  //List Shared cart Items
  Future<Map<String, dynamic>?> getCartItemDetails(
      String? cartId, String? next, String? previous) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/shopping-cart/list-shared-shopping-cart-details/$cartId/";
    } else {
      url = getSecureUrl(url: next);
    }

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers)
        .timeout(timeOutDuration, onTimeout: () => timeOutFunction());

    print('List of cart group ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      // List cartItem = [];
      var jsonData = json.decode(response.body);

      // Map<String, dynamic> jsonData = {
      //   "results": [
      //     {
      //       "id": "a3c3953c-937b-4763-8e24-83b631e9c707",
      //       "type": "product",
      //       "name": "Stylish Haircut 20",
      //       "short_description": "Get your stylish haircut with us",
      //       "description": "Get your stylish haircut with us",
      //       "category": "Men's Fashion",
      //       "condition": "Good",
      //       "currency": "NGN",
      //       "price": 70008,
      //       "created_at": "2023-10-04T12:45:32.090039Z",
      //       "available_from": "2023-10-04",
      //       "is_available": true,
      //       "qr_code":
      //           "http://0.0.0.0:8000/media/products/qr-code/bb0a2c94-4312-4c5a-9158-01ac843aa5d1.png",
      //       "quantity": 4,
      //       "seller": "psami",
      //       "seller_fullname": "psami",
      //       "seller_avatar": "http://0.0.0.0:8000/static/images/User_Avatar.png",
      //       "manufacturer": null,
      //       "pictures": [
      //         {
      //           "id": 43,
      //           "file":
      //               "http://0.0.0.0:8000/media/pngtree-concept-banking-logo-png-image_712961_qsQEX3y.jpg",
      //           "title": "Image 1"
      //         },
      //         {
      //           "id": 44,
      //           "file":
      //               "http://0.0.0.0:8000/media/WhatsApp_Image_2023-08-14_at_6.49.35_AM_ut06rxA.jpeg",
      //           "title": "Image 2"
      //         }
      //       ],
      //       "cover":
      //           "https://0.0.0.0:8000/media/pngtree-concept-banking-logo-png-image_712961_qsQEX3y.jpg",
      //       "web_url": "/store/product/a3c3953c-937b-4763-8e24-83b631e9c707/",
      //       "rating": 0,
      //       "enable_in_superstore": true,
      //       "variants": [],
      //       "weight": 2.0,
      //       "weight_si_unit": "kg",
      //       "height": 20.0,
      //       "height_si_unit": "cm",
      //       "width": 20.0,
      //       "width_si_unit": "cm",
      //       "track_inventory": true,
      //       "is_shippable": true,
      //       "add_ons": [
      //         {
      //           "id": 41,
      //           "options": [
      //             {
      //               "id": 7,
      //               "picture": "http://0.0.0.0:8000/media/cloudbet_pPAcE1g.png",
      //               "name": "Tash",
      //               "description": null,
      //               "merchant": "psami",
      //               "currency": "NGN",
      //               "price": 2000,
      //               "is_available": true,
      //               "created_at": "2023-10-17T06:46:09.642350Z",
      //               "quantity": 3
      //             }
      //           ],
      //           "merchant": "psami",
      //           "name": "Protein",
      //           "description": "Yeahhhh",
      //           "input_type": "radio",
      //           "select_type": "single",
      //           "is_required": true,
      //           "created_at": "2023-10-17T09:20:07.076947Z"
      //         }
      //       ],
      //       "created_by": "psami",
      //       "updated_by": "psami",
      //       "qty": 4
      //     }
      //   ],
      // };

      // for (var item in jsonData["results"]) {
      //   Product categories = Product.fromJson(item);
      //   cartItem.add(item);
      // }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": getCartItems(jsonData)
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  List<dynamic> getCartItems(var jsonResponse) {
    List items = [];
    var data = jsonResponse["results"];

    for (int i = 0; i < data.length; i++) {
      if (data[i]["type"] == "product") {
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

  Future<bool> addItemToSharedCart(String? cart_id, Map data) async {
    var url = AppConfig.baseUrl +
        "/api/v1/shopping-cart/add-item-to-shared-cart/$cart_id/";
    var _data = jsonEncode(data);
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<bool> removeItemFromSharedCart(String? cart_id, Map data) async {
    var url = AppConfig.baseUrl +
        "/api/v1/shopping-cart/remove-item-from-shared-cart/$cart_id/";
    var _data = jsonEncode(data);
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    } else
      return false;
  }

  Future<bool> addMemberToSharedCart(String? cart_id, Map data) async {
    var url = AppConfig.baseUrl +
        "/api/v1/shopping-cart/add-members-to-shared-shopping-cart/$cart_id/";
    var _data = jsonEncode(data);
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    } else
      return false;
  }

  Future<bool> removeMemberFromSharedCart(String? cart_id, Map data) async {
    var url = AppConfig.baseUrl +
        "/api/v1/shopping-cart/remove-members-from-shared-shopping-cart/$cart_id/";
    var _data = jsonEncode(data);
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    } else
      return false;
  }

  Future<bool> requestPayment(String? cart_id, Map data) async {
    var url = AppConfig.baseUrl +
        "/api/v1/shopping-cart/update-cart-meta-data-shared-shopping-cart/$cart_id/";
    var _data = jsonEncode(data);
    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers, body: _data);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
