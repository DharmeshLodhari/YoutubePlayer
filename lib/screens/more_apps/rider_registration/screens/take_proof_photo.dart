import 'dart:async';
import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/main.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/util.dart';
import 'package:camera/camera.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class TakeProofPhoto extends StatefulWidget {
  TakeProofPhoto({Key? key});

  @override
  State<TakeProofPhoto> createState() => _TakeProofPhotoState();
}

class _TakeProofPhotoState extends State<TakeProofPhoto> {
  CameraController? _cameraController;
  bool _isRearCameraSelected = true;
  late RiderRegistrationBloc riderRegistrationBloc;

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
        checkCameraAvailable();
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

  @override
  Widget build(BuildContext context) {
    riderRegistrationBloc = Provider.of<RiderRegistrationBloc>(context);
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
              height: 100,
              decoration: const BoxDecoration(color: Colors.black),
              child: Center(
                child: InkWell(
                  onTap: takePhoto,
                  child: SvgPicture.asset(
                    'assets/images/rider/camera_btn.svg',
                  ),
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
      final XFile? picture = await _cameraController?.takePicture();
      riderRegistrationBloc.tempPicture = picture;
      Navigator.of(context).popAndPushNamed(Routes.PREVIEW_SCREEN);
    } on CameraException catch (e) {
      debugPrint('Error occurred while taking picture: $e');
      return null;
    }
  }
}
