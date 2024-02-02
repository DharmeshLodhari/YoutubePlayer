import 'dart:io';

import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/screens/more_apps/user_profile/forms/add_edit_shipping_address.dart';
import 'package:Slydo/screens/more_apps/user_profile/models/user.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';

class SharedCartConfirmOrder extends StatefulWidget {
  const SharedCartConfirmOrder({super.key});

  @override
  State<SharedCartConfirmOrder> createState() => _SharedCartConfirmOrderState();
}

class _SharedCartConfirmOrderState extends State<SharedCartConfirmOrder> {
  ShippingAddress? defaultAddress;
  bool isAddressEmpty = false;
  ScrollController _confirmOrderScrollController = new ScrollController();

  @override
  void initState() {
    getAddressList();
    super.initState();
  }

  void getAddressList() async {
    if (mounted) setState(() {});

    Map<String, dynamic>? result =
        await ShoppingAuthService().listOfDispatchAddress("", null);

    if (result == null) {
      if (mounted) {
        setState(() {});
      }
      return;
    }

    List<ShippingAddress> tempList = result['results'];

    if (mounted) {
      setState(() {
        isAddressEmpty = tempList.isEmpty;
        defaultAddress = tempList.firstWhere((element) => element.is_default!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop();
          return false;
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
          Navigator.of(context).pop();
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
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDeliveryAddress(),
                    SizedBox(height: 15.0),
                    _buildOrderSummary(),
                    SizedBox(height: 15.0),
                    _buildFinalOrderList(),
                  ],
                ),
              ),
            ),
          ),
          _buildConfirmOrderButton(),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Shipping Address",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: black,
                      fontFamily: "Inter",
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        if (!isAddressEmpty) {
                          Navigator.of(context)
                              .pushNamed(Routes.DISPATCH_ADDRESS, arguments: {
                            "isForSelection": true,
                            "shippingAddress": defaultAddress,
                            "onShippingAddressChange": (address) {
                              defaultAddress = address;
                              setState(() {});
                            }
                          });
                        } else {
                          NavigationUtil.push(
                            context,
                            screen: AddEditShippingAddress(),
                          ).whenComplete(() => getAddressList());
                        }
                        setState(() {});
                      },
                      child: Icon(Icons.edit))
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                defaultAddress?.toFullAddress() ?? "",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: darkGrey,
                  fontFamily: "Inter",
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Postal code : ${defaultAddress?.zip}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: darkGrey,
                  fontFamily: "Inter",
                ),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildFinalOrderList() {
    return Column(
      children: [
        Text(
          "Order",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: blackFont,
            fontFamily: "Inter",
          ),
        ),
        // ListView.builder(
        //     itemCount: basketBloc.items.length,
        //     itemBuilder: (BuildContext context, int index) => getItemTile(index))
      ],
    );
  }

  Widget _buildConfirmOrderButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CurvedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.SEND_CART_PAYMENT);
          // BottomSheetPassCode(
          //     context: context,
          //     isValidCallback: () async {
          //       // await checkAccountBalance();
          //
          //       // Create the orders
          //       await placeOrder();
          //     },
          //     cancelCallBack: () {
          //       Navigator.pop(context);
          //     });
        },
        backgroundColor: navyBlue,
        textColor: white,
        text: 'Confirm Order',
        // isLoading: isOrderLoading,
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
          // "₦${moneyDisplayNormalizer(shippingProcessBloc.getTotalItemCost())}",
          "₦0.00",
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
          // "₦${moneyDisplayNormalizer(shippingProcessBloc.getTotalShipping())}",
          "₦0.00",
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
          "₦0.00",
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
          // "₦${moneyDisplayNormalizer(getTotalOrder())}",
          "₦0.00",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: black,
            fontFamily: "Inter",
          ),
        ),
      ],
    );
  }

  // int? getTotalOrder() {
  //   int? totalItemCost = shippingProcessBloc.getTotalItemCost();
  //   int? totalShipping = shippingProcessBloc.getTotalShipping();
  //   return (totalItemCost ?? 0) + (totalShipping ?? 0);
  // }
}
