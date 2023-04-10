import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/routes/route_constants.dart';
import 'package:Slydo/screens/more_apps/shopping/models/store.dart';
import 'package:Slydo/screens/more_apps/shopping/screens/checkout_screen.dart';
import 'package:Slydo/screens/more_apps/shopping/tiles/shopping_cart_tile.dart';
import 'package:Slydo/utils/navigation_util.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
import 'package:Slydo/utils/util.dart';
import 'package:Slydo/widget/LoadingIndicator.dart';
import 'package:Slydo/widget/customized_passcode_sheet/bottomsheet_passcode.dart';
import 'package:Slydo/widget/noItemInList.dart';
import 'package:Slydo/widget/rounded_background_icon.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../locator.dart';
import '../../../../services/app_config_bloc.dart';
import '../../payment_and_banking/payment_and_banking_auth.dart';
import '../../user_profile/user_auth.dart';
import '../shopping_auth.dart';

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  late BasketBloc basketBloc;
  late CustomerProfileBloc customerProfileBloc;
  late UserBloc userBloc;
  List<int?> orders = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = PaymentAndBankingAuth();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    //check network connectivity and if true then refresh the list
    Connectivity().checkConnectivity().then((value) {
      var connectionResult = value;
      if (connectionResult == ConnectivityResult.wifi ||
          connectionResult == ConnectivityResult.mobile) {
        //clear old items
        basketBloc.items.clear();
        basketBloc.total = 0;
        //fetch items again
        initializeShoppingCart();
        _refreshController.refreshCompleted();
      } else {
        showToast(
            message:
                AppLocalization.of(context)!.internetConnectionNotAvailable);
        _refreshController.refreshCompleted();
      }
    });
  }

  void initializeShoppingCart() async {
    debugPrint("initializeShoppingCart called");
    basketBloc.resetShoppingCart();
  }

  AppConfigurationModel? appConfigurationModel;

  @override
  void initState() {
    super.initState();
    appConfigurationModel = getIt<AppConfigurationBloc>().appConfigurationModel;
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: appBar() as PreferredSizeWidget?,
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(
          complete: Container(),
          waterDropColor: navyBlue,
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: _buildBodyOfCart(),
      ),
      floatingActionButton:
          basketBloc.total == 0 ? Container() : checkoutWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget appBar() {
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
        AppLocalization.of(context)!.basket,
        style: TextStyle(
            color: blackFont, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      actions: <Widget>[
        scanQRCodeBtn(),
        SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget scanQRCodeBtn() {
    return RoundedBackgroundIcon(
      height: 34,
      width: 34,
      icon: Icon(
        SlydoAppIcon.qr_code,
        size: 16,
        color: blackFont,
      ),
      onTap: () {
        Navigator.of(context)
            .pushNamed(Routes.SCAN_QR, arguments: {'isRequest': false});
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget _buildBodyOfCart() {
    return basketBloc.total == 0
        ? Center(
            child: NoItemInList(
                msg: AppLocalization.of(context)!.shoppingCartIsEmpty),
          )
        : ListView.builder(
            itemCount: basketBloc.items.length,
            itemBuilder: (BuildContext context, int index) =>
                getItemTile(index));
  }

  Widget checkoutWidget() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 16),
      shadowColor: boxShadowTwo,
      elevation: 4,
      child: Container(
        decoration: decorateBox(),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  AppLocalization.of(context)!.total + " : ",
                  style: TextStyle(fontSize: 14, color: blackFont),
                ),
                Text(
                  worldCurrencies[userBloc.user.currency!]!,
                  style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  moneyDisplayNormalizer(
                      int.parse(basketBloc.total.toString())),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Expanded(
              child: SizedBox(
                width: 10,
              ),
            ),
            Expanded(
              child: MaterialButton(
                height: 40,
                color: navyBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  "Checkout",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
                onPressed: () {
                  if (appConfigurationModel?.enableCheckout == true) {
                    NavigationUtil.push(
                      context,
                      screen: CheckoutScreen(),
                    );
                  } else {
                    showToast(message: 'Checkout not available now');
                  }

                  // if (basketBloc.items.length != 0) {
                  //   addNoteDialog();
                  // } else {
                  //   showToast(
                  //       message: AppLocalization.of(context)!
                  //           .pleaseAddSomeItemsFirst);
                  // }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getItemTile(int index) {
    return getItemTileUI(index);
  }

  Widget getItemTileUI(int index) {
    basketBloc = Provider.of<BasketBloc>(context);

    if (index < basketBloc.items.length) {
      if (basketBloc.items[index]["item"] is Product) {
        return ShoppingCartTileForProduct(
          basketBloc.items[index],
          index: index,
          onDecreaseQty: () {
            removeItem(index);
          },
          onIncreaseQty: () {
            addItem(index);
          },
        );
      }
      return ShoppingCartTileForService(
        basketBloc.items[index],
        index: index,
        onDecreaseQty: () {
          removeItem(index);
        },
        onIncreaseQty: () {
          addItem(index);
        },
      );
    } else {
      return Container();
    }
  }

  Widget addItemToBasket() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed(Routes.SCAN_QR, arguments: {'isRequest': false});
        },
        child: Image.asset(
          'assets/images/qr_code.png',
          height: 24.0,
          width: 24.0,
          color: Colors.white,
        ),
      ),
    );
  }

  void addItem(int index) async {
    String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";
    basketBloc.addItemToCart(item: basketBloc.items[index]["item"], type: type);
    late var mapData;
    basketBloc.items.forEach((element) {
      if (element["item"].id == basketBloc.items[index]["item"].id) {
        mapData = element;
        return;
      }
    });
    Map data = {
      "type": type,
      "id": mapData["item"].id,
      "qty": mapData["qty"],
    };
    debugPrint("Data From increasing the  item : $data");
    await ShoppingAuthService().addItemToShoppingCart(data);
  }

  void removeItem(int index) async {
    String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";

    late var mapData;
    basketBloc.items.forEach((element) {
      if (element["item"].id == basketBloc.items[index]["item"].id) {
        mapData = element;
        return;
      }
    });
    Map data = {
      "type": type,
      "id": mapData["item"].id,
      "qty": mapData["qty"] - 1,
    };

    debugPrint("Data send From Remove Button : $data");
    basketBloc.removeItemFromCart(basketBloc.items[index]["item"]);
    await ShoppingAuthService().removeItemFromShoppingCart(data);
  }

  List<Widget> listActionSlideActions(int index) {
    String caption1 = AppLocalization.of(context)!.remove;

    return [
      IconSlideAction(
          caption: caption1,
          color: Colors.red,
          icon: Icons.remove,
          onTap: () {
            removeItem(index);
          }),
    ];
  }

  void navigateToSendPayment(Product product, int index) async {
    customerProfileBloc.customer =
        await UserAuth().fetchCustomerProfile(product.seller);
    Navigator.of(context).pushNamed(
      Routes.SEND_PAYMENT,
      arguments: {
        'isFromProfile': false,
        'product': product,
        'itemIndex': index
      },
    );
  }

  Product getProduct(String productId) {
    Product product = Product();
    product.id = productId;
    product.name = "";
    product.shortDescription = "";
    product.description = "";
    product.condition = "";
    product.currency = userBloc.user.currency;
    product.price = "0";
    product.availableFrom = DateTime.now();
    product.isAvailable = false;
    product.qrCode = "";
    product.seller = "";
    product.manufacturer = "";
    product.serverImages = [];
    return product;
  }

  addNoteDialog() {
    showMaterialDialog<String>(
      context: context,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, 'cancel');
          return false;
        },
        child: AlertDialog(
          titlePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(
            AppLocalization.of(context)!.confirmation,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: blackFont),
          ),
          content: Container(
            child: Text(
              AppLocalization.of(context)!.areYouSureWantToPlaceThisOrderFor +
                  '(${worldCurrencies[userBloc.user.currency!]} ${moneyDisplayNormalizer(basketBloc.total)})?',
              style: TextStyle(
                fontSize: 16,
                color: blackFont,
                fontFamily: "Roboto",
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalization.of(context)!.cancel,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context, 'cancel');
              },
            ),
            TextButton(
              child: Text(
                AppLocalization.of(context)!.place,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context, 'place');
              },
            ),
          ],
        ),
      ),
    );
  }

  void showMaterialDialog<T>({required BuildContext context, Widget? child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child!,
    ).then<void>((T? value) async {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        var data = {"note": value};
        if (value != "cancel") {
          BottomSheetPassCode(
              context: context,
              isValidCallback: () async {
                showDialog(
                  context: context,
                  builder: (context) => Center(
                    child: CircularLoadingIndicator(),
                  ),
                );

                await checkAccountBalance();

                // Create the orders
                var userOrder =
                    await ShoppingAuthService().placeOrderOfShoppingCart(data);

                if (userOrder != null) {
                  basketBloc.items.clear(); // Shopping cart
                  basketBloc.total = 0; // clearing the total amount

                  // Send the list of of orders for payment processing
                  for (int i = 0; i < userOrder.length; i++) {
                    orders.add(userOrder[i]["id"]);
                  }
                  var response =
                      await _auth.makePaymentForCartOrder({"orders": orders});
                  Navigator.popUntil(
                      context, ModalRoute.withName(Routes.DASHBOARD));
                  if (response.statusCode == 200) {
                    Navigator.pushNamed(context, Routes.ORDERS_LIST);
                  } else if (response.statusCode == 500) {
                    showToast(
                        message: AppLocalization.of(context)!.serverError);
                  }

                  // else if (response.statusCode == 800) {
                  //   Navigator.pop(context);
                  //   Navigator.pushNamed(
                  //     context,
                  //     "/add-document",
                  //   );
                  // }
                  else {
                    debugPrint(
                      "MakePaymentForCartOrder Unsuccessful",
                    );
                  }
                } else {
                  debugPrint(
                    "Could Not Place The Order",
                  );
                }
              },
              cancelCallBack: () {
                Navigator.pop(context);
              });
        }
      }
    });
  }

  Future<void> checkAccountBalance() async {
    BankAccountBloc bankAccountBloc =
        Provider.of<BankAccountBloc>(context, listen: false);
    if (bankAccountBloc.bankAccount == null ||
        bankAccountBloc.bankAccount!.bankName == null) {
      Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
      showToast(message: "Please add bank account first !!");
    } else {
      double accountBalance = await getAccountBalance();
      Navigator.popUntil(context, ModalRoute.withName(Routes.DASHBOARD));
      debugPrint("accountBalance:- $accountBalance");
      double spendingAmount = basketBloc.total / 100;
      debugPrint("spendingAmount:- $spendingAmount");
      if (spendingAmount > accountBalance) {
        showToast(message: "You don't have enough money in Slydo account!!");
        return;
      }
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

// ignore: must_be_immutable
class VerticalListItem extends StatelessWidget {
  Widget? child;
  var item;
  String? type;

  VerticalListItem(Widget child, var item) {
    this.child = child;
    this.type = item["type"];
    this.item = item["item"];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (type == "product") {
          Product? product = item;
          Navigator.pushNamed(context, Routes.PRODUCT,
              arguments: {"product": product});
        }
        if (type == "service") {
          Service? service = item;
          Navigator.pushNamed(context, Routes.SERVICE_DETAIL,
              arguments: {"service": service});
        }
      },
      child: child,
    );
  }
}
