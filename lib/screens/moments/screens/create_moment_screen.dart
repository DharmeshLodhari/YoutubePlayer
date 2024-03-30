import 'dart:async';
import 'dart:io';

import 'package:Slydo/screens/moments/screens/preview_moment_screen.dart';
import 'package:Slydo/screens/moments/screens/trimmer_view.dart';
import 'package:Slydo/screens/more_apps/messaging/chat/utils.dart';

import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/storage_permission.dart';
import 'package:Slydo/utils/util.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../../../main.dart';
import '../../../widget/image_crop.dart';

class CreateMediaMomentScreen extends StatefulWidget {
  var arguments;

  CreateMediaMomentScreen({Key? key, this.arguments}) : super(key: key);

  @override
  _CreateMediaMomentScreenState createState() =>
      _CreateMediaMomentScreenState();
}

class _CreateMediaMomentScreenState extends State<CreateMediaMomentScreen> {
  Timer? timer;
  String? videoPath;
  String? imagePath;
  int videoTimer = 30;
  bool videoPlayerLoading = false;
  CameraController? cameraController;
  VideoPlayerController? videoPlayerController;

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
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null ||
        !(cameraController?.value.isInitialized ?? false)) {
      return Scaffold(
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

    double wt = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          mediaCaptured()
              ? showCapturedMedia()
              : Center(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: CameraPreview(
                      cameraController!,
                    ),
                  ),
                ),
          // Positioned(
          //   top: ht / 3,
          //   left: 4,
          //   child: Column(
          //     children: [
          //       IconButton(
          //         onPressed: () {},
          //         icon: const Icon(
          //           Icons.sync,
          //           color: Colors.white,
          //         ),
          //       ),
          //       IconButton(
          //         onPressed: () {},
          //         icon: const Icon(
          //           Icons.speed,
          //           color: Colors.white,
          //         ),
          //       ),
          //       IconButton(
          //         onPressed: () {},
          //         icon: const Icon(
          //           Icons.timer_outlined,
          //           color: Colors.white,
          //         ),
          //       ),
          //       IconButton(
          //         onPressed: () {},
          //         icon: const Icon(
          //           Icons.join_inner_rounded,
          //           color: Colors.white,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
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
                            bool isPermissionGranted =
                                await requestGalleryPermission();
                            if (isPermissionGranted) {
                              await pickFileFromMedia();
                            } else {
                              bool isPermissionIsDenied =
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
                    videoTimer != 30
                        ? Text(
                            videoTimer.toString(),
                            style: TextStyle(
                                color: navyBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: 4),
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
                      "Preview",
                      style: TextStyle(
                          color: mediaCaptured()
                              ? navyBlue
                              : Colors.white.withOpacity(0.5),
                          fontSize: 14),
                    ),
                    onPressed: mediaCaptured()
                        ? () {
                            NavigationUtil.push(
                              context,
                              screen: PreviewMomentScreen(
                                  filePath: getMediaPathToSendToPreviewScreen(),
                                  arguments: {
                                    "channel": widget.arguments == null
                                        ? ""
                                        : widget.arguments['channel']
                                  }),
                            );
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
                      primary: Colors.white,
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
          child: Icon(
            Icons.flip_camera_android_outlined,
            color: Colors.white,
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildBackButton() {
    return Positioned(
      left: 15,
      top: 50,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Icon(
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

        String? croppedImagePath = await ImageCrop().cropImage(file.path);
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
        timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
      ..initialize().then((_) => videoPlayerController?.pause());
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
                  videoPlayerController?.dispose();
                });
              },
              icon: Icon(Icons.close, size: 25, color: Colors.red),
            ),
          ),
        ],
      );

      // if (videoPlayerController != null &&
      //     videoPlayerController.value.isInitialized) {
      // }
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
                icon: Icon(Icons.close, size: 25, color: Colors.red)),
          ),
        ],
      );
    }

    return Container(color: greyBorderColor);
  }

  pickFileFromMedia() async {
    // final file = await ImagePicker()
    //     .pickImage(source: ImageSource.gallery, imageQuality: 70);

    // FilePickerResult? pickedMedia = await FilePicker.platform.pickFiles(
    //     allowMultiple: false,
    //     type: FileType.custom,
    //     allowedExtensions: imageExtensions);

    // List<Media>? res = await ImagesPicker.pick(
    //   count: 1,
    //   pickType: PickType.all,
    //   language: Language.System,
    //   maxTime: 900,
    //   cropOpt: CropOption(
    //     // aspectRatio: CropAspectRatio.wh16x9,
    //     cropType: CropType.rect,
    //   ),
    // );

    XFile? res = await selectSingleImageVideo();

    if (res == null) return;
    File file = File(res.path);
    String? mediaType = getFileTypeByPath(path: file.path);

    if (mediaType == null) return;

    if (mediaType == 'image') {
      imagePath = file.path;
      if (mounted) setState(() {});

      // String? croppedImagePath = await ImageCrop().cropImage(file.path);
      // if (croppedImagePath != null) {
      //   imagePath = croppedImagePath;
      //   if (mounted) setState(() {});
      // }
    } else if (mediaType == 'video') {
      var videoFilePath =
          await NavigationUtil.push(context, screen: TrimmerView(file: file));
      if (videoFilePath is String) {
        videoPath = videoFilePath;
        if (mounted) setState(() {});
      } else {
        // showToast(message: 'Error formatting video, please try again');
      }
    }
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
    List<CameraDescription> _availableCameras = await availableCameras();
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
}
