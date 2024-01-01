import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shipping_option_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/cupertino.dart';

class ShippingProcessAuthService extends AuthService {
  // Get all package details in cart
  Future<List<PackageDetailsModel>> getAllPackageDetail() async {
    var url = "${AppConfig.baseUrl}/api/v1/shopping-cart/item-addresses";

    var headers = await getAuthHeaders();
    // var response = await httpGet(url, headers: headers);
    // var jsonData = jsonDecode(response.body);
    // debugPrint('Fetch Package Details BODY ---> ${response.body}');
    // print("response ${response.body}");
    // print(response.statusCode);
    // if (response.statusCode == 500) {
    List jsonDataResult = [
      {
        "merchant": "cameraman",
        "address_id": "AD-ND3ZNKNGWAONVW0J",
        "total_items": 6,
        "total_price": 2000672
      },
      {
        "merchant": "sanxynet",
        "address_id": "AD-3YHHLBYD9K3P8M1I",
        "total_items": 1,
        "total_price": 632304
      }
    ];

    // List jsonDataResult = jsonData;
    return jsonDataResult
        .map((json) => PackageDetailsModel.fromJson(json))
        .toList();
    // } else {
    //   showToast(message: response.body.toString());
    //   throw response.body;
    // }
  }

  // List ship with slydo
  Future<List<ShippingOptionModel>> getShipWithSlydo() async {
    var url = AppConfig.baseUrl + "/api/v1/shipping-options/system/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = jsonDecode(response.body);

    debugPrint('URL :: $url');
    debugPrint('BODY shipping:: ${response.body}');
    debugPrint('STATUS CO  :: ${response.statusCode}');

    if (response.statusCode == 200) {
      List jsonDataResult = jsonData['results'];

      return jsonDataResult
          .map((json) => ShippingOptionModel.fromJson(json))
          .toList();
    } else {
      debugPrint('BODY shipping 00:: ${response.body}');

      return Future.error(response.body);
    }
  }

  // List ship with merchant
  Future<List<ShippingOptionModel>> getShipWithMerchant(
      String? merchantName) async {
    var url =
        AppConfig.baseUrl + "/api/v1/shipping-options/public-list/$merchantName";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = jsonDecode(response.body);

    debugPrint('URL :: $url');
    debugPrint('BODY shipping:: ${response.body}');
    debugPrint('STATUS CO  :: ${response.statusCode}');

    if (response.statusCode == 200) {
      List jsonDataResult = jsonData['results'];

      return jsonDataResult
          .map((json) => ShippingOptionModel.fromJson(json))
          .toList();
    } else {
      debugPrint('BODY shipping 00:: ${response.body}');

      return Future.error(response.body);
    }
  }
}
