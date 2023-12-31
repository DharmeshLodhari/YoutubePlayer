import 'dart:io';

import 'package:Slydo/screens/more_apps/rider_delivery/preview_screen.dart';
import 'package:camera/camera.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TakePicture extends StatefulWidget {
  const TakePicture({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription>? cameras;

  @override
  State<TakePicture> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.cameras![0]);
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: Colors.white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
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
          onPressed: () {
            setState(() => _isRearCameraSelected = !_isRearCameraSelected);
            initCamera(widget.cameras![_isRearCameraSelected ? 0 : 1]);
          },
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return IconButton(
      onPressed: () {
        Navigator.pop(context, "back pressed");
      },
      icon: Icon(
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
          (_cameraController.value.isInitialized)
              ? CameraPreview(_cameraController)
              : Container(
                  color: Colors.black,
                  child: Center(child: CircularProgressIndicator())),
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
              )),
        ],
      ),
    );
  }

  Future takePhoto() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PreviewPage(
                    picture: picture,
                  )));
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }
}
// Row(
// crossAxisAlignment: CrossAxisAlignment.center,
// children: [
// Expanded(
// child: Padding(
// padding: EdgeInsets.symmetric(horizontal: 16.0),
// child: CustomElevatedButton(
// backgroundColor: Colors.white,
// title: 'Retake',
// onPressed: takePicture,
// Textcolor: AppColor().ButtonBlueColor),
// ),
// ),
// Expanded(
// child: Padding(
// padding: EdgeInsets.symmetric(horizontal: 16.0),
// child: CustomElevatedButton(
// backgroundColor: AppColor().ButtonBlueColor,
// title: 'Use Photo',
// onPressed: () {},
// Textcolor: Colors.white),
// ),
// ),
// // Spacer(),
// ],
// )
