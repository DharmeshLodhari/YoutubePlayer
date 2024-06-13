import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/courier_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/shipping_option_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';

class ShippingProcessAuthService extends AuthService {
  // Get all package details in cart
  Future<List<PackageDetailsModel>> getAllPackageDetail(
      bool isSharedCart, String cartId) async {
    try {
      String url = AppConfig.baseUrl;

      if (!isSharedCart) {
        url += "/api/v1/shopping-cart/item-addresses/";
      } else {
        url += "/api/v1/shopping-cart/shared-cart/$cartId/item-addresses/";
      }

      final headers = await getAuthHeaders();
      final response = await httpGet(url, headers: headers);
      final jsonData = jsonDecode(response.body);
      debugPrint('Fetch Package Details BODY ---> ${response.body}');
      debugPrint("response ${response.body}");
      debugPrint("${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List jsonDataResult = jsonData;
        return jsonDataResult
            .map((json) => PackageDetailsModel.fromJson(json))
            .toList();
      } else {
        showToast(message: response.body.toString());
        throw response.body;
      }
    } on Exception catch (e) {
      showToast(message: e.toString());
      debugPrint("response $e");
      debugPrint("Error: $e");
      throw e;
    } catch (err) {
      showToast(message: err.toString());
      debugPrint("$err");
      throw err;
    }
  }

  // List shipping options
  Future<List<ShippingOptionModel>> getShippingEstimation(
      PackageDetailsModel packageDetailsModel, String cartId) async {
    String url = AppConfig.baseUrl;
    if (packageDetailsModel.shippingType == ShippingTypes.slydo) {
      url +=
          "/api/v1/shipping/get-rates/slydo/?delivery_address_id=${packageDetailsModel.deliveryAddress?.id}&pickup_address_id=${packageDetailsModel.addressId}"
          "&anonymous=false&cart_id=$cartId&currency=NGN&merchant=${packageDetailsModel.merchant}";
    } else if (packageDetailsModel.shippingType == ShippingTypes.merchant) {
      url +=
          "/api/v1/shipping-options/public-list/${packageDetailsModel.merchant}/";
    } else if (packageDetailsModel.shippingType == ShippingTypes.courier) {
      url +=
          "/api/v1/shipping/get-rates/terminal/?delivery_address_id=${packageDetailsModel.deliveryAddress?.id}&pickup_address_id=${packageDetailsModel.addressId}"
          "&anonymous=false&cart_id=$cartId&currency=NGN&merchant=${packageDetailsModel.merchant}/";
    }

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    final jsonData = jsonDecode(response.body);

    debugPrint('URL :: $url');
    debugPrint('BODY shipping:: ${response.body}');
    debugPrint('STATUS CO  :: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (packageDetailsModel.shippingType == ShippingTypes.courier) {
        final List jsonDataResult = json.decode(response.body);
        return jsonDataResult
            .map((json) => CourierModel.fromJson(json).toShippingOptionModel())
            .toList();
      }
      final List jsonDataResult = jsonData['results'];
      return jsonDataResult
          .map((json) => ShippingOptionModel.fromJson(json))
          .toList();
    } else {
      debugPrint('BODY shipping 00:: ${response.body}');

      return Future.error(response.body);
    }
  }

  // Placing An order
  Future<dynamic> placeOrder(
      {Map? data,
      bool? isCartProcess,
      bool? isSharedCart,
      String? sharedCartId}) async {
    String url = AppConfig.baseUrl;
    if (isCartProcess == true) {
      url += "/api/v1/shopping-cart/";
    } else if (isSharedCart == true) {
      url +=
          "/api/v1/shopping-cart/place-order-from-shared-cart/$sharedCartId/";
    } else {
      url += "/api/v1/shopping-cart/buy-now/";
    }
    final _data = jsonEncode(data);
    debugPrint('Order details ::: $_data');

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: _data);
    final jsonData = jsonDecode(response.body);

    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonData;
    } else {
      showToast(message: response.body.toString());
      throw response.body;
    }
  }

  // List of Addresses
  Future<Map<String, dynamic>?> getAddressListing(
      String? next, String? previous, Map? data) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/shipping/addresses/list-given-addresses/";
    } else {
      url = getSecureUrl(url: next);
    }

    final _data = jsonEncode(data);
    debugPrint('My Job URL ---> $url');

    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: _data);
    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<ShippingAddress> addresses = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final ShippingAddress categories = ShippingAddress.fromJson(item);
        addresses.add(categories);
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": addresses
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  Future<String> getCartId() async {
    final String url = "${AppConfig.baseUrl}/api/v1/shopping-cart/?id=true";

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    // var jsonData = jsonDecode(response.body);

    debugPrint('URL :: $url');
    debugPrint('BODY shipping:: ${response.body}');
    debugPrint('STATUS CO  :: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);

      final String id = data['id'];

      return id;
    } else {
      debugPrint('BODY shipping 00:: ${response.body}');

      return Future.error(response.body);
    }
  }
}
