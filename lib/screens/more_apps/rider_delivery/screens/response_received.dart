import 'dart:io';

import 'package:Slydo/data/state_notifiers/shared_cart_bloc.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class ResponseReceived extends StatefulWidget {
  const ResponseReceived({super.key});

  @override
  State<ResponseReceived> createState() => _ResponseReceivedState();
}

class _ResponseReceivedState extends State<ResponseReceived> {
  late SharedCartBloc sharedCartBloc;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      sharedCartBloc.refreshAllCart(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    sharedCartBloc = Provider.of<SharedCartBloc>(context);
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          backgroundColor: lightGrey,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSuccessImage(),
                  _buildText(),
                  const SizedBox(height: 10.0),
                  _buildSubText(),
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
      'assets/lottie/completed.json',
      height: 250,
      width: 250,
    );
  }

  Widget _buildText() {
    return Text(
      "Response Received",
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: blackFont,
        fontFamily: "Inter",
      ),
    );
  }

  Widget _buildSubText() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        "Thank you for taking out your time to fill this. We will look into this to improve our system to serve you better.",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: blackFont,
          fontFamily: "Inter",
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildViewOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: CurvedButton(
        onPressed: () {
          Navigator.of(context).popUntil(ModalRoute.withName(Routes.DASHBOARD));
        },
        backgroundColor: navyBlue,
        textColor: white,
        fontSize: 15,
        text: 'Done',
      ),
    );
  }
}
