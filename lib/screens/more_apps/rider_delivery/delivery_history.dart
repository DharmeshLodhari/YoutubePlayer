import 'package:Slydo/screens/more_apps/rider_delivery/comman/address_widget.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/comman/colors.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/comman/string.dart';
import 'package:Slydo/screens/more_apps/rider_delivery/comman/style.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeliveryHistory extends StatefulWidget {
  @override
  State<DeliveryHistory> createState() => _DeliveryHistoryState();
}

class _DeliveryHistoryState extends State<DeliveryHistory> {
  String? todayDate;
  String? Amount = "3000";
  int? km = 2;
  void myDate() {
    var now = DateTime.now();
    var formatter = DateFormat('d MMMM,y');
    String formattedDate = formatter.format(now);
    todayDate = formattedDate;
  }

  @override
  void initState() {
    myDate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Delivery History",
          style: appbarHeadline,
        ),
        leading: _buildIcon(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(14.0),
          child: Column(children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.26,
                        decoration: BoxDecoration(
                          border:
                              Border.all(width: 1, color: Colors.grey.shade500),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDateAndWaitingButton(),
                              _buildLogoAndDeliveryAndAmount(),
                              _buildItemsAndKg(),
                              AddressPickupAndDelivery(
                                  TextColor: Colors.grey.shade600,
                                  PickupAddressText: PickupAddress,
                                  DeliveryByAddressText: DeliveryByAddress),
                              // _buildButtonCancleAndPickup(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                );
              },
            ),
            SizedBox(height: 50),
          ]),
        ),
      ),
    );
  }

  Widget _buildItemsAndKg() {
    return Text(
      "8 Items (34kg)",
      style: TextStyleMedium,
    );
  }

  Widget _buildDate() {
    return Text(
      todayDate.toString(),
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          fontSize: 17),
    );
  }

  _buildStatusButton() {
    return CurvedButton(
      text: Cancelled,
      textColor: AppColor().DarkRedButtonColor,
      backgroundColor: AppColor().LightRedButtonColor,
      onPressed: () {},
    );
  }

  Widget _buildButtonCancleAndPickup() {
    return Row(
      children: [
        Expanded(
            child: CurvedButton(
          text: Cancle,
          textColor: AppColor().Black,
          backgroundColor: AppColor().ButtonGreyColor,
          onPressed: () {},
        )),
        SizedBox(width: 10),
        Expanded(
            child: CurvedButton(
          text: Pickup,
          backgroundColor: AppColor().ButtonBlueColor,
          onPressed: () {},
        ))
      ],
    );
  }

  Widget _buildIcon() {
    return Icon(
      Icons.arrow_back_ios,
      size: 20,
      color: Colors.black,
    );
  }

  Widget _buildLogoAndDeliveryAndAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildLogo(),
            _buildVerticalDivider(),
            _buildDelivery(),
          ],
        ),
        Row(
          children: [
            _buildAmount(),
          ],
        )
      ],
    );
  }

  Widget _buildDateAndWaitingButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDate(),
        _buildStatusButton(),
      ],
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      "assets/images/rider/kfc.png",
      height: 45,
      width: 35,
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 70,
      child: VerticalDivider(
        color: Colors.grey.shade400,
        thickness: 1.5,
        indent: 14,
        endIndent: 15,
        width: 20,
      ),
    );
  }

  Widget _buildDelivery() {
    return Text(
      Delivery,
      style: TextStyle(
          color: AppColor().Black, fontSize: 18, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildEst() {
    return Text(
      "Est ",
      style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 17,
          fontWeight: FontWeight.w500),
    );
  }

  Widget _buildAmount() {
    return Text(
      "₦${Amount}",
      style: TextStyle(
          color: AppColor().Black, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}
