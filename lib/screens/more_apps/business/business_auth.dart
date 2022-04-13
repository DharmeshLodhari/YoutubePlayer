import 'dart:convert';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/transactions.dart';
import 'package:Slydo/services/auth.dart';
import 'package:flutter/material.dart';

import 'models/Contract.dart';
import 'models/Invoice.dart';

class BusinessAuth extends AuthService {
  /// Contract and Invoice
  //get all contract list
  Future<List<Contract>> getContractList() async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/payment-contract/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    var jsonData = json.decode(response.body);
    List data = jsonData["results"];

    List<Contract> contracts = [];

    data.forEach((element) {
      contracts.add(Contract.fromJson(element));
    });

    return contracts;
  }

  Future<Contract> getContract(String id) async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/payment-contract/$id/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    if (response.statusCode == 200) {
      Contract contract = Contract.fromJson(json.decode(response.body));

      return contract;
    } else {
      var jsonData = json.decode(response.body);
      return Future.error(jsonData.toStiring());
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

    if (response.statusCode == 200) {
      return true;
    }
    var jsonData = json.decode(response.body);
    return Future.error(jsonData.toString());
  }

  //get all invoice list
  Future<List<Invoice>> getInvoiceList() async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/invoice/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    var jsonData = json.decode(response.body);
    List data = jsonData["results"];

    List<Invoice> invoices = [];

    data.forEach((element) {
      invoices.add(Invoice.fromJson(element));
    });

    return invoices;
  }

  Future<Invoice> getInvoice(String id) async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/invoice/$id/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      Invoice invoice = Invoice.fromJson(json.decode(response.body));
      return invoice;
    }
    var jsonData = json.decode(response.body);
    return Future.error(jsonData.toStiring());
  }

  Future<bool> addInvoice(Map data) async {
    var url = AppConfig.baseUrl + "/api/v1/transactions/invoice/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, body: _data, headers: headers);
    if (response.statusCode == 201) {
      return true;
    }
    var jsonData = json.decode(response.body);
    return Future.error(jsonData.toStiring());
  }

  Future<bool> updateInvoice(Invoice invoice) async {
    var url = AppConfig.baseUrl + "/api/v1/messaging/send/";
    var headers = await getAuthHeaders();
    var data = invoice.toJson();
    var _data = jsonEncode(data);
    var response = await httpPost(url, body: _data, headers: headers);
    if (response.statusCode == 201) {
      return true;
    }
    var jsonData = json.decode(response.body);
    return Future.error(jsonData.toStiring());
  }
}
