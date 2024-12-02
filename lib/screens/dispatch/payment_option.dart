import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/dispatch/payment_confirmation_screen.dart';
import 'package:Slydo/screens/more_apps/payment_loading_screen.dart';
import 'package:Slydo/utils/colors.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';

class PaymentOption extends StatefulWidget {
  const PaymentOption({super.key});

  @override
  State<PaymentOption> createState() => _PaymentOptionState();
}

class _PaymentOptionState extends State<PaymentOption> {
  double _initialSheetChildSize = 0.25;

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      child: Scaffold(
        backgroundColor: white,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar() as PreferredSizeWidget?,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 16,
      title: Text(
        'Dispatch',
        style: TextStyle(
          fontSize: 16,
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
    return Stack(
      children: [
        // MapUI(),
        Image.asset(
          "assets/images/map.png",
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
        Padding(
          padding: const EdgeInsets.all(50.0),
          child: Image.asset(
            "assets/images/taxi/route_map_image.png",
            fit: BoxFit.fill,
          ),
        ),
        _buildPaymentBottomSheet(),
      ],
    );
  }

  Widget _buildPaymentBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: _initialSheetChildSize,
      maxChildSize: _initialSheetChildSize,
      minChildSize: _initialSheetChildSize,
      builder: (context, scrollController) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: white,
          child: _buildPackageReview(),
        ),
      ),
    );
  }

  Widget _buildPackageReview() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
      child: Column(
        children: [
          Container(
            height: 2,
            width: 12.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: greyBorderColor,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPaymentDetails(),
                const SizedBox(height: 30),
                _buildReadyForThePaymentButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        "You are about to make a payment of ₦1000 for this delivery ",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: black,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          fontFamily: "Inter",
        ),
      ),
    );
  }

  Widget _buildReadyForThePaymentButton() {
    return CurvedButton(
      onPressed: () {
        BottomSheetPassCode(
            context: context,
            isValidCallback: () async {
              // Create the orders
              await placeOrder(100);
            },
            cancelCallBack: () {
              Navigator.pop(context);
            });
      },
      textColor: Colors.white,
      backgroundColor: navyBlue,
      text: "Proceed",
    );
  }

  Future<void> placeOrder(int? totalAmount) async {
    /*Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const PaymentLoadingScreen(
            text: 'Payment Processing......',
            imagePath: 'assets/images/app_logo.png',
          )),
    );

    await Future.delayed(Duration(seconds: 5),);*/
    Navigator.of(context).pushNamed(Routes.PAYMENT_CONFIRMATION);
    // if (!isOrderLoading) {
    //   isOrderLoading = true;
    //   if (mounted) setState(() {});
    //   await ShippingProcessAuthService()
    //       .placeOrder(
    //     data: shippingProcessBloc.toPlaceOrder(userBloc.user.userName,
    //         totalAmount: totalAmount),
    //     isCartProcess: shippingProcessBloc.isUseCart,
    //     isSharedCart: false,
    //     sharedCartId: '',
    //   )
    //       .then(
    //     (value) async {
    //       if (value == "cart is empty") {
    //         Navigator.popAndPushNamed(context, Routes.SHOPPING_CART);
    //       }
    //       if (value != null) {
    //         // Send the list of of orders for payment processing
    //         for (int i = 0; i < value.length; i++) {
    //           orders.add(value[i]["id"]);
    //         }
    //         final response = await PaymentAndBankingAuth()
    //             .makePaymentForCartOrder({"orders": orders});
    //
    //         if (response.statusCode == 200 || response.statusCode == 201) {
    //           shippingProcessBloc.isPaymentSuccessfully(true);
    //           showToast(
    //               message: AppLocalization.of(context)!.sendPaymentSuccess);
    //         } else if (response.statusCode == 500) {
    //           showToast(message: AppLocalization.of(context)!.serverError);
    //         } else {
    //           showToast(message: "Payment Not Successful");
    //           // debugPrint(
    //           //   "MakePaymentForCartOrder Unsuccessful",
    //           // );
    //         }
    //       } else {
    //         shippingProcessBloc.isPaymentSuccessfully(false);
    //         showToast(message: 'Error');
    //         // debugPrint(
    //         //   "Could Not Place The Order",
    //         // );
    //       }
    //       isOrderLoading = false;
    //       if (mounted) setState(() {});
    //     },
    //   ).catchError((error) {
    //     isOrderLoading = false;
    //     if (mounted) setState(() {});
    //     debugPrint(error.toString());
    //     showToast(message: error.toString());
    //   });
    // }
  }
}
