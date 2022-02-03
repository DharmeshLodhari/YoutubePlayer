import 'package:flutter/material.dart';

/// This File is use to set environment SERVER Urls of the app
/// PRODUCTION & DEVELOPMENT

enum AppType { DEVELOPMENT, PRODUCTION }

class AppConfig {
  static final AppConfig _appConfig = AppConfig._internal();

  static AppType? appType;

  static late String baseUrl;
  static late String localHost;
  static late String gifApiKey;
  static String? socketUrl;
  static String? googleMapApiKey;
  static late String chatUrl;
  static String? termsAndCondition;
  static String? privacyPolicy;

  static void initialize() {
    const BUILD_TYPE =
        String.fromEnvironment('BUILD_TYPE', defaultValue: 'PRODUCTION');
    debugPrint("BUILD_TYPE:- $BUILD_TYPE");
    if (BUILD_TYPE == "PRODUCTION") {
      appType = AppType.PRODUCTION;
    } else if (BUILD_TYPE == "DEVELOPMENT") {
      appType = AppType.DEVELOPMENT;
    } else {
      appType = AppType.PRODUCTION;
    }

    if (appType == AppType.DEVELOPMENT) {
      // baseUrl = "https://devapi.slydo.co";
      baseUrl = "https://api.slydo.co";
      localHost = "https://127.0.0.1:8080";
      gifApiKey = "Jmh8SVxEvtKVCegoJDNYnxSSSbfPISPs";
      socketUrl = "wss://devchat.slydo.co/ws/main";
      chatUrl = "https://devchat.slydo.co";
      googleMapApiKey = "AIzaSyCLDiXFm1mRQEsutNrxX_Hv-sHrbhvASzY";
      termsAndCondition = "https://slydo.co/terms/";
      privacyPolicy = "https://slydo.co/privacy/";
    } else if (appType == AppType.PRODUCTION) {
      baseUrl = "https://api.slydo.co";
      localHost = "https://127.0.0.1:8080";
      gifApiKey = "Jmh8SVxEvtKVCegoJDNYnxSSSbfPISPs";
      socketUrl = "wss://chat.slydo.co/ws/main";
      chatUrl = "https://chat.slydo.co";
      googleMapApiKey = "AIzaSyCLDiXFm1mRQEsutNrxX_Hv-sHrbhvASzY";
      termsAndCondition = "https://slydo.co/terms/";
      privacyPolicy = "https://slydo.co/privacy/";
    }
  }

  factory AppConfig() {
    initialize();
    return _appConfig;
  }

  AppConfig._internal();
}
