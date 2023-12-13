import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Slydo/data/environment.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/VirtualAccount.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/bank.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/bank_list.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/models/fee_structure.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/banking/models/credit_card_data_model.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/screens/banking/models/kyc_model.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/shipping_option_list_model.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'models/payout.dart';
import 'models/transactions.dart';

class PaymentAndBankingAuth extends AuthService {
  Future<List<BankAccount>> getBankAccounts() async {
    var url = "${AppConfig.baseUrl}/api/v1/transactions/bank-accounts-list/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

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
      debugPrint(
          "URL:- $url StatusCode:- ${response.statusCode} Body:- ${response.body}");
      return Future.error(
          "ERROR while calling $url StatusCode:- ${response.statusCode} Body:- ${response.body}");
    }
  }

  Future<Map<String, dynamic>?> getAccountBalance() async {
    var url = "${AppConfig.baseUrl}/api/v1/transactions/check-account-balance/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      return jsonData;
    } else {
      return {"balance": 0, "spendable_balance": 0, "over_draft": 0};
    }
  }

  Future<bool> verifyCardNumber({required String cardNumber}) async {
    String url =
        "${AppConfig.baseUrl}/api/v1/transactions/credit-card/verify-card/";

    var data = {'card_number': cardNumber};
    var headers = await getAuthHeaders();
    var response =
        await httpPost(url, headers: headers, body: jsonEncode(data));

    print('VERIFY CARD RESPONSE ::: $response');
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['msg'] == 'valid') {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<String?> verifyOtp(String otp) async {
    var url = "${AppConfig.baseUrl}/api/v1/sms/verify/";
    var headers = getNonAuthHeader();
    var data = {
      "code": otp,
    };
    var _data = jsonEncode(data);
    var response = await httpPost(url,
        body: _data, headers: headers as Map<String, dynamic>?);
    var jsonData = json.decode(response.body);
    if (response.statusCode == 200) {
      var resetToken = jsonData['reset-token'];
      return resetToken;
    } else {
      if (AppConfig.enableLogs.value) debugPrint("DATA SENT:- $data");
      debugPrint(
          "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      throw jsonData;
    }
  }

  Future<String> verifyCreditCardOtp(String otp) async {
    String responseString = 'Something went wrong';
    var url =
        "${AppConfig.baseUrl}/api/v1/transactions/credit-card/verify-card-otp/";
    var headers = await getAuthHeaders();
    var data = {"otp": otp};
    var _data = jsonEncode(data);

    var response = await httpPost(url, body: _data, headers: headers);
    print('OTP RESPONSE ----> ${response.body}');

    print('OTP RESPONSE ----> ${response.statusCode}');
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);

      responseString = 'successful';
    } else if (response.statusCode == 400) {
      if (jsonDecode(response.body)['errMsg']
          .toLowerCase()
          .contains('please enter the otp')) {
        responseString = 'invalid otp';
      } else if (jsonDecode(response.body)['errMsg']
          .toLowerCase()
          .contains('session expired')) {
        responseString = 'session expired';
      } else if (jsonDecode(response.body)['errMsg']
          .toLowerCase()
          .contains('insufficient funds')) {
        responseString = 'insufficient funds';
      } else {
        responseString = jsonDecode(response.body)['errMsg'];
      }
    } else {
      if (AppConfig.enableLogs.value) debugPrint("DATA SENT:- $data");
      debugPrint(
          "URL:- $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return Future.error(response.body);
    }
    print('RESPONSE STRING ::: $responseString');
    return responseString;
  }

  // delete single bank account
  Future<bool> deleteBankAccount(String id) async {
    var url =
        "${AppConfig.baseUrl}/api/v1/transactions/delete-bank-account/$id/";
    var headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);

    debugPrint(
        "status code delete :- ${response.statusCode} response ${response.body}");
    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>?> addBankAccount(Map data) async {
    var url = "${AppConfig.baseUrl}/api/v1/transactions/add-bank-account/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);

    if (response.statusCode == 201) {
      var jsonData = json.decode(response.body);
      Map<String, dynamic> result = {
        "status": 201,
        "results": jsonData,
      };
      return result;
    } else {
      Map<String, dynamic> result = {
        "status": response.statusCode,
        "results": response.body,
      };
      return result;
    }
  }

  Future<Map<String, dynamic>?> verifyBankAccount(Map data) async {
    String? accountNumber = data['account_number'];
    String? bankCode = data['bank_code'];

    var url =
        "${AppConfig.baseUrl}/api/v1/bankly/transfers/lookup/$accountNumber/$bankCode/";

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint(
        "status code :- ${response.statusCode} VerifyBankAccount ---> response ${response.body}");

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      Map<String, dynamic> result = {
        "results": jsonData,
      };
      return result;
    } else {
      return null;
      // throw "Can't get https.";
    }
  }

  // List the  searchBankList with pagination
  Future<Map<String, dynamic>?> searchBankList(
      String url, String? next, String? previous) async {
    debugPrint("URl:- $url");
    if (next == null) {
      return null;
    }
    if (next != "") {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();

    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${jsonData}");

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": jsonData["results"],
      };
      return result;
    } else {
      debugPrint(
          "URL:- $url RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
      return Future.error("ERROR:- ${response.body}");
    }
  }

  // update bank account information
  Future<bool> updateBankAccount(Map data) async {
    var url =
        "${AppConfig.baseUrl + "/api/v1/transactions/set-default-bank-account/" + data['uuid']}/";
    var headers = await getAuthHeaders();
    late var response;
    var _data = jsonEncode(data);
    try {
      response = await httpPatch(url, headers: headers, body: _data);
    } catch (e) {
      debugPrint("update bank account : $e");
    }
    if (response.statusCode != 200) {
      var jsonData = response.body;
      debugPrint(jsonData);
    }
    return response.statusCode == 200;
  }

  // List the users bank accounts with pagination
  Future<Map<String, dynamic>?> getBankAccountsPagination(
      String? next, String? previous, String searchText) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      if (searchText != "") {
        url =
            "${AppConfig.baseUrl}/api/v1/transactions/bank-accounts-list/?search=$searchText";
      } else {
        url = "${AppConfig.baseUrl}/api/v1/transactions/bank-accounts-list/";
      }
    } else {
      url = getSecureUrl(url: next);
    }

    print('Bank List url :::: $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    print('Bank List DATA :::: ${json.decode(response.body)}');

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
          bankName: bank['name'],
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

  // List the users shipping options with pagination
  Future<Map<String, dynamic>?> getShippingOptions(
      String? next, String? previous) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/shipping-options/";
    } else {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    print('SHIPPING OPTIONS List DATA :::: ${json.decode(response.body)}');

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<ShippingOptionsListModel> shippingModelList = [];

      for (var item in jsonData['results']) {
        ShippingOptionsListModel shippingModel = ShippingOptionsListModel(
          id: item["id"],
          currency: item['currency'],
          name: item['name'],
          price: item['price'],
          owner: item['owner'],
        );
        shippingModelList.add(shippingModel);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": shippingModelList
      };
      return result;
    } else {
      throw "Can't get https.";
    }
  }

  //Add Shipping Option
  Future<http.Response> addShippingOption(Map data) async {
    var url = "${AppConfig.baseUrl}/api/v1/shipping-options/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);

    print('ADD SHIPPING OPTIONS List :::: ${json.decode(response.body)}');

    return response;
  }

  //Delete Shipping Option
  Future<bool?> deleteShippingOption(int shippingId) async {
    String url = "";
    if (shippingId != null) {
      url = "${AppConfig.baseUrl}/api/v1/shipping-options/$shippingId/";
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);

    if (response.statusCode == 204) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  //Edit Shipping Option
  Future<http.Response> editShippingOption(Map data, int shippingId) async {
    var url = "${AppConfig.baseUrl}/api/v1/shipping-options/$shippingId/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);

    print('EDIT SHIPPING OPTIONS List :::: ${json.decode(response.body)}');

    return response;
  }

  Future<String> addCreditCard(CreditCardData creditCardData) async {
    late String responseString;
    var url = "${AppConfig.baseUrl}/api/v1/transactions/credit-card/";
    var headers = await getAuthHeaders();

    Map<String, dynamic> data = creditCardData.toJson();
    data.removeWhere((key, value) => value == null);

    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);

    print('ADD CREDIT CARD RESPONSE ----> ${response.body}');
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['validationRequired'] == true) {
        responseString = 'otp';
      }
    } else if (response.statusCode == 400) {
      if (response.body.toLowerCase().contains('too many connections')) {
        responseString = 'too many connections';
      } else if (response.body.toLowerCase().contains('pin')) {
        responseString = 'invalid pin';
      } else if (response.body.toLowerCase().contains('insufficient funds')) {
        responseString = 'insufficient funds';
      } else {
        responseString = response.body;
      }
    } else {
      responseString = response.body;
      return Future.error(response.body);
    }

    return responseString;
  }

  Future<String> fundWallet(CreditCardData creditCardData) async {
    late String responseString;

    var url =
        "${AppConfig.baseUrl}/api/v1/transactions/credit-card/credit-wallet-account/";
    var headers = await getAuthHeaders();

    Map<String, dynamic> data = creditCardData.toJson();
    data.removeWhere((key, value) => value == null);
    print('CREDIT CARD DATA :::: $data');

    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);
    print('FUND WALLET ----> ${response.body}');
    if (response.statusCode == 200) {
      if (jsonDecode(response.body)['validationRequired'] == true) {
        responseString = 'otp';
      }
    } else if (response.statusCode == 400) {
      if (response.body.toLowerCase().contains('too many connections')) {
        responseString = 'too many connections';
      } else if (response.body.toLowerCase().contains('pin')) {
        responseString = 'invalid pin';
      } else if (response.body.toLowerCase().contains('insufficient funds')) {
        responseString = 'insufficient funds';
      } else {
        responseString = response.body;
      }
    } else {
      responseString = response.body;
      return Future.error(response.body);
    }

    return responseString;
  }

  Future<Map<String, dynamic>?> getCreditCardPagination(
      String? next, String? previous) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/transactions/credit-card/";
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('URL ->>> $url');
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint('CREDIT CARD LIST STATUS CODE ::: ${response.statusCode}');
    print('CREDIT CARD LIST ----> ${response.body}');

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      List resultData = jsonData['results'];
      List<CreditCard> creditCardList =
          resultData.map((json) => CreditCard.fromJson(json)).toList();

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": creditCardList
      };

      return result;
    } else {
      throw "Can't get https.";
    }
  }

  // delete credit card
  Future<bool> deleteCreditCard(int cardId) async {
    var url = AppConfig.baseUrl +
        "/api/v1/transactions/credit-card/" +
        '$cardId' +
        "/";
    var headers = await getAuthHeaders();
    var response = await httpDelete(url, headers: headers);

    debugPrint(
        "status code :- ${response.statusCode} DELETE ---> response ${response.body}");
    if (response.statusCode == 204) {
      return true;
    } else {
      return false;
    }
  }

  // update credit card information
  Future<bool> updateCreditCard(int id) async {
    var url =
        AppConfig.baseUrl + "/api/v1/transactions/credit-card/" + '$id' + '/';
    var headers = await getAuthHeaders();
    late var response;
    var _data = jsonEncode({"is_default_cc": true});
    try {
      response = await httpPatch(url, headers: headers, body: _data);
      print('RESPONSE -----> ${response.body}');
    } catch (e) {
      debugPrint("update credit card : $e");
    }
    if (response.statusCode != 200) {
      var jsonData = response.body;
      debugPrint(jsonData);
    }
    return response.statusCode == 200;
  }

  // Transactions graph and Category
  Future<Map<String, dynamic>?> getTransactionWeeklyReport(
      String weekNumber) async {
    var url =
        "${AppConfig.baseUrl}/api/v1/transactions/transaction-filter/?week=$weekNumber";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      return jsonData;
    } else {
      var jsonData = json.decode(response.body);
      throw jsonData;
    }
  }

  Future<Map<String, dynamic>> getPaymentCategory() async {
    var url = "${AppConfig.baseUrl}/api/v1/transactions/payment-category/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
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
      {String? messageId}) async {
    var url =
        "${AppConfig.baseUrl}/api/v1/transactions/request-payment/accept/";

    if (messageId != null) {
      url += "?message-id=$messageId";
    }
    debugPrint("URL:- $url");
    var data = {"id": paymentRequest.id};
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);
    debugPrint("RESPONSE STATUS CODE:- ${response.statusCode}");
    debugPrint("RESPONSE BODY:- ${response.body}");
    return response;
  }

  // Patch payment status with empty data  patch
  Future<bool> rejectPaymentRequests(PaymentRequest paymentRequest,
      {String? messageId}) async {
    var url =
        "${AppConfig.baseUrl}/api/v1/transactions/request-payment/update/${paymentRequest.id!}/";

    if (messageId != null) {
      url += "?message-id=$messageId";
    }
    debugPrint("URL:- $url");
    var headers = await getAuthHeaders();
    var data = {};
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);

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
    if (AppConfig.enableLogs.value) debugPrint("Data sent:- $data");
    var url =
        "${AppConfig.baseUrl}/api/v1/transactions/request-payment/create/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);
    debugPrint(
        "RESPONSE STATUS CODE:- ${response.statusCode}  RESPONSE BODY:- ${response.body}");
    return response;
  }

  Future<Map<String, dynamic>?> listPaymentRequests(
      String? next, String? previous,
      {required bool? fromMe,
      required String? userName,
      required bool isRefreshing,
      DateTimeRange? dateTimeRange}) async {
    if (isRefreshing) next = "";
    var url = "";
    if (next == null) {
      return null;
    }

    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/transactions/request-payment/list/";

      if (userName != null) {
        url = "$url?search=$userName";
      }

      if (fromMe != null) {
        if (url.contains('?')) {
          url = "$url&from_me=$fromMe";
        } else {
          url = "$url?from_me=$fromMe";
        }
      }

      if (dateTimeRange != null) {
        DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        String toDate = dateFormat.format(dateTimeRange.end);
        String fromDate = dateFormat.format(dateTimeRange.start);

        if (url.contains('?')) {
          url = "$url&start_date=$fromDate&end_date=$toDate";
        } else {
          url = "$url?start_date=$fromDate&end_date=$toDate";
        }
      }
    } else {
      url = getSecureUrl(url: next);
    }

    debugPrint('PAYMENT REQUEST URL ::: $url');

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    if (response.statusCode == 200) {
      List<PaymentRequest> paymentRequests = [];
      // This variable will hold list of transactions we got from server
      await getUser();
      var jsonData = json.decode(response.body);
      for (var item in jsonData["results"]) {
        PaymentRequest paymentRequest = PaymentRequest.fromJson(item);

        paymentRequests.add(paymentRequest);
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": paymentRequests
      };
      List lsts = jsonData['results'];
      lsts.forEach((element) {
        print(element['created_at']);

        print("Fola Key : $element");
      });

      return result;
    } else if (response.statusCode == 500) {
      throw "Server Error";
    } else {
      debugPrint(
          "URL: $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
      return Future.error(
          "URL: $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");
    }
  }

  // List users transactions
  Future<Map<String, dynamic>?> getTransactions(
    String? next,
    String? previous,
    bool? moneyIn,
    DateTimeRange? dateTimeRange, {
    String? userName,
  }) async {
    var url = "";
    if (next == null) {
      return null;
    }

    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/transactions/list/";

      if (userName != null) {
        url = "$url?search=$userName";
      }

      if (moneyIn != null) {
        if (url.contains('?')) {
          url = "$url&money_in=$moneyIn";
        } else {
          url = "$url?money_in=$moneyIn";
        }
      }

      if (dateTimeRange != null) {
        DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        String toDate = dateFormat.format(dateTimeRange.end);
        String fromDate = dateFormat.format(dateTimeRange.start);

        if (url.contains('?')) {
          url = "$url&start_date=$fromDate&end_date=$toDate";
        } else {
          url = "$url?start_date=$fromDate&end_date=$toDate";
        }
      }
    } else {
      url = getSecureUrl(url: next);
    }

    var headers = await getAuthHeaders();
    debugPrint("URL :::: $url");

    var response = await httpGet(url, headers: headers);
    debugPrint("URL resonspose :::: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 400) {
      List<Transaction> transactions = [];
      // This variable will hold list of transactions we got from server
      // var user = await getUser();

      var jsonData;
      if (response.statusCode == 400) {
        jsonData = {"results": [], "count": 0, "previous": "", "next": ""};
        return jsonData;
      } else {
        jsonData = json.decode(response.body);
      }

      for (var item in jsonData["results"]) {
        // if sender is not current user then

        Transaction transaction = Transaction.fromJson(item);

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
      throw response.body;
    }
  }

  // update moment support list
  Future<bool> updateMomentSupporter(
      String momentId, String transactionId) async {
    var url =
        "${AppConfig.baseUrl}/api/v1/social/moments/add-user-to-moment-supporters-list/$momentId/";
    var headers = await getAuthHeaders();
    late var response;
    var _data = jsonEncode(transactionId);
    try {
      response = await httpPatch(url, headers: headers, body: _data);
    } catch (e) {
      debugPrint("update moment supporter : $e");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  // update yarn supporter list
  Future<bool> updateYarnSupporter(String yarnId, String transactionId) async {
    var url =
        "${AppConfig.baseUrl}/api/v1/social/ask/add-user-to-yarn-supporters-list/$yarnId/";
    var headers = await getAuthHeaders();
    late var response;
    var _data = jsonEncode(transactionId);
    try {
      response = await httpPatch(url, headers: headers, body: _data);
    } catch (e) {
      debugPrint("update yarn supporter : $e");
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  //Send payment to backend
  Future<http.Response> makePayment(Map data) async {
    var url = "${AppConfig.baseUrl}/api/v1/transactions/make-payment/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    print('message data::::$_data');
    var response = await httpPost(url, headers: headers, body: _data);
    print('message::::$response');
    return response;
  }

  //Send payment to backend to update status
  Future<http.Response> updateStatusPayment(
      {String? jobId, String? transactionId}) async {
    var url = "${AppConfig.baseUrl}/api/v1/job-service/job/$jobId/pay-for-job/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode({"transaction_id": transactionId});
    print('message data::::$_data');
    var response = await httpPatch(url, headers: headers, body: _data);
    print('message::::$response');
    return response;
  }

  //Create payment_link to backend
  Future<http.Response> makePaymentLink(Map data) async {
    var url = "${AppConfig.baseUrl}/api/v1/transactions/payment-link/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);

    return response;
  }

  //Cash out payment_link to backend
  Future<http.Response> cashoutPaymentLink(Map data, String id) async {
    var url =
        "${AppConfig.baseUrl}/api/v1/transactions/payment-link/$id/payout/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);
    log(response.toString());
    return response;
  }

  //GEt all payment link and search
  Future<Map<String, dynamic>> getPaymentLinks({String? searchLink}) async {
    var url;
    dynamic result;
    if (searchLink != null) {
      url =
          "${AppConfig.baseUrl}/api/v1/transactions/payment-link/?search=$searchLink";
    } else {
      url = "${AppConfig.baseUrl}/api/v1/transactions/payment-link/";
    }
    var headers = await getAuthHeaders();
    // var _data = jsonEncode(data);
    var response = await httpGet(
      url,
      headers: headers,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      result = jsonDecode(response.body);
    } else {
      throw "Server Error";
    }
    return result;
  }

  //Cancel payment link
  Future<bool> cancelPaymentLinks(String? paymentLinkId) async {
    var url;
    dynamic result;
    url =
        "${AppConfig.baseUrl}/api/v1/transactions/payment-link/$paymentLinkId/cancel";

    var headers = await getAuthHeaders();
    // var _data = jsonEncode(data);
    var response = await httpGet(
      url,
      headers: headers,
    );
    log("message${response.statusCode} and ${response.body}");
    if (response.statusCode == 201 || response.statusCode == 200) {
      result = jsonDecode(response.body);
      return true;
    } else {
      return false;
    }
  }

  //get single payment link
  Future<Map<String, dynamic>> getSinglePaymentLinkDetails(
      String? paymentLinkId) async {
    var url;
    dynamic result;
    url =
        "${AppConfig.baseUrl}/api/v1/transactions/payment-link/$paymentLinkId/";

    var headers = await getAuthHeaders();
    // var _data = jsonEncode(data);
    var response = await httpGet(
      url,
      headers: headers,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      result = jsonDecode(response.body);
    } else {
      throw "Server Error";
    }
    return result;
  }

  // activate and deactivate payment links
  Future<http.Response> paymentLinksAction(Map data) async {
    var url;
    dynamic result;
    url = "${AppConfig.baseUrl}/api/v1/transactions/payment-link/action/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(
      url,
      body: _data,
      headers: headers,
    );
    log(response.statusCode.toString());
    log(data.toString());
    if (response.statusCode == 201 || response.statusCode == 200) {
      result = jsonDecode(response.body);
      log(result.toString());
    } else {
      throw "Server Error";
    }
    return response;
  }

  //filter payment_link to backend
  Future<Map<String, dynamic>> filterPaymentLinks({String? filter}) async {
    var url;
    dynamic result;
    if (filter == '') {
      url = "${AppConfig.baseUrl}/api/v1/transactions/payment-link/";
    } else {
      url =
          "${AppConfig.baseUrl}/api/v1/transactions/payment-link/?status=$filter";
    }
    var headers = await getAuthHeaders();
    // var _data = jsonEncode(data);
    var response = await httpGet(
      url,
      headers: headers,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      result = jsonDecode(response.body);
    } else {
      throw "Server Error";
    }
    return result;
  }

  //Delete payment_link to backend
  Future<http.Response> deletePaymentLinks(String id) async {
    var url = "${AppConfig.baseUrl}/api/v1/transactions/payment-link/$id";
    var headers = await getAuthHeaders();
    // var _data = jsonEncode(data);
    var response = await httpDelete(
      url,
      headers: headers,
    );

    return response;
  }

  //send payment of the order to particular sellers
  Future<http.Response> makePaymentForCartOrder(var data) async {
    var url =
        "${AppConfig.baseUrl}/api/v1/transactions/make-payment-for-orders/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);
    debugPrint('MAKE PAYMENT ::: ${response.body}');
    return response;
  }

  //Send payout to backend
  Future<http.Response> accountPayout(Map data) async {
    var url = "${AppConfig.baseUrl}/api/v1/transactions/payout/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);

    debugPrint('MAKE PAYMENT ::: ${response.body}');
    return response;
  }

  // List of bank Payout
  Future<Map<String, dynamic>?> getPayoutList(
      String? next, String? previous) async {
    var url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/transactions/payout/";
    } else {
      url = getSecureUrl(url: next);
    }
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    if (response.statusCode == 200) {
      List<Payout> payouts = [];
      var jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        debugPrint("Fola payout list::: ${item}");

        var timeStamp = item["credited_at"] == null
            ? item["created_at"]
            : item["credited_at"];

        Payout payout = Payout(
          uuid: item['id'],
          status: item['status'],
          amount: item['amount'],
          currency: item['currency'],
          timeStamp: timeStamp,
          bankName: item["customer_bank_account"]["bank"]["name"],
          bankLogo: item["customer_bank_account"]["bank"]["logo_url"],
          accountName: item["customer_bank_account"]["account_name"],
          accountNumber: item["customer_bank_account"]["account_number"],
        );
        if (item['description'] == null) {
          payout.description = "---";
        } else {
          payout.description = item['description'];
        }
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
    var url = "${AppConfig.baseUrl}/api/v1/transactions/top-up/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);
    if (response.statusCode != 200) {
      return true;
    }
    debugPrint("topUp By CC${response.body}");
    return false;
  }

  Future<Map<String, dynamic>?> topUpAccountByBank(
      Map<String, dynamic> data) async {
    var url = "${AppConfig.baseUrl}/api/v1/transactions/get-payment-reference/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return Future.error("${response.body}");
    }
  }

  Future<VirtualAccount?> getVirtualAccountDetail() async {
    var url =
        "${AppConfig.baseUrl}/api/v1/transactions/get-virtual-account-info/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint(
        "URL $url STATUS CODE:- ${response.statusCode} BODY:- ${response.body}");

    debugPrint('GET VIRTUAL ACCOUNT ::: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      VirtualAccount virtualAccount =
          VirtualAccount.fromJson(jsonDecode(response.body));
      return virtualAccount;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyReferenceNumber(
      Map<String, dynamic> data) async {
    var url = "${AppConfig.baseUrl}/api/v1/transactions/get-payment-reference/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return Future.error("${response.body}");
    }
  }

  Future<bool> confirmTopUpWithReferenceNumber(
      Map<String, dynamic> data) async {
    var url = "${AppConfig.baseUrl}/api/v1/transactions/topup-by-reference/";
    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPost(url, headers: headers, body: _data);
    debugPrint("Response ${response.statusCode}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 400) {
      return Future.error(jsonDecode(response.body)["error"]);
    } else {
      return Future.error(jsonDecode(response.body));
    }
  }

  Future<KycModel?> checkIfKycIsVerified({required String userName}) async {
    var url = "${AppConfig.baseUrl}/api/v1/user/kyc/$userName";
    var headers = await getAuthHeaders();

    var response = await httpGet(url, headers: headers);
    print('URL RESPONSE ----> ${response.statusCode}');
    print('URL RESPONSE ----> ${response.body}');
    if (response.statusCode == 200) {
      return KycModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      return Future.error(jsonDecode(response.body));
    }
  }

  Future<bool> addBvnNumberAndIdProof(Map<String, dynamic> data) async {
    var headers = await getAuthHeaders();
    var url = "${AppConfig.baseUrl}/api/v1/user/kyc/";

    //create multipart request for POST or PATCH method
    var request = http.MultipartRequest("POST", Uri.parse(url));

    Map<dynamic, dynamic> _data = data;

    _data.forEach((k, v) {
      request.fields[k] = v.toString();
    });
    List<MultipartFile> newList = [];

    if (data["business_registration_license"] != null ||
        data["business_registration_license"] != "") {
      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "business_registration_license",
          data["business_registration_license"]);

      // Add multipart to newList
      newList.add(multipartFile);
    }
    if (data["government_id"] != null || data["government_id"] != "") {
      // Create multipart using filepath, string or bytes
      var multipartFile = await http.MultipartFile.fromPath(
          "government_id", data["government_id"]);

      // Add multipart to newList
      newList.add(multipartFile);
    }

    // Add multipart to request
    request.files.addAll(newList);
    headers.forEach((k, v) => request.headers[k] = v);
    var response = await request.send();
    if (response.statusCode == 413) {
      return Future.error(
          "Please upload smaller images, One or all of your images are too large.");
    }
    var responseBody = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      return true;
    }
    debugPrint(
        "URL: $url Data:-${request.fields} Status code:-${response.statusCode} body:- $responseBody");
    return Future.error("Something went Wrong please try after some time.");

    // var url = secureAppConfig.baseUrl + "/api/v1/transactions/topup-by-reference/";
    // var headers = await getAuthHeaders();
    // var _data = jsonEncode(data);
    // var response = await httpPost(url, headers: headers, body: _data);
    // debugPrint("Response ${response.statusCode}");
    // if (response.statusCode == 200 || response.statusCode == 201) {
    //   return true;
    // } else if (response.statusCode == 400) {
    //   return Future.error(jsonDecode(response.body)["error"]);
    // } else {
    //   return Future.error(jsonDecode(response.body));
    // }
    // return true;
  }

  Future<FeeStructure> getFeeStructure() async {
    var url = "${AppConfig.baseUrl}/api/v1/transactions/fees/";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);
    debugPrint("Fee Structure Response status code ${response.statusCode}");
    debugPrint("Fee Structure Response body ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return FeeStructure.fromJson(jsonDecode(response.body));
    } else {
      return FeeStructure.fromJson({
        "customer_api_transaction_fee": 1100,
        "business_transaction_fee": 1000,
        "magic_envelope_fee": 400,
        "empty_envelope_fee": 400,
        "anonymous_transaction_fee": 400,
        "tax_rate": 0,
        "country": "Nigeria",
        "currency": "NGN",
      });
    }
  }
}
