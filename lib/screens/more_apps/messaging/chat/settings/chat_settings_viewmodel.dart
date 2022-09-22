import 'package:Slydo/utils/util.dart';
import 'package:flutter/cupertino.dart';

class ChatSettingViewModel extends ChangeNotifier {
  String? imagePath;
  bool? isImagePicked = false;

  void pickBlogImage(
      {Function(String image)? imagePickedCallBack,
      BuildContext? context}) async {
    String? croppedImage = await getFile(context!);

    if (imagePickedCallBack != null && croppedImage != null) {
      imagePickedCallBack(croppedImage);
    } else {
      if (croppedImage != null) {
        imagePath = croppedImage;
        isImagePicked = true;
      }
    }
  }
}
