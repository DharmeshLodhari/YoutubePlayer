//TODO: ADD APP LOCALIZATION
import 'package:Slydo/data/currency.dart';
import 'package:Slydo/data/state_notifier.dart';
import 'package:Slydo/models/store.dart';
import 'package:Slydo/screens/tiles/shopping_cart_tile.dart';
import 'package:Slydo/services/auth.dart';
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
          automaticallyImplyLeading: true,
          backgroundColor: darkBlue(),
          title: Text("Shopping Basket"),
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
                addNoteDialog();
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
        ShoppingCartTile(
          product: basketBloc.items[index],
        ),
        basketBloc.items[index],
        index);
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
      BuildContext context, Widget productTile, Product product, int index) {
    return Slidable(
      controller: slidableController,
      direction: Axis.horizontal,
      actionPane: SlidableBehindActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(productTile, product),
      actions: listActionSlideActions(index),
      secondaryActions: listSecondaryActions(index),
    );
  }

  List<Widget> listSecondaryActions(int index) {
    String caption = "Remove";
    return [
      IconSlideAction(
          caption: caption,
          color: Colors.red,
          icon: Icons.remove_shopping_cart,
          onTap: () async {
            removeItem(index);
          }),
    ];
  }

  void removeItem(int index) async {
    Map data = {
      "type": "product",
      "id": basketBloc.items[index].id,
    };
    await _auth.removeItemToShoppingCart(data);
    basketBloc.removeItemFromCart(basketBloc.items[index]);
    Toast.show("Product is Removed Successfully from the cart", context,
        backgroundColor: darkBlue(),
        textColor: Colors.white,
        duration: Toast.LENGTH_LONG);
  }

  List<Widget> listActionSlideActions(int index) {
    var product = basketBloc.items[index];

    bool isValid = true;
    if (product.seller == userBloc.user.userName) {
      isValid = false;
    }
    return [
      IconSlideAction(
        caption: "Buy",
        color: isValid ? Colors.green : Colors.grey[600],
        icon: Icons.send,
        onTap: isValid
            ? () {
                navigateToSendPayment(product, index);
              }
            : () {},
      ),
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

  void handleSlideIsOpenChanged(bool isOpen) {}

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
    var note = "";
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
            'ADD Note',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: darkBlue()),
          ),
          content: Container(
            child: TextFormField(
              cursorColor: darkBlue(),
              decoration: InputDecoration(
                  hintText: "Enter your note here..",
                  isDense: true,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: darkBlue())),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: darkBlue()))),
              onChanged: (val) {
                note = val;
              },
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
                'NEXT',
                style: TextStyle(color: darkBlue()),
              ),
              onPressed: () {
                Navigator.pop(context, note);
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
          var userOrder = await _auth.placeOrderOfShoppingCart(data);
          if (!userOrder[0].containsKey('error')) {
            basketBloc.items.clear(); // Shopping cart
            var successful = await _auth.makePaymentForCartOrder(userOrder);
            if (successful) {
              Navigator.pushNamed(context, '/orders-list');
            } else {
              Navigator.pop(context);
            }
          }
        }
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('You selected: $value'),
        ));
      }
    });
  }
}

// ignore: must_be_immutable
class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.child, this.product);
  final Widget child;
  Product product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/product",
            arguments: {"product": product});
      },
      child: Container(
        color: lightBlue(),
        child: child,
      ),
    );
  }
}
