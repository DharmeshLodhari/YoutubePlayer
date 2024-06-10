import 'dart:io';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CompletedUploadPhoto extends StatefulWidget {
  CompletedUploadPhoto({Key? key}) : super(key: key);

  @override
  State<CompletedUploadPhoto> createState() => _CompletedUploadPhotoState();
}

class _CompletedUploadPhotoState extends State<CompletedUploadPhoto>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      if (_controller.isCompleted) {
        Future.delayed(const Duration(seconds: 1)).then((value) {
          if (mounted)
            Navigator.of(context)
                .popUntil(ModalRoute.withName(Routes.REQUIRE_STEPS));
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: PopScope(
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }
        },
        child: Scaffold(
          backgroundColor: lightGrey,
          appBar: _buildAppBar() as PreferredSizeWidget?,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context, "back pressed");
        },
      ),
      // shadowColor: greySecondaryYarn,
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSuccessImage(),
          const SizedBox(height: 10.0),
          _buildText(),
        ],
      ),
    );
  }

  Widget _buildSuccessImage() {
    return Lottie.asset(
      'assets/lottie/completed.json',
      height: 250,
      width: 250,
      controller: _controller,
      onLoaded: (composition) {
        _controller
          ..duration = composition.duration
          ..forward();
      },
    );
  }

  Widget _buildText() {
    return Text(
      "Photo added successfully.",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: blackFont,
        fontFamily: "Inter",
      ),
    );
  }
}
