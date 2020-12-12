// Future<String> captureVideo(BuildContext context, Duration duration) async {
//   String result = await showDialog<String>(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Container(
//             child: MaterialButton(
//               onPressed: () {
//                 Navigator.pop(context, "ok");
//               },
//               child: Text("ok"),
//             ),
//           ));
//
//   return Future.value(result);
// }
import 'dart:async';
import 'dart:io';

import 'package:Slydo/utils/util.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class VideoRecorder extends StatefulWidget {
  var arguments;

  VideoRecorder({this.arguments});

  @override
  _VideoRecorderState createState() {
    return _VideoRecorderState();
  }
}

class _VideoRecorderState extends State<VideoRecorder> {
  CameraController controller;
  String videoPath;

  List<CameraDescription> cameras;
  int selectedCameraIdx;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Timer timer;

  Duration videoDuration;

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

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
        });

        _onCameraSwitched(cameras[selectedCameraIdx]).then((void v) {});
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
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
    return Scaffold(
      key: _scaffoldKey,
      // appBar: appBar(),
      body: Stack(
        children: <Widget>[
          Container(
            child: Center(
              child: _cameraPreviewWidget(),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: controller != null && controller.value.isRecordingVideo
                    ? mateRed
                    : dividerColor,
                width: 1.0,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16),
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
          ),
        ],
      ),
    );
  }

  Widget _closeBtnWidget() {
    return Expanded(
        child: Align(
      alignment: Alignment.center,
      child: FlatButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(
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
    if (controller == null || !controller.value.isInitialized) {
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
      scale: controller.value.aspectRatio / deviceRatio,
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    if (cameras == null) {
      return Row();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
        child: Align(
      alignment: Alignment.center,
      child: FlatButton(
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
              onTap: controller != null && controller.value.isInitialized
                  ? !controller.value.isRecordingVideo
                      ? _onRecordButtonPressed
                      : _onStopButtonPressed
                  : null,
              child: ClipOval(
                child: AnimatedSwitcher(
                  child: recordingButton,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  duration: Duration(microseconds: 500),
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
    if (controller.value.isRecordingVideo) {
      recordingButton = Container(
        height: 58,
        width: 58,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Icon(
          Icons.stop,
          color: Colors.red,
        ),
      );
      setState(() {});
    } else if (!controller.value.isRecordingVideo) {
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
      await controller.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.high,
        enableAudio: true);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
        Toast.show(
            'Camera error ${controller.value.errorDescription}', context);
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];

    _onCameraSwitched(selectedCamera);

    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
  }

  void _onRecordButtonPressed() {
    _startVideoRecording().then((String filePath) {
      if (filePath != null) {
        Toast.show('Recording video started', context);
      }
      changeRecordIcon();
      //Timer
      timer = Timer.periodic(videoDuration, (Timer t) {
        _onStopButtonPressed();
        timer.cancel();
      });
    });
  }

  void _onStopButtonPressed() {
    _stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      changeRecordIcon();
      timer.cancel(); //when user close it manually

      Toast.show('Video recorded to $videoPath', context);
      Navigator.pop(context, videoPath);
    });
  }

  Future<String> _startVideoRecording() async {
    if (!controller.value.isInitialized) {
      Toast.show('Please wait', context);
      return null;
    }

    // Do nothing if a recording is on progress
    if (controller.value.isRecordingVideo) {
      return null;
    }

    final Directory tempDirectory = await getTemporaryDirectory();
    // final String videoDirectory = '${tempDirectory.path}/Videos';
    // await Directory("${tempDirectory.path}").create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '${tempDirectory.path}/captured_$currentTime.mp4';

    try {
      await controller.startVideoRecording(filePath);
      videoPath = filePath;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    return filePath;
  }

  Future<void> _stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);
    Toast.show('Error: ${e.code}\n${e.description}', context);
  }
}
