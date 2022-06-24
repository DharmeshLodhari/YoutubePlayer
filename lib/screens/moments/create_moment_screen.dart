import 'dart:async';
import 'dart:io';

import 'package:Slydo/screens/moments/models/create_moment_model.dart';
import 'package:Slydo/screens/moments/moments_service.dart';
import 'package:Slydo/screens/moments/preview_moment_screen.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_textform_field.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../main.dart';
import '../../utils/video_player_controller/chewie_player.dart';
import '../../widget/LoadingIndicator.dart';
import '../../widget/image_crop.dart';

class CreateMomentScreen extends StatefulWidget {
  CreateMomentScreen({Key? key}) : super(key: key);

  @override
  State<CreateMomentScreen> createState() => _CreateMomentScreenState();
}

class _CreateMomentScreenState extends State<CreateMomentScreen> {
  bool isPublic = false;
  String? filePath = '';

  final TextEditingController momentTextCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Moment'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24),
          child: Column(
            children: [
              CurvedButton(
                text: 'Pick image',
                onPressed: () async {
                  filePath = await getFile(context);
                  if (filePath != null) {
                    setState(() {});
                  }
                },
              ),
              SizedBox(height: 20),
              CurvedButton(
                text: 'Pick video',
                onPressed: () async {
                  filePath = await getFile(context, fileType: MediaType.video);
                },
              ),
              SizedBox(height: 20),
              Text(filePath!.isNotEmpty
                  ? filePath!.split('/').last
                  : 'fileName'),
              CustomizedTextFormField(
                controller: momentTextCtrl,
                hintText: 'Write your moment text...',
              ),
              Row(
                children: [
                  Text('Make Moment Public'),
                  Switch(
                    value: isPublic,
                    onChanged: (value) {
                      setState(() {
                        isPublic = value;
                      });
                      debugPrint('is public :: $isPublic');
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              CurvedButton(
                text: 'Create moment',
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (dialogLoadingContext) => LoadingIndicator());

                  MomentsService()
                      .createMoment(
                    createMomentModel: CreateMomentModel(
                        filePath: filePath!,
                        isPublic: isPublic,
                        text: momentTextCtrl.text),
                  )
                      .then((created) {
                    if (created == true) {
                      Navigator.pop(context);
                      Navigator.pop(context, true);
                    }
                  }).catchError((e) {
                    Navigator.pop(context);
                    showToast(message: 'Error message -> $e');
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddVideo extends StatefulWidget {
  const AddVideo({Key? key}) : super(key: key);

  @override
  _AddVideoState createState() => _AddVideoState();
}

class _AddVideoState extends State<AddVideo> {
  Timer? timer;
  String? videoPath;
  String? imagePath;
  int videoTimer = 30;
  bool videoPlayerLoading = false;
  late CameraController cameraController;
  VideoPlayerController? videoPlayerController;

  @override
  void initState() {
    super.initState();
    cameraController = CameraController(cameras[0], ResolutionPreset.max);
    cameraController.initialize().then((_) {
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
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return Scaffold(
        body: Center(
          child: Text(
            'Camera has not been initialized',
            style: TextStyle(
              color: blackFont,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    double wt = MediaQuery.of(context).size.width;
    double ht = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          mediaCaptured()
              ? showCapturedMedia()
              : CameraPreview(cameraController),
          Positioned(
            top: ht / 3,
            left: 4,
            child: Column(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.sync,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.speed,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.timer_outlined,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.join_inner_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            width: wt,
            bottom: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    if (!cameraController.value.isTakingPicture &&
                        !cameraController.value.isRecordingVideo) {
                      pickImageFromMedia();
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
                  ),
                ),
                Column(
                  children: [
                    videoTimer != 30
                        ? Text(
                            videoTimer.toString(),
                            style: TextStyle(color: Colors.orange),
                          )
                        : SizedBox.shrink(),
                    SizedBox(height: 4),
                    GestureDetector(
                      onLongPressDown: mediaCaptured()
                          ? null
                          : (longPressDownDetails) async {
                              takePictureOrVideo(mediaType: MediaType.video);
                            },
                      onLongPressUp: mediaCaptured()
                          ? null
                          : () {
                              timer?.cancel();
                              videoTimer = 30;
                              stopVideoRecording();
                            },
                      onTap: () {
                        debugPrint('IMAGE PATH XFILE ::');
                      },
                      // mediaCaptured() ? null : onTakePictureButtonPressed,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.camera,
                          color: Colors.orange,
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
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          fontSize: 10),
                    ),
                    onPressed: mediaCaptured()
                        ? () {
                            NavigationUtil.push(
                              context,
                              screen: PreviewMomentScreen(
                                  filePath:
                                      getMediaPathToSendToPreviewScreen()),
                            );
                          }
                        : null,
                    label: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(
                            color: Colors.white,
                          )),
                      primary: Colors.transparent,
                      fixedSize: const Size(208, 43),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onTakePictureButtonPressed() {
    debugPrint('IMAGE PATH XFILE ::');

    takePictureOrVideo(mediaType: MediaType.picture).then((file) async {
      if (file != null) {
        debugPrint('IMAGE PATH XFILE ->');

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
        final XFile file = await cameraController.takePicture();
        debugPrint('IMAGE PATH XFILE :: $file');

        return file;
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

        return null;
      }
    } on CameraException catch (e) {
      showToast(message: 'Error: ${e.code}\n${e.description}');
      return null;
    }
  }

  setUpVideoPlayer() async {
    videoPlayerController = VideoPlayerController.file(File(videoPath!))
      ..initialize().then((_) => videoPlayerController!.play())
      ..setLooping(true);
  }

  Widget showCapturedMedia() {
    if (videoPath != null) {
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
              fit: BoxFit.cover,
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

  pickImageFromMedia() async {
    final file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (file != null) {
      String? croppedImagePath = await ImageCrop().cropImage(file.path);
      if (croppedImagePath != null) {
        imagePath = croppedImagePath;
        if (mounted) setState(() {});
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
}
