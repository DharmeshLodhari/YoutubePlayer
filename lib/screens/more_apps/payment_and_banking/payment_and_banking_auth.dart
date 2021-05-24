import 'dart:convert';

import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models/payout.dart';
import 'models/transactions.dart';

class PaymentAndBankingAuth extends AuthService {
  // List the users bank accounts
  Future<List<BankAccount>> getBankAccounts() async {
    var url = secureBaseUrl + "/api/v1/transactions/bank-accounts-list/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<BankAccount> accounts = [];
      for (var item in jsonData['results']) {
        if (item['is_default'] == true) {
          var bank = item["bank"];
          var logoUrl = item["bank"]['logo_url'];
          item["bank"]['logo_url'] = logoUrl;
          BankAccount account = BankAccount(
              bankAvatar: item["bank"]['logo_url'],
              uuid: item['id'].toString(),
              bankName: bank['short_name'],
              accountName: item['account_name'],
              accountNumber: item['account_number']);
          accounts.add(account);
        }
      }
      return accounts;
    } else {
      return Future.error(
          "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- ${jsonDecode(response.body)}");
    }
  }

  // Get Account Balance
  Future<Map> getAccountBalance() async {
    var url = secureBaseUrl + "/api/v1/transactions/check-account-balance/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      return jsonData;
    } else {
      return {"balance": 0, "spendable_balance": 0, "over_draft": 0};
    }
  }

  // delete single bankaccount
  Future<bool> deleteBankAccount(String id) async {
    var url =
        secureBaseUrl + "/api/v1/transactions/delete-bank-account/" + id + "/";
    var headers = await getAuthHeaders();
    var response = await http.delete(url, headers: headers);

    debugPrint(
        "status code :- ${response.statusCode} response ${response.body}");
    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addBankAccount(Map data) async {
    var url = secureBaseUrl + "/api/v1/transactions/add-bank-account/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    return response.statusCode == 201;
  }

  // update bank account information
  Future<bool> updateBankAccount(Map data) async {
    var url = secureBaseUrl +
        "/api/v1/transactions/set-default-bank-account/" +
        data['uuid'] +
        "/";
    var headers = await getAuthHeaders();
    var response;
    var _data = jsonEncode(data);
    try {
      response = await http.patch(url, headers: headers, body: _data);
    } catch (e) {
      debugPrint("update bank account : " + e.toString());
    }
    if (response.statusCode != 200) {
      var jsonData = response.body;
      debugPrint(jsonData);
    }
    return response.statusCode == 200;
  }

  // List the users bank accounts with pagination
  Future<Map<String, dynamic>> getBankAccountsPagination(
      String next, String previous) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/transactions/bank-accounts-list/";
    } else {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<BankAccount> accounts = [];
      for (var item in jsonData['results']) {
        var bank = item["bank"];
        var logoUrl = item["bank"]['logo_url'];
        item["bank"]['logo_url'] = logoUrl;

        BankAccount account = BankAccount(
          bankAvatar: item["bank"]['logo_url'],
          uuid: item['id'].toString(),
          bankName: bank['short_name'],
          accountName: item['account_name'],
          accountNumber: item['account_number'],
          isDefault: item['is_default'],
        );
        accounts.add(account);
      }
      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": accounts
      };
      return result;
    } else {
      throw "Can't get https.";
    }
  }

  // Transactions graph and Category
  Future<Map<String, dynamic>> getTransactionWeeklyReport(
      String weekNumber) async {
    var url = secureBaseUrl +
        "/api/v1/transactions/transaction-filter/?week=" +
        weekNumber;
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      return jsonData;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  Future<Map<String, dynamic>> getPaymentCategory() async {
    var url = secureBaseUrl + "/api/v1/transactions/payment-category/";
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      Map<String, dynamic> result = {
        "results": jsonData["results"],
      };
      return result;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  // Accept Payment with POST method with empty data  post
  Future<http.Response> acceptPaymentRequests(PaymentRequest paymentRequest,
      {String messageId}) async {
    var url = secureBaseUrl + "/api/v1/transactions/request-payment/accept/";
    debugPrint("messageId:- $messageId");

    if (messageId != null) {
      url += "?message-id=$messageId";
    }
    debugPrint("URL:- $url");
    var data = {"id": paymentRequest.id};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);
    debugPrint("RESPONSE STATUS CODE:- ${response.statusCode}");
    debugPrint("RESPONSE BODY:- ${response.body}");
    return response;
  }

  // Patch payment status with empty data  patch
  Future<bool> rejectPaymentRequests(PaymentRequest paymentRequest,
      {String messageId}) async {
    var url = secureBaseUrl +
        "/api/v1/transactions/request-payment/update/" +
        paymentRequest.id +
        "/";

    if (messageId != null) {
      url += "?message-id=$messageId";
    }
    debugPrint("URL:- $url");
    var headers = await getAuthHeaders();
    var data = {};
    var _data = jsonEncode(data);
    var response = await http.patch(url, headers: headers, body: _data);

    debugPrint("RESPONSE STATUS CODE:- ${response.statusCode}");
    debugPrint("RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // Create Payment request with data from user input  post method  return true / false
  Future<http.Response> createPaymentRequests(Map data) async {
    debugPrint("Data sent:- $data");
    var url = secureBaseUrl + "/api/v1/transactions/request-payment/create/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    debugPrint(
        "RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
    return response;
  }

  Future<Map<String, dynamic>> listPaymentRequests(
      String next, String previous, bool toMe, bool fromMe) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/transactions/request-payment/list/";
      if (toMe) {
        url = url + "?to_me=true";
      }
      if (fromMe) {
        url = url + "?from_me=true";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      List<PaymentRequest> paymentRequests = [];
      // This variable will hold list of transactions we got from server
      var user = await getUser();
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        // if sender is not current user then
        bool isCredit = (item["from_customer"] != user.userName &&
                item["to_customer"] == user.userName)
            ? true
            : false;

        var payee = isCredit ? item["from_customer"] : item['to_customer'];
        var avatar = isCredit
            ? item["from_customer_avatar"]
            : item['to_customer_avatar'];

        PaymentRequest paymentRequest = PaymentRequest(
            status: item['status'],
            id: item['id'].toString(),
            description: item['description'],
            payee: payee,
            avatar: avatar,
            currency: item['currency'],
            createdAt: item['created_at'],
            amount: item['amount'],
            isCredit: isCredit);
        paymentRequests.add(paymentRequest);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": paymentRequests
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  // List users transactions
  Future<Map<String, dynamic>> getTransactions(
      String next, String previous, bool moneyIn, bool moneyOut) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/transactions/list/";
      if (moneyIn) {
        url = url + "?money_in=true";
      }
      if (moneyOut) {
        url = url + "?money_out=true";
      }
    } else {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();

    var response = await http.get(url, headers: headers);
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

  //Send payment to backend
  Future<http.Response> makePayment(Map data) async {
    var url = secureBaseUrl + "/api/v1/transactions/make-payment/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);

    return response;
  }

  //send payment of the order to particular sellers
  Future<http.Response> makePaymentForCartOrder(var data) async {
    var url = secureBaseUrl + "/api/v1/transactions/make-payment-for-orders/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    return response;
  }

  //Send payout to backend
  Future<http.Response> accountPayout(Map data) async {
    var url = secureBaseUrl + "/api/v1/transactions/payout/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    return response;
  }

  // List of bank Payout
  Future<Map<String, dynamic>> getPayoutList(
      String next, String previous) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = secureBaseUrl + "/api/v1/transactions/payout/";
    } else {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<Payout> payouts = [];
      var jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        var timeStamp = item["credited_at"] == null
            ? item["created_at"]
            : item["credited_at"];

        Payout payout = Payout(
          uuid: item['id'],
          status: item['status'],
          amount: item['amount'],
          currency: item['currency'],
          timeStamp: timeStamp,
          bankName: item["customer_bank_account"]["bank"]["short_name"],
          bankLogo: item["customer_bank_account"]["bank"]["logo_url"],
        );
        payouts.add(payout);
      }
      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": payouts
      };
      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      throw json.decode(response.body);
    }
  }

  // top up slydo account
  Future<bool> topUpAccountByCC(Map data) async {
    var url = secureBaseUrl + "/api/v1/transactions/top-up/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    if (response.statusCode != 200) {
      return true;
    }
    debugPrint("topUp By CC${response.body}");
    return false;
  }

  Future<Map<String, dynamic>> topUpAccountByBank(
      Map<String, dynamic> data) async {
    var url = secureBaseUrl + "/api/v1/transactions/get-payment-reference/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return Future.error("${response.body}");
    }
  }

  Future<Map<String, dynamic>> verifyReferenceNumber(
      Map<String, dynamic> data) async {
    var url = secureBaseUrl + "/api/v1/transactions/get-payment-reference/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return Future.error("${response.body}");
    }
  }

  Future<bool> confirmTopUpWithReferenceNumber(
      Map<String, dynamic> data) async {
    var url = secureBaseUrl + "/api/v1/transactions/topup-by-reference/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await http.post(url, headers: headers, body: _data);
    debugPrint("Response ${response.statusCode}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 400) {
      return Future.error(jsonDecode(response.body)["error"]);
    } else {
      return Future.error(jsonDecode(response.body));
    }
  }
}
