import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/delivery_option_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/merchant_address_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';

class ShippingProcessAuthService extends AuthService {
  // Get Merchant and addresses in cart
  Future<MerchantAddressModel?> getMerchantAddress(String? jobId) async {
    try {
      var url = "${AppConfig.baseUrl}/api/v1/shopping-cart/item-addresses";

      var headers = await getAuthHeaders();
      var response = await httpGet(url, headers: headers);
      debugPrint('Fetch Delivery Options BODY ---> ${response.body}');

      print(response.statusCode);
      if (response.statusCode == 200) {
        return MerchantAddressModel.fromJson(json.decode(response.body));
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

  // List Delivery options
  Future<List<DeliveryOptionModel>> getDeliveryOption() async {
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
          .map((json) => DeliveryOptionModel.fromJson(json))
          .toList();
    } else {
      debugPrint('BODY shipping 00:: ${response.body}');

      return Future.error(response.body);
    }
  }

  // List of packages of order
  // Future<List<DeliveryOptionModel>> getPackagesList() async {
  //   var url = AppConfig.baseUrl + "/api/v1/shopping-cart/item-addresses";
  //   var headers = await getAuthHeaders();
  //   var response = await httpGet(url, headers: headers);
  //   var jsonData = jsonDecode(response.body);
  //
  //   debugPrint('URL :: $url');
  //   debugPrint('BODY shipping:: ${response.body}');
  //   debugPrint('STATUS CO  :: ${response.statusCode}');
  //
  //   if (response.statusCode == 200) {
  //     List jsonDataResult = jsonData['results'];
  //
  //     return jsonDataResult
  //         .map((json) => DeliveryOptionModel.fromJson(json))
  //         .toList();
  //   } else {
  //     debugPrint('BODY shipping 00:: ${response.body}');
  //
  //     return Future.error(response.body);
  //   }
  // }
}
