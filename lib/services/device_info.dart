import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';

Future<Map> getDeviceInfo() async {
  final Map data = {};
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    data['type'] = "IOS";
    data["mode"] = iosInfo.model;
    data["device_id"] = iosInfo.identifierForVendor;
    data["device_name"] = iosInfo.name;
  } else {
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    data['type'] = "Android";
    data["mode"] = androidInfo.model;
    data["device_id"] = androidInfo.id;
    data["device_name"] = androidInfo.display;
  }
  return data;
}

Future<String?> getId() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
    debugPrint(iosDeviceInfo.identifierForVendor);
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else {
    final AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    debugPrint(androidDeviceInfo.id);
    return androidDeviceInfo.id; // unique ID on Android
  }
}
