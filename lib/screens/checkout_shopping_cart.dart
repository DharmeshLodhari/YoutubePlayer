//TODO: ADD APP LOCALIZATION
import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/screens/tiles/shopping_cart_tile.dart';
import 'package:Slydo/services/auth.dart';
import 'package:Slydo/widget/passcodePopup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'colors.dart';

class ShoppingCart extends StatefulWidget {
  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  BasketBloc basketBloc;
  CustomerProfileBloc customerProfileBloc;
  SlidableController slidableController;
  UserBloc userBloc;
  List<int> orders = List<int>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _auth = AuthService();

  @override
  void initState() {
    slidableController = SlidableController(
      onSlideAnimationChanged: handleSlideAnimationChanged,
      onSlideIsOpenChanged: handleSlideIsOpenChanged,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    basketBloc = Provider.of<BasketBloc>(context);
    customerProfileBloc = Provider.of<CustomerProfileBloc>(context);
    userBloc = Provider.of<UserBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/dashboard',
            arguments: {"dashboardIndex": 5});
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: lightBlue(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: darkBlue(),
          title: Text("Basket"),
          actions: <Widget>[
            search(),
            addItemToBasket(),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: basketBloc.items.length,
                  itemBuilder: (BuildContext context, int index) =>
                      getItemTile(index)),
            ),
            checkoutWidget(),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  Widget search() {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        Navigator.pushNamed(context, "/dashboard",
            arguments: {"dashboardIndex": 3});
      },
    );
  }

  Widget checkoutWidget() {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                    "Total : " + worldCurrencies[userBloc.user.currency] + " "),
                Text(
                  basketBloc.total.toString(),
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            MaterialButton(
              color: darkBlue(),
              child: Text(
                "Buy",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (basketBloc.items.length != 0) {
                  addNoteDialog();
                } else {
                  Toast.show("Please Add Some Items First !!", context,
                      textColor: Colors.white,
                      backgroundColor: darkBlue(),
                      duration: Toast.LENGTH_LONG,
                      gravity: Toast.CENTER);
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget getItemTile(int index) {
    return _getSlidableWithLists(
      context,
      getItemTileUI(index),
      basketBloc.items[index],
      index,
    );
  }

  Widget getItemTileUI(int index) {
    if (basketBloc.items[index]["item"] is Product) {
      return ShoppingCartTileForProduct(
        basketBloc.items[index],
      );
    }
    return ShoppingCartTileForService(
      basketBloc.items[index],
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

  Widget _getSlidableWithLists(
      BuildContext context, Widget itemTile, var item, int index) {
    return Slidable(
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(itemTile, item),
      actions: listActionSlideActions(index),
      secondaryActions: listSecondaryActions(index),
    );
  }

  List<Widget> listSecondaryActions(int index) {
    String caption2 = "Add";
    return [
      IconSlideAction(
          caption: caption2,
          color: Colors.green,
          icon: Icons.add,
          onTap: () {
            addItem(index);
          }),
    ];
  }

  void addItem(int index) async {
    int qty = 1;


    basketBloc.items.forEach((element) {
      if (element["item"].id == basketBloc.items[index]["item"].id) {
        qty = element["qty"] + qty;
      }
    });

    debugPrint("qty:$qty");
    String type = basketBloc.items[index]["item"] is Service? "service":"product";
    basketBloc.items[index]["type"] = type;
    Map data = {
      "type": type,
      "id": basketBloc.items[index]["item"].id,
      "qty": qty,
    };

    basketBloc.addItemToCart(item: basketBloc.items[index]["item"], type: basketBloc.items[index]["type"]);
    await _auth.addItemToShoppingCart(data);
    debugPrint("after qty:");

  }

  void removeItem(int index) async {
    Map data = {
      "type": basketBloc.items[index]["type"],
      "id": basketBloc.items[index]["item"].id,
    };
    basketBloc.removeItemFromCart(basketBloc.items[index]["item"]);
    await _auth.removeItemToShoppingCart(data);
  }

  List<Widget> listActionSlideActions(int index) {
    String caption1 = "Remove";

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

  void handleSlideAnimationChanged(Animation<double> slideAnimation) {}

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {});
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
          title: Text(
            "Confirmation",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: darkBlue()),
          ),
          content: Container(
            child: Text(
              'Are you Sure You Want To Place This Order For (${worldCurrencies[userBloc.user.currency]} ${basketBloc.total})?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'CANCEL',
                style: TextStyle(color: darkBlue()),
              ),
              onPressed: () {
                Navigator.pop(context, 'cancel');
              },
            ),
            FlatButton(
              child: Text(
                'PLACE',
                style: TextStyle(color: darkBlue()),
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
          PasscodePopup(
              context: context,
              isValidCallback: () async {
                showDialog(
                  context: context,
                  builder: (context) => Center(
                    child: CircularProgressIndicator(),
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
                  var successful =
                      await _auth.makePaymentForCartOrder({"orders": orders});
                  if (successful) {
                    Navigator.popAndPushNamed(context, '/orders-list');
                  } else {
                    debugPrint("MakePaymentForCartOrder UnSuccesfull");
                  }
                } else {
                  debugPrint("Could Not Place The Order");
                }
              },
              cancelCallBack: () {
                Navigator.pop(context);
              });
        }
      }
    });
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
          Navigator.pushNamed(context, "/service",
              arguments: {"service": service});
        }
      },
      child: Container(
        color: lightBlue(),
        child: child,
      ),
    );
  }
}
