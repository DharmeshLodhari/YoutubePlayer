import 'dart:async';
import 'dart:io';

import 'package:Slydo/main.dart';
import 'package:Slydo/screens/moments/screens/trimmer_view.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';
import 'package:Slydo/screens/more_apps/yarn/models/Topics/yarn_model.dart';
import 'package:Slydo/screens/more_apps/yarn/utils/utils.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/storage_permission.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/image_crop.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class CreateMediaScreen extends StatefulWidget {
  final Function(List<YarnMedia>)? addedSelectedMedia;
  int? imageCount;

  CreateMediaScreen({Key? key, this.addedSelectedMedia, this.imageCount})
      : super(key: key);

  @override
  _CreateMediaScreenState createState() => _CreateMediaScreenState();
}

class _CreateMediaScreenState extends State<CreateMediaScreen> {
  Timer? timer;
  String? videoPath;
  String? imagePath;
  int videoTimer = 30;
  bool videoPlayerLoading = false;
  CameraController? cameraController;
  VideoPlayerController? videoPlayerController;

  List<Map<String, dynamic>> selectedImagesList = [];
  List<YarnMedia> selectedMedia = [];
  List<PickedFile> selectedImages = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (cameras.isNotEmpty) {
        _initCameraController(newCameraDescription: cameras[0]);
      } else {
        showToast(message: "You don't have any Camera !!");
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    cameraController?.dispose();
    videoPlayerController?.dispose();
    super.dispose();
  }

