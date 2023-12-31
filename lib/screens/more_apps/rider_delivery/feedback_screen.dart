import 'package:Slydo/screens/more_apps/rider_delivery/comman/colors.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/comman/style.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/thnakyou_screen.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';

class FeedBackScreen extends StatefulWidget {
  @override
  State<FeedBackScreen> createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  TextEditingController feedbackController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 100.0, right: 10, left: 10),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Share your experience",
                  style: TextStyleMedium,
                ),
                SizedBox(height: 20),
                Text(
                  "Let us know about your experience about the route, ",
                  style: TextStyleLow,
                ),
                Text(
                  "product delivered or customer in order to serve you more",
                  style: TextStyleLow,
                ),
                Text(
                  "better. e.g this route has bad road or long traffic, the",
                  style: TextStyleLow,
                ),
                Text(
                  "product is not well packaged etc.",
                  style: TextStyleLow,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: TextFormField(
                    cursorColor: Colors.black,
                    controller: feedbackController,
                    decoration: InputDecoration(
                      hintText: "Type here",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.4),
                          )),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.4),
                          ),
                          borderRadius: BorderRadius.circular(16)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    maxLines: 10,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.24),
                CurvedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThankyouScreen(),
                        ));
                  },
                  backgroundColor: AppColor().ButtonBlueColor,
                  textColor: AppColor().White,
                  text: "Submit",
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
