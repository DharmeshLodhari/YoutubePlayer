import 'dart:io';

import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCrop {
  Future<String?> cropImage(String filePath) async {
    debugPrint("Selected image => $filePath");

    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      uiSettings: [
        AndroidUiSettings(
          statusBarColor: navyBlue,
          activeControlsWidgetColor: navyBlue,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(aspectRatioLockEnabled: false)
      ],
    );

    if (croppedImage != null) {
      debugPrint("Cropped image => ${croppedImage.path}");
      return croppedImage.path;
    }
    return null;
  }
}
