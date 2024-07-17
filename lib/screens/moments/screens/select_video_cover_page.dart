import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/storage_permission.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/utils/video_frame_extractor/video_frame_extractor.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class SelectVideoCoverPage extends StatefulWidget {
  final String videoPath;

  const SelectVideoCoverPage({super.key, required this.videoPath});

  @override
  State<SelectVideoCoverPage> createState() => _SelectVideoCoverPageState();
}

class _SelectVideoCoverPageState extends State<SelectVideoCoverPage> {
  String? imagePath;
  List<String> frames = [];
  bool isLoading = false;

  @override
  void initState() {
    generateFrames();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          backgroundColor: lightGrey,
          appBar: appBar(),
          body: _buildBody(),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        AppLocalization.of(context)!.selectCover,
        style: TextStyle(
          color: blackFont,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (imagePath == null)
          const SizedBox.shrink()
        else
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CurvedButton(
              width: 100,
              borderRadius: 20,
              text: 'Save',
              fontSize: 14,
              onPressed: () async {
                Navigator.pop(context, imagePath);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: navyBlue,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Extracting images, This may take up to 20 seconds.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Inter",
                    ),
                  )
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: mediaRenderer(),
                ),
                const SizedBox(height: 20.0),
                if (frames.isEmpty)
                  const SizedBox.shrink()
                else
                  SizedBox(
                    height: 75,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            imagePath = frames[index];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: imagePath == frames[index]
                                  ? navyBlue
                                  : transparent, // Apply border if selected
                              width: imagePath == frames[index]
                                  ? 4
                                  : 0, // Adjust border width as needed
                            ),
                          ),
                          child: Image.file(
                            height: 70,
                            width: 50,
                            File(frames[index]),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      itemCount: frames.length,
                    ),
                  ),
                const SizedBox(height: 20.0),
                _buildButton()
              ],
            ),
    );
  }

  Widget mediaRenderer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: imagePath == null
          ? Center(
              child: Image.asset(
                defaultProductAndServiceImage,
                colorBlendMode: BlendMode.darken,
                filterQuality: FilterQuality.high,
              ),
            )
          : Image(
              image: FileImage(
                File(imagePath ?? ""),
              ),
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _buildButton() {
    return CurvedButton(
      onPressed: () async {
        final bool isPermissionGranted = await requestGalleryPermission();
        if (isPermissionGranted) {
          pickImage();
        } else {
          final bool isPermissionIsDenied =
              await isPermanentlyDeniedPermission();
          if (isPermissionIsDenied) {
            await openAppSettings();
          } else {
            await openAppSettings();
          }
        }
      },
      backgroundColor: navyBlue,
      textColor: white,
      text: 'Choose from gallery',
    );
  }

  void pickImage() async {
    ImagePicker().pickImage(source: ImageSource.gallery).then((value) async {
      if (value != null) {
        /// for cropping the image
        final String? croppedImage = await ImageCrop().cropImage(value.path);
        if (croppedImage == null) {
          return;
        }

        imagePath = croppedImage;
        if (mounted) setState(() {});
      }
    });
  }

  Future<void> generateFrames() async {
    String url;
    if (widget.videoPath.contains("Trimmer")) {
      url = "file://${widget.videoPath}";
    } else {
      url = widget.videoPath;
    }
    frames.clear();
    // deleteFiles();
    setState(() {
      isLoading = true;
    });
    final tempDir = Directory.systemTemp;
    frames = await VideoFrameExtractor.fromNetwork(
        videoUrl: url,
        imagesCount: 8,
        destinationDirectoryPath: tempDir.path,
        onProgress: (progress) {},
        quality: 8);
    imagePath = frames[0];
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteFiles() async {
    try {
      // Get the download directory path
      // Directory? downloadDirectory = await getDownloadsDirectory();
      // String? downloadPath = downloadDirectory?.path;
      // Path to the directory
      const String downloadPath = '/storage/emulated/0/Download';

      // Create a Directory object from the path
      final Directory downloadDirectory = Directory(downloadPath);

      // List all files in the download directory
      final List<FileSystemEntity> fileList = downloadDirectory.listSync();

      // Iterate through each file and delete if it starts with "extracted_"
      for (FileSystemEntity file in fileList ?? []) {
        if (file is File && file.path.startsWith('$downloadPath/extracted_')) {
          if (await file.exists()) {
            file.delete();
          } else {
            debugPrint('Error');
          }
        }
      }

      debugPrint('Files deleted successfully');
    } catch (e) {
      debugPrint('Error deleting files: $e');
    }
  }
}
