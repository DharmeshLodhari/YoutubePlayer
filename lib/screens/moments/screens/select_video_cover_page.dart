import 'dart:io';

import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/storage_permission.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/utils/video_frame_extractor/video_frame_extractor.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
              height: 10,
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
      padding: EdgeInsets.all(25.0),
      child: Column(
        children: [
          Expanded(
            child: mediaRenderer(),
          ),
          SizedBox(height: 20.0),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : frames.isEmpty
                  ? const SizedBox.shrink()
                  : Container(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              imagePath = frames[index];
                            });
                          },
                          child: Image.file(
                            height: 70,
                            width: 60,
                            File(frames[index]),
                            fit: BoxFit.fill,
                          ),
                        ),
                        itemCount: frames.length,
                      ),
                    ),
          SizedBox(height: 20.0),
          _buildButton()
        ],
      ),
    );
  }

  Widget mediaRenderer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: imagePath == null
          ? Image.asset(
              defaultProductAndServiceImage,
              width: double.infinity,
              height: double.infinity,
              colorBlendMode: BlendMode.darken,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            )
          : Image(
              image: FileImage(
                File(imagePath ?? ""),
              ),
              fit: BoxFit.fill,
            ),
    );
  }

  Widget _buildButton() {
    return CurvedButton(
      onPressed: () async {
        bool isPermissionGranted = await requestGalleryPermission();
        if (isPermissionGranted) {
          pickImage();
        } else {
          bool isPermissionIsDenied = await isPermanentlyDeniedPermission();
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
        String? croppedImage = await ImageCrop().cropImage(value.path);
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
    frames = await VideoFrameExtractor.fromNetwork(
      videoUrl: url,
      imagesCount: 8,
      destinationDirectoryPath: '/storage/emulated/0/Download',
      onProgress: (progress) {},
    );
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteFiles() async {
    try {
      // Get the download directory path
      Directory? downloadDirectory = await getDownloadsDirectory();
      String? downloadPath = downloadDirectory?.path;

      // List all files in the download directory
      List<FileSystemEntity>? fileList = downloadDirectory?.listSync();

      // Iterate through each file and delete if it starts with "extracted_"
      for (FileSystemEntity file in fileList ?? []) {
        if (file is File && file.path.startsWith('$downloadPath/extracted_')) {
          await file.delete();
        }
      }

      print('Files deleted successfully');
    } catch (e) {
      print('Error deleting files: $e');
    }
  }
}
