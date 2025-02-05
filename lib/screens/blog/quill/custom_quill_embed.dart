// import 'package:Slydo/screens/blog/quill/image_embed_builder.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_quill/flutter_quill.dart' hide Text;
// import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
//
// class CustomQuillEmbed {
//   static List<EmbedBuilder> builders(
//           {void Function(GlobalKey videoContainerKey)? onVideoInit}) =>
//       [
//         ImageEmbedBuilder(),
//         VideoEmbedBuilder(onVideoInit: onVideoInit),
//         FormulaEmbedBuilder(),
//       ];
//
//   static List<EmbedButtonBuilder> buttons({
//     bool showImageButton = true,
//     bool showVideoButton = true,
//     bool showCameraButton = true,
//     bool showFormulaButton = false,
//     // OnImagePickCallback? onImagePickCallback,
//     // OnVideoPickCallback? onVideoPickCallback,
//     // MediaPickSettingSelector? mediaPickSettingSelector,
//     // MediaPickSettingSelector? cameraPickSettingSelector,
//     // FilePickImpl? filePickImpl,
//     // WebImagePickImpl? webImagePickImpl,
//     // WebVideoPickImpl? webVideoPickImpl,
//   }) {
//     return [
//       if (showImageButton)
//         (controller, toolbarIconSize, iconTheme, dialogTheme) =>
//             QuillToolbarImageButton(
//               controller: controller,
//               options: QuillToolbarImageButtonOptions(
//                 iconData: Icons.image,
//                 iconSize: toolbarIconSize,
//                 dialogTheme: dialogTheme,
//                 iconTheme: iconTheme,
//                 // onImagePickCallback: onImagePickCallback,
//                 // filePickImpl: filePickImpl,
//                 // webImagePickImpl: webImagePickImpl,
//                 // mediaPickSettingSelector: mediaPickSettingSelector,
//               ),
//             ),
//       if (showVideoButton)
//         (controller, toolbarIconSize, iconTheme, dialogTheme) =>
//             QuillToolbarVideoButton(
//               controller: controller,
//               options: QuillToolbarVideoButtonOptions(
//                 iconData: Icons.movie_creation,
//                 iconTheme: iconTheme,
//                 iconSize: toolbarIconSize,
//                 dialogTheme: dialogTheme,
//                 // onVideoPickCallback: onVideoPickCallback,
//                 // filePickImpl: filePickImpl,
//                 // webVideoPickImpl: webImagePickImpl,
//                 // mediaPickSettingSelector: mediaPickSettingSelector,
//               ),
//             ),
//       if (showCameraButton)
//         (controller, toolbarIconSize, iconTheme, dialogTheme) =>
//             QuillToolbarCameraButton(
//               controller: controller,
//               options: QuillToolbarCameraButtonOptions(
//                 iconData: Icons.photo_camera,
//                 iconTheme: iconTheme,
//                 iconSize: toolbarIconSize,
//                 // onImagePickCallback: onImagePickCallback,
//                 // onVideoPickCallback: onVideoPickCallback,
//                 // filePickImpl: filePickImpl,
//                 // webImagePickImpl: webImagePickImpl,
//                 // webVideoPickImpl: webVideoPickImpl,
//                 // cameraPickSettingSelector: cameraPickSettingSelector,
//               ),
//             ),
//       if (showFormulaButton)
//         (controller, toolbarIconSize, iconTheme, dialogTheme) =>
//             QuillToolbarFormulaButton(
//               controller: controller,
//               options: QuillToolbarFormulaButtonOptions(
//                 iconData: Icons.functions,
//                 iconSize: toolbarIconSize,
//                 iconTheme: iconTheme,
//                 // onImagePickCallback: onImagePickCallback,
//                 // filePickImpl: filePickImpl,
//                 // webImagePickImpl: webImagePickImpl,
//                 // mediaPickSettingSelector: mediaPickSettingSelector,
//                 // dialogTheme: dialogTheme,
//               ),
//             )
//     ];
//   }
// }
