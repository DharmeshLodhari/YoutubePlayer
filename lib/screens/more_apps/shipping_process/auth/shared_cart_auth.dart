import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shared_cart_model.dart';
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

    // var headers = await getAuthHeaders();
    // var response = await httpGet(url, headers: headers)
    //     .timeout(timeOutDuration, onTimeout: () => timeOutFunction());
    //
    // print('List of cart group ::: ${response.body}');
    // if (response.statusCode == 200 || response.statusCode == 201) {
    List<SharedCartModel> sharedCart = [];
    //   var jsonData = json.decode(response.body);

    Map<String, dynamic> jsonData = {
      "results": [
        {
          "id": "ceeeb02b-8461-47da-83e8-0fab4048f6c2",
          "members_details": [
            {
              "username": "psami",
              "avatar":
                  "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
              "full_name": "Samo"
            },
            {
              "username": "japa",
              "avatar":
                  "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/ca75f781-3615-4e3c-9e65-803ebcf7eb4b.jpg",
              "full_name": "Japa Inc"
            },
            {
              "username": "blackstriker",
              "avatar":
                  "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/310d1a87-48e9-4fee-b876-36cae907dcf7.jpg",
              "full_name": "Black Striker Enterprise"
            },
            {
              "username": "psami",
              "avatar":
                  "https://slydo-assets.s3.amazonaws.com/static/images/User_Avatar.png",
              "full_name": "Samo"
            },
            {
              "username": "japa",
              "avatar":
                  "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/ca75f781-3615-4e3c-9e65-803ebcf7eb4b.jpg",
              "full_name": "Japa Inc"
            },
            {
              "username": "blackstriker",
              "avatar":
                  "http://cdn.slydo.co.global.prod.fastly.net/media/customer/avatar/310d1a87-48e9-4fee-b876-36cae907dcf7.jpg",
              "full_name": "Black Striker Enterprise"
            }
          ],
          "name": "My special cart",
          "shared": true,
          "members": ["psami", "japa", "blackstriker"],
          "customer_username": "sanxynet",
          "created_at": "2024-01-29T14:15:19.164792+01:00",
          "cart_items": {}
        },
        {
          "id": "29e6e39b-4c6c-4ecf-b2bc-b9fc1d7f3538",
          "members_details": [
            {
              "username": "psami",
              "avatar": "http://0.0.0.0:8000/static/images/User_Avatar.png",
              "full_name": "psami"
            },
            {
              "username": "okey",
              "avatar": "http://0.0.0.0:8000/static/images/User_Avatar.png",
              "full_name": "okey"
            },
            {
              "username": "boss",
              "avatar": "http://0.0.0.0:8000/static/images/User_Avatar.png",
              "full_name": "boss"
            },
            {
              "username": "sam",
              "avatar": "http://0.0.0.0:8000/static/images/User_Avatar.png",
              "full_name": "sam"
            }
          ],
          "name": "My special cart",
          "shared": true,
          "members": ["psami", "okey", "boss", "sam"],
          "customer_username": "psami",
          "created_at": "2023-10-23T17:17:11.581465+01:00"
        },
        {
          "id": "1efe0ea8-5029-4d39-af3e-3b2f89216993",
          "members_details": [
            {
              "username": "psami",
              "avatar": "http://0.0.0.0:8000/static/images/User_Avatar.png",
              "full_name": "psami"
            },
            {
              "username": "sam",
              "avatar": "http://0.0.0.0:8000/static/images/User_Avatar.png",
              "full_name": "sam"
            },
            {
              "username": "boss",
              "avatar": "http://0.0.0.0:8000/static/images/User_Avatar.png",
              "full_name": "boss"
            }
          ],
          "name": "My special cart",
          "shared": true,
          "members": ["psami", "sam", "boss"],
          "customer_username": "psami",
          "created_at": "2023-10-25T06:35:58.780674+01:00"
        }
      ],
    };

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
    // } else if (response.statusCode == 500) {
    //   return null;
    // } else {
    //   return null;
    // }
  }
}
