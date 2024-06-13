import 'dart:async';
import 'dart:io';

import 'package:Slydo/main.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/util.dart';
import 'package:camera/camera.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TakeDeliveryProof extends StatefulWidget {
  const TakeDeliveryProof({super.key});

  @override
  State<TakeDeliveryProof> createState() => _TakeDeliveryProofState();
}

class _TakeDeliveryProofState extends State<TakeDeliveryProof> {
  CameraController? _cameraController;
  bool _isRearCameraSelected = true;

  Timer? timer;
  String? videoPath;
  int videoTimer = 4;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (cameras.isNotEmpty) {
        // checkCameraAvailable();
        _initCameraController(newCameraDescription: cameras[0]);
      } else {
        showToast(message: "You don't have any Camera !!");
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> checkCameraAvailable() async {
    await availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.isNotEmpty) {
        initCamera(cameras[0]);
      } else {
        debugPrint("No camera available");
      }
    }).catchError((err) {
      // 3
      debugPrint('Error: $err.code\nError Message: $err.message');
    });
  }

  void _initCameraController(
      {required CameraDescription newCameraDescription}) {
    _cameraController =
        CameraController(newCameraDescription, ResolutionPreset.max);
    _cameraController?.initialize().then((_) {
      _cameraController?.setFlashMode(FlashMode.off);

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
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: Colors.white,
      child: PopScope(
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
        },
        child: Scaffold(
          appBar: _buildAppbar() as PreferredSizeWidget?,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildAppbar() {
    return AppBar(
      leading: _buildIcon(),
      automaticallyImplyLeading: true,
      backgroundColor: Colors.black,
      actions: [
        IconButton(
          padding: EdgeInsets.zero,
          iconSize: 30,
          icon: SvgPicture.asset(
            'assets/images/rider/flip_camera.svg',
            fit: BoxFit.cover,
          ),
          onPressed: () async {
            setState(() => _isRearCameraSelected = !_isRearCameraSelected);
            await availableCameras().then((availableCameras) {
              cameras = availableCameras;
              if (cameras.isNotEmpty) {
                initCamera(cameras[_isRearCameraSelected ? 0 : 1]);
              } else {
                debugPrint("No camera available");
              }
            }).catchError((err) {
              // 3
              debugPrint('Error: $err.code\nError Message: $err.message');
            });
          },
        ),
      ],
    );
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController?.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  Widget _buildIcon() {
    return IconButton(
      onPressed: () {
        Navigator.pop(context, "back pressed");
      },
      icon: const Icon(
        Icons.keyboard_arrow_left,
        size: 20,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Stack(
        children: [
          if (_cameraController?.value.isInitialized ?? false)
            CameraPreview(_cameraController!)
          else
            Container(
                color: Colors.black,
                child: const Center(child: CircularProgressIndicator())),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 125,
              decoration: const BoxDecoration(color: Colors.black),
              child: Center(
                child: Column(
                  children: [
                    // ignore: prefer_if_elements_to_conditional_expressions
                    videoTimer != 4
                        ? Text(
                            videoTimer.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: takePhoto,
                      onLongPressStart: mediaCaptured()
                          ? null
                          : (longPressDownDetails) async {
                              debugPrint("Details :- $longPressDownDetails");
                              takePictureOrVideo(mediaType: MediaType.video);
                            },
                      onLongPressUp: mediaCaptured()
                          ? null
                          : () {
                              timer?.cancel();
                              videoTimer = 4;
                              if (_cameraController?.value.isRecordingVideo ??
                                  false) {
                                stopVideoRecording();
                              }
                            },
                      child: SvgPicture.asset(
                        'assets/images/rider/camera_btn.svg',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future takePhoto() async {
    if (_cameraController?.value.isInitialized == false) {
      return null;
    }
    if (_cameraController?.value.isTakingPicture ?? false) {
      return null;
    }
    try {
      await _cameraController?.setFlashMode(FlashMode.off);
      XFile? picture = await _cameraController?.takePicture();
      Navigator.of(context).popAndPushNamed(
          Routes.PREVIEW_DELIVERY_PROOF_SCREEN,
          arguments: {"filePath": picture?.path});
    } on CameraException catch (e) {
      debugPrint('Error occurred while taking picture: $e');
      return null;
    }
  }

  Future<XFile?> takePictureOrVideo({required MediaType mediaType}) async {
    if (!(_cameraController?.value.isInitialized ?? false)) {
      showToast(message: 'Error: select a camera first.');
      return null;
    }

    if (_cameraController?.value.isRecordingVideo ?? false) {
      return null;
    }

    try {
      _cameraController?.startVideoRecording();
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            videoTimer--;
          });

          if (videoTimer == 0) {
            timer.cancel();
            videoTimer = 4;
            stopVideoRecording();
          }
        }
      });

      return null;
    } on CameraException catch (e) {
      showToast(message: 'Error: ${e.code}\n${e.description}');
      return null;
    }
  }

  bool mediaCaptured() {
    return videoPath != null;
  }

  void stopVideoRecording() {
    _cameraController?.stopVideoRecording().then((xfile) {
      if (mounted) {
        setState(() {
          videoPath = xfile.path;
          Navigator.of(context).popAndPushNamed(
              Routes.PREVIEW_DELIVERY_PROOF_SCREEN,
              arguments: {"filePath": videoPath ?? ""});
        });
      }
    });
  }
}