  void _initCameraController(
      {required CameraDescription newCameraDescription}) {
    cameraController =
        CameraController(newCameraDescription, ResolutionPreset.max);
    cameraController?.initialize().then((_) {
      cameraController?.setFlashMode(FlashMode.off);

      if (mounted) setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            debugPrint('User denied camera access.');
            break;
          default:
            debugPrint('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null ||
        !(cameraController?.value.isInitialized ?? false)) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Camera permissions have not been granted yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }

    final double wt = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          if (mediaCaptured())
            showCapturedMedia()
          else
            Center(
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: CameraPreview(
                  cameraController!,
                ),
              ),
            ),
          Positioned(
            width: wt,
            bottom: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: mediaCaptured()
                      ? null
                      : () async {
                          if (!(cameraController?.value.isTakingPicture ??
                                  false) &&
                              !(cameraController?.value.isRecordingVideo ??
                                  false)) {
                            final bool isPermissionGranted =
                                await requestGalleryPermission();
                            if (isPermissionGranted) {
                              await pickFileFromMedia();
                            } else {
                              final bool isPermissionIsDenied =
                                  await isPermanentlyDeniedPermission();
                              if (isPermissionIsDenied) {
                                await openAppSettings();
                              } else {
                                await openAppSettings();
                              }
                            }
                          }
                        },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: greyBorderColor,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.white,
                      ),
                    ),
                    child: Image.asset('assets/images/apps_icon.png'),
                  ),
                ),
                Column(
                  children: [
                    if (videoTimer != 30)
                      Text(
                        videoTimer.toString(),
                        style: TextStyle(
                            color: navyBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      )
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onLongPressStart: mediaCaptured()
                          ? null
                          : (longPressDownDetails) async {
                              takePictureOrVideo(mediaType: MediaType.video);
                            },
                      onLongPressUp: mediaCaptured()
                          ? null
                          : () {
                              timer?.cancel();
                              videoTimer = 30;
                              if (cameraController?.value.isRecordingVideo ??
                                  false) {
                                stopVideoRecording();
                              }
                            },
                      onTap: mediaCaptured()
                          ? null
                          : () {
                              onTakePictureButtonPressed();
                            },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.camera,
                          color: navyBlue,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 100,
                  height: 35,
                  child: ElevatedButton.icon(
                    icon: Text(
                      "Done",
                      style: TextStyle(
                          color: mediaCaptured()
                              ? navyBlue
                              : Colors.white.withOpacity(0.5),
                          fontSize: 14),
                    ),
                    onPressed: mediaCaptured()
                        ? () {
                            goBack();

                            imagePath = null;
                            videoPath = null;
                            if (mounted) setState(() {});
                          }
                        : null,
                    label: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: mediaCaptured()
                          ? navyBlue
                          : Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: mediaCaptured()
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      fixedSize: const Size(208, 43),
                    ),
                  ),
                )
              ],
            ),
          ),
          _buildCameraToggle(),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildCameraToggle() {
    if (!mediaCaptured()) {
      return Positioned(
        right: 15,
        top: 50,
        child: InkWell(
          onTap: () {
            _toggleCameraLens();
          },
          child: const Icon(
            Icons.flip_camera_android_outlined,
            color: Colors.white,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBackButton() {
    return Positioned(
      left: 15,
      top: 50,
      child: InkWell(
        onTap: () {
          cameraController?.dispose();
          videoPlayerController?.dispose();
          Navigator.of(context).pop();
        },
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  void onTakePictureButtonPressed() {
    debugPrint('onTakePictureButtonPressed');
    takePictureOrVideo(mediaType: MediaType.picture).then((file) async {
      if (file != null) {
        debugPrint('IMAGE PATH XFILE -> $file');

        final String? croppedImagePath = await ImageCrop().cropImage(file.path);
        if (croppedImagePath != null) {
          imagePath = croppedImagePath;
          if (mounted) setState(() {});
        }
      }
    });
  }

  Future<XFile?> takePictureOrVideo({required MediaType mediaType}) async {
    if (!(cameraController?.value.isInitialized ?? false)) {
      showToast(message: 'Error: select a camera first.');
      return null;
    }

    if ((cameraController?.value.isTakingPicture ?? false) ||
        (cameraController?.value.isRecordingVideo ?? false)) {
      return null;
    }

    try {
      if (mediaType == MediaType.picture) {
        debugPrint('Taking picture');

        final XFile? file = await cameraController?.takePicture();
        debugPrint('PICTURE TAKEN :: $file');

        if (file != null) {
          return file;
        } else {
          return null;
        }
      } else {
        cameraController?.startVideoRecording();
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              videoTimer--;
            });

            if (videoTimer == 0) {
              timer.cancel();
              videoTimer = 30;
              stopVideoRecording();
            }
          }
        });

        //We do not need what it returns here (for video) so we can safely return null
        // (the result for taking the video is done in stopRecording() method).
        return null;
      }
    } on CameraException catch (e) {
      showToast(message: 'Error: ${e.code}\n${e.description}');
      return null;
    }
  }

  setUpVideoPlayer() async {
    videoPlayerController = VideoPlayerController.file(File(videoPath!),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
      ..initialize().then((_) => videoPlayerController?.play())
      ..setLooping(true);
  }

  Widget showCapturedMedia() {
    if (videoPath != null) {
      debugPrint('VIDEO SIZE -> ::: ${File(videoPath!).lengthSync()}');

      setUpVideoPlayer();
      return Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: VideoPlayer(videoPlayerController!),
          ),
          Positioned(
            right: 15,
            top: 30,
            child: IconButton(
              onPressed: () {
                setState(() {
                  videoPath = null;
                  videoPlayerController?.pause();
                  videoPlayerController?.dispose();
                });
              },
              icon: const Icon(Icons.close, size: 25, color: Colors.red),
            ),
          ),
        ],
      );
    }

    debugPrint('IMAGE PATH -> ::: $imagePath');

    if (imagePath != null) {
      return Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.file(
              File(
                imagePath!,
              ),
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned(
            right: 15,
            top: 30,
            child: IconButton(
                onPressed: () {
                  setState(() {
                    imagePath = null;
                  });
                },
                icon: const Icon(Icons.close, size: 25, color: Colors.red)),
          ),
        ],
      );
    }

    return Container(color: greyBorderColor);
  }

  pickFileFromMedia() async {
    int countMedia = 0;
    if (widget.imageCount! > 0) {
      countMedia = 4 - widget.imageCount!;
    }

    // List<Media>? res = await ImagesPicker.pick(
    //   count: countMedia,
    //   pickType: PickType.all,
    //   language: Language.System,
    //   maxTime: 900,
    //   cropOpt: CropOption(
    //     cropType: CropType.rect,
    //   ),
    // );

    final List<XFile> res = await selectMultipleImageVideo();
    debugPrint("imageCount = ${widget.imageCount}");
    if (res == null || res.isEmpty) return;
    if ((widget.imageCount ?? 0) + res.length > 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You can select only 4 images or videos'),
      ));
      return;
    }

    for (var item in res) {
      final File file = File(item.path);
      final String? mediaType = getFileTypeByPath(path: file.path);

      if (mediaType == null) return;

      if (mediaType == 'image') {
        imagePath = file.path;
        selectedMedia
            .add(YarnMedia(mediaFile: File(imagePath!), mediaType: mediaType));
      } else if (mediaType == 'video') {
        final videoFilePath =
            await NavigationUtil.push(context, screen: TrimmerView(file: file));
        if (videoFilePath is String) {
          videoPath = videoFilePath;
          final Uint8List? uInt8List =
              await getVideoThumbnailFromUrl(videoPath!);
          final String? thumbnailImage =
              await generateThumbNailFromVideo(videoPath: videoPath!);

          selectedMedia.add(YarnMedia(
              mediaFile: File(videoPath!),
              mediaType: mediaType,
              mediaPoster: thumbnailImage));
        }
      }
    }

    if (widget.addedSelectedMedia != null)
      widget.addedSelectedMedia!(selectedMedia);

    cameraController?.dispose();
    videoPlayerController?.dispose();

    Navigator.pop(context);
  }

  void stopVideoRecording() {
    cameraController?.stopVideoRecording().then((xfile) {
      if (mounted) {
        setState(() {
          videoPath = xfile.path;
        });
      }
    });
  }

  String getMediaPathToSendToPreviewScreen() {
    if (imagePath != null) {
      return imagePath!;
    }
    return videoPath!;
  }

  bool mediaCaptured() {
    return imagePath != null || videoPath != null;
  }

  void _toggleCameraLens() async {
    // get current lens direction (front / rear)
    final lensDirection = cameraController?.description.lensDirection ??
        CameraLensDirection.front;
    final List<CameraDescription> _availableCameras = await availableCameras();
    CameraDescription? newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = _availableCameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = _availableCameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }

    if (newDescription != null) {
      debugPrint('NEW DESC :: $newDescription');
    }
    _initCameraController(newCameraDescription: newDescription);
  }

  goBack() async {
    if (videoPath != null) {
      debugPrint('VIDEO SIZE -> ::: ${File(videoPath!).lengthSync()}');

      final String? mediaType = getFileTypeByPath(path: videoPath.toString());

      if (videoPath is String) {
        final File file = File(videoPath.toString());

        videoPlayerController!.pause();

        final videoFilePath =
            await NavigationUtil.push(context, screen: TrimmerView(file: file));
        if (videoFilePath is String) {
          videoPath = videoFilePath;

          final String? thumbnailImage =
              await generateThumbNailFromVideo(videoPath: videoPath!);

          selectedMedia.add(YarnMedia(
              mediaFile: File(videoPath!),
              mediaType: mediaType,
              mediaPoster: thumbnailImage));
          widget.addedSelectedMedia!(selectedMedia);

          cameraController?.dispose();
          videoPlayerController?.dispose();

          Navigator.pop(context);
          if (mounted) setState(() {});
        }
      }
    }

    debugPrint('IMAGE PATH -> ::: $imagePath');

    if (imagePath != null) {
      final String? mediaType = getFileTypeByPath(path: imagePath.toString());

      selectedMedia
          .add(YarnMedia(mediaFile: File(imagePath!), mediaType: mediaType));

      widget.addedSelectedMedia!(selectedMedia);

      cameraController?.dispose();
      videoPlayerController?.dispose();

      Navigator.pop(context);
      if (mounted) setState(() {});
    }
  }
}
