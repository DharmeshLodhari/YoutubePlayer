import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CancelBooking extends StatefulWidget {
  const CancelBooking({super.key});

  @override
  State<CancelBooking> createState() => _CancelBookingState();
}

class _CancelBookingState extends State<CancelBooking> {
  @override
  void initState() {
    super.initState();
  }

  List<String> reasons = [
    "I don’t want to share",
    "Can't contact the driver",
    "Driver is late",
    "The price is not reasonable",
    "Pickup address is incorrect",
    "Driver asked me to cancel",
    "Driver didn't match description",
    "Long pickup time",
    "Car didn't match description",
    "Wrong pickup location",
  ];

  String selectedReason = "I don’t want to share";

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
        body: scaffoldBody(),
      ),
    );
  }

  Widget appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left_sharp,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        "",
        style: TextStyle(
            color: blackFont, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget scaffoldBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            "Please select the reason for cancellation:",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(
            height: 40,
          ),
          Expanded(child: getReason()),
          getDriverActions(),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget getReason() {
    return SingleChildScrollView(
      child: Column(
        children: reasons.map((e) => getReasoneTile(reason: e)).toList(),
      ),
    );
  }

  Widget getReasoneTile({required String reason}) {
    final bool isSelected = reason == selectedReason;
    return GestureDetector(
      onTap: () {
        selectedReason = reason;
        if (mounted) setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_off_rounded,
              color: isSelected ? navyBlue : dividerColor,
              size: 26,
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Text(
                reason,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getTipUI() {
    final UserBloc userBloc = Provider.of<UserBloc>(context, listen: false);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: CachedNetworkImage(
            imageUrl: userBloc.user.avatar!,
            height: 80,
            width: 80,
            fit: BoxFit.fill,
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Text(
          "Add a tip?",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w700, color: blackFont),
        ),
        const SizedBox(
          height: 30,
        ),
        const SizedBox(
          height: 30,
        ),
        Text(
          "Tipping is welcome, but not required.\nThe amount is always up to you.",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w400, color: darkGrey),
        ),
      ],
    );
  }

  Widget getDriverInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        "Your trip has ended",
        style: TextStyle(
            color: blackFont, fontSize: 22, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget getDriverActions() {
    return CurvedButton(
      borderRadius: 10,
      backgroundColor: navyBlue,
      onPressed: () {
        Navigator.of(context).pushNamed("/payment-options");
      },
      textColor: Colors.white,
      text: "Submit",
    );
  }

  Widget getRideInfo() {
    return Card(
      elevation: 3,
      borderOnForeground: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      shadowColor: dividerColor.withAlpha(125),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  "11:24",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: blackFont),
                ),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  "11:38",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: blackFont),
                ),
              ],
            ),
            const SizedBox(
              width: 12,
            ),
            Image.asset(
              "assets/images/taxi/route.png",
              height: 80,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "1 Bola Dada Avenue, Victoria Island, Lagos",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: blackFont),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Tafawa Balewa Square, Lagos Island, Lagos",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: blackFont),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
