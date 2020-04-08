import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';

Future<Map> getDeviceInfo() async {
  Map data = {};
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    data['type'] = "IOS";
    data["mode"] = iosInfo.model;
    data["device_id"] = iosInfo.identifierForVendor;
    data["device_name"] = iosInfo.name;
  } else {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    data['type'] = "Android";
    data["mode"] = androidInfo.model;
    data["device_id"] = androidInfo.androidId;
    data["device_name"] = androidInfo.display;
  }
  return data;
}


Future<String> getId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    debugPrint(iosDeviceInfo.identifierForVendor);
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    debugPrint(androidDeviceInfo.androidId);
    return androidDeviceInfo.androidId; // unique ID on Android
  }
}
