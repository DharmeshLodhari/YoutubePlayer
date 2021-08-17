import 'package:flutter/material.dart';

enum AppType { DEVELOPMENT, PRODUCTION }

class AppConfig {
  static final AppConfig _appConfig = AppConfig._internal();

  static AppType appType;

  static String baseUrl;
  static String localHost;
  static String gifApiKey;
  static String socketUrl;
  static String googleMapApiKey;

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
      baseUrl = "https://api.slydo.co";
      localHost = "https://127.0.0.1:8080";
      gifApiKey = "Jmh8SVxEvtKVCegoJDNYnxSSSbfPISPs";
      socketUrl = "wss://chat.slydo.co/ws/main";
      googleMapApiKey = "AIzaSyCLDiXFm1mRQEsutNrxX_Hv-sHrbhvASzY";
    } else if (appType == AppType.PRODUCTION) {
      baseUrl = "https://api.slydo.co";
      localHost = "https://127.0.0.1:8080";
      gifApiKey = "Jmh8SVxEvtKVCegoJDNYnxSSSbfPISPs";
      socketUrl = "wss://chat.slydo.co/ws/main";
      googleMapApiKey = "AIzaSyCLDiXFm1mRQEsutNrxX_Hv-sHrbhvASzY";
    }
  }

  factory AppConfig() {
    initialize();
    return _appConfig;
  }

  AppConfig._internal();
}
