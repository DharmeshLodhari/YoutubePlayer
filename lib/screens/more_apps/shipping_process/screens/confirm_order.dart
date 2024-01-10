import 'dart:io';

import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shipping_process_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/tiles/package_detail_tile.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
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
  late UserBloc userBloc;
  bool isLoading = false;
  bool isOrderLoading = false;
  bool isSelected = false;
  List<int?> orders = [];

  late ShippingProcessBloc shippingProcessBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (shippingProcessBloc.isUseCart == true) {
          getAllPackageDetail();
        } else {
          shippingProcessBloc.setPackageDetailForBuyNow();
        }
      },
    );
  }

  Future<void> getAllPackageDetail() async {
    if (!isLoading) {
      isLoading = true;
      if (mounted) setState(() {});

      await ShippingProcessAuthService().getAllPackageDetail().then(
        (value) {
          shippingProcessBloc.packagesList = value;
          shippingProcessBloc.isPaymentSuccessfully(false);
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
    userBloc = Provider.of<UserBloc>(context);
    shippingProcessBloc = Provider.of<ShippingProcessBloc>(context);
    return ColorfulSafeArea(
      bottom: Platform.isIOS ? true : false,
      top: false,
      color: white,
      child: WillPopScope(
        onWillPop: () async {
          if (shippingProcessBloc.isPaymentSuccessful) {
            shippingProcessBloc.clearBuyNowData();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pop();
          }
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
          if (shippingProcessBloc.isPaymentSuccessful) {
            shippingProcessBloc.clearBuyNowData();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      elevation: 0,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: CircularLoadingIndicator(),
      );
    }

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
                        return PackageDetailTile(
                            packageDetailsModel:
                                shippingProcessBloc.packagesList[index],
                            index: index);
                      },
                    ),
                    SizedBox(height: 10.0),
                    if (shippingProcessBloc.isAllShippingProcessCompleted() ==
                            true &&
                        shippingProcessBloc.isPaymentSuccessful == false)
                      _buildOrderSummary(),
                  ],
                ),
              ),
            ),
          ),
          shippingProcessBloc.isPaymentSuccessful == true
              ? _buildDoneButton()
              : _buildPayButton(),
        ],
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

  Widget _buildPayButton() {
    if (shippingProcessBloc.isAllShippingProcessCompleted() == false) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CurvedButton(
        onPressed: () {
          BottomSheetPassCode(
              context: context,
              isValidCallback: () async {
                // await checkAccountBalance();

                // Create the orders
                await placeOrder();
              },
              cancelCallBack: () {
                Navigator.pop(context);
              });
        },
        backgroundColor: navyBlue,
        textColor: white,
        text: 'Pay ₦${moneyDisplayNormalizer(getTotalOrder())}',
        isLoading: isOrderLoading,
      ),
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CurvedButton(
        onPressed: () {
          shippingProcessBloc.clearBuyNowData();
          Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
          Navigator.of(context).pushNamed(Routes.SUCCESSFUL_ORDER);
        },
        backgroundColor: navyBlue,
        textColor: white,
        text: 'Done',
      ),
    );
  }

  Future<void> placeOrder() async {
    if (!isOrderLoading) {
      isOrderLoading = true;
      if (mounted) setState(() {});
      await ShippingProcessAuthService()
          .placeOrder(
              data: shippingProcessBloc.toPlaceOrder(userBloc.user.userName),
              isCartProcess: shippingProcessBloc.isUseCart)
          .then(
        (value) async {
          if (value != null) {
            // Send the list of of orders for payment processing
            for (int i = 0; i < value.length; i++) {
              orders.add(value[i]["id"]);
            }
            var response = await PaymentAndBankingAuth()
                .makePaymentForCartOrder({"orders": orders});

            if (response.statusCode == 200) {
              shippingProcessBloc.isPaymentSuccessfully(true);
            } else if (response.statusCode == 500) {
              showToast(message: AppLocalization.of(context)!.serverError);
            } else {
              debugPrint(
                "MakePaymentForCartOrder Unsuccessful",
              );
            }
          } else {
            shippingProcessBloc.isPaymentSuccessfully(false);
            showToast(message: 'Error');
            debugPrint(
              "Could Not Place The Order",
            );
          }
          isOrderLoading = false;
          if (mounted) setState(() {});
        },
      ).catchError((error) {
        isOrderLoading = false;
        if (mounted) setState(() {});
        debugPrint(error.toString());
        showToast(message: error.toString());
      });
    }
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
          "₦${moneyDisplayNormalizer(shippingProcessBloc.getTotalItemCost())}",
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
          "₦${moneyDisplayNormalizer(shippingProcessBloc.getTotalShipping())}",
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
          "₦${moneyDisplayNormalizer(getTotalOrder())}",
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

  int? getTotalOrder() {
    int? totalItemCost = shippingProcessBloc.getTotalItemCost();
    int? totalShipping = shippingProcessBloc.getTotalShipping();
    return (totalItemCost ?? 0) + (totalShipping ?? 0);
  }
}
