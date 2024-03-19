import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';

class YourTripEndScreen extends StatefulWidget {
  const YourTripEndScreen({super.key});

  @override
  State<YourTripEndScreen> createState() => _YourTripEndScreenState();
}

class _YourTripEndScreenState extends State<YourTripEndScreen> {
  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      child: Scaffold(
        backgroundColor: white,
        appBar: _buildAppBar() as PreferredSizeWidget?,
        body: Column(
          children: [
            _buildYourTripEndImageAndText(),
            SizedBox(height: 40),
            _buildOkButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16,
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
      elevation: 0,
    );
  }

  Widget _buildYourTripEndImageAndText() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Image.asset(
            "assets/images/white_background.png",
          ),
        ),
        Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60,
                  height: 60,
                  color: naturalGreen,
                  child: Image.asset(
                    "assets/images/check_icon.png",
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
            SizedBox(height: 36),
            Text(
              "Your trip has ended",
              style: TextStyle(
                color: black,
                fontWeight: FontWeight.w700,
                fontFamily: "Inter",
                fontSize: 24,
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
              margin: EdgeInsets.only(left: 50, right: 50, top: 20),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "11:24",
                          style: TextStyle(
                            color: black,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Inter",
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 25),
                        Text(
                          "11:38",
                          style: TextStyle(
                            color: black,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Inter",
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Image.asset(
                        "assets/images/ic_route_icon.png",
                        width: 16,
                        height: 65,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "24 Bashir Musa Road, Agege",
                          style: TextStyle(
                            color: black,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Inter",
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 25),
                        Text(
                          "20, Pedro Street, Alausa, Ikeja",
                          style: TextStyle(
                            color: black,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Inter",
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOkButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 25, left: 25),
      child: CurvedButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.RATE_AND_TIP_DRIVER);
        },
        textColor: Colors.white,
        backgroundColor: navyBlue,
        text: "Ok",
      ),
    );
  }
}
