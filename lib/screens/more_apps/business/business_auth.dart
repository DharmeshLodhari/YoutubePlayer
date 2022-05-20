import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';

import '../../../utils/enums.dart';
import '../../../utils/util.dart';
import 'models/Contract.dart';
import 'models/Invoice.dart';
import 'models/Item.dart';

class BusinessAuth extends AuthService {
  /// Contract and Invoice
  //get all contract list
  Future<Map<String, dynamic>?> getContractList(String? next,
      {ContractStatus? contractStatus, required bool isContractor}) async {
    var url = "";
    if (next == null) {
      return null;
    }

    debugPrint('IS CONTRACTOR :: $isContractor');
    if (next == "") {
      url = AppConfig.baseUrl + "/api/v1/transactions/payment-contract/";

      url = url + "?is_contractor=$isContractor";

      if (contractStatus != null) {
        url = url + "&status=${contractStatus.name}";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    print('GET CONTRACT LIST URL :: $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      debugPrint('GET CONTRACT LIST :::: $jsonData');

      List<ContractModel> contractList = [];
      List jsonResult = jsonData['results'];

      jsonResult.forEach((json) {
        contractList.add(ContractModel.fromJson(json));
      });

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": contractList
      };
      return result;
    } else if (response.statusCode == 404) {
      var jsonData = json.decode(response.body);

      return jsonData;
    } else {
      return Future.error(response.body);
    }
  }

  Future<ContractModel> getContract(String id) async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/payment-contract/$id/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('GET CONTRACT ::: ${json.decode(response.body)}');
    if (response.statusCode == 200) {
      ContractModel contract =
          ContractModel.fromJson(json.decode(response.body));

      return contract;
    } else {
      var jsonData = json.decode(response.body);
      return Future.error(jsonData.toStiring());
    }
  }

  Future<bool> acceptContract({required int contractId}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/transactions/payment-contract/accepted/$contractId";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('ACCEPT CONTRACT ::: ${json.decode(response.body)}');
    debugPrint('ACCEPT CONTRACT STATUS CODE::: ${response.statusCode}');
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> cancelContract({required int contractId}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/transactions/payment-contract/reject-or-cancel/$contractId/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('CANCEL CONTRACT ::: ${response.body}');
    debugPrint('CANCEL CONTRACT STATUSCODE ::: ${response.statusCode}');
    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<String?> getConversationId({required String name}) async {
    var url = AppConfig.baseUrl + "/api/v1/user/contacts/get-conversation-id/";

    var data = {"contact": name};

    var headers = await getAuthHeaders();
    var response =
        await httpPost(url, body: jsonEncode(data), headers: headers);

    debugPrint('GET CONVERSATION ID :: ${response.body}');
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return jsonData['conversation_id'];
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getContractTransactions(
      String? next, String? previous, bool moneyIn, bool moneyOut) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = AppConfig.baseUrl + "/api/v1/transactions/list/";
      if (moneyIn) {
        url = url + "?money_in=true";
      }
      if (moneyOut) {
        url = url + "?money_out=true";
      }
    } else {
      url = next;
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint("${response.body}");
    if (response.statusCode == 200) {
      List<Transaction> transactions = [];
      // This variable will hold list of transactions we got from server
      // var user = await getUser();
      var jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        // if sender is not current user then
        bool isCredit = item["is_credit"];

        var payee = isCredit ? item["from_customer"] : item['to_customer'];
        var avatar = isCredit
            ? item["from_customer_avatar"]
            : item['to_customer_avatar'];

        Transaction transaction = Transaction(
            status: item['status'],
            uuid: item['slug'],
            description: item['description'],
            payee: payee,
            avatar: avatar,
            currency: item['currency'],
            createdAt: item['created_at'],
            category: item['category'],
            note: item['notes'],
            latitude: item['latitude'] ?? "",
            longitude: item['longitude'] ?? "",
            amount: item['amount'],
            isAnonymous: item['is_anonymous'] ?? false,
            isCredit: isCredit);
        transactions.add(transaction);
      }
      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": transactions
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  Future<bool> addContract(Map data) async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/payment-contract/";
    var headers = await getAuthHeaders();

    var _data = jsonEncode(data);
    debugPrint("$_data");
    var response = await httpPost(url, body: _data, headers: headers);
    debugPrint('ADD CONTRACT RESPONSE ::: ${response.body}');
    if (response.statusCode == 201) {
      return true;
    } else {
      var jsonData = json.decode(response.body);
      return Future.error(jsonData.toString());
    }
  }

  Future<bool> updateContract({String? id, Map? data}) async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/payment-contract/$id/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);
    debugPrint('UPDATE CONTRACT ::: ${response.body}');
    debugPrint('STATUS :: ${json.decode(response.body)['status']}');

    if (response.statusCode == 200) {
      return true;
    }
    var jsonData = json.decode(response.body);
    return Future.error(jsonData.toString());
  }

