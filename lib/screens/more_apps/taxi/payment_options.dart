import 'package:Slydo/screens/more_apps/taxi/map_ui.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:flutter/material.dart';

class PaymentOptions extends StatefulWidget {
  const PaymentOptions({super.key});

  @override
  State<PaymentOptions> createState() => _PaymentOptionsState();
}

class _PaymentOptionsState extends State<PaymentOptions> {
  bool isSearchingForDriver = false;

  bool isPaymentLoading = false;
  bool isPaymentRetry = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: lightGrey,
        appBar: appBar() as PreferredSizeWidget?,
        body: Stack(
          children: [
            // Image.asset(
            //   "assets/images/map.png",
            //   height: double.infinity,
            //   width: double.infinity,
            //   fit: BoxFit.fill,
            // ),

            const MapUI(),

            // FlutterMap(
            //   mapController: mapController,
            //   options: MapOptions(
            //       center: mapPoint, zoom: 18.0, minZoom: 5, maxZoom: 18),
            //   layers: [
            //     TileLayerOptions(
            //       urlTemplate:
            //           "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            //       subdomains: ['a', 'b', 'c'],
            //       overrideTilesWhenUrlChanges: true,
            //     ),
            //     MarkerLayerOptions(
            //       markers: [
            //         Marker(
            //           point: mapPoint,
            //           builder: (ctx) => Container(
            //             child: Icon(
            //               SlydoAppIcon.location,
            //               color: blackFont,
            //               size: 28,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            driverDetailUI()
          ],
        ),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        "Payment options",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget driverDetailUI() {
    return Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: Card(
          elevation: 4,
          shadowColor: dividerColor,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  if (isPaymentLoading)
                    Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: CircularLoadingIndicator(),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "Retrying payment.\n It may take a few seconds...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: blackFont,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        getDriverInfo(),
                        const SizedBox(
                          height: 20,
                        ),
                        getPayButton(),
                      ],
                    ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget getPayButton() {
    return CurvedButton(
        text: isPaymentRetry ? "Retry payment" : "Pay",
        textColor: Colors.white,
        onPressed: () {
          if (isPaymentRetry) {
            //
          } else {
            isPaymentLoading = true;
            if (mounted) setState(() {});
            Future.delayed(const Duration(seconds: 3)).then((value) {
              isPaymentLoading = false;
              isPaymentRetry = true;
              if (mounted) setState(() {});
            });
          }
        },
        borderRadius: 10,
        backgroundColor: navyBlue);
  }

  Widget getDriverInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isPaymentRetry
                ? "Sorry, you have an unpaid order. Order amount:"
                : "Your fare is",
            style: TextStyle(
                color: blackFont, fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "₦",
                style: TextStyle(
                    color: blackFont,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    fontFamily: "Inter"),
              ),
              Text(
                "1000",
                style: TextStyle(
                    color: blackFont,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
