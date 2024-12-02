import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
class PaymentConfirmationScreen extends StatelessWidget {
  const PaymentConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40,),
            Image.asset(
              "assets/images/confirmation.gif",

           //   color: navyBlue,
              colorBlendMode: BlendMode.darken,
             // fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Text(
              'Payment Successful',
              style: TextStyle(
                color: blackFont,
                fontWeight: FontWeight.w600,
                fontFamily: "Inter",
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '₦1,000 has been deducted from your account for this delivery request.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: lightBlackFont,
                fontWeight: FontWeight.w400,
                fontFamily: "Inter",
                fontSize: 12,

              ),
            ),

             const Spacer(),
             CurvedButton(
            onPressed: () {
          Navigator.of(context).pushNamed(Routes.SEARCH_RIDER);
      },
        textColor: Colors.white,
        backgroundColor: navyBlue,
        text: "Proceed",
      ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
