import 'package:Slydo/screens/blog/quill/image_embed_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/embeds/embed_types.dart';
import 'package:flutter_quill_extensions/embeds/toolbar/camera_button.dart';
import 'package:flutter_quill_extensions/embeds/toolbar/formula_button.dart';
import 'package:flutter_quill_extensions/embeds/toolbar/image_button.dart';
import 'package:flutter_quill_extensions/embeds/toolbar/video_button.dart';

class CustomQuillEmbed {
  static List<EmbedBuilder> builders(
          {void Function(GlobalKey videoContainerKey)? onVideoInit}) =>
      [
        ImageEmbedBuilder(),
        VideoEmbedBuilder(onVideoInit: onVideoInit),
        FormulaEmbedBuilder(),
      ];

  static List<EmbedButtonBuilder> buttons({
    bool showImageButton = true,
    bool showVideoButton = true,
    bool showCameraButton = true,
    bool showFormulaButton = false,
    OnImagePickCallback? onImagePickCallback,
    OnVideoPickCallback? onVideoPickCallback,
    MediaPickSettingSelector? mediaPickSettingSelector,
    MediaPickSettingSelector? cameraPickSettingSelector,
    FilePickImpl? filePickImpl,
    WebImagePickImpl? webImagePickImpl,
    WebVideoPickImpl? webVideoPickImpl,
  }) {
    return [
      if (showImageButton)
        (controller, toolbarIconSize, iconTheme, dialogTheme) => ImageButton(
              icon: Icons.image,
              iconSize: toolbarIconSize,
              controller: controller,
              onImagePickCallback: onImagePickCallback,
              filePickImpl: filePickImpl,
              webImagePickImpl: webImagePickImpl,
              mediaPickSettingSelector: mediaPickSettingSelector,
              iconTheme: iconTheme,
              dialogTheme: dialogTheme,
            ),
      if (showVideoButton)
        (controller, toolbarIconSize, iconTheme, dialogTheme) => VideoButton(
              icon: Icons.movie_creation,
              iconSize: toolbarIconSize,
              controller: controller,
              onVideoPickCallback: onVideoPickCallback,
              filePickImpl: filePickImpl,
              webVideoPickImpl: webImagePickImpl,
              mediaPickSettingSelector: mediaPickSettingSelector,
              iconTheme: iconTheme,
              dialogTheme: dialogTheme,
            ),
      if ((onImagePickCallback != null || onVideoPickCallback != null) &&
          showCameraButton)
        (controller, toolbarIconSize, iconTheme, dialogTheme) => CameraButton(
              icon: Icons.photo_camera,
              iconSize: toolbarIconSize,
              controller: controller,
              onImagePickCallback: onImagePickCallback,
              onVideoPickCallback: onVideoPickCallback,
              filePickImpl: filePickImpl,
              webImagePickImpl: webImagePickImpl,
              webVideoPickImpl: webVideoPickImpl,
              cameraPickSettingSelector: cameraPickSettingSelector,
              iconTheme: iconTheme,
            ),
      if (showFormulaButton)
        (controller, toolbarIconSize, iconTheme, dialogTheme) => FormulaButton(
              icon: Icons.functions,
              iconSize: toolbarIconSize,
              controller: controller,
              onImagePickCallback: onImagePickCallback,
              filePickImpl: filePickImpl,
              webImagePickImpl: webImagePickImpl,
              mediaPickSettingSelector: mediaPickSettingSelector,
              iconTheme: iconTheme,
              dialogTheme: dialogTheme,
            )
    ];
  }
}
