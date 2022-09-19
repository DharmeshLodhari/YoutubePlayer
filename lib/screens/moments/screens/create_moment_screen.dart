import 'dart:async';
import 'dart:io';

import 'package:Slydo/screens/moments/screens/preview_moment_screen.dart';
import 'package:Slydo/screens/moments/screens/trimmer_view.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../main.dart';
import '../../../widget/image_crop.dart';
import '../../more_apps/messaging/chat/utils.dart';

class CreateMediaMomentScreen extends StatefulWidget {
  const CreateMediaMomentScreen({Key? key}) : super(key: key);

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
  late CameraController cameraController;
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initCameraController(newCameraDescription: cameras[0]);
  }

  _initCameraController({required CameraDescription newCameraDescription}) {
    cameraController =
        CameraController(newCameraDescription, ResolutionPreset.max);
    cameraController.initialize().then((_) {
      cameraController.setFlashMode(FlashMode.off);
      if (!mounted) {
        return;
      }
      setState(() {});
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
  void dispose() {
    cameraController.dispose();
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
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
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          mediaCaptured()
              ? showCapturedMedia()
              : CameraPreview(cameraController),
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
                      : () {
                          if (!cameraController.value.isTakingPicture &&
                              !cameraController.value.isRecordingVideo) {
                            pickFileFromMedia();
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
                              if (cameraController.value.isRecordingVideo) {
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
                              ),
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
          !mediaCaptured()
              ? Positioned(
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
                )
              : SizedBox.shrink()
        ],
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
    if (!cameraController.value.isInitialized) {
      showToast(message: 'Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture ||
        cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      if (mediaType == MediaType.picture) {
        debugPrint('Taking picture');

        final XFile? file = await cameraController.takePicture();
        debugPrint('PICTURE TAKEN :: $file');

        if (file != null) {
          return file;
        } else {
          return null;
        }
      } else {
        cameraController.startVideoRecording();
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
    videoPlayerController = VideoPlayerController.file(File(videoPath!))
      ..initialize().then((_) => videoPlayerController.play())
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
            child: VideoPlayer(videoPlayerController),
          ),
          Positioned(
            right: 15,
            top: 30,
            child: IconButton(
              onPressed: () {
                setState(() {
                  videoPath = null;
                  videoPlayerController.dispose();
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

    FilePickerResult? pickedMedia = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: imageExtensions);

    if (pickedMedia != null) {
      File file = File(pickedMedia.files.single.path!);
      String mediaType = getFileType(pickedMedia);

      if (mediaType == 'image') {
        String? croppedImagePath = await ImageCrop().cropImage(file.path);
        if (croppedImagePath != null) {
          imagePath = croppedImagePath;
          if (mounted) setState(() {});
        }
      } else if (mediaType == 'video') {
        var videoFilePath =
            await NavigationUtil.push(context, screen: TrimmerView(file: file));
        if (videoFilePath is String) {
          if (mounted) {
            setState(() {
              videoPath = videoFilePath;
            });
          }
        } else {
          // showToast(message: 'Error formatting video, please try again');
        }
      }
    }
  }

  void stopVideoRecording() {
    cameraController.stopVideoRecording().then((xfile) {
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
    final lensDirection = cameraController.description.lensDirection;
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
