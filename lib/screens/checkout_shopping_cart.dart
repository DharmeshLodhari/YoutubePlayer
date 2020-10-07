import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/locale/app_localization.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/screens/tiles/shopping_cart_tile.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/utils/slydo_app_icon_icons.dart';
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
import 'package:toast/toast.dart';

import '../utils/colors.dart';

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  BasketBloc basketBloc;
  CustomerProfileBloc customerProfileBloc;
  UserBloc userBloc;
  List<int> orders = List<int>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = AuthService();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
  }

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
        Toast.show(
            AppLocalization.of(context).internetConnectionNotAvailable, context,
            gravity: Toast.BOTTOM, backgroundColor: darkBlue());
        _refreshController.refreshCompleted();
      }
    });
  }

  void initializeShoppingCart() async {
    debugPrint("initializeShoppingCart called");
    List items = await _auth.getShoppingCart();
    items.forEach((element) {
      String type = element is Product ? "product" : "service";
      basketBloc.addItemToCart(item: element, type: type);
    });
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: appBar(),
      body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(
            complete: Container(),
            waterDropColor: navyBlue,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: _buildBodyOfCart()),
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
      title: Text(
        AppLocalization.of(context).basket,
        style: TextStyle(
            color: blackFont, fontSize: 22, fontWeight: FontWeight.w700),
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
            .pushNamed('/scan-qr', arguments: {'isRequest': false});
      },
      backgroundColor: iconBtnGrey,
      enableMargin: true,
    );
  }

  Widget _buildBodyOfCart() {
    return basketBloc.total == 0
        ? Center(
            child: NoItemInList(
                msg: AppLocalization.of(context).shoppingCartIsEmpty),
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
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: iconBtnGrey, width: 1)),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  AppLocalization.of(context).total + " : ",
                  style: TextStyle(fontSize: 14, color: blackFont),
                ),
                Text(
                  worldCurrencies[userBloc.user.currency],
                  style: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  basketBloc.total.toString(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Expanded(
                child: SizedBox(
              width: 10,
            )),
            Expanded(
              child: MaterialButton(
                height: 40,
                color: navyBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  "Pay",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
                onPressed: () {
                  if (basketBloc.items.length != 0) {
                    addNoteDialog();
                  } else {
                    Toast.show(
                        AppLocalization.of(context).pleaseAddSomeItemsFirst,
                        context,
                        textColor: Colors.white,
                        backgroundColor: darkBlue(),
                        duration: Toast.LENGTH_LONG,
                        gravity: Toast.CENTER);
                  }
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
  }

  Widget addItemToBasket() {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed('/scan-qr', arguments: {'isRequest': false});
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
    var mapData;
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
    await _auth.addItemToShoppingCart(data);
  }

  void removeItem(int index) async {
    String type =
        basketBloc.items[index]["item"] is Product ? "product" : "service";

    var mapData;
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
    await _auth.removeItemToShoppingCart(data);
  }

  List<Widget> listActionSlideActions(int index) {
    String caption1 = AppLocalization.of(context).remove;

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
        await _auth.fetchCustomerProfile(product.seller);
    Navigator.of(context).pushNamed(
      '/send-payment',
      arguments: {
        'isFromProfile': false,
        'isRequest': false,
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
            AppLocalization.of(context).confirmation,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: blackFont),
          ),
          content: Container(
            child: Text(
              AppLocalization.of(context).areYouSureWantToPlaceThisOrderFor +
                  '(${worldCurrencies[userBloc.user.currency]} ${basketBloc.total})?',
              style: TextStyle(
                fontSize: 16,
                color: blackFont,
                fontFamily: "Roboto",
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                AppLocalization.of(context).cancel,
                style: TextStyle(
                    color: blackFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context, 'cancel');
              },
            ),
            FlatButton(
              child: Text(
                AppLocalization.of(context).place,
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

  void showMaterialDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) async {
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

                // Create the orders
                var userOrder = await _auth.placeOrderOfShoppingCart(data);

                if (userOrder != null) {
                  basketBloc.items.clear(); // Shopping cart
                  basketBloc.total = 0; // clearing the total amount

                  // Send the list of of orders for payment processing
                  for (int i = 0; i < userOrder.length; i++) {
                    orders.add(userOrder[i]["id"]);
                  }
                  var response =
                      await _auth.makePaymentForCartOrder({"orders": orders});
                  if (response.statusCode == 200) {
                    Navigator.popAndPushNamed(
                      context,
                      '/orders-list',
                    );
                  } else if (response.statusCode == 500) {
                    Navigator.pop(context);
                    Toast.show(
                      AppLocalization.of(context).serverError,
                      context,
                      gravity: Toast.TOP,
                      backgroundColor: darkBlue(),
                      textColor: Colors.white,
                    );
                  } else if (response.statusCode == 700) {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      "/bvn-verification",
                    );
                  } else if (response.statusCode == 800) {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      "/add-document",
                    );
                  } else {
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

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

// ignore: must_be_immutable
class VerticalListItem extends StatelessWidget {
  Widget child;
  var item;
  String type;

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
          Product product = item;
          Navigator.pushNamed(context, "/product",
              arguments: {"product": product});
        }
        if (type == "service") {
          Service service = item;
          Navigator.pushNamed(context, "/service-detail",
              arguments: {"service": service});
        }
      },
      child: child,
    );
  }
}
