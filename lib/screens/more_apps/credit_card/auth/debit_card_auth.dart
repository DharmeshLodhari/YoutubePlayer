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

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      final List<AllCards> cards = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final AllCards allCards = AllCards.fromJson(item);
        cards.add(allCards);
        // debugPrint("JSON CARDS::- $item");

      }

      final Map<String, dynamic> result = {
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

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      final List<CardTransactions> cardTransaction = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final CardTransactions cardTransactions =
            CardTransactions.fromJson(item);
        cardTransaction.add(cardTransactions);
        // debugPrint("JSON CARDS TRANSACTIONS::- $item");
      }

      final Map<String, dynamic> result = {
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

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      final List<CardTransactions> cardTransaction = [];
      final jsonData = json.decode(response.body);

      for (var item in jsonData["results"]) {
        final CardTransactions cardTransactions =
            CardTransactions.fromJson(item);
        cardTransaction.add(cardTransactions);
        // debugPrint("JSON CARDS TRANSACTIONS::- $item");
      }

      final Map<String, dynamic> result = {
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

    final String url =
        "${AppConfig.baseUrl}/api/v1/virtual-cards/exchange-rate/";
    debugPrint(url);

    final headers = await getAuthHeaders();
    final response = await httpGet(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      // debugPrint("JSON EXCHANGE RATE::- $jsonData");

      final ExchangeRate exchangeRate = ExchangeRate.fromJson(jsonData);
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

    final String url = "${AppConfig.baseUrl}/api/v1/virtual-cards/cards/";
    debugPrint('url:: $url');
    debugPrint('report body::: $body');

    final headers = await getAuthHeaders();
    final response =
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

    final String url =
        "${AppConfig.baseUrl}/api/v1/virtual-cards/cards/$cardId/activate-deactivate/";

    final headers = await getAuthHeaders();
    final _data = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: _data);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
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

    final String url =
        "${AppConfig.baseUrl}/api/v1/virtual-cards/cards/$cardId/terminate/";

    final headers = await getAuthHeaders();
    final response = await httpPatch(url, headers: headers);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
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
    debugPrint("FUND CARD :::: $data");

    final String url =
        "${AppConfig.baseUrl}/api/v1/virtual-cards/cards/$cardId/top-up/";

    final headers = await getAuthHeaders();
    final _data = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: _data);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
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

    final String url =
        "${AppConfig.baseUrl}/api/v1/virtual-cards/cards/$cardId/withdraw/";

    final headers = await getAuthHeaders();
    final _data = jsonEncode(data);
    final response = await httpPatch(url,
        headers: headers,
        body: _data,
        newTimeOutDuration: const Duration(seconds: 45));

    debugPrint(
        "RESPONSE WITHDRAW CARD CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
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

    final String url =
        "${AppConfig.baseUrl}/api/v1/virtual-cards/cards/$cardId/";

    final headers = await getAuthHeaders();
    final _data = jsonEncode(data);
    final response = await httpPatch(url, headers: headers, body: _data);

    debugPrint(
        "RESPONSE CODE:- ${response.statusCode} RESPONSE BODY:- ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 500) {
      return null;
    } else {
      return null;
    }
  }
}
