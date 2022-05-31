import 'dart:convert';

import 'package:Slydo/services/auth.dart';
import 'package:flutter/cupertino.dart';

import '../data/environment.dart';

class AppConfigurationBloc extends ChangeNotifier {
  AppConfigurationModel? _appConfigurationModel;

  AppConfigurationModel? get appConfigurationModel => _appConfigurationModel;

  set appConfigurationModel(AppConfigurationModel? appConfigurationModel) {
    _appConfigurationModel = appConfigurationModel;
    notifyListeners();
  }
}

class AppConfigurationModel {
  bool creditCardWorks;

  AppConfigurationModel({required this.creditCardWorks});
}

class AppConfigurationService extends AuthService {
  Future<AppConfigurationModel?> getAppConfigurations() async {
    String url = AppConfig.baseUrl + "api/v1/app-config";
    var headers = await getAuthHeaders();
    var response = await httpGet(url, headers: headers);

    return AppConfigurationModel(creditCardWorks: false);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
    }
  }
}
