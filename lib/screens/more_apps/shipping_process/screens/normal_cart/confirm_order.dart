import 'dart:io';

import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/payment_and_banking/payment_and_banking_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/auth/shipping_process_auth.dart';
import 'package:Slydo/screens/more_apps/shipping_process/tiles/package_detail_tile.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/loading_indicator.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class ConfirmOrder extends StatefulWidget {
  ConfirmOrder({this.arguments, Key? key}) : super(key: key);

  final dynamic arguments;

  @override
  State<ConfirmOrder> createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  final ScrollController _confirmOrderScrollController = ScrollController();

  late BasketBloc basketBloc;
  late UserBloc userBloc;
  bool isLoading = false;
  bool isOrderLoading = false;
  bool isSelected = false;
  List<int?> orders = [];
  String sharedCartId = '';
  bool isSharedCart = false;

  late ShippingProcessBloc shippingProcessBloc;

  @override
  void initState() {
    super.initState();
    sharedCartId = widget.arguments['sharedCartId'];
    isSharedCart = widget.arguments['isSharedCart'];
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

      await ShippingProcessAuthService()
          .getAllPackageDetail(isSharedCart, sharedCartId)
          .then(
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
          backgroundColor: lightGrey,
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
                padding: const EdgeInsets.all(10.0),
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
                    const SizedBox(height: 10.0),
                    if (shippingProcessBloc.isAllShippingProcessCompleted() ==
                            true &&
                        shippingProcessBloc.isPaymentSuccessful == false)
                      _buildOrderSummary(),
                  ],
                ),
              ),
            ),
          ),
          if (shippingProcessBloc.isPaymentSuccessful == true)
            _buildDoneButton()
          else
            _buildPayButton(),
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
              const SizedBox(
                height: 15.0,
              ),
              _buildTotalItemCost(),
              const SizedBox(
                height: 10,
              ),
              _buildTotalShipping(),
              const SizedBox(
                height: 10,
              ),
              _buildServiceCharge(),
              const SizedBox(
                height: 10,
              ),
              _buildInsurance(),
              const SizedBox(
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
          isSharedCart == true
              ? Navigator.of(context).pushNamed(Routes.SHARED_CART_PAYMENT)
              : BottomSheetPassCode(
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
        text:
            'Pay ${worldCurrencies[userBloc.user.currency]}${moneyDisplayNormalizer(shippingProcessBloc.getTotalOrder())}',
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
              isCartProcess: shippingProcessBloc.isUseCart,
              isSharedCart: false,
              sharedCartId: '')
          .then(
        (value) async {
          if (value != null) {
            // Send the list of of orders for payment processing
            for (int i = 0; i < value.length; i++) {
              orders.add(value[i]["id"]);
            }
            final response = await PaymentAndBankingAuth()
                .makePaymentForCartOrder({"orders": orders});

            if (response.statusCode == 200 || response.statusCode == 201) {
              shippingProcessBloc.isPaymentSuccessfully(true);
              showToast(
                  message: AppLocalization.of(context)!.sendPaymentSuccess);
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
        Row(
          children: [
            Text(
              "${worldCurrencies[userBloc.user.currency]}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: darkGrey,
                fontFamily: "Inter",
              ),
            ),
            Text(
              moneyDisplayNormalizer(shippingProcessBloc.getTotalItemCost()),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: darkGrey,
                fontFamily: "Inter",
              ),
            ),
          ],
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
        Row(
          children: [
            Text(
              "${worldCurrencies[userBloc.user.currency]}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: darkGrey,
                fontFamily: "Inter",
              ),
            ),
            Text(
              moneyDisplayNormalizer(shippingProcessBloc.getTotalShipping()),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: darkGrey,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceCharge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              "Service Charge ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: darkGrey,
                fontFamily: "Inter",
              ),
            ),
            SvgPicture.asset(
              'assets/images/info_circle.svg',
              height: 16,
              width: 16,
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "${worldCurrencies[userBloc.user.currency]}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: darkGrey,
                fontFamily: "Inter",
              ),
            ),
            Text(
              moneyDisplayNormalizer(shippingProcessBloc
                      .getPackageDetailModel()
                      .customerServiceFee ??
                  0),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: darkGrey,
                fontFamily: "Inter",
              ),
            ),
          ],
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
        Row(
          children: [
            Text(
              "${worldCurrencies[userBloc.user.currency]}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: darkGrey,
                fontFamily: "Inter",
              ),
            ),
            Text(
              "0.00",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: darkGrey,
                fontFamily: "Inter",
              ),
            ),
          ],
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
        Row(
          children: [
            Text(
              "${worldCurrencies[userBloc.user.currency]}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: black,
                fontFamily: "Inter",
              ),
            ),
            Text(
              moneyDisplayNormalizer(shippingProcessBloc.getTotalOrder()),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: black,
                fontFamily: "Inter",
              ),
            ),
          ],
        ),
      ],
    );
  }
}
