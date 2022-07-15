import 'dart:convert';

import 'package:Slydo/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/environment.dart';

/// This class holds the data we can use to manipulate our app.
/// E.g if we do not want the user to interact with the credit card feature yet,
/// we set the variable for it and do the check (if, else) for the feature and disable it.
class AppConfigurationBloc extends ChangeNotifier {
  AppConfigurationModel? _appConfigurationModel;

  AppConfigurationModel? get appConfigurationModel => _appConfigurationModel;

  set appConfigurationModel(AppConfigurationModel? appConfigurationModel) {
    _appConfigurationModel = appConfigurationModel;
    notifyListeners();
  }
}

class AppFeaturesService extends AuthService {
  Future<AppConfigurationModel?> getAppFeatures() async {
    String url = AppConfig.baseUrl + "/api/v1/user/app-settings";

    var headers = getNonAuthHeader();
    var response = await httpGet(url, headers: headers as Map<String, dynamic>?);

    debugPrint('SETTINGS :: ${response.body}');

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return AppConfigurationModel.fromJson(jsonData);
    } else {
      return Future.error('Something went wrong');
    }
  }
}

class AppConfigurationModel {
  int? id;
  String? country;
  bool enableMoment;
  bool enableLocationSharing;
  bool enableEmptyEnvelope;
  bool enableMagicEnvelope;
  bool enableCashout;
  bool enableInvoice;
  bool enableContract;
  bool enableUtility;
  bool enableGroupChat;
  bool freeSubscription;
  bool enableAddUserCreditCard;
  bool enableWalletTopupWithCreditCard;

  AppConfigurationModel({
    required this.id,
    required this.country,
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

  factory AppConfigurationModel.fromJson(Map<String, dynamic> json) {
    return AppConfigurationModel(
      id: json['id'],
      country: json['country'],
      freeSubscription: json['free_subscription'],
      enableMoment: json['enable_moments'],
      enableAddUserCreditCard: json['enable_add_user_credit_card'],
      enableCashout: json['enable_cashout'],
      enableContract: json['enable_contract'],
      enableEmptyEnvelope: json['enable_empty_envelope'],
      enableGroupChat: json['enable_group_chat'],
      enableInvoice: json['enable_invoice'],
      enableLocationSharing: json['enable_location_sharing'],
      enableMagicEnvelope: json['enable_magic_envelope'],
      enableUtility: json['enable_utility'],
      enableWalletTopupWithCreditCard:
          json['enable_wallet_topup_with_credit_card'],
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
