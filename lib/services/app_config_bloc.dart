import 'dart:convert';

import 'package:Slydo/services/auth.dart';
import 'package:flutter/cupertino.dart';

import '../data/environment.dart';

/// This class holds the data we can use to manipulate our app.
/// E.g if we do not want the user to interact with the credit card feature yet,
/// we set the variable for it and do the check (if, else) for the feature and disable it.

class AppConfigurationBloc {
  AppConfigurationModel? appConfigurationModel;
}

class AppFeaturesService extends AuthService {
  Future<AppConfigurationModel> getAppFeatures() async {
    String url = AppConfig.baseUrl + "/api/v1/user/app-settings";

    var headers = getNonAuthHeader();
    var response =
        await httpGet(url, headers: headers as Map<String, dynamic>?);

    debugPrint('SETTINGS :: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      var jsonData = jsonDecode(response.body);
      return AppConfigurationModel.fromJson(jsonData);
    } else {
      return AppConfigurationModel.fromJson({});
    }
  }
}

class AppConfigurationModel {
  int? id;
  String? country;
  bool enableMoment;
  bool enableAsk;
  bool enableSuperBlog;
  bool enableLocationSharing;
  bool enableEmptyEnvelope;
  bool enableMagicEnvelope;
  bool enableCashout;
  bool enableInvoice;
  bool enableContract;
  bool enableUtility;
  bool enableGroupChat;
  bool enablePayment;
  bool freeSubscription;
  bool enableAddUserCreditCard;
  bool enableWalletTopupWithCreditCard;
  bool enablePaidGroupChat;
  bool enableCheckout;

  AppConfigurationModel({
    required this.id,
    required this.country,
    this.enableAsk = false,
    this.enableCheckout = false,
    this.enablePaidGroupChat = false,
    this.enableSuperBlog = false,
    this.enablePayment = false,
    this.freeSubscription = false,
    this.enableUtility = false,
    this.enableMoment = false,
    this.enableCashout = false,
    this.enableContract = false,
    this.enableEmptyEnvelope = false,
    this.enableGroupChat = false,
    this.enableInvoice = false,
    this.enableLocationSharing = false,
    this.enableMagicEnvelope = false,
    this.enableAddUserCreditCard = false,
    this.enableWalletTopupWithCreditCard = false,
  });

  // factory AppConfigurationModel.fromJson(Map<String, dynamic> json) {
  //   return AppConfigurationModel(
  //     id: json['id'] ?? '1',
  //     country: json['country_name'] ?? 'Nigeria',
  //     enableCheckout: json['enable_checkout'] ?? false,
  //     freeSubscription: json['free_subscription'] ?? false,
  //     enablePaidGroupChat: json['enable_paid_group_chat'] ?? false,
  //     enableAsk: json['enable_ask'] ?? false,
  //     enableSuperBlog: json['enable_super_blog'] ?? false,
  //     enablePayment: json['enable_payment'] ?? false,
  //     enableMoment: json['enable_moments'] ?? false,
  //     enableAddUserCreditCard: json['enable_add_user_credit_card'] ?? false,
  //     enableCashout: json['enable_cashout'] ?? false,
  //     enableContract: json['enable_contract'] ?? false,
  //     enableEmptyEnvelope: json['enable_empty_envelope'] ?? false,
  //     enableGroupChat: json['enable_group_chat'] ?? false,
  //     enableInvoice: json['enable_invoice'] ?? false,
  //     enableLocationSharing: json['enable_location_sharing'] ?? false,
  //     enableMagicEnvelope: json['enable_magic_envelope'] ?? false,
  //     enableUtility: json['enable_utility'] ?? false,
  //     enableWalletTopupWithCreditCard:
  //         json['enable_wallet_topup_with_credit_card'] ?? false,
  //   );
  // }
  factory AppConfigurationModel.fromJson(Map<String, dynamic> json) {
    return AppConfigurationModel(
      id: json['id'] ?? '1',
      country: json['country_name'] ?? 'Nigeria',
      enableCheckout: true,
      freeSubscription: json['free_subscription'] ?? false,
      enablePaidGroupChat: json['enable_paid_group_chat'] ?? false,
      enableAsk: json['enable_ask'] ?? false,
      enableSuperBlog: json['enable_super_blog'] ?? false,
      enablePayment: true,
      enableMoment: json['enable_moments'] ?? false,
      enableAddUserCreditCard: json['enable_add_user_credit_card'] ?? false,
      enableCashout: true,
      enableContract: json['enable_contract'] ?? false,
      enableEmptyEnvelope: true,
      enableGroupChat: json['enable_group_chat'] ?? false,
      enableInvoice: json['enable_invoice'] ?? false,
      enableLocationSharing: json['enable_location_sharing'] ?? false,
      enableMagicEnvelope: true,
      enableUtility: json['enable_utility'] ?? false,
      enableWalletTopupWithCreditCard:
          json['enable_wallet_topup_with_credit_card'] ?? false,
    );
  }

  static Map<String, dynamic> toMap(AppConfigurationModel model) => {
        'id': model.id,
        'country': model.country,
        'free_subscription': model.freeSubscription,
        'enable_moments': model.enableMoment,
        'enable_add_user_credit_card': model.enableAddUserCreditCard,
        'enable_cashout': model.enableCashout,
        'enable_contract': model.enableContract,
        'enable_empty_envelope': model.enableEmptyEnvelope,
        'enable_group_chat': model.enableGroupChat,
        'enable_invoice': model.enableInvoice,
        'enable_location_sharing': model.enableLocationSharing,
        'enable_magic_envelope': model.enableMagicEnvelope,
        'enable_utility': model.enableUtility,
        'enable_wallet_topup_with_credit_card':
            model.enableWalletTopupWithCreditCard,
      };

  static String serialize(AppConfigurationModel model) =>
      json.encode(AppConfigurationModel.toMap(model));

  static AppConfigurationModel deserialize(String json) =>
      AppConfigurationModel.fromJson(jsonDecode(json));

  // {"id":1,
  // "enable_wallet_topup_with_credit_card":false,
  // "enable_add_user_credit_card":false,
  // "enable_group_chat":false,
  // "enable_utility":false,
  // "enable_invoice":false,
  // "enable_contract":false,
  // "enable_cashout":false,
  // "enable_magic_envelope":false,
  // "enable_empty_envelope":false,
  // "enable_location_sharing":false,
  // "country_name":"Nigeria"}

}
