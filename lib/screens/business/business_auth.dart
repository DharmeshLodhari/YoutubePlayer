import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/payment_and_banking/models/transactions.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/enums.dart';
import 'package:Slydo/utils/util.dart';

import 'models/contract_model.dart';
import 'models/invoice_model.dart';
import 'models/item_model.dart';

class BusinessAuth extends AuthService {
  /// Contract and Invoice
  //get all contract list
  Future<Map<String, dynamic>?> getContractList(String? next,
      {ContractStatus? contractStatus, required bool isContractor}) async {
    String url = "";
    if (next == null) {
      return null;
    }

    // debugPrint('IS CONTRACTOR :: $isContractor');
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/transactions/payment-contract/";

      url = "$url?is_contractor=$isContractor";

      if (contractStatus != null) {
        url = "$url&status=${contractStatus.name}";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    // debugPrint('GET CONTRACT LIST URL :: $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      // debugPrint('GET CONTRACT LIST :::: $jsonData');

      final List<ContractModel> contractList = [];
      final List jsonResult = jsonData['results'];

      for (var json in jsonResult) {
        contractList.add(ContractModel.fromJson(json));
      }

      final Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": contractList
      };
      return result;
    } else if (response.statusCode == 404) {
      final jsonData = json.decode(response.body);

      return jsonData;
    } else {
      return Future.error(response.body);
    }
  }

  Future<ContractModel> getContract(String id) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/transactions/payment-contract/$id/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('GET CONTRACT ::: ${json.decode(response.body)}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final ContractModel contract =
          ContractModel.fromJson(json.decode(response.body));

      return contract;
    } else {
      final jsonData = json.decode(response.body);
      return Future.error(jsonData.toStiring());
    }
  }

  Future<bool> acceptContract({required int contractId}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/transactions/payment-contract/accepted/$contractId";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> cancelOrRejectContract({required int contractId}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/transactions/payment-contract/reject-or-cancel/$contractId/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<String?> getConversationId({required String name}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/user/contacts/get-conversation-id/";

    final data = {"contact": name};

    final headers = await getAuthHeaders();
    final response =
        await httpPost(url, body: jsonEncode(data), headers: headers);

    // debugPrint('GET CONVERSATION ID :: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return jsonData['conversation_id'];
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getContractTransactions(
      String? next, String? previous, bool moneyIn, bool moneyOut) async {
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/transactions/list/";
      if (moneyIn) {
        url = "$url?money_in=true";
      }
      if (moneyOut) {
        url = "$url?money_out=true";
      }
    } else {
      url = next;
    }
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);
    // debugPrint(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<Transaction> transactions = [];
      // This variable will hold list of transactions we got from server
      // var user = await getUser();
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        // if sender is not current user then
        final bool isCredit = item["is_credit"];

        final payee = isCredit ? item["from_customer"] : item['to_customer'];
        final avatar = isCredit
            ? item["from_customer_avatar"]
            : item['to_customer_avatar'];

        final Transaction transaction = Transaction(
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
      final Map<String, dynamic> result = {
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
    final String url =
        "${AppConfig.baseUrl}/api/v1/transactions/payment-contract/";
    final headers = await getAuthHeaders();

    final data0 = jsonEncode(data);
    // debugPrint(data0);
    final response = await httpPost(url, body: data0, headers: headers);
    // debugPrint('ADD CONTRACT RESPONSE ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final jsonData = json.decode(response.body);
      return Future.error(jsonData.toString());
    }
  }

  Future<bool> updateContract({String? id, Map? data}) async {
    final String url =
        "${AppConfig.baseUrl}/api/v1/transactions/payment-contract/$id/";
    final headers = await getAuthHeaders();
    final data0 = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: data0);
    // debugPrint('UPDATE CONTRACT ::: ${response.body}');
    // debugPrint('STATUS :: ${json.decode(response.body)['status']}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    final jsonData = json.decode(response.body);
    return Future.error(jsonData.toString());
  }

  //get all invoice list
  Future<Map<String, dynamic>?> getInvoiceList(String? next, String? previous,
      {InvoiceStatus? invoiceStatus, required bool isSender}) async {
    String url = "";
    if (next == null) {
      return null;
    }

    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/transactions/invoice/";

      url = "$url?sender=$isSender";

      if (invoiceStatus != null) {
        url = "$url&status=${invoiceStatus.name}";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    // debugPrint('INVOICE URL ::: $url');

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    // debugPrint('GET INVOICE LIST ::: ${response.body}');
    final jsonData = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<InvoiceModel> invoiceList = [];
      final List jsonResult = jsonData['results'];

      for (var json in jsonResult) {
        invoiceList.add(InvoiceModel.fromJson(json));
      }

      final Map<String, dynamic> result = {
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
    final url = "${AppConfig.baseUrl}/api/v1/transactions/invoice/$id/";
    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final InvoiceModel invoice =
          InvoiceModel.fromJson(json.decode(response.body));
      return invoice;
    }
    final jsonData = json.decode(response.body);
    return Future.error(jsonData.toStiring());
  }

  Future<bool> addInvoice(Map data) async {
    final url = "${AppConfig.baseUrl}/api/v1/transactions/invoice/";
    final headers = await getAuthHeaders();

    // debugPrint('DATE ::: $data');
    final data0 = jsonEncode(data);
    final response = await httpPost(url, body: data0, headers: headers);

    // debugPrint('ADD INVOICE RESPONSE ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    final jsonData = json.decode(response.body);
    return Future.error(jsonData.toStiring());
  }

  Future<bool> updateInvoice({String? invoiceId, Map? data}) async {
    final url = "${AppConfig.baseUrl}/api/v1/transactions/invoice/$invoiceId/";
    final headers = await getAuthHeaders();

    final data0 = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: data0);

    // debugPrint('DATA ::: $data0');
    // debugPrint('UPDATE INVOICE RESPONSE ::: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    final jsonData = json.decode(response.body);
    return Future.error(jsonData.toString());
  }

  Future<bool> deleteInvoice({required int invoiceId}) async {
    final url = "${AppConfig.baseUrl}/api/v1/transactions/invoice/$invoiceId/";
    final headers = await getAuthHeaders();

    final response = await httpDelete(url, headers: headers);

    // debugPrint('DELETE INVOICE RESPONSE ::: ${response.body}');

    if (response.statusCode == 204) {
      return true;
    }
    final jsonData = json.decode(response.body);
    return Future.error(jsonData.toString());
  }

  Future<bool> markInvoiceAsPaid({required int invoiceId}) async {
    final url =
        "${AppConfig.baseUrl}/api/v1/transactions/invoice/mark-as-pay/$invoiceId/";
    final headers = await getAuthHeaders();

    final response = await httpGet(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    final jsonData = json.decode(response.body);
    return Future.error(jsonData.toString());
  }

  Future<bool> payInvoice({required int invoiceId}) async {
    final url =
        "${AppConfig.baseUrl}/api/v1/transactions/invoice/pay/$invoiceId/";
    final headers = await getAuthHeaders();

    final response = await httpGet(url, headers: headers);
    // debugPrint('PAY INVOICE ::: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    final jsonData = json.decode(response.body);
    return Future.error(jsonData.toString());
  }

  Future<bool> deleteInvoiceItem({required int itemId}) async {
    final url =
        "${AppConfig.baseUrl}/api/v1/transactions/invoice/item/$itemId/";
    final headers = await getAuthHeaders();
    final response = await httpDelete(url, headers: headers);
    // debugPrint('DELETE INVOICE ITEM ::: ${response.body}');
    // debugPrint('DELETE INVOICE ITEM ::: ${response.statusCode}');

    if (response.statusCode == 204) {
      return true;
    }
    final jsonData = json.decode(response.body);
    return Future.error(jsonData.toString());
  }

  Future<bool> addInvoiceItemToExistingInvoice(
      {required int invoiceId, required InvoiceItem invoiceItem}) async {
    final url = "${AppConfig.baseUrl}/api/v1/transactions/invoice/$invoiceId/";
    final headers = await getAuthHeaders();
    final data = invoiceItem.toJson();
    data.removeWhere((key, value) => value == null);

    final response =
        await httpPost(url, headers: headers, body: jsonEncode(data));
    // debugPrint('ADD INVOICE ITEM TO EXISTING INVOICE ::: ${response.body}');
    // debugPrint(
    //     'ADD INVOICE ITEM TO EXISTING INVOICE::: ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }

    return Future.error(response.body);
  }

  Future<bool> updateInvoiceItem(
      {required int itemId, required InvoiceItem invoiceItem}) async {
    final url =
        "${AppConfig.baseUrl}/api/v1/transactions/invoice/item/$itemId/";
    final headers = await getAuthHeaders();
    final data = invoiceItem.toJson();
    data.removeWhere((key, value) => value == null);

    final response =
        await httpPatch(url, headers: headers, body: jsonEncode(data));
    // debugPrint('UPDATE INVOICE ITEM ::: ${response.body}');
    // debugPrint('UPDATE INVOICE ITEM ::: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
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
  //   if (response.statusCode == 200 || response.statusCode == 201) {
  //     return true;
  //   }
  //   var jsonData = json.decode(response.body);
  //   return Future.error(jsonData.toStiring());
  // }
}
