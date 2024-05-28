import 'dart:convert';

import 'package:Slydo/screens/more_apps/utility/models/bill_payment_model.dart';
import 'package:Slydo/screens/more_apps/utility/models/provider_product_model.dart';
import 'package:Slydo/screens/more_apps/utility/models/utility_transaction_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';

import '../../../data/environment.dart';
import '../../../utils/enums.dart';
import 'models/provider_model.dart';

class UtilityAuth extends AuthService {
  Future<Map<String, dynamic>?> getUtilityProviderList(
      String? next, String? previous,
      {required UtilitiesProvidersEnum providerEnum}) async {
    final String utilitiesProvider = enumToString(providerEnum);

    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl +
          "/api/v1/utilities/providers/?category=$utilitiesProvider";
    } else {
      url = getSecureUrl(url: next);
    }

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<ProviderModel> providerModelList = [];

      final jsonData = json.decode(response.body);

      final List providerListResults = jsonData['results'];

      providerListResults.forEach((json) {
        final ProviderModel providerModel = ProviderModel.fromJson(json);
        providerModelList.add(providerModel);
      });

      final Map<String, dynamic> result = {
        "next": jsonData["next"],
        "count": jsonData["count"],
        "results": providerModelList,
        "previous": jsonData["previous"],
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  Future<List<ProviderProductModel>> getUtilityProviderProduct(
      {required String providerId}) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/utilities/providers/$providerId/";

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    debugPrint('provider details response ::: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List providerProduct = jsonDecode(response.body)['products'];
      final List<ProviderProductModel> providerDetailsModelList =
          providerProduct
              .map((json) => ProviderProductModel.fromJson(json))
              .toList();
      return providerDetailsModelList;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  Future<Map<String, dynamic>?> getUtilityTransactions(
      String? next, String? previous) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl + "/api/v1/utilities/transactions/";
    } else {
      url = getSecureUrl(url: next);
    }

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint('HISTORY :::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      final List resultList = jsonData['results'];

      final List<UtilityHistoryModel> utilityHistoryModelList =
          resultList.map((json) => UtilityHistoryModel.fromJson(json)).toList();

      final Map<String, dynamic> result = {
        "next": jsonData["next"],
        "count": jsonData["count"],
        "results": utilityHistoryModelList,

        // [
        //   {
        //     "id": "3182c6bf-cc4c-428c-8cc7-a7869653e3be",
        //     "status": "Successful",
        //     "customer_username": "tosinmomodu",
        //     "created_at": "2022-04-14T17:38:20.951735Z",
        //     "product": {
        //       "name": "Prepaid",
        //       "amount": 100000,
        //       "currency": "NGN",
        //       "id": "feded17b-db7e-425d-b2bd-2798fb9d7467",
        //       "provider": {
        //         "name": "Eko Electricity Distribution Company Plc",
        //         "avatar":
        //             "https://slydo-assets.s3.amazonaws.com/media/provider_avatars/ea494008-6209-4f87-98b1-4397c90cf8b6.jpg",
        //         "id": "afc2f974-2a60-4706-8106-46bdf5cb59ee"
        //       }
        //     },
        //   },
        // ],
        // "results": jsonData['results'],
        "previous": jsonData["previous"],
      };

      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  Future<UtilityHistoryModel?> getUtilityTransactionsDetails(
      {required String transactionsId}) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/utilities/transactions/$transactionsId/";

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint('TRANSACTION DETAILS RESPONSE ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return UtilityHistoryModel.fromJson(jsonData);
    } else {
      return null;
    }
  }

  Future<String?> verifyCustomerReferenceNumber({
    required String productId,
    required String providerId,
    required String customerRefNum,
  }) async {
    final String url =
        AppConfig.baseUrl + "/api/v1/utilities/ref-number-lookup/";

    // var data = {
    //   "product_id": productId,
    //   "provider_id": providerId,
    //   "customer_ref_num": customerRefNum,
    // };

    // debugPrint('data ----> $data');

    final data = {
      "customer_ref_num": '0105498919',
      "product_id": "e5743eed-769b-484f-8545-6e9fdb61a016",
      "provider_id": "b8783924-dbb9-413e-99d3-c504cb4dead5"
    };
    final _body = jsonEncode(data);
    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: _body);

    debugPrint('VERIFY REFERENCE RESPONSE ::: ${response.body}');
    return 'a';
    if (response.statusCode == 200 || response.statusCode == 201) {
      // return jsonDecode(response.body)['customer_id'];
    } else {
      return null;
    }
  }

  Future<bool> payUtilityBill(
      {required BillPaymentModel billPaymentModel}) async {
    final String url = AppConfig.baseUrl + "/api/v1/utilities/payment/";

    final Map<String, dynamic> data = billPaymentModel.toJson();

    // var data = {
    //   "amount": 1000,
    //   "customer_ref_num": '0105498919',
    //   "product_id": "e5743eed-769b-484f-8545-6e9fdb61a016",
    //   "customer_id": "ed448481-9d61-41ce-a480-a5fa4bf1b613",
    //   "provider_id": "b8783924-dbb9-413e-99d3-c504cb4dead5",
    // };
    final _body = jsonEncode(data);
    final headers = await getAuthHeaders();
    final response = await httpPost(url, headers: headers, body: _body);

    debugPrint('PAYMENT RESPONSE ::: ${response.body}');

    return true;
  }
}
