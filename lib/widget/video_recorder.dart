import 'dart:async';
import 'dart:io';

import 'package:Slydo/services/timer_service.dart';
import 'package:Slydo/utils/util.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class VideoRecorder extends StatefulWidget {
  final dynamic arguments;

  const VideoRecorder({super.key, this.arguments});

  @override
  State<VideoRecorder> createState() {
    return _VideoRecorderState();
  }
}

class _VideoRecorderState extends State<VideoRecorder> {
  CameraController? controller;
  String? videoPath;

  List<CameraDescription>? cameras;
  int? selectedCameraIdx;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer? timer;

  Duration? videoDuration;

  late TimerService timerService;

  Widget recordingButton = Container(
      height: 58,
      width: 58,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white, width: 1.5),
      ));

  @override
  void initState() {
    super.initState();

    videoDuration = widget.arguments["duration"];

    // Get the listonNewCameraSelected of available cameras.
    // Then set the first camera as selected.
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras!.isNotEmpty) {
        setState(() {
          selectedCameraIdx = 0;
        });

        _onCameraSwitched(cameras![selectedCameraIdx!]).then((void v) {});
      }
    }).catchError((err) {
      debugPrint('Error: $err.code\nError Message: $err.message');
    });
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(
          Icons.keyboard_arrow_left,
          color: Colors.white,
          size: 28,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    timerService = Provider.of<TimerService>(context);
    return WillPopScope(
      onWillPop: () async {
        timerService.stop();
        timerService.reset();

        return Future.value(true);
      },
      child: Scaffold(
        key: _scaffoldKey,
        // appBar: appBar(),
        body: OrientationBuilder(builder: (context, orientation) {
          debugPrint("=> ${orientation.index}");
          if (orientation == Orientation.portrait) {
            return Stack(
              children: <Widget>[
                Center(
                  child: _cameraPreviewWidget(),
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: controller != null &&
                              controller!.value.isRecordingVideo
                          ? mateRed
                          : dividerColor,
                      width: 1.0,
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(1.0),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Column(
                    children: [
                      Text(
                        getTimerDuration(timerService.currentDuration),
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black45,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _cameraTogglesRowWidget(),
                            _captureControlRowWidget(),
                            _closeBtnWidget(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return Stack(
            children: <Widget>[
              Center(
                child: _cameraPreviewWidget(),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color:
                        controller != null && controller!.value.isRecordingVideo
                            ? mateRed
                            : dividerColor,
                    width: 1.0,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(1.0),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Column(
                  children: [
                    Text(
                      getTimerDuration(timerService.currentDuration),
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          _cameraTogglesRowWidget(),
                          _captureControlRowWidget(),
                          _closeBtnWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String getTimerDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _closeBtnWidget() {
    return Expanded(
        child: Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          timerService.stop();
          timerService.reset();
          Navigator.pop(context);
        },
        child: const Icon(
          Icons.close_rounded,
          color: Colors.white,
        ),
      ),
    ));
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.flip_camera_ios_outlined;
      case CameraLensDirection.front:
        return Icons.flip_camera_ios_outlined;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  // Display 'Loading' text when the camera is still loading.
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller!.value.isInitialized) {
      return const Text(
        'Loading',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w900,
        ),
      );
    }
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return Transform.scale(
      scale: controller!.value.aspectRatio / deviceRatio,
      child: AspectRatio(
        aspectRatio: controller!.value.aspectRatio,
        child: CameraPreview(controller!),
      ),
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    if (cameras == null) {
      return const Row();
    }

    final CameraDescription selectedCamera = cameras![selectedCameraIdx!];
    final CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
        child: Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: _onSwitchCamera,
        child: Icon(
          _getCameraLensIcon(lensDirection),
          color: Colors.white,
        ),
      ),
    ));
  }

  /// Display the control bar with buttons to record videos.
  Widget _captureControlRowWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            InkWell(
              onTap: controller != null && controller!.value.isInitialized
                  ? !controller!.value.isRecordingVideo
                      ? _onRecordButtonPressed
                      : _onStopButtonPressed
                  : null,
              child: ClipOval(
                child: AnimatedSwitcher(
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  duration: const Duration(microseconds: 500),
                  child: recordingButton,
                ),
              ),
            ),
            // IconButton(
            //   icon: const Icon(Icons.stop),
            //   color: mateRed,
            //   onPressed: controller != null &&
            //           controller.value.isInitialized &&
            //           controller.value.isRecordingVideo
            //       ? _onStopButtonPressed
            //       : null,
            // )
          ],
        ),
      ),
    );
  }

  void changeRecordIcon() {
    if (controller!.value.isRecordingVideo) {
      recordingButton = Container(
        height: 58,
        width: 58,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: const Icon(
          Icons.stop,
          color: Colors.red,
        ),
      );
      setState(() {});
    } else if (!controller!.value.isRecordingVideo) {
      recordingButton = Container(
          height: 58,
          width: 58,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white, width: 1.5),
          ));
      setState(() {});
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.high,
        enableAudio: true);

    // If the controller is updated then update the UI.
    controller!.addListener(() {
      debugPrint("===>> ${controller!.value.aspectRatio} ");

      if (mounted) {
        setState(() {});
      }

      if (controller!.value.hasError) {
        showToast(
            message: 'Camera error ${controller!.value.errorDescription}');
      }
    });

    try {
      await controller!.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx! < cameras!.length - 1 ? selectedCameraIdx! + 1 : 0;
    final CameraDescription selectedCamera = cameras![selectedCameraIdx!];

    _onCameraSwitched(selectedCamera);

    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
  }

  void _onRecordButtonPressed() {
    _startVideoRecording().then((String? filePath) {
      if (filePath != null) {
        timerService.start();
        changeRecordIcon();
        showToast(message: 'Recording video started');
      }

      //Timer
      timer = Timer.periodic(videoDuration!, (Timer t) {
        _onStopButtonPressed();
        timerService.stop();
        timerService.reset();

        timer!.cancel();
      });
    });
  }

  void _onStopButtonPressed() {
    _stopVideoRecording().then((_) {
      if (mounted) {
        setState(() {});
        changeRecordIcon();
        timer!.cancel(); //when user close it manually
        timerService.stop();
        timerService.reset();

        showToast(message: 'Video recorded to $videoPath');
        Navigator.pop(context, videoPath);
      }
    });
  }

  Future<String?> _startVideoRecording() async {
    if (!controller!.value.isInitialized) {
      showToast(message: 'Please wait');
      return null;
    }

    // Do nothing if a recording is on progress
    if (controller!.value.isRecordingVideo) {
      return null;
    }

    final Directory tempDirectory = await getTemporaryDirectory();
    // final String videoDirectory = '${tempDirectory.path}/Videos';
    // await Directory("${tempDirectory.path}").create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '${tempDirectory.path}/captured_$currentTime.mp4';

    try {
      await controller!.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  Future<void> _stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      return null;
    }

    try {
      final XFile file = await controller!.stopVideoRecording();
      videoPath = file.path;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    final String errorText =
        'Error: ${e.code}\nError Message: ${e.description}';
    debugPrint(errorText);
    showToast(message: 'Error: ${e.code}\n${e.description}');
  }

  @override
  void dispose() {
    timer?.cancel();
    timerService.stop();
    timerService.reset();

    super.dispose();
  }
}
