import 'dart:io';

import 'package:device_info/device_info.dart';


Future<Map> getDeviceInfo() async {
  Map data = {};
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    data["mode"] = iosInfo.model;
    data["device_id"] = iosInfo.identifierForVendor;
    data["name"] = iosInfo.name;
  }
  else {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    data["mode"] = androidInfo.model;
    data["device_id"] = androidInfo.androidId;
    data["name"] = androidInfo.display;
  }
  return data;
}