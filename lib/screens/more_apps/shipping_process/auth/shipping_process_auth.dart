import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/courier_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shipping_option_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';

class ShippingProcessAuthService extends AuthService {
  // Get all package details in cart
  Future<List<PackageDetailsModel>> getAllPackageDetail() async {
    try {
      var url = "${AppConfig.baseUrl}/api/v1/shopping-cart/item-addresses/";

      var headers = await getAuthHeaders();
      var response = await httpGet(url, headers: headers);
      var jsonData = jsonDecode(response.body);
      debugPrint('Fetch Package Details BODY ---> ${response.body}');
      print("response ${response.body}");
      print(response.statusCode);
      if (response.statusCode == 200) {
        List jsonDataResult = jsonData;
        return jsonDataResult
            .map((json) => PackageDetailsModel.fromJson(json))
            .toList();
      } else {
        showToast(message: response.body.toString());
        throw response.body;
      }
    } on Exception catch (e) {
      showToast(message: e.toString());
      debugPrint("response ${e}");
      print(e);
      throw e;
    } catch (err) {
      showToast(message: err.toString());
      print(err);
      throw err;
    }
  }

  // List shipping options
  Future<List<ShippingOptionModel>> getShippingEstimation(
      PackageDetailsModel packageDetailsModel) async {
    String url = AppConfig.baseUrl;
    if (packageDetailsModel.shippingType == ShippingTypes.slydo) {
      url +=
          "/api/v1/shipping/get-rates/slydo/?delivery_address_id=${packageDetailsModel.deliveryAddress?.id}&pickup_address_id=${packageDetailsModel.addressId}"
          "&anonymous=true&cart_id=29be44ec-fa3f-4980-a98e-64c828cca9fc&currency=NGN&merchant=${packageDetailsModel.merchant}";
    } else if (packageDetailsModel.shippingType == ShippingTypes.merchant) {
      url +=
          "/api/v1/shipping-options/public-list/${packageDetailsModel.merchant}";
    } else if (packageDetailsModel.shippingType == ShippingTypes.courier) {
      url +=
          "/api/v1/shipping/get-rates/terminal/?delivery_address_id=${packageDetailsModel.deliveryAddress?.id}&pickup_address_id=${packageDetailsModel.addressId}"
          "&anonymous=false&cart_id=29be44ec-fa3f-4980-a98e-64c828cca9fc&currency=NGN&merchant=${packageDetailsModel.merchant}";
    }

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = jsonDecode(response.body);

    debugPrint('URL :: $url');
    debugPrint('BODY shipping:: ${response.body}');
    debugPrint('STATUS CO  :: ${response.statusCode}');

    if (response.statusCode == 200) {
      if (packageDetailsModel.shippingType == ShippingTypes.courier) {
        List jsonDataResult = json.decode(response.body);
        return jsonDataResult
            .map((json) => CourierModel.fromJson(json).toShippingOptionModel())
            .toList();
      }
      List jsonDataResult = jsonData['results'];
      return jsonDataResult
          .map((json) => ShippingOptionModel.fromJson(json))
          .toList();
    } else {
      debugPrint('BODY shipping 00:: ${response.body}');

      return Future.error(response.body);
    }
  }

  // Placing An order
  Future<dynamic> placeOrder({Map? data}) async {
      var url = "${AppConfig.baseUrl}/api/v1/shopping-cart/";
      var _data = jsonEncode(data);
      debugPrint('Order details ::: $_data');

      var headers = await getAuthHeaders();
      var response = await httpPost(url, headers: headers, body: _data);
      var jsonData = jsonDecode(response.body);

      debugPrint(
          "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      if (response.statusCode == 201) {
        return jsonData;
      } else {
        showToast(message: response.body.toString());
        throw response.body;
      }
  }
}
