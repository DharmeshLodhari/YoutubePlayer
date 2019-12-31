import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';



class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: SpinKitChasingDots(
        color: Colors.white,
        size: 100.0,
        duration: Duration(milliseconds: 4000),

      ),
    );
  }
}






