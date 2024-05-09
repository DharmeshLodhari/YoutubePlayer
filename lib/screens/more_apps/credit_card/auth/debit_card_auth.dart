import 'dart:convert';

import 'package:Slydo/services/auth.dart';
import 'package:flutter/cupertino.dart';

import '../../../../data/environment.dart';
import '../../../../utils/util.dart';
import '../models/all_cards.dart';
import '../models/card_transactions.dart';
import '../models/exchange_rate.dart';

class DebitCardAuth extends AuthService {
  // Get all virtual cards
  Future<Map<String, dynamic>?> getAllCards(
      String? next, String? previous) async {
    debugPrint("CALLING ALL CARDS");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url = "${AppConfig.baseUrl}/api/v1/virtual-cards/cards?full=true";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<AllCards> cards = [];
      var jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        AllCards allCards = AllCards.fromJson(item);
        cards.add(allCards);
        // debugPrint("JSON CARDS::- $item");

      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": cards
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Get single virtual cards transactions
  Future<Map<String, dynamic>?> getSingleCardsTransactions(
      String? next, String? previous, String? currentCardId) async {
    debugPrint("CALLING SINGLE CARDS TRANSACTIONS");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/virtual-cards/transactions/?card_id=$currentCardId";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<CardTransactions> cardTransaction = [];
      var jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        CardTransactions cardTransactions = CardTransactions.fromJson(item);
        cardTransaction.add(cardTransactions);
        // debugPrint("JSON CARDS TRANSACTIONS::- $item");
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": cardTransaction
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Search single virtual cards transactions
  Future<Map<String, dynamic>?> searchSingleCardsTransactions(String? next,
      String? previous, String? currentCardId, String? searchText) async {
    debugPrint("CALLING SEARCH SINGLE CARDS TRANSACTIONS");
    String url = "";
    if (next == null) {
      return null;
    }
    if (next == "") {
      url =
          "${AppConfig.baseUrl}/api/v1/virtual-cards/transactions?card_id=$currentCardId&search=$searchText";
    } else {
      url = getSecureUrl(url: next);
    }
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<CardTransactions> cardTransaction = [];
      var jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        CardTransactions cardTransactions = CardTransactions.fromJson(item);
        cardTransaction.add(cardTransactions);
        // debugPrint("JSON CARDS TRANSACTIONS::- $item");
      }

      Map<String, dynamic> result = {
        "count": jsonData["count"],
        "next": jsonData["next"],
        "previous": jsonData["previous"],
        "results": cardTransaction
      };

      return result;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // Get exchange rate
  Future<ExchangeRate?> getExchangeRate() async {
    debugPrint("CALLING EXCHANGE RATE");

    String url = "${AppConfig.baseUrl}/api/v1/virtual-cards/exchange-rate/";
    debugPrint(url);

    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonData = json.decode(response.body);

      // debugPrint("JSON EXCHANGE RATE::- $jsonData");

      ExchangeRate exchangeRate = ExchangeRate.fromJson(jsonData);
      return exchangeRate;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // create debit card
  Future<bool?> createDebitCard(Map<String, dynamic> body) async {
    debugPrint("CALLING CREATE DEBIT CARD");

    String url = "${AppConfig.baseUrl}/api/v1/virtual-cards/cards/";
    debugPrint('url:: $url');
    debugPrint('report body::: ${body}');

    var headers = await getAuthHeaders();
    var response =
        await httpPost(url, headers: headers, body: jsonEncode(body));

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // freeze/unfreeze card
  Future<bool?> freezeCard(Map<String, dynamic> data, String cardId) async {
    debugPrint("FREEZE CARD");

    String url =
        "${AppConfig.baseUrl}/api/v1/virtual-cards/cards/$cardId/activate-deactivate/";

    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  //terminate card
  Future<bool?> terminateCard(String cardId) async {
    debugPrint("TERMINATE CARD");

    String url =
        "${AppConfig.baseUrl}/api/v1/virtual-cards/cards/$cardId/terminate/";

    var headers = await getAuthHeaders();
    var response = await httpPatch(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // fund card
  Future<bool?> fundCard(Map<String, dynamic> data, String cardId) async {
    debugPrint("FUND CARD");
    debugPrint("FUND CARD :::: ${data}");

    String url =
        "${AppConfig.baseUrl}/api/v1/virtual-cards/cards/$cardId/top-up/";

    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // withdraw card
  Future<bool?> withdrawCard(Map<String, dynamic> data, String cardId) async {
    debugPrint("WITHDRAW CARD");

    String url =
        "${AppConfig.baseUrl}/api/v1/virtual-cards/cards/$cardId/withdraw/";

    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url,
        headers: headers,
        body: _data,
        newTimeOutDuration: Duration(seconds: 45));

    debugPrint(
        "RESPONSE WITHDRAW CARD CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }

  // edit card label
  Future<bool?> updateCardLabel(
      Map<String, dynamic> data, String cardId) async {
    debugPrint("Update Card Label");

    String url = "${AppConfig.baseUrl}/api/v1/virtual-cards/cards/$cardId/";

    var headers = await getAuthHeaders();
    var _data = jsonEncode(data);
    var response = await httpPatch(url, headers: headers, body: _data);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }
}
