import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/currency.dart';
import '../../../../data/state_notifier.dart';
import '../../../../locale/app_localization.dart';
import '../../../../routes/route_constants.dart';
import '../../../../widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import '../../../../widget/loading_indicator.dart';
import '../../payment_and_banking/payment_and_banking_auth.dart';
import '../../user_profile/models/user.dart';
import '../utils.dart';

class OrderSummaryScreen extends StatefulWidget {
  final ShippingAddress address;
  const OrderSummaryScreen({Key? key, required this.address}) : super(key: key);

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  List<int?> orders = [];
  late BasketBloc basketBloc;
  PaymentAndBankingAuth _auth = PaymentAndBankingAuth();
  final _orderSummaryScaffoldMessenger = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);

    return ScaffoldMessenger(
      key: _orderSummaryScaffoldMessenger,
      child: Scaffold(
        appBar: appBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price',
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                priceRow(
                  title: 'Order total',
                  amount: moneyDisplayNormalizer(
                      basketBloc.total + basketBloc.totalShippingCost),
                ),
                priceRow(
                    title: 'Total shipping cost',
                    amount:
                        moneyDisplayNormalizer(basketBloc.totalShippingCost)),
                Divider(color: blackFont, thickness: 0.5),
                SizedBox(height: 5),
                Text(
                  'Shipping Address',
                  style: TextStyle(
                      color: blackFont,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10),
                widget.address.addressLineOne != null
                    ? addressRow(
                        title: 'Address line 1',
                        subTitle: widget.address.addressLineOne!)
                    : SizedBox.shrink(),
                widget.address.addressLineTwo != null
                    ? addressRow(
                        title: 'Address line 2',
                        subTitle: widget.address.addressLineTwo!)
                    : SizedBox.shrink(),
                widget.address.city != null
                    ? addressRow(title: 'City', subTitle: widget.address.city!)
                    : SizedBox.shrink(),
                widget.address.userState != null
                    ? addressRow(
                        title: 'State', subTitle: widget.address.stateName!)
                    : SizedBox.shrink(),
                Divider(color: blackFont, thickness: 0.5),
                SizedBox(height: 10),
                widget.address.shippingNote != ''
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shipping Note',
                            style: TextStyle(
                                color: blackFont,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 10),
                          Text(
                            widget.address.shippingNote!,
                            style: TextStyle(color: blackFont),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                SizedBox(height: 40),
                Builder(builder: (context) {
                  return CurvedButton(
                    isPaymentBtn: true,
                    text: 'Complete Order',
                    onPressed: onCompleteOrder,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  onCompleteOrder() async {
    BottomSheetPassCode(
        context: context,
        isValidCallback: () async {
          showDialog(
              context: context,
              builder: (dialogLoadingContext) => LoadingIndicator());

          Map data = {'note': widget.address.shippingNote};
          data['address'] = widget.address.toJson();
          data['shipping_options'] = basketBloc.userSelectedShippingOption;

          bool ableToPay = await checkAccountBalance(null, context);

          //Create the orders
          if (ableToPay) {
            var userOrders =
                await ShoppingAuthService().placeOrderOfShoppingCart(data);

            if (userOrders != null) {
              basketBloc.items.clear(); // Shopping cart
              basketBloc.total = 0; // clearing the total amount

              // Send the list of of orders for payment processing
              for (int i = 0; i < userOrders.length; i++) {
                orders.add(userOrders[i]["id"]);
              }
              var response =
                  await _auth.makePaymentForCartOrder({"orders": orders});

              debugPrint('STATUS CODE :: ${response.statusCode}');
              if (response.statusCode == 200 || response.statusCode == 201) {
                Navigator.of(context)
                    .popUntil(ModalRoute.withName(Routes.DASHBOARD));
                Navigator.pushNamed(context, Routes.ORDERS_LIST);
                showToast(message: 'Order placed successfully');
              } else if (response.statusCode == 500) {
                Navigator.pop(context);
                showToast(message: AppLocalization.of(context)?.serverError);
              } else {
                debugPrint("MakePaymentForCartOrder Unsuccessful");
                showToast(
                    message: AppLocalization.of(context)?.somethingWentWrong);
                Navigator.pop(context);
              }
            } else {
              debugPrint(
                "Could Not Place The Order",
              );
              showToast(
                  message: AppLocalization.of(context)?.couldNotPlaceTheOrder);
              Navigator.pop(context);
            }
          }
        },
        cancelCallBack: () {
          Navigator.pop(context);
          _orderSummaryScaffoldMessenger.currentState?.showSnackBar(SnackBar(
            content: Text(AppLocalization.of(context)!.invalidPassword),
          ));
        });
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      titleSpacing: 16,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.keyboard_arrow_left,
          color: navyBlue,
          size: 24,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Order Summary',
        style: TextStyle(
            color: blackFont, fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget priceRow(
      {required String title,
      required String amount,
      TextStyle? amountTextStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                worldCurrencies['NGN']!,
                style: TextStyle(
                    color: blackFont,
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
              Text(
                amount,
                style: amountTextStyle ??
                    TextStyle(
                      fontSize: 16,
                      color: blackFont,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget addressRow({required String title, required String subTitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
            ),
          ),
          Text(
            subTitle,
            style: TextStyle(
              fontSize: 16,
              color: blackFont,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Future<bool> checkAccountBalance() async {
  //   BankAccountBloc bankAccountBloc =
  //       Provider.of<BankAccountBloc>(context, listen: false);
  //
  //   if (bankAccountBloc.bankAccount == null ||
  //       bankAccountBloc.bankAccount!.bankName == null) {
  //     Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
  //     showToast(message: "Please add bank account first !!");
  //     return false;
  //   } else {
  //     double accountBalance = await getAccountBalance();
  //     // Navigator.popUntil(context, ModalRoute.withName("/dashboard"));
  //     debugPrint("accountBalance:- $accountBalance");
  //     double spendingAmount = basketBloc.total / 100;
  //     debugPrint("spendingAmount:- $spendingAmount");
  //     if (spendingAmount > accountBalance) {
  //       showToast(message: "You don't have enough money in Slydo account!!");
  //       return false;
  //     }
  //     return true;
  //   }
  // }
}

// {black: {address: {city: Lagos, state: Lagos, country: Nigeria, shipping_note: Just in note, address_line_1: No 2, Adebowale close, Akute, address_line_2: Omole estate, Berger, country_iso_code: NG}, shipping-option: null, note: Just in note}}
class OrderDataModel {
  String merchantName;
  Map<String, dynamic> address;
  int? shippingOption;
  String? shippingNote;

  OrderDataModel({
    required this.merchantName,
    required this.address,
    required this.shippingOption,
    required this.shippingNote,
  });

  Map<String, dynamic> toJson() {
    return {
      merchantName: {
        "address": address,
        "shipping-option": shippingOption,
        "note": shippingNote,
      }
    };
  }
}
