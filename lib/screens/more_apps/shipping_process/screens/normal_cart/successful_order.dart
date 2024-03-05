import 'dart:io';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessfulOrder extends StatefulWidget {
  const SuccessfulOrder({Key? key}) : super(key: key);

  @override
  State<SuccessfulOrder> createState() => _SuccessfulOrderState();
}

class _SuccessfulOrderState extends State<SuccessfulOrder> {
  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          backgroundColor: white,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSuccessImage(),
                  SizedBox(height: 16.0),
                  _buildText(),
                ],
              ),
            ),
            _buildViewOrderButton(),
          ],
        ),
      ),
    );
  }

  // Widget _buildSuccessImage() {
  //   return Image.network(
  //     "https://s3-alpha-sig.figma.com/img/1869/38bf/4d2470e3628037c3f7d1f3b05b8cc8e4?Expires=1704672000&Signature=R88Rds6T09Tu2OGNCC2fnpXMDsyqdrA2-aqFe4VOVrkcSfGh-K-Gl-tVFV~OKH7EMV21yaCsOmC0lFpRFHY69xFDflfaanXlVYtE8NTbgWy3zECWp8yW7OvL-1TjOuwNPo3hmkDW83es7yzQ14oBIE6Y7KfApD8mxGlrvbRLRgo9pegrO2808BRwLNa83~IdISFTDz2P0FNbfmXNL7Y9JoKnKiiYqgLQkU3BsipavWHNxtFwqgOMEO2SAcba9aUKFzeJ6Gpyo3vPaiD9j~pA-iy5TMC756DzmLV9X9cuKXjciM00RNDHuwBWhek0p6HOZQbQCrvtO9UGtJ50t-YRAg__&Key-Pair-Id=APKAQ4GOSFWCVNEHN3O4",
  //     height: 150,
  //     width: 270,
  //     fit: BoxFit.fill,
  //     filterQuality: FilterQuality.high,
  //     cacheHeight: 150,
  //     cacheWidth: 270,
  //     frameBuilder: imageFrameBuilder,
  //     errorBuilder: (context, error, stackTrace) {
  //       return Image.network(
  //         defaultImage,
  //         colorBlendMode: BlendMode.darken,
  //         fit: BoxFit.fill,
  //         filterQuality: FilterQuality.high,
  //       );
  //     },
  //   );
  // }

  Widget _buildSuccessImage() {
    return Lottie.asset(
      'assets/lottie/successful.json',
    );
  }

  Widget _buildText() {
    return Text(
      "Order Placed Successfully",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: black,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildViewOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CurvedButton(
        onPressed: () {
          Navigator.of(context).popAndPushNamed(Routes.ORDERS_LIST);
        },
        backgroundColor: navyBlue,
        textColor: white,
        text: 'Track Order',
      ),
    );
  }
}
