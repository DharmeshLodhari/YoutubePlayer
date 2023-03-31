import 'package:Slydo/screens/more_apps/shopping/shopping_auth.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/curved_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/currency.dart';
import '../../../../../data/state_notifier.dart';
import '../../../../../locale/app_localization.dart';
import '../../../../../routes/route_constants.dart';
import '../../../../../widget/LoadingIndicator.dart';
import '../../../payment_and_banking/payment_and_banking_auth.dart';
import '../../../user_profile/models/user.dart';
import '../order_summary_screen.dart';

class OrderSummaryProductService extends StatefulWidget {
  final ShippingAddress address;
  const OrderSummaryProductService({Key? key, required this.address})
      : super(key: key);

  @override
  State<OrderSummaryProductService> createState() =>
      _OrderSummaryProductServiceState();
}

class _OrderSummaryProductServiceState
    extends State<OrderSummaryProductService> {
  List<int?> orders = [];
  late BasketBloc basketBloc;
  PaymentAndBankingAuth _auth = PaymentAndBankingAuth();

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);

    return Scaffold(
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
                amount:
                    moneyDisplayNormalizer(basketBloc.orderTotalProductService),
              ),
              priceRow(
                  title: 'Total shipping cost',
                  amount: moneyDisplayNormalizer(basketBloc.totalShippingCost)),
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
    );
  }

  onCompleteOrder() async {
    showDialog(
        context: context,
        builder: (dialogLoadingContext) => LoadingIndicator());

    Map data = {'note': 'places'};
    data['address'] = widget.address.toJson();
    data['shipping_options'] = basketBloc.userSelectedShippingOption;

    List<OrderDataModel> orderDataModelList = [];

    Map<dynamic, dynamic> merchantNameMap = {};

    for (var item in basketBloc.productOrService) {
      // debugPrint('Fola product::: ${item}');
      merchantNameMap = item['results'];
      // merchantNameMap = item['results'].cast<String, String>();
    }

    merchantNameMap.values.forEach((merchantName) {
      // print('fola buy now $key: $value');
      // print('fola buy now $merchantName');

      OrderDataModel orderDataModel = OrderDataModel(
        merchantName: merchantName.toString(),
        address: widget.address.toJson(),
        shippingNote: widget.address.shippingNote,
        shippingOption: basketBloc.userSelectedShippingOption[merchantName],
      );

      orderDataModelList.add(orderDataModel);
    });

    debugPrint('ORDER DATA LIST ---> $orderDataModelList');
    orderDataModelList.forEach((element) {
      debugPrint('ORDER LIST ---> ${element.toJson()}');
    });

    bool ableToPay = await checkAccountBalance();

    //Create the orders
    if (ableToPay) {
      var userOrders =
          await ShoppingAuthService().placeOrderOfShoppingCart(data);

      debugPrint('');
      if (userOrders != null) {
        // basketBloc.items.clear(); // Shopping cart
        basketBloc.total = 0; // clearing the total amount

        // Send the list of of orders for payment processing
        for (int i = 0; i < userOrders.length; i++) {
          orders.add(userOrders[i]["id"]);
        }
        var response = await _auth.makePaymentForCartOrder({"orders": orders});

        debugPrint('STATUS CODE :: ${response.statusCode}');
        if (response.statusCode == 200) {
          basketBloc.productOrService.clear();
          Navigator.of(context).popUntil(ModalRoute.withName(Routes.DASHBOARD));
          Navigator.pushNamed(context, Routes.ORDERS_LIST);
          showToast(message: 'Order placed successfully');
        } else if (response.statusCode == 500) {
          showToast(message: AppLocalization.of(context)!.serverError);
        } else {
          debugPrint("MakePaymentForCartOrder Unsuccessful");
        }
      } else {
        debugPrint(
          "Could Not Place The Order",
        );
      }
    }
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
                    fontFamily: "Roboto",
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

  Future<bool> checkAccountBalance() async {
    BankAccountBloc bankAccountBloc =
        Provider.of<BankAccountBloc>(context, listen: false);

    if (bankAccountBloc.bankAccount == null ||
        bankAccountBloc.bankAccount!.bankName == null) {
      Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
      showToast(message: "Please add bank account first !!");
      return false;
    } else {
      double accountBalance = await getAccountBalance();
      // Navigator.popUntil(context, ModalRoute.withName("/dashboard"));
      debugPrint("accountBalance:- $accountBalance");
      double spendingAmount = basketBloc.total / 100;
      debugPrint("spendingAmount:- $spendingAmount");
      if (spendingAmount > accountBalance) {
        showToast(message: "You don't have enough money in Slydo account!!");
        return false;
      }
      return true;
    }
  }
}
