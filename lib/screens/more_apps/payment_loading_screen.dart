import 'package:Slydo/screens/more_apps/animated_logo.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PaymentLoadingScreen extends StatelessWidget {
  final String text;
  final String imagePath;

  PaymentLoadingScreen({required this.text, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,// Allow back button to pop the screen when not loading
      onPopInvoked: (didPop) async {
        if(didPop) {
          return;
        }
      },
      child: Stack(
        children: <Widget>[
          Opacity(
            opacity: 0.9, // Make the screen transparent
            child: ModalBarrier(dismissible: false, color: navyBlue),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: AnimatedLogo(imagePath: imagePath),
              ),
              const SizedBox(height: 20.0),
              Text(
                text,
                style: TextStyle(
                    color: white,
                    fontSize: 14,
                    decoration: TextDecoration.none),
              ),
              const SizedBox(height: 20.0),
              const SpinKitFadingCube(
                color: Colors.white,
                size: 50.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
