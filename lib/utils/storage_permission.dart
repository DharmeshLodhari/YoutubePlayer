import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestGalleryPermission() async {
  bool permissionStatus;

  if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    final int sdkVersion = deviceInfo.version.sdkInt;

    if (sdkVersion >= 33) {
      permissionStatus = await Permission.photos.request().isGranted;
    } else {
      permissionStatus = await Permission.storage.request().isGranted;
    }
  } else {
    permissionStatus = await Permission.storage.request().isGranted;
  }

  return permissionStatus;
}

Future<bool> isPermanentlyDeniedPermission() async {
  bool permissionStatus;
  if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    final int sdkVersion = deviceInfo.version.sdkInt;
    if (sdkVersion != null && sdkVersion >= 33) {
      permissionStatus = await Permission.photos.isPermanentlyDenied;
    } else {
      permissionStatus = await Permission.storage.isPermanentlyDenied;
    }
  } else {
    permissionStatus = await Permission.storage.isPermanentlyDenied;
  }

  return permissionStatus;
}
