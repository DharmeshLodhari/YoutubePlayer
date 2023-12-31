import 'dart:io';

import 'package:Slydo/screens/more_apps/rider_delivery/comman/colors.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/delivery_complated_screen.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.picture}) : super(key: key);

  final XFile? picture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircleAvatar(
            radius: 140,
            backgroundColor: Colors.white,
            backgroundImage: FileImage(
              File(picture!.path),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          // Text(picture!.name),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: CurvedButton(
                      backgroundColor: AppColor().ButtonBlueColor,
                      text: 'Retake',
                      onPressed: () async {
                        // await availableCameras().then((value) => Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => TakePicture(cameras: value))));
                      },
                      textColor: Colors.white),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: CurvedButton(
                      backgroundColor: AppColor().ButtonBlueColor,
                      text: 'Use Photo',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeliveryCompletedScreen(),
                            ));
                      },
                      textColor: Colors.white),
                ),
              ),
// Spacer(),
            ],
          )
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 50.0),
          //   child: CustomElevatedButton(
          //     backgroundColor: AppColor().ButtonBlueColor,
          //     Textcolor: AppColor().White,
          //     title: "Order Done",
          //     onPressed: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => DeliveryCompletedScreen(),
          //           ));
          //     },
          //   ),
          // ),
        ]),
      ),
    );
  }
}
