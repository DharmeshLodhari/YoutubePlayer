import 'package:Slydo/screens/more_apps/rider_delivery/comman/address_widget.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/comman/colors.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/comman/string.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/comman/style.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/feedback_screen.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DeliveryCompletedScreen extends StatefulWidget {
  @override
  State<DeliveryCompletedScreen> createState() =>
      _DeliveryCompletedScreenState();
}

class _DeliveryCompletedScreenState extends State<DeliveryCompletedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDeliveryText(),
              _buildImageOrderComplete(),
              _buildRideNumber(),
              SizedBox(height: 18),
              _buildEarningText(),
              _buildEarningAmount(),
              SizedBox(height: 10),
              _buildDivider(),
              SizedBox(height: 10),
              AddressPickupAndDelivery(
                  PickupAddressText: PickupAddress,
                  DeliveryByAddressText: DeliveryByAddress),
              SizedBox(height: 10),
              _buildDivider(),
              SizedBox(height: 10),
              _buildCircleImageAndName(),
              _buildDivider(),
              SizedBox(height: 20),
              _buildDistance(),
              SizedBox(height: 10),
              _buildDuration(),
              SizedBox(height: 10),
              _buildItems(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.06),
              _buildShareYourExperience(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareYourExperience() {
    return CurvedButton(
      backgroundColor: AppColor().ButtonBlueColor,
      textColor: AppColor().White,
      text: "Share your experience",
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FeedBackScreen(),
            ));
      },
    );
  }

  Widget _buildItems() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "8 items",
          style: TextStyle(
              color: AppColor().Black,
              fontSize: 22,
              fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Text(
              "36",
              style: TextStyleMediumBlue,
            ),
            Text(
              "kg",
              style: TextStyleMediumBlueL,
            )
          ],
        ),
      ],
    );
  }

  Widget _buildDuration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Duration",
          style: TextStyle(
              color: AppColor().Black,
              fontSize: 22,
              fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Text(
              "1",
              style: TextStyleMediumBlue,
            ),
            Text(
              "hr",
              style: TextStyleMediumBlueL,
            ),
            Text(
              " 30",
              style: TextStyleMediumBlue,
            ),
            Text(
              "mins",
              style: TextStyleMediumBlueL,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildDistance() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Distance Covered",
          style: TextStyle(
              color: AppColor().Black,
              fontSize: 22,
              fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            Text(
              "23",
              style: TextStyleMediumBlue,
            ),
            Text(
              "km",
              style: TextStyleMediumBlueL,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey,
      thickness: 0.8,
    );
  }

  Widget _buildCircleImageAndName() {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage("assets/images/emoji.jpg"),
          foregroundImage: AssetImage("assets/images/emoji.jpg"),
        ),
        SizedBox(width: 10),
        Text(
          CustomerName,
          style: TextStyleMedium,
        ),
      ],
    );
  }

  Widget _buildEarningAmount() {
    return Text(
      "₦ 3,000.00",
      style: TextStyleHighBlue,
    );
  }

  Widget _buildEarningText() {
    return Text(
      "Your Earning",
      style: TextStyleHigh,
    );
  }

  Widget _buildRideNumber() {
    return Text(
      "Ride #267",
      style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColor().AppBarTextColor),
    );
  }

  Widget _buildImageOrderComplete() {
    return Lottie.asset('assets/images/thankyou.json', height: 150, width: 150);
  }

  Widget _buildDeliveryText() {
    return Text(
      "Delivery Completed!!!",
      style: TextStyleHigh,
    );
  }
}
