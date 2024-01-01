import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shipping_process_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/models/package_details_model.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfirmOrder extends StatefulWidget {
  const ConfirmOrder({Key? key}) : super(key: key);

  @override
  State<ConfirmOrder> createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  ScrollController _confirmOrderScrollController = new ScrollController();

  late BasketBloc basketBloc;
  bool isLoading = false;
  bool isSelected = false;

  late ShippingProcessBloc shippingProcessBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      shippingProcessBloc = Provider.of<ShippingProcessBloc>(context);
      getAllPackageDetail();
    });
  }

  Future<void> getAllPackageDetail() async {
    if (!isLoading) {
      isLoading = true;
      if (mounted) setState(() {});

      await ShippingProcessAuthService().getAllPackageDetail().then(
        (value) {
          shippingProcessBloc.packagesList = value;
          isLoading = false;
          if (mounted) setState(() {});
        },
      ).catchError((error) {
        isLoading = false;
        if (mounted) setState(() {});
        showToast(message: error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
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
          appBar: _buildAppBar() as PreferredSizeWidget?,
          body: _buildBody(),
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
      title: Text(
        'Confirm Order',
        style: TextStyle(
          fontSize: 20,
          fontFamily: "Inter",
          fontWeight: FontWeight.w700,
          color: yarnBlack,
          height: 1.3,
        ),
      ),
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

  Widget _buildBody() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _confirmOrderScrollController,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    ListView.builder(
                      itemCount: shippingProcessBloc.packagesList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return _buildPackageDetailTile(index);
                      },
                    ),
                    Visibility(visible: false, child: _buildOrderSummary()),
                  ],
                ),
              ),
            ),
          ),
          _buildPayButton(),
        ],
      ),
    );
  }

  Widget _buildPackageDetailTile(int index) {
    return Container(
      margin: EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected == true ? navyBlue : white,
          width: 1,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(Routes.DELIVERY_OPTION, arguments: {
            'merchantName': shippingProcessBloc.packagesList[index].merchant,
          });
        },
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              ListTile(
                leading: _buildImage(),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      shippingProcessBloc.packagesList[index].merchant ?? "",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: black,
                        fontFamily: "Inter",
                      ),
                    ),
                    Text(
                      "₦${shippingProcessBloc.packagesList[index].totalPrice}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: black,
                        fontFamily: "Inter",
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  "Package 1 (${shippingProcessBloc.packagesList[index].totalItems} item)",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: black,
                    fontFamily: "Inter",
                  ),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              // _buildShippingData(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select delivery option",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: navyBlue,
                      fontFamily: "Inter",
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right_outlined,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Image.asset(
      "assets/images/package.png",
      fit: BoxFit.fill,
    );
  }

  Widget _buildShippingData() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Shipping: ",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                  Text(
                    "₦2,000.00",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 3,
              ),
              Text(
                "Estimated delivery time 2-5 days",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: darkGrey,
                  fontFamily: "Inter",
                ),
              ),
              //
            ],
          ),
        ),
        Icon(
          Icons.keyboard_arrow_right_outlined,
        )
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 20,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: selectedListItemBackgroundBlue),
          borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      shadowColor: boxShadowTwo,
      color: white,
      child: Container(
        decoration: decorateBox(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order Summary",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: black,
                  fontFamily: "Inter",
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              _buildTotalItemCost(),
              SizedBox(
                height: 10,
              ),
              _buildTotalShipping(),
              SizedBox(
                height: 10,
              ),
              _buildInsurance(),
              SizedBox(
                height: 10,
              ),
              _buildOrderTotal(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CurvedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.SEND_CART_PAYMENT);
        },
        backgroundColor: navyBlue,
        textColor: white,
        text: 'Pay 98,500.00',
      ),
    );
  }

  Widget _buildTotalItemCost() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Total item costs :",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: darkGrey,
            fontFamily: "Inter",
          ),
        ),
        Text(
          "#285,700.00",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget _buildTotalShipping() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Total Shipping :",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: darkGrey,
            fontFamily: "Inter",
          ),
        ),
        Text(
          "#8,000.00",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget _buildInsurance() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Insurance",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: darkGrey,
            fontFamily: "Inter",
          ),
        ),
        Text(
          "#500.00",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: darkGrey,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Order Total",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: black,
            fontFamily: "Inter",
          ),
        ),
        Text(
          "#285,700.00",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: black,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }
}
