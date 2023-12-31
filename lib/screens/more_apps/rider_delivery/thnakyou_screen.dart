import 'package:Slydo/screens/more_apps/rider_delivery/comman/colors.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/comman/style.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/delivery_history.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ThankyouScreen extends StatefulWidget {
  @override
  State<ThankyouScreen> createState() => _ThankyouScreenState();
}

class _ThankyouScreenState extends State<ThankyouScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Lottie.asset(
            'assets/images/thankyou.json',
            repeat: false,
          ),
          Text(
            "Response Received",
            style: TextStyleMedium,
          ),
          SizedBox(height: 20),
          Text(
            "Thank you for taking out your time to fill this. We will look",
            style: TextStyleLow,
          ),
          SizedBox(height: 5),
          Text(
            "into this to improve our system to serve you better.",
            style: TextStyleLow,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          CurvedButton(
            textColor: AppColor().White,
            text: "Done",
            backgroundColor: AppColor().ButtonBlueColor,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveryHistory(),
                  ));
            },
          )
        ]),
      ),
    );
  }
}