  //get all invoice list
  Future<Map<String, dynamic>?> getInvoiceList(String? next, String? previous,
      {InvoiceStatus? invoiceStatus, required bool isSender}) async {
    var url = "";
    if (next == null) {
      return null;
    }

    if (next == "") {
      url = AppConfig.baseUrl + "/api/v1/transactions/invoice/";

      url = url + "?sender=$isSender";

      if (invoiceStatus != null) {
        url = url + "&status=${invoiceStatus.name}";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('INVOICE URL ::: $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('GET INVOICE LIST ::: ${response.body}');
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      List<InvoiceModel> invoiceList = [];
      List jsonResult = jsonData['results'];

      jsonResult.forEach((json) {
        invoiceList.add(InvoiceModel.fromJson(json));
      });

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": invoiceList
      };
      return result;
    } else if (response.statusCode == 404) {
      return jsonData;
    } else {
      return Future.error(jsonData);
    }
  }

  Future<InvoiceModel> getInvoice(String id) async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/invoice/$id/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      InvoiceModel invoice = InvoiceModel.fromJson(json.decode(response.body));
      return invoice;
    }
    var jsonData = json.decode(response.body);
    return Future.error(jsonData.toStiring());
  }

  Future<bool> addInvoice(Map data) async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/invoice/";
    var headers = await getAuthHeaders();

    debugPrint('DATE ::: $data');
    var _data = jsonEncode(data);
    var response = await httpPost(url, body: _data, headers: headers);

    debugPrint('ADD INVOICE RESPONSE ::: ${response.body}');
    if (response.statusCode == 201) {
      return true;
    }
    var jsonData = json.decode(response.body);
    return Future.error(jsonData.toStiring());
  }

  Future<bool> updateInvoice({String? id, Map? data}) async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/invoice/$id/";
    var headers = await getAuthHeaders();

    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);

    if (response.statusCode == 200) {
      return true;
    }
    var jsonData = json.decode(response.body);
    return Future.error(jsonData.toString());
  }

  Future<bool> markInvoiceAsPaid({required int invoiceId}) async {
    var url = AppConfig.baseUrl +
        "/api/v1/transactions/invoice/mark-as-pay/$invoiceId/";
    var headers = await getAuthHeaders();

    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      return true;
    }
    var jsonData = json.decode(response.body);
    return Future.error(jsonData.toString());
  }

  Future<bool> payInvoice({required int invoiceId}) async {
    var url =
        AppConfig.baseUrl + "/api/v1/transactions/invoice/pay/$invoiceId/";
    var headers = await getAuthHeaders();

    var response = await httpGet(url, headers: headers);
    debugPrint('PAY INVOICE ::: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    }
    var jsonData = json.decode(response.body);
    return Future.error(jsonData.toString());
  }

  Future<bool> deleteInvoice({required int invoiceId}) async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/invoice/$invoiceId/";
    var headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);
    debugPrint('DELETE INVOICE ::: ${response.body}');

    if (response.statusCode == 204) {
      return true;
    }
    var jsonData = json.decode(response.body);
    return Future.error(jsonData.toString());
  }

  Future<bool> deleteInvoiceItem({required int itemId}) async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/invoice/item/$itemId/";
    var headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);
    debugPrint('DELETE INVOICE ITEM ::: ${response.body}');
    debugPrint('DELETE INVOICE ITEM ::: ${response.statusCode}');

    if (response.statusCode == 204) {
      return true;
    }
    var jsonData = json.decode(response.body);
    return Future.error(jsonData.toString());
  }

  Future<bool> addInvoiceItemToExistingInvoice(
      {required int invoiceId, required InvoiceItem invoiceItem}) async {
    var url =
        AppConfig.baseUrl + "/api/v1/transactions/invoice/item/$invoiceId/";
    var headers = await getAuthHeaders();
    var data = invoiceItem.toJson();
    data.removeWhere((key, value) => value == null);

    var response =
        await httpPost(url, headers: headers, body: jsonEncode(data));
    debugPrint('ADD INVOICE ITEM TO EXISTING INVOICE ::: ${response.body}');
    debugPrint(
        'ADD INVOICE ITEM TO EXISTING INVOICE::: ${response.statusCode}');
    if (response.statusCode == 200) {
      return true;
    }

    return Future.error(response.body);
  }

  Future<bool> updateInvoiceItem(
      {required int itemId, required InvoiceItem invoiceItem}) async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/invoice/item/$itemId/";
    var headers = await getAuthHeaders();
    var data = invoiceItem.toJson();
    data.removeWhere((key, value) => value == null);

    var response =
        await httpPatch(url, headers: headers, body: jsonEncode(data));
    debugPrint('UPDATE INVOICE ITEM ::: ${response.body}');
    debugPrint('UPDATE INVOICE ITEM ::: ${response.statusCode}');

    if (response.statusCode == 200) {
      return true;
    }

    return Future.error(response.body);
  }

// Future<bool> updateInvoice(Invoice invoice) async {
  //   var url = AppConfig.baseUrl + "/api/v1/messaging/send/";
  //   var headers = await getAuthHeaders();
  //   var data = invoice.toJson();
  //   var _data = jsonEncode(data);
  //   var response = await httpPost(url, body: _data, headers: headers);
  //   if (response.statusCode == 201) {
  //     return true;
  //   }
  //   var jsonData = json.decode(response.body);
  //   return Future.error(jsonData.toStiring());
  // }
}
